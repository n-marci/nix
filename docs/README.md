# Docs

| Document                                     | What it covers                                                                                                               |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| [subvolumes.md](subvolumes.md)               | How service state is stored as btrfs subvolumes: concept, lifecycle, systemd wiring, the script step by step                 |
| [subvolumes-howto.md](subvolumes-howto.md)   | Day-to-day recipes: add a service, disable/re-enable, reset, restore an older archive, clean up, troubleshoot                |
| [inspirion-2026-11.md](inspirion-2026-11.md) | What happened on inspirion in November 2026: the paperless crash loop, the migration away from disko subvolumes, open issues |

## TL;DR

```nix
# host: turn the machinery on
marci.subvolumes.enable = true;

# service module: declare the state directory
marci.subvolumes.paths."/var/lib/paperless" = {
  requiredBy = [ "paperless-web.service" ];  # units that need the data
  migrateFrom = "@paperless";                # optional: old top-level subvolume
  # reset = "2026-11-06";                    # optional: change to start fresh once
};
```

- **Service enabled** → its directory is a btrfs subvolume, created before the service starts.
- **Service disabled** → the subvolume is moved to `/var/lib/.subvolumes/archive/…` and made read-only.
- **Service enabled again** → the newest archive is restored.
- **`reset` changed** → current data is archived, the service starts with an empty subvolume.
