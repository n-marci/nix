
# btrbk configuration

{config, vars, lib, unstable, host, ...}:

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
                  "var/lib/paperless" = {
                    snapshot_create = "always";
                  };
                  "var/lib/nextcloud" = {
                    snapshot_create = "always";
                  };
                  "var/lib/postgresql" = {
                    snapshot_create = "always";
                  };
                  # rootfs = { };
                };
                snapshot_dir = "/bkp/.snapshots";
                target = "/bkp/target";
              };
            };
          };
        };
      };
    };
  };
}
