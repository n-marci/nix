# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, stable, unstable, inputs, vars,  ... }:

# TODO fix setup with btrfs... lol
# TODO check out how to do static ip address

{
  imports = (
    # import ./modules/desktops ++
    import ./modules/services
    # ./modules/services/nextcloud.nix
    # ./modules/services/paperless.nix
    # ./modules/services/searx.nix
    # import ./modules/services/syncthing.nix
  ) ++ ([
    ./modules/programs/helix.nix
    # inputs.sops-nix.nixosModules.sops
  ]);

  ##############################################################################
  # configured services
  ##############################################################################

  syncthing = {
    enable = true;
    versioning = true;
    storeInBackupLocation = true;
  };

  paperless.enable = true;
  nextcloud.enable = true;
  immich.enable = true;
  actualbudget.enable = true;
  adguard.enable = true;
  mealie.enable = false;
  nginx.enable = true;
  cockpit.enable = true;

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

  ##############################################################################
  # other services
  ##############################################################################

  # Disable suspend when closing the lid
  # systemd targets sleep.target, suspend.target, hibernate.target, hybrid-sleep.target
  # seem to already be masked for some reason
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
    # extraUpFlags = [ "--ssh" "--accept-routes" ];
      # -> used it in proxmox and I was able to use nextcloud
      # - maybe different scenario tho, since there tailscale was inside container - now it is on the host
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Enable sound with pipewire.
  # sound.enable = true;
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  # Set time zone and locale
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.user} = {
    isNormalUser = true;
    description = "Marcel Neugebauer";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Automatic Garbage collection
  nix = {
    settings.auto-optimise-store = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 32d";
    };
  };

  nixpkgs.config.allowUnfree = true;
  # nixpkgs-unstable.config.allowUnfree = true;

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      # dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
    };
  };

  environment = {
    variables = {
      HISTSIZE = "20000";
      HISTFILESIZE = "20000";
      EDITOR = "${vars.editor}";
    };

    systemPackages = (with unstable; [
      # cli tools
      sops
      wget
      git
      tldr
      btop
      syncthing # add program to be able to use cli additionally to web interface
      nginx
      docker-compose

      # language servers
      nil # nix lsp
      clang-tools  # c lsp
      marksman  # markdown lsp
      nodePackages.bash-language-server  # bash lsp

    ]) ++ (with pkgs; [
      neovim
    ]) ++ (with stable; [
      htop
    ]);
  };

  # other services
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
  # SSD enable fstrim
  services.fstrim.enable = true;
  # zram swap (info: https://libreddit.tiekoetter.com/r/linux/comments/11dkhz7/zswap_vs_zram_in_2023_whats_the_actual_practical/ ) 
  zramSwap.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # settings = {
    #   PermitRootLogin = false;
    # };
  };

  # services.cockpit = {
  #   enable = true;
  #   openFirewall = true;
  # };
  

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "23.11"; # Did you read the comment?

  # home-manager.users.${vars.user} = {
  #   home = {
  #     stateVersion = "23.11";
  #   };

  #   programs = {
  #     home-manager.enable = true;
  #   };
  # };
}
