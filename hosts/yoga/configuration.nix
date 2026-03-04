{ pkgs, config, user, latest-kernel, ... }:

{
  imports = (
      import ../../modules/configurations ++
      import ../../modules/hosts ++
      import ../../modules/desktops ++
      import ../../modules/programs ++
      import ../../modules/services
    ) ++ ([
      # ../shared/baremetals.nix
      # ../shared/common.nix
      # ../../modules/configurations/hosts/gui.nix
      # ../../modules/configurations/hosts/mobile.nix
      ./hardware-configuration.nix
    ]);

  ##############################################################################
  # PLAYGROUND
  ##############################################################################

  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" "ddcci_backlight" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  services.ddccontrol.enable = true;
  environment.systemPackages = [ pkgs.ddcutil ];
  services.udev.packages = [ pkgs.ddcutil ];

  sops = {
    secrets.pangolin-env = {
      owner = "marci";
    }; # to be moved to pangolin.nix with mesh.nix managing that is only active on key holder (yoga)
  };
  # nix.settings.trusted-users = [ "marci" ];

  ##############################################################################
  # FLEET
  ##############################################################################

  marci = {
    hosts = {
      baremetal.enable = true;
      common.enable = true;
      gui.enable = true;
      mobile.enable = true;
      mesh.enable = true;
    };
  };

  fleet = {
    plymouth.enable = true;
    # syncthing.enable = true;
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
