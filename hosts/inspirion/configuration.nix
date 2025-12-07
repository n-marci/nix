{ pkgs, name, user, lts-kernel, ... }:

{
  imports = (
      # import ../../modules/configurations ++
      # import ../../modules/desktops ++
      # import ../../modules/programs ++
      import ../../modules/services
    ) ++ ([
      ../baremetals.nix
      ../common.nix
      ../servers.nix
      ./hardware-configuration.nix

      # ../../modules/programs/helix.nix
      ../../modules/configurations/networking.nix
      ../../modules/configurations/virtualisation.nix
    ]);

  ##############################################################################
  # FLEET
  ##############################################################################

  fleet = {
    syncthing = {
      enable = true;
      versioning = true;
      storeInBackupLocation = true;
    };
    paperless.enable = true;
    nextcloud.enable = true;
    immich = {
      enable = true;
      backup = true;
    };
    actualbudget.enable = true;
    adguard.enable = true;
    mealie = {
      enable = true;
      backup = true;
    };
    nginx.enable = true;
    cockpit.enable = true;
    traccar.enable = true;
    synapse.enable = false;
    audiobookshelf.enable = true;

    ##############################################################################
    # backup services
    ##############################################################################

    btrbk = {
      enable = true;
      node = "source";
    };

    # postgresql backup
    pg-bkp = {
      enable = true;
      databases = [ "nextcloud" "immich" ];
    };

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

  # home-manager.users.${user} = {
  #   home = {
  #     stateVersion = "23.11";
  #   };

  #   programs = {
  #     home-manager.enable = true;
  #   };

  #   nix = {
  #     # package = pkgs.nix;
  #     settings.experimental-features = [ "nix-command" "flakes" ];
  #   };
  # };

}
