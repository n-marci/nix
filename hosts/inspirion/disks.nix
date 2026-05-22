# Example to create a bios compatible gpt partition
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
              label = "nixos-1";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = lib.mkDefault [ "-f" "-d raid1" "-m raid1" "/dev/disk/by-label/nixos-2" ];
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

                  # /var/lib
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
                  "@psql-export" = {
                    mountpoint = "/var/lib/psql-export";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@paperless" = {
                    mountpoint = "/var/lib/paperless";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@samba" = {
                    mountpoint = "/var/lib/samba";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@audiobookshelf" = {
                    mountpoint = "/var/lib/audiobookshelf";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@ocis" = {
                    mountpoint = "/var/lib/ocis";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@opencloud" = {
                    mountpoint = "/var/lib/opencloud";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # /var/lib/private
                  "@actual" = {
                    mountpoint = "/var/lib/private/actual";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@AdGuardHome" = {
                    mountpoint = "/var/lib/private/AdGuardHome";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@mealie" = {
                    mountpoint = "/var/lib/private/mealie";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@newt" = {
                    mountpoint = "/var/lib/private/newt";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # syncthing
                  "@syncthing-nix" = {
                    mountpoint = "/var/lib/syncthing/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@secrets" = {
                    mountpoint = "/var/lib/syncthing/secrets";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@wallpapers" = {
                    mountpoint = "/var/lib/syncthing/wallpapers";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@obsidian" = {
                    mountpoint = "/var/lib/syncthing/obsidian";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@phone" = {
                    mountpoint = "/var/lib/syncthing/phone";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@signal" = {
                    mountpoint = "/var/lib/syncthing/signal";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@whatsapp" = {
                    mountpoint = "/var/lib/syncthing/whatsapp";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
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
              label = "nixos-2";
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
