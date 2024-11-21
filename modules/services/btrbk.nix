
# btrbk configuration

{config, pkgs, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    btrbk = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      # versioning = mkOption {
      #   type = types.bool;
      #   default = false;
      # };
    };
  };
  
  config = mkIf (config.btrbk.enable) {

    # btrfs-progs is a prerequisite in the documentation
    # not sure if needed
    # environment.systemPackages = with pkgs; [
    #   btrfs-progs
    # ];

    services = {
      btrbk = {
        instances.btrbk = {
          onCalendar = "hourly";
          settings = {
            # good explanation on gentoo wiki https://wiki.calculate-linux.org/btrbk
            preserve_hour_of_day = "0"; # the daily backup is the first one after midnight
            preserve_day_of_week = "monday"; # Monday is the first day of week
            snapshot_preserve_min = "1d"; # preserve all temporary snapshots for at least one day
            snapshot_preserve = "14d 8w 6m 1y"; # preserve 14 latest daily, 8 weekly, 6 monthly, 1 annual snapshots
            target_preserve_min = "no"; # do not preserve temporary snapshots
            target_preserve = "6d 4w 6m 1y"; # preserve 6 latest daily, 4 weekly, 6 monthly, 1 annual snapshots
            stream_compress = "zstd";
            volume = {
              "/" = {
                subvolume = {

                  ###########################
                  # Server Applications
                  ###########################

                  "var/lib/paperless" = {
                    snapshot_create = "always";
                  };
                  "var/lib/nextcloud" = {
                    snapshot_create = "always";
                  };
                  "var/lib/postgresql" = {
                    snapshot_create = "always";
                  };
                  "var/lib/immich" = {
                    snapshot_create = "always";
                  };
                  "var/lib/actualbudget" = {
                    snapshot_create = "always";
                  };
                  
                  ###########################
                  # Syncthing Folders
                  ###########################

                  "var/lib/syncthing/obsidian" = {
                    snapshot_create = "always";
                  };
                  "var/lib/syncthing/logseq" = {
                    snapshot_create = "always";
                  };
                  "var/lib/syncthing/live" = {
                    snapshot_create = "always";
                  };
                  "var/lib/syncthing/linux" = {
                    snapshot_create = "always";
                  };
                  "var/lib/syncthing/idle" = {
                    snapshot_create = "always";
                  };
                  "var/lib/syncthing/archive" = {
                    snapshot_create = "always";
                  };
                  "var/lib/syncthing/dev" = {
                    snapshot_create = "always";
                  };
                  "home/marci/nix" = {
                    snapshot_create = "always";
                  };
                  "home/marci/secrets" = {
                    snapshot_create = "always";
                  };
                  # rootfs = { };
                };
                snapshot_dir = "/var/bkp/btrfs-snaps";
                target = "/var/bkp/btrfs-target";
              };
            };
          };
        };
      };
    };

    security.sudo = {
      enable = true;
      extraRules = [{
        commands = [{
        command = "${pkgs.coreutils-full}/bin/test";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.coreutils-full}/bin/readlink";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.btrfs-progs}/bin/btrfs";
        options = [ "NOPASSWD" ];
      }];
        users = [ "btrbk" ];
      }];
      extraConfig = with pkgs; ''
        Defaults:picloud secure_path="${lib.makeBinPath [
          btrfs-progs coreutils-full
        ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
  };
}
