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
      ../../modules/hosts/mesh.nix
      ./hardware-configuration.nix

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
      server.enable = true;
      mesh.enable = true;
    };
  };

  fleet = {
    syncthing = {
      enable = true;
      versioning = false;
      storeInBackupLocation = true;
    };

    ##############################################################################
    # backup services
    ##############################################################################

    # btrbk = {
    #   enable = true;
    #   node = "target";
    # };
  };

  ##############################################################################
  # BOOT
  ##############################################################################

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # set the timeout for the screen going dark - value in seconds
  boot.kernelParams = [ "consoleblank=120" ];

  boot.kernelPackages = lts-kernel;

  ##############################################################################
  # STORAGE SETUP
  ##############################################################################

  fileSystems."/media/bkp" = {
    device = "/dev/disk/by-uuid/a6237260-b23e-49c2-963c-c9a9b97b5190";
    fsType = "btrfs";
    options = [
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  ##############################################################################
  # NETWORKING
  ##############################################################################

  networking.networkmanager.enable = true; # needed cause helix-s is connected via wifi

  ##############################################################################
  # STATE VERSION
  ##############################################################################

  system.stateVersion = "24.05"; # Did you read the comment?

}
