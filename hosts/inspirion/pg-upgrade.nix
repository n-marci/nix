# TEMPORARY: postgres 15 -> 18 upgrade helper (remove after the upgrade)
#
#   pg-upgrade-18 check   non-destructive dry run against the running 15 cluster
#   pg-upgrade-18 run     stops services, dumps, snapshots, pg_upgrade --clone
#
# The 15 data directory is never modified (--clone uses reflinks), and a
# read-only btrfs snapshot plus a pg_dumpall are taken before anything else.

{ config, lib, pkgs, ... }:

let
  cfg = config.services.postgresql;
  oldPostgres = pkgs.postgresql_15.withPackages cfg.extensions;
  newPostgres = pkgs.postgresql_18.withPackages cfg.extensions;
  initdbArgs = lib.escapeShellArgs ([
    "--no-data-checksums" # old cluster has checksums off, pg_upgrade requires a match
    "--encoding=UTF8"
    "--locale=en_US.UTF-8"
  ] ++ cfg.initdbArgs);
  services = [
    "immich-server" "immich-machine-learning"
    "nextcloud-cron.timer" "nextcloud-cron.service" "phpfpm-nextcloud"
    "nextcloud-update-plugins.timer" "nextcloud-update-plugins.service"
    "postgresqlBackup-immich.timer" "postgresqlBackup-nextcloud.timer"
  ];

  script = pkgs.writeShellApplication {
    name = "pg-upgrade-18";
    runtimeInputs = with pkgs; [ coreutils util-linux btrfs-progs systemd gzip ];
    text = ''
      OLDDATA=/var/lib/postgresql/15
      OLDBIN=${oldPostgres}/bin
      NEWBIN=${newPostgres}/bin
      STAMP=$(date +%Y%m%d-%H%M%S)
      EXPORT=/var/lib/psql-export/pre-pg18-$STAMP
      SNAPDIR=/var/snap/pre-pg18-$STAMP
      pg() { runuser -u postgres -- "$@"; }
      counts() {
        for db in immich nextcloud; do
          pg "$1/psql" -X -At -d "$db" -c "
            select '$db', table_schema || '.' || table_name,
              (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', table_schema, table_name), false, true, ''')))[1]::text
            from information_schema.tables
            where table_type = 'BASE TABLE' and table_schema not in ('pg_catalog', 'information_schema')
            order by 2"
        done
      }

      [ "$(id -u)" = 0 ] || { echo "run as root"; exit 1; }
      [ "$(cat "$OLDDATA/PG_VERSION")" = 15 ] || { echo "$OLDDATA is not a 15 cluster"; exit 1; }

      case "''${1:-}" in
        check)
          NEWDATA=$(mktemp -d /var/lib/postgresql/18-check.XXXXXX)
          chown postgres:postgres "$NEWDATA"; chmod 700 "$NEWDATA"
          trap 'rm -rf "$NEWDATA"' EXIT
          pg "$NEWBIN/initdb" -D "$NEWDATA" ${initdbArgs} >/dev/null
          cd "$NEWDATA"
          pg "$NEWBIN/pg_upgrade" --check \
            --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
            --old-options "-c config_file=$OLDDATA/postgresql.conf" \
            --new-options "-c shared_preload_libraries=vchord.so" \
            --old-port 5432 --new-port 50433 --socketdir /run/postgresql
          ;;
        run)
          NEWDATA=/var/lib/postgresql/18
          [ ! -e "$NEWDATA" ] || { echo "$NEWDATA already exists, aborting"; exit 1; }

          systemctl stop ${lib.escapeShellArgs services}
          clients=$(pg "$OLDBIN/psql" -X -At -c "select datname || ' ' || coalesce(application_name, ''') from pg_stat_activity where datname in ('immich', 'nextcloud') and pid <> pg_backend_pid()")
          [ -z "$clients" ] || { echo "still connected, aborting:"; echo "$clients"; exit 1; }

          install -d -m 0700 -o postgres -g postgres "$EXPORT"
          pg "$OLDBIN/pg_dumpall" | gzip > "$EXPORT/dumpall.sql.gz"
          chown postgres:postgres "$EXPORT/dumpall.sql.gz"
          gzip -t "$EXPORT/dumpall.sql.gz"
          echo "dump: $EXPORT/dumpall.sql.gz"
          counts "$OLDBIN" > "$EXPORT/counts-15.txt"
          echo "row counts: $EXPORT/counts-15.txt ($(wc -l < "$EXPORT/counts-15.txt") tables)"

          systemctl stop postgresql
          install -d -m 0700 "$SNAPDIR"
          for sv in postgresql immich nextcloud; do
            btrfs subvolume snapshot -r "/var/lib/$sv" "$SNAPDIR/$sv"
          done
          echo "snapshots: $SNAPDIR/{postgresql,immich,nextcloud}"

          # /run/postgresql is removed by systemd when postgresql.service stops
          install -d -m 0700 -o postgres -g postgres /run/pg-upgrade
          install -d -m 0700 -o postgres -g postgres "$NEWDATA"
          pg "$NEWBIN/initdb" -D "$NEWDATA" ${initdbArgs}
          cd "$NEWDATA"
          pg "$NEWBIN/pg_upgrade" --clone --jobs "$(nproc)" \
            --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
            --old-options "-c config_file=$OLDDATA/postgresql.conf" \
            --new-options "-c shared_preload_libraries=vchord.so" \
            --socketdir /run/pg-upgrade

          echo
          echo "pg_upgrade done. postgres and dependent services are still stopped."
          echo "Now deploy the config with services.postgresql.package = pkgs.postgresql_18."
          ;;
        verify)
          # run after the 18 cluster is up: compares exact row counts with the pre-upgrade ones
          latest=$(find /var/lib/psql-export -maxdepth 2 -path '*/pre-pg18-*/counts-15.txt' | sort | tail -n1)
          counts "$NEWBIN" > "''${latest%/*}/counts-18.txt"
          if diff "$latest" "''${latest%/*}/counts-18.txt"; then
            echo "OK: all $(wc -l < "$latest") tables have identical row counts"
          else
            echo "MISMATCH, see diff above"; exit 1
          fi
          ;;
        *) echo "usage: pg-upgrade-18 check|run|verify"; exit 1 ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [ script ];

  # never let NixOS initdb an empty 18 cluster (apps would start on empty databases)
  systemd.services.postgresql.unitConfig.ConditionPathExists = "${cfg.dataDir}/PG_VERSION";
  systemd.services.postgresql-setup.unitConfig.ConditionPathExists = "${cfg.dataDir}/PG_VERSION";
}
