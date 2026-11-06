{ lib, ... }:
let
  disk-1 = "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_1000GB_23132T801154";
  disk-2 = "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_1000GB_23011F466308";
in
{
  disko.devices = {
    disk = {
      
      internal-1 = {
        device = lib.mkDefault disk-1;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {

            esp = {
              name = "ESP1";
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
              name = "root-1";
              # label = "nixos-1";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = lib.mkDefault [ "-f" "-d raid1" "-m raid1" disk-2 ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };

                  # service state in /var/lib is NOT declared here - it lives in nested
                  # subvolumes managed by marci.subvolumes (modules/services/subvolumes.nix)
                };
              };
            };
          };
        };
      };

      internal-2 = {
        device = lib.mkDefault disk-2;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {

            esp = {
              name = "ESP2";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                # Do NOT mount this by default; we’ll mount it only for syncing.
              };
            };

            root = {
              name = "root-2";
              # label = "nixos-2";
              size = "100%";
              # No standalone filesystem here: disk2's root partition becomes
              # the second device of the btrfs filesystem created on disk1,
              # via additionalDevices above.
              content = {
                type = "btrfs";
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
