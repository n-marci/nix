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

## Postgres 15 → 18 (Nov 8)

- **Prep (morning):** dumped all DBs to `/var/lib/psql-export/pre-maintenance-2026-11-08/`, dropped the unused `matrix-synapse` and `mautrix-whatsapp` DBs and roles, dropped the old pgvecto.rs `vectors` extension, reindexed and refreshed collations (glibc 2.40 → 2.44).
- **Upgrade:** `hosts/inspirion/pg-upgrade.nix` provides `pg-upgrade-18 check|run|verify`. `run` stops immich and nextcloud, takes a `pg_dumpall` and per-table row counts, stops postgres, snapshots `/var/lib/{postgresql,immich,nextcloud}` read-only, then runs `pg_upgrade --clone` (initdb with `--no-data-checksums`, because the 15 cluster had checksums off). Then `colmena apply boot` and a reboot.
- **Result:** PG 18.6 runs from `/var/lib/postgresql/18`. `verify`: all 242 tables in immich and nextcloud have identical row counts. Immich and Nextcloud are healthy.
- **Rollback material:** `/var/snap/pre-pg18-20261108-100403/{postgresql,immich,nextcloud}` (read-only, consistent), `/var/lib/psql-export/pre-pg18-20261108-100403/dumpall.sql.gz`, and the untouched `/var/lib/postgresql/15`. `pre-pg18-20261108-100234` is from a first attempt that aborted before changing anything (`/run/postgresql` disappears when postgres stops), so it's redundant.
- **Immich "schema drift" warning** (`album_asset_delete_audit` "missing"): a false positive. pg_upgrade gave the function OID 16703, which collides with an extension-owned type OID, and Immich's reader then skips it. The function and trigger exist and match. On the 15 snapshot `immich-admin schema-check` reports no drift.

## Open issues

1. `btrbk.nix`: `mkIf (attrNames cfg.settings == [])` is inverted. Instances with settings (immich, nextcloud, actual, syncthing) and the retention defaults incl. `ssh_user = "btrbk"` never get applied.
2. As a result, btrbk connects as `root@helix-s`, and helix-s is offline anyway.
3. `ocis` fails because its state dir is empty.
4. helix-s and ovh-vps don't evaluate: `lts-kernel` is missing from the colmena specialArgs. This was already the case before these changes.
5. ~~Cleanup~~ done (Nov 6): old `@name` subvolumes, `rescue/*`, `var/bkp/*` and the paperless `.bak` were deleted, and `migrateFrom` was removed from the module.
6. `modules/services/btrfs-create-subvolumes.nix` is superseded (only helix-b uses it).
7. `btrbk.nix`: the btrbk user has his hashed password written there - better move it to ./private
8. harden my servers: ovh-vps, inspirion (e.g. hardened kernel)
9. ~~Postgres 15 → 17/18 upgrade~~ done (Nov 8). Later cleanup: delete `/var/lib/postgresql/15`, `/var/snap/pre-pg18-*` and `/var/lib/psql-export/pre-*`, then remove the `pg-upgrade.nix` import.

# Maintenance agents.md
1. dont forget to run nix flake update
2. check the evaluation warnings in the very beginning of a colmena apply for required maintenance changes (applies to every machine, not just inspirion)
3. prefer colmena apply boot + reboot to colmena apply switch
