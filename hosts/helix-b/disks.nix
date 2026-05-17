# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  disko.devices = {
    disk.internal = {
      device = lib.mkDefault "/dev/disk/by-id/ata-INTEL_SSDSCKJF240A5L_CVTT5173013J240M";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {

          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@immich" = {
                  mountpoint = "/var/lib/immich";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nextcloud" = {
                  mountpoint = "/var/lib/nextcloud";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@postgresql" = {
                  mountpoint = "/var/lib/postgresql";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };

    # disk.btrfs-raid-1-disk-a = {
    #   device = "...";
    #   type = "disk";
    #   content = {
    #     type = "gpt";
    #     partitions = {
    #       btrfs = {
    #         size = "100%";
    #         content = {
    #           type = "btrfs";
    #           # Note: metadata/data raid1 is what most people want
    #           extraArgs = [ "-f" "-d" "raid1" "-m" "raid1" ];
    #           label = "EXTRA";
    #           # IMPORTANT: add the second device to the same filesystem declaratively:
    #           additionalDevices = [ "..." ];
    #         };
    #       };
    #     };
    #   };
    # };

    # disk.btrfs-raid-1-disk-b = {
    #   device = "...";
    #   type = "disk";
    # };
  };
}
