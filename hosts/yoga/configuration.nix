{ pkgs, name, user, ... }:

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
      # sops-nix.nixosModules.sops
    ]);

  ##############################################################################
  # my modules
  ##############################################################################

  fleet = {
    # graphics = {
    #   enable = true;
    #   hardware = "intel";
    # };

    plymouth.enable = true;

    services.syncthing.enable = true;
  };

  ##############################################################################
  # boot
  ##############################################################################

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # update the kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_7;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.initrd.kernelModules = [ "amdgpu" ];

  ##############################################################################
  # sops-nix secrets
  ##############################################################################

  sops = {
    defaultSopsFile = ../../secrets/yoga.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile= "/home/marci/.config/sops/age/keys.txt";

    secrets.syncthing-key = { };
    secrets.syncthing-cert = { };
  };

  ##############################################################################
  # state version
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
