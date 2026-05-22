{ pkgs, name, user, lts-kernel, ... }:

{
  imports = (
      # import ../../modules/configurations ++
      # import ../../modules/desktops ++
      # import ../../modules/programs ++
      import ../../modules/services
    ) ++ ([
      ../../modules/hosts/baremetals.nix
      ../../modules/hosts/common.nix
      ../../modules/hosts/servers.nix
      ../../modules/hosts/nixos-install.nix
      ../../modules/hosts/mesh.nix
      ./hardware-configuration.nix
      ./disks.nix

      # ../../modules/programs/helix.nix
      ../../modules/configurations/networking.nix
      ../../modules/configurations/virtualisation.nix
    ]);

  ##############################################################################
  # FLEET
  ##############################################################################

  marci = {
    hosts = {
      baremetal.enable = true;
      common.enable = true;
      # server.enable = true;
      nixos-install.enable = true;
      # mesh.enable = true;
    };
  };

  ##############################################################################
  # BOOT
  ##############################################################################

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # set the timeout for the screen going dark - value in seconds
  boot.kernelParams = [ "consoleblank=120" ];

  boot.kernelPackages = lts-kernel;

  ##############################################################################
  # STATE VERSION
  ##############################################################################

  system.stateVersion = "23.11"; # Did you read the comment?

}
