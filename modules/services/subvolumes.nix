# subvolumes config
#
# Every declared path becomes a nested btrfs subvolume (e.g. /var/lib/paperless
# inside @). No fstab entries/mounts are involved, so a missing subvolume can
# never block the boot - it is just a directory.
#
# Lifecycle (runs on boot and on every colmena deploy):
#   - path declared, subvolume exists        -> nothing happens
#   - path declared, subvolume missing       -> restore latest archive snapshot,
#                                               else snapshot `migrateFrom`,
#                                               else create an empty subvolume
#   - path no longer declared (service off)  -> subvolume is moved into the
#                                               archive and made read-only
#   - `reset` set to a new value             -> current data is archived and an
#                                               empty subvolume is created (once)
#
# Archives live in ${stateDir}/archive/<escaped-path>/<timestamp> and are never
# deleted automatically.

{ config, lib, pkgs, utils, ... }:

let
  cfg = config.marci.subvolumes;
  inherit (lib) mkEnableOption mkOption mkIf mkMerge mapAttrs' nameValuePair attrNames types;

  subvolume = pkgs.writeShellApplication {
    name = "subvolume";
    runtimeInputs = with pkgs; [ btrfs-progs coreutils findutils util-linux systemd ];
    text = ''
      STATE_DIR=${lib.escapeShellArg cfg.stateDir}
      ARCHIVE_DIR="$STATE_DIR/archive"
      RESET_DIR="$STATE_DIR/reset"
      DISPLACED_DIR="$STATE_DIR/displaced"

      log() { echo "$*"; }
      die() { echo "ERROR: $*" >&2; exit 1; }

      timestamp() { date +%Y%m%dT%H%M%S; }
      escape() { systemd-escape --path "$1"; }

      is_subvolume() {
        [ -d "$1" ] && [ ! -L "$1" ] \
          && [ "$(stat -f -c %T "$1")" = btrfs ] \
          && [ "$(stat -c %i "$1")" = 256 ]
      }

      latest_archive() {
        local dir
        dir="$ARCHIVE_DIR/$(escape "$1")"
        [ -d "$dir" ] || return 0
        find "$dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -n 1
      }

      # rename only - never fall back to copying
      move() { mv --no-copy -T "$1" "$2"; }

      archive() {
        local path="$1" dir dest
        dir="$ARCHIVE_DIR/$(escape "$path")"
        dest="$dir/$(timestamp)"
        mkdir -p "$dir"
        [ -e "$dest" ] && dest="$dest-$$"
        move "$path" "$dest"
        btrfs property set -ts "$dest" ro true
        log "archived $path -> $dest (read-only)"
      }

      make_parent() {
        local parent
        parent="$(dirname "$1")"
        if [ ! -d "$parent" ]; then
          # systemd requires /var/lib/private to be 0700
          if [ "$parent" = /var/lib/private ]; then install -d -m 0700 "$parent"; else mkdir -p "$parent"; fi
        fi
      }

      # snapshot a subvolume from the top-level (subvolid=5) of the filesystem
      # (the unit runs with PrivateMounts=yes, so this mount is never visible)
      snapshot_toplevel() {
        local name="$1" path="$2" device top
        device="$(findmnt -nvo SOURCE -T "$(dirname "$path")")"
        top="$(mktemp -d /run/subvolume-top.XXXXXX)"
        mount -t btrfs -o subvolid=5 "$device" "$top"
        if is_subvolume "$top/$name"; then
          btrfs subvolume snapshot "$top/$name" "$path"
          log "migrated top-level subvolume $name -> $path"
        fi
        umount "$top"
        rmdir "$top"
      }

      ensure() {
        local path="$1" owner="$2" group="$3" mode="$4" reset="$5" migrate_from="$6"
        local esc token_file stored reset_requested=0 latest

        mkdir -p "$STATE_DIR" "$RESET_DIR"
        esc="$(escape "$path")"
        token_file="$RESET_DIR/$esc"
        stored=""
        [ -f "$token_file" ] && stored="$(cat "$token_file")"
        [ -n "$reset" ] && [ "$reset" != "$stored" ] && reset_requested=1

        if mountpoint -q "$path"; then
          log "$path is a mount point (legacy mount?) - leaving it untouched"
          return 0
        fi

        [ "$(stat -f -c %T "$(dirname "$path")" 2>/dev/null || echo missing)" = btrfs ] \
          || [ ! -d "$(dirname "$path")" ] \
          || die "$(dirname "$path") is not on btrfs"

        # 1. normalise: plain directories become subvolumes (or are removed if empty)
        if [ -L "$path" ] || { [ -e "$path" ] && [ ! -d "$path" ]; }; then
          die "$path exists but is not a directory"
        elif [ -d "$path" ] && ! is_subvolume "$path"; then
          if [ -z "$(find "$path" -mindepth 1 ! -type d -print -quit)" ]; then
            log "removing empty directory skeleton at $path"
            find "$path" -depth -type d -empty -delete
          else
            log "converting plain directory $path into a subvolume"
            btrfs subvolume create "$path.subvolume-tmp"
            cp -a --reflink=always "$path/." "$path.subvolume-tmp/"
            mkdir -p "$DISPLACED_DIR"
            move "$path" "$DISPLACED_DIR/$esc-$(timestamp)"
            move "$path.subvolume-tmp" "$path"
            log "original directory kept in $DISPLACED_DIR"
          fi
        fi

        # 2. existing subvolume: keep it, unless a reset was requested
        if is_subvolume "$path"; then
          if [ "$reset_requested" = 1 ]; then
            log "reset requested ('$stored' -> '$reset')"
            archive "$path"
          else
            log "$path: ok"
            return 0
          fi
        fi

        # 3. create the subvolume
        make_parent "$path"
        latest="$(latest_archive "$path")"
        if [ "$reset_requested" = 0 ] && [ -n "$latest" ]; then
          btrfs subvolume snapshot "$ARCHIVE_DIR/$esc/$latest" "$path"
          log "restored $path from archive $latest"
        elif [ "$reset_requested" = 0 ] && [ -n "$migrate_from" ]; then
          snapshot_toplevel "$migrate_from" "$path"
        fi
        if ! is_subvolume "$path"; then
          btrfs subvolume create "$path"
          chown "$owner:$group" "$path"
          chmod "$mode" "$path"
          log "created empty subvolume $path"
        fi

        [ -n "$reset" ] && printf '%s' "$reset" > "$token_file"
        # recreate directories that tmpfiles.d declares below this path
        systemd-tmpfiles --create --prefix="$path" || true
      }

      archive_removed() {
        local managed="$STATE_DIR/managed" path keep=()
        mkdir -p "$STATE_DIR"
        if [ -f "$managed" ]; then
          while IFS= read -r path; do
            [ -n "$path" ] || continue
            local declared=0 p
            for p in "$@"; do [ "$p" = "$path" ] && declared=1; done
            [ "$declared" = 1 ] && continue

            if mountpoint -q "$path"; then
              log "WARNING: $path is no longer declared but still mounted - not archiving"
              keep+=("$path")
            elif is_subvolume "$path"; then
              archive "$path" || keep+=("$path")
            fi
          done < "$managed"
        fi
        printf '%s\n' "$@" "''${keep[@]}" | sort -u | sed '/^$/d' > "$managed.tmp"
        mv "$managed.tmp" "$managed"
        [ "''${#keep[@]}" = 0 ] || die "could not archive: ''${keep[*]}"
      }

      cmd="$1"; shift
      case "$cmd" in
        ensure) ensure "$@" ;;
        archive-removed) archive_removed "$@" ;;
        *) die "unknown command $cmd" ;;
      esac
    '';
  };

  unitName = path: "subvolume-${utils.escapeSystemdPath path}";
