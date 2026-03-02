{ pkgs, name, user, lts-kernel, ... }:

{
  imports = (
      # import ../../modules/configurations ++
      # import ../../modules/desktops ++
      # import ../../modules/programs ++
      import ../../modules/services
    ) ++ ([
      # ../../modules/hosts/baremetals.nix
      # ../../modules/hosts/vms.nix
      ../../modules/hosts/common.nix
      ../../modules/hosts/servers.nix
      ../../modules/hosts/mesh.nix
      ./hardware-configuration.nix

      # ../../modules/programs/helix.nix
      ../../modules/configurations/networking.nix
      ../../modules/configurations/virtualisation.nix
    ]);

  ##############################################################################
  # FLEET
  ##############################################################################

  marci = {

    # TODO: merge config from nixos-anywhere-example and my colmena config
    # TODO: with the merge just include the basic disko config
    # TODO: look through modules if everything the common configurations work out
    # TODO: configure pangolin
    
    # hosts = {
    #   baremetal.enable = true;
    #   common.enable = true;
    #   server.enable = true;
    #   mesh.enable = true;
    # };
  };

  fleet = {
    # TODO
  };

  ##############################################################################
  # BOOT
  ##############################################################################

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.configurationLimit = 3;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.timeout = 5;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # set the timeout for the screen going dark - value in seconds
  boot.kernelParams = [ "consoleblank=120" ];

  boot.kernelPackages = lts-kernel;

  ##############################################################################
  # STATE VERSION
  ##############################################################################

  system.stateVersion = "23.11"; # Did you read the comment?

}
