# inspirion, November 2026

## Paperless crash loop (Nov 5)

- **Symptom:** loud fans. `paperless-scheduler` had restarted 27k times, using about 7 s of CPU each time.
- **Cause:** the database was still on 2.19.6. v3.3.4 can only migrate from 2.20.15.
- **Fix:** deployed once with a temporary pin to `stable.paperless-ngx` (2.20.15), then removed the pin. Backup at `/var/lib/paperless/db.sqlite3.pre-v3-20261105.bak`.

## Migration to managed subvolumes (Nov 6)

- Removed all `/var/lib/*` subvolumes from `hosts/inspirion/disks.nix`.
- Ran `colmena apply boot` and rebooted. Each path was snapshotted from its old `@name`, using a temporary `migrateFrom` option that has since been removed.
- Checked file counts before and after: identical apart from runtime churn (audiobookshelf logs, samba sockets).

| Path | From |
| --- | --- |
| `/var/lib/{paperless,immich,nextcloud,ocis,audiobookshelf,postgresql,psql-export,samba,tailscale}` | `@<name>` |
| `/var/lib/private/{mealie,AdGuardHome,actual,newt}` | `@<name>` |
| `/var/lib/syncthing/{obsidian,phone,secrets,signal,wallpapers,whatsapp}` | `@<name>` |
| `/var/lib/syncthing/nix` | `@syncthing-nix` |

`@opencloud` is not migrated (service disabled).

## Open issues

1. `btrbk.nix`: `mkIf (attrNames cfg.settings == [])` is inverted. Instances with settings (immich, nextcloud, actual, syncthing) and the retention defaults incl. `ssh_user = "btrbk"` never get applied.
2. As a result, btrbk connects as `root@helix-s`, and helix-s is offline anyway.
3. `ocis` fails because its state dir is empty.
4. helix-s and ovh-vps don't evaluate: `lts-kernel` is missing from the colmena specialArgs. This was already the case before these changes.
5. ~~Cleanup~~ done (Nov 6): old `@name` subvolumes, `rescue/*`, `var/bkp/*` and the paperless `.bak` were deleted, and `migrateFrom` was removed from the module.
6. `modules/services/btrfs-create-subvolumes.nix` is superseded (only helix-b uses it).
7. `btrbk.nix`: the btrbk user has his hashed password written there - better move it to ./private
8. harden my servers: ovh-vps, inspirion (e.g. hardened kernel)
