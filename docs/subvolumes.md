# Service state as btrfs subvolumes
## Layout

```
top level (subvolid=5)
├── @                       → /
│   └── var/lib/
│       ├── paperless/      ← subvolume
│       ├── private/mealie/ ← subvolume
│       └── .subvolumes/
│           ├── managed                     paths declared last run
│           ├── reset/<path>                last reset token
│           ├── archive/<path>/<timestamp>  read-only archives
│           └── displaced/                  converted plain dirs
├── @nix, @persist
└── @paperless, @mealie, …  ← old disko subvolumes, unused, untouched
```

`<path>` = `systemd-escape --path`, e.g. `var-lib-private-mealie`.

## Lifecycle

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Live: enable<br/>(archive → migrateFrom → empty)
    Live --> Archived: disable<br/>(rename + read-only)
    Archived --> Live: enable again<br/>(snapshot of newest archive)
    Live --> Live: reset changed<br/>(archive, then empty)
```

## Options

```nix
marci.subvolumes.enable = true;            # host
marci.subvolumes.paths."/var/lib/x" = {    # service module
  requiredBy  = [ "x.service" ];           # Requires= + After= on the subvolume unit
  migrateFrom = "@x";                      # used only if no subvolume and no archive
  reset       = null;                      # new value ⇒ start fresh once
  owner = "root"; group = "root"; mode = "0755";  # only for new empty subvolumes
};
```

Postgres, psql-export, tailscale and samba are declared automatically in the module when those services are enabled.

## Generated units

| Unit                         | Runs                     | Does                                                    |
| ---------------------------- | ------------------------ | ------------------------------------------------------- |
| `subvolumes-archive.service` | first                    | archives paths in `managed` that are no longer declared |
| `subvolume-<path>.service`   | after that, one per path | `subvolume ensure …` (flowchart below)                  |

Both are `oneshot`, `DefaultDependencies=no`, `After=local-fs.target`, `Before=sysinit.target`.
At boot they therefore run **before every normal service** and before tmpfiles.
`requiredBy` means a service won't start if its subvolume failed. Restarting the
subvolume unit (e.g. on a reset) restarts the service too.

### On deploy (`switch-to-configuration`)

```mermaid
sequenceDiagram
    participant c as switch
    participant y as disabled service
    participant a as subvolumes-archive
    participant s as subvolume-x
    participant x as enabled service
    c->>y: 1. stop removed units
    c->>a: 2. restart (path list changed) → archive /var/lib/y
    c->>s: 3. start → restore/migrate/create /var/lib/x
    s-->>x: Before=
    c->>x: 3. start
```

A disabled service is stopped **before** its data is archived. A new service starts **after** its data exists.

## `ensure` logic

```mermaid
flowchart TD
    A([/var/lib/x]) --> M{mount point?}
    M -- yes --> SKIP([leave alone])
    M -- no --> K{what's there?}
    K -- "empty dir tree" --> DEL[remove] --> N
    K -- "dir with files" --> CONV[reflink-copy into subvolume,<br/>original → displaced/] --> V
    K -- subvolume --> V{reset token new?}
    K -- nothing --> N
    V -- no --> OK([ok])
    V -- yes --> ARC[archive] --> N
    N{source?} -- "archive exists, no reset" --> R[snapshot newest archive]
    N -- "migrateFrom exists, no reset" --> MIG[snapshot @x from top level]
    N -- otherwise --> E[create empty, chown/chmod]
    R & MIG & E --> T[store token, run tmpfiles for path]
```

- **Archive** = `mv --no-copy` (atomic rename within `@`) + `btrfs property set ro true`.
- **Restore/migrate** = `btrfs subvolume snapshot` (instant CoW; the source is kept).
- **Subvolume check** = btrfs and inode `256`.
- **Top-level mount** for `migrateFrom` is private to the unit (`PrivateMounts=yes`).

## Reset token

`reset` is compared with `.subvolumes/reset/<path>`. A different, non-null value causes one reset, then the new value is stored.
Keeping the same value, or removing it, does nothing afterwards.

## btrbk

`modules/services/btrbk.nix` now creates every configured `snapshot_dir` via tmpfiles. btrbk used to abort because these directories were missing.
Archives are **local only**. btrbk does not back them up.

## Caveats

- Archives are never pruned automatically.
- If the script's store path changes (nixpkgs bump), the subvolume units restart, and their services restart once.
- Don't declare nested managed paths (`/a` and `/a/b`).
- Renaming a path in Nix = disable old + enable new (old data gets archived).
- Only for hosts with `/var/lib` on btrfs.
