# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  imports = [
    ./initial-disks.nix
  ];

  disko.devices = {
    disk.internal = {
      content = {
        partitions = {
          root = {
            content = {
              # extraArgs = [ ];
              subvolumes = {
                "@test2" = {
                  mountpoint = "/var/lib/test2";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
