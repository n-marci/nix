{ user, latest-kernel, ... }:

{
  imports = (
      import ../../modules/configurations ++
      import ../../modules/desktops ++
      import ../../modules/programs ++
      import ../../modules/services
    ) ++ ([
      ../baremetals.nix
      ../common.nix
      ../desktops.nix
      ../mobile.nix
      ./hardware-configuration.nix
    ]);

  ##############################################################################
  # FLEET
  ##############################################################################

  fleet = {
    plymouth.enable = true;
    syncthing.enable = true;
  };

  ##############################################################################
  # BOOT
  ##############################################################################

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  boot.kernelPackages = latest-kernel;

  ##############################################################################
  # STATE VERSION
  ##############################################################################

  system.stateVersion = "23.11"; # Did you read the comment?

  home-manager.users.${user} = {
    home = {
      stateVersion = "23.11";
    };

    programs = {
      home-manager.enable = true;
    };

    nix = {
      # package = pkgs.nix;
      settings.experimental-features = [ "nix-command" "flakes" ];
    };
  };

}
