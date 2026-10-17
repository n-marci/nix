{ lib, user, ... }:
let
  disk = "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_1000GB_23132T801154";
in
{
  disko.devices = {
    disk = {
      
      internal = {
        device = lib.mkDefault disk;
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
              name = "root";
              # label = "nixos";
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  # os
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@nix-store" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };

                  # syncthing
                  "@nix" = {
                    mountpoint = "/home/${user}/nix";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@secrets" = {
                    mountpoint = "/home/${user}/secrets";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@wallpapers" = {
                    mountpoint = "/home/${user}/Pictures/wallpapers";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@obsidian" = {
                    mountpoint = "/home/${user}/obsidian";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@phone" = {
                    mountpoint = "/home/${user}/phone";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@signal" = {
                    mountpoint = "/home/${user}/signal";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                  "@whatsapp" = {
                    mountpoint = "/home/${user}/whatsapp";
                    mountOptions = [ "compress=zstd" "noatime" "nofail" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