in
{

  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.subvolumes = {
    enable = mkEnableOption "Manage service state directories as btrfs subvolumes";

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/.subvolumes";
      description = "Holds the archive of disabled services and bookkeeping. Must be on the same subvolume as the managed paths' parents.";
    };

    paths = mkOption {
      default = { };
      example = { "/var/lib/paperless" = { requiredBy = [ "paperless-web.service" ]; migrateFrom = "@paperless"; }; };
      type = types.attrsOf (types.submodule {
        options = {
          requiredBy = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Units that need this subvolume. They start after it and are restarted with it (e.g. on a reset).";
          };

          reset = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "2026-11-06";
            description = ''
              Set (or change) to any new value to archive the current data once and
              start with an empty subvolume. Leaving the value in place does nothing
              on later deploys.
            '';
          };

          migrateFrom = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "@paperless";
            description = "Top-level subvolume to snapshot into place if there is neither a subvolume nor an archive yet.";
          };

          owner = mkOption { type = types.str; default = "root"; description = "Owner for newly created empty subvolumes."; };
          group = mkOption { type = types.str; default = "root"; description = "Group for newly created empty subvolumes."; };
          mode = mkOption { type = types.str; default = "0755"; description = "Mode for newly created empty subvolumes."; };
        };
      });
    };
  };

  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) (mkMerge [

  ##############################################################################
  # SERVICES
  ##############################################################################

    {
      systemd.services = {
        subvolumes-archive = {
          description = "Archive btrfs subvolumes of disabled services";
          wantedBy = [ "sysinit.target" ];
          after = [ "local-fs.target" ];
          before = [ "sysinit.target" "shutdown.target" ] ++ map (p: "${unitName p}.service") (attrNames cfg.paths);
          conflicts = [ "shutdown.target" ];
          unitConfig.DefaultDependencies = false;
          stopIfChanged = false;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = utils.escapeSystemdExecArgs ([ (lib.getExe subvolume) "archive-removed" ] ++ attrNames cfg.paths);
          };
        };
      } // mapAttrs' (path: sv: nameValuePair (unitName path) {
        description = "Btrfs subvolume ${path}";
        wantedBy = [ "sysinit.target" ];
        requiredBy = sv.requiredBy;
        after = [ "local-fs.target" "subvolumes-archive.service" ];
        before = [ "sysinit.target" "systemd-tmpfiles-setup.service" "shutdown.target" ] ++ sv.requiredBy;
        conflicts = [ "shutdown.target" ];
        unitConfig.DefaultDependencies = false;
        stopIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          PrivateMounts = true;
          ExecStart = utils.escapeSystemdExecArgs [
            (lib.getExe subvolume) "ensure" path sv.owner sv.group sv.mode
            (if sv.reset == null then "" else sv.reset)
            (if sv.migrateFrom == null then "" else sv.migrateFrom)
          ];
        };
      }) cfg.paths;

      environment.systemPackages = [ subvolume ];
    }

  ##############################################################################
  # SHARED INFRASTRUCTURE
  ##############################################################################

    {
      marci.subvolumes.paths = mkMerge [
        (mkIf config.services.tailscale.enable {
          "/var/lib/tailscale" = { requiredBy = [ "tailscaled.service" "tailscaled-set.service" ]; migrateFrom = "@tailscale"; mode = "0700"; };
        })
        (mkIf config.services.samba.enable {
          "/var/lib/samba" = { requiredBy = [ "samba-smbd.service" "samba-nmbd.service" "samba-winbindd.service" ]; migrateFrom = "@samba"; };
        })
        (mkIf config.services.postgresql.enable {
          "/var/lib/postgresql" = { requiredBy = [ "postgresql.service" "postgresql-setup.service" ]; migrateFrom = "@postgresql"; owner = "postgres"; group = "postgres"; mode = "0750"; };
        })
        (mkIf config.services.postgresqlBackup.enable {
          ${config.services.postgresqlBackup.location} = {
            requiredBy = map (db: "postgresqlBackup-${db}.service") config.services.postgresqlBackup.databases;
            migrateFrom = "@psql-export";
            owner = "postgres";
            mode = "0700";
          };
        })
      ];
    }
  ]);
}
