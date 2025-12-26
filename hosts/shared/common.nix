{ pkgs, name, user, ... }:

{
  ##############################################################################
  # ANTIVIRUS
  ##############################################################################

  services.clamav.updater.enable = true;

  ##############################################################################
  # sops-nix secrets
  ##############################################################################

  sops = {
    defaultSopsFile = ../secrets/${name}.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile= "/home/${user}/.config/sops/age/keys.txt";
  };

  ##############################################################################
  # NIX
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

  # nixpkgs.config.allowUnfree = true;

  ##############################################################################
  # USERS
  ##############################################################################

  users.users.${user} = {
    isNormalUser = true;
    description = "Marcel Neugebauer";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  ##############################################################################
  # NETWORKING
  ##############################################################################

  # fleet.networking.enable = true;
  networking.hostName = name;
  services.tailscale.enable = true;

  ##############################################################################
  # BASH & SHELL
  ##############################################################################

  environment = {
    variables = {
      HISTSIZE = "20000";
      HISTFILESIZE = "20000";
      EDITOR = "hx";
      XCURSOR_THEME="ComixCursors-Opaque-Black"; # not entirely sure if needed
    };
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  ##############################################################################
  # PKGS
  ##############################################################################

  environment.systemPackages = with pkgs; [
    # cli tools
    sops
    wget
    git
    tldr
    btop
    helix
    neovim
    clamav
    trashy
  ];

  ##############################################################################
  # LOCALIZATION & TIMEZONE
  ##############################################################################

  console.keyMap = "de";

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
