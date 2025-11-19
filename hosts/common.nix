{ pkgs, vars, ... }:

{
  # imports = [
  #   ../modules/monitoring/node-exporter.nix
  # ];
  # imports = (
  #   import ./modules/services
  # ) ++ ([
  #   # ./modules/programs/helix.nix
  # ]);

  ##############################################################################
  # nix
  ##############################################################################

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  nixpkgs.config.allowUnfree = true;

  ##############################################################################
  # users
  ##############################################################################

  users.users.${vars.user}= {
    isNormalUser = true;
    description = "Marcel Neugebauer";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  ##############################################################################
  # networking
  ##############################################################################

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  ##############################################################################
  # bash
  ##############################################################################

  environment = {
    variables = {
      HISTSIZE = "20000";
      HISTFILESIZE = "20000";
      EDITOR = "${vars.editor}";
    };
  };

  ##############################################################################
  # pkgs
  ##############################################################################

  environment.systemPackages = with pkgs; [
    # cli tools
    sops
    wget
    git
    tldr
    btop
    helix
  ];

  ##############################################################################
  # LOCALIZATION & TIMEZONE
  ##############################################################################

  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

}
