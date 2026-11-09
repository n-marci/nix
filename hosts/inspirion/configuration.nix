{ pkgs, name, user, lts-kernel, latest-kernel, ... }:

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
      ./disks.nix
      ./pg-upgrade.nix # TEMPORARY: remove after the postgres 18 upgrade

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
      server.enable = true;
      mesh.enable = true;
    };

    # service state in /var/lib as btrfs subvolumes, archived when a service is disabled
    subvolumes.enable = true;
  };

  fleet = {
    # syncthing = {
    #   enable = true;
    #   versioning = true;
    #   storeInBackupLocation = true;
    # };
    paperless = {
      enable = true;
      backup = true;
    };
    # nextcloud = {
    #   enable = true;
    #   backup = true;
    # };
    # immich = {
    #   enable = true;
    #   backup = true;
    # };
    # actualbudget = {
    #   enable = true;
    #   backup = true;
    # };
    adguard.enable = true;
    mealie = {
      enable = true;
      backup = true;
    };
    nginx.enable = true;
    # cockpit.enable = true;
    # traccar.enable = true;
    audiobookshelf.enable = true;

    ##############################################################################
    # backup services
    ##############################################################################

    # btrbk = {
    #   enable = true;
    #   node = "source";
    # };

    # postgresql backup
    # pg-bkp = {
    #   enable = true;
    #   databases = [ "nextcloud" "immich" ];
    # };

  };

  ##############################################################################
  # POSTGRES
  ##############################################################################

  # 15 -> 18 upgrade: run `pg-upgrade-18 run` BEFORE deploying this (see hosts/inspirion/pg-upgrade.nix)
  # services.postgresql.package = pkgs.postgresql_18;
  # made default in immich and nextcloud modules

  ##############################################################################
  # BOOT
  ##############################################################################

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # set the timeout for the screen going dark - value in seconds
  boot.kernelParams = [ "consoleblank=120" ];

  boot.kernelPackages = latest-kernel;

  ##############################################################################
  # STATE VERSION
  ##############################################################################

  system.stateVersion = "23.11"; # Did you read the comment?

}
