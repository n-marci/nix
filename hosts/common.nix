{ pkgs, vars, ... }:

{
  imports = [
    ../modules/monitoring/node-exporter.nix
  ];

  # ============================================================================
  # nix
  # ============================================================================

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

  # ============================================================================
  # USER MANAGEMENT
  # ============================================================================

  users.users.${vars.user}= {
    isNormalUser = true;
    description = "Marcel Neugebauer";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # ============================================================================
  # PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
  ];

  # ============================================================================
  # LOCALIZATION & TIMEZONE
  # ============================================================================

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
