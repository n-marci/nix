# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# TODO add xremap-flake to imports somewhere
# TODO thin out the list of installed packages so this config can also be used for a server
# TODO figure out if I want syncthing declared once or seperate for every host
# TODO figure out secrets so I can store the syncthing IDs without worry (low prio - I can just leave my git repo private)
# TODO figure out if btrfs and fstrim is fine
# TODO add ~/.config/shell_gpt to configuration
# TODO add other .config files to configuration
# TODO split up configuration.nix into minimal.nix and desktop.nix

{ config, lib, pkgs, stable, unstable, inputs, vars,  ... }:

{
  imports = (
      import ./modules/desktops ++
      import ./modules/programs ++
      import ./modules/services
  #   ) ++ ([
  #   <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  # ]);
  );

  nixpkgs.overlays = [
    (final: prev:
    {
      arduino-cli = prev.arduino-cli.overrideAttrs ( old: {
        src = prev.fetchFromGithub {
          owner = "arduino";
          repo = "arduino-cli";
          rev = "refs/tags/v1.1.0";
          hash = "";
        };
      });
    })
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" ]; # scanner and lp group so i can access scanners and printers i guess
  };

  # Automatic Garbage collection
  nix = {
    settings.auto-optimise-store = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nix.settings = {
    substituters = [ "https://tweag-jupyter.cachix.org" ];
    trusted-public-keys = [ "tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g=" ];
  };

  # font setup and configuration
  fonts = {
    fontDir.enable = true;   # needed for flatpak to use the right cursor and fonts
    packages = (with pkgs; [
      comfortaa
      montserrat
      intel-one-mono
      newcomputermodern
      # (nerdfonts.override { fonts = [ "Monofur" "Agave" "AurulentSansMono" "CascadiaCode" "FantasqueSansMono" "Hermit" "OpenDyslexic" ]; })
    ]) ++ (with pkgs.nerd-fonts; [
      monofur
      agave
      aurulent-sans-mono
      caskaydia-mono
      fantasque-sans-mono
      open-dyslexic
    ]);
    fontconfig.defaultFonts.monospace = [ "Monofur Nerd Font" ];
  };
  nixpkgs.config.allowUnfree = true;
  # nixpkgs-unstable.config.allowUnfree = true;

  virtualisation = {
    podman = {
      enable = true;
      # dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
    };
    waydroid.enable = true;
  };

  environment = {
    variables = {
      HISTSIZE = "20000";
      HISTFILESIZE = "20000";
      EDITOR = "${vars.editor}";
      # XCURSOR_THEME="Bibata_Ghost";
      XCURSOR_THEME="ComixCursors-Opaque-Black";
    };

    sessionVariables = { # needed for nh
      FLAKE = "/home/marci/nix";
    };

    # shellAliases = {
    #   c4 = "sgpt --model gpt-4 --role custom-chat --chat";
    #   c3 = "sgpt --model gpt-3.5-turbo --role custom-chat --chat";
    # };

    systemPackages = (with unstable; [
      # cli tools
      nh # nix helper - upgrade command nh os switch
      sops
      neovim
      comma # wrapper around nix shell, to run programs without installing them
      # zathura
      # helix
      pdfgrep
      wget
      git
      wl-clipboard
      mpv
      tldr
      btop
      ttyper
      ntfs3g
      nssmdns # needed by avahi-daemon i guess
      ghostscript
      imagemagick
      ffmpeg
      translate-shell  # move to script if i write a nixpkg for it
      # python311Packages.gtts
      # piper-tts
      python312Packages.langid
      keyd  # key remapper for my sweet super key on the mouse button
      shell-gpt
      aichat
      # llm
      inotify-tools
      distrobox
      fzf
      zellij
      texliveFull
      # waypipe
      # poetry
      # conda # out of date
      # micromamba
      mesa
      clamav
      arduino-cli
      pioasm
      minicom
      piper-tts

      # eye candy cli programs
      cli-visualizer

      # language servers
      nil # nix lsp
      clang-tools  # c lsp
      python312Packages.python-lsp-server  # python lsp (unfort. there is no 'latest' option)
      marksman  # markdown lsp
      # nodePackages.bash-language-server  # bash lsp
      cmake-language-server  # cmake lsp
      texlab
      bibtex-tidy
      ltex-ls
      arduino-language-server
      ruff
      python313Packages.python-lsp-ruff

      # virtualisation
      distrobox

      # terminals 
      gnome-terminal
      ptyxis
      alacritty

      # images
      inkscape
      gimp
      oculante
      drawio

      # audio
      spotify
      helvum

      # documents
      libreoffice-still
      xournalpp
      rnote                  # https://github.com/flxzt/rnote
      zotero
      papers
      gscan2pdf

      # browser
      brave
      firefox
      librewolf
      
      # gui program
      thunderbird
      remmina
      keepassxc
      gnome-extension-manager
      # (obsidian.overrideAttrs (oldAttrs: {
        
      # })
      # obsidian
      # logseq
      # obsidianDesktopEntry
      # anytype
      # protonmail-bridge
      # protonmail-bridge-gui
      # protonmail-desktop
      # freecad
      # alpaca
      # (blender.override {
      #   cudaSupport = true;
      # })
      kdePackages.kasts

      # cursors
      comixcursors.Opaque_Black
      # comixcursors.Opaque_Slim_Black
      # comixcursors.Opaque_White
      # comixcursors.Opaque_Slim_White
      # volantes-cursors
      # vimix-cursors
      # bibata-cursors-translucent
      # bibata-cursors

      # temporary programs
      # libsForQt5.kdenlive
      # glaxnimate            # needed for kdenlive

      # programs to watch development
      # muzika                 # https://github.com/vixalien/muzika
      # waypipe
      # moonlight-qt        # https://moonlight-stream.org/
      # sunshine            # https://github.com/LizardByte/Sunshine
    ]) ++ (with pkgs; [
      # micromamba
      microfetch                  # dummy package so i can have nixpkgs version here
    ]) ++ (with stable; [

      ### packages with build problems in unstable ###
      ### packages with build problems in unstable ###

      ### packages which need to build from source in unstable ###
      ### packages which need to build from source in unstable ###

      # gaphor
      htop                  # dummy package so i can have stable pkgs here
      # blender-hip
    ]);
  };

  # maybe put indo module
  # programs.fzf.enable = true;
  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  # programs.ydotool.enable = true;

  # configured services
  syncthing.enable = true;

  # other services
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
  # SSD enable fstrim
  services.fstrim.enable = true;
  # zram swap (info: https://libreddit.tiekoetter.com/r/linux/comments/11dkhz7/zswap_vs_zram_in_2023_whats_the_actual_practical/ ) 
  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;
  boot.kernel.sysctl = { "vm.swappiness" = 120; };
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ mfcl2700dnlpr brlaser ]; # brlaser 
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable SANE to scan documents
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    brscan4 = {
      enable = true;
    };
  };
  services.ipp-usb.enable = true;

  services.udev.extraRules = ''
    # udev rule for user level access to Arduino Uno R4 connected with USB
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", MODE:="0666"

    # make raspberry pi pico accessible without sudo
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", MODE:="0666"
    # SUBSYSTEM!="usb_device", ACTION!="add", GOTO="rpi2_end"
    # Raspberry Pi Pico
    # ATTR{idVendor}=="2e8a", ATTRS{idProduct}=="000f", MODE="660", GROUP="plugdev"
    # LABEL="rpi2_end"

  '';

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            "stop" = "leftmeta";
          };
        };
      };
    };
  };

  services.clamav = {
    updater = {
      enable = true;
      # interval = "hourly";
    };
  };

  # services.protonmail-bridge = {
  #   enable = true;
  #   path = with pkgs; [ gnome-keyring ];
  # };

  # services.ollama.enable = true;
  services.ratbagd.enable = true;
  services.tailscale.enable = true;
  services.flatpak.enable = true;
    # non-declarative steps
      # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      # flatpak update
    # programs installed through flatpak
      # flatseal
      # gaphor
      # blender
        # cursor is wrong even with the workaround...
        # set environment variables in flatseal
          # XCURSOR_SIZE=32
          # XCURSOR_THEME=Bibata_Ghost
      # obsidian
      # logseq
      # kasasa - snip and pin useful information - https://github.com/KelvinNovais/Kasasa
    # right now it flatpak does not use the right font
      # more info: https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts

  # This should enable the right cursor and fonts in flatpak applications
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    aggregatedIcons = pkgs.buildEnv {
      name = "system-icons";
      paths = with pkgs; [
        #libsForQt5.breeze-qt5  # for plasma
        # bibata-cursors-translucent
        comixcursors.Opaque_Black
        comixcursors.Opaque_Slim_Black
        comixcursors.Opaque_White
        comixcursors.Opaque_Slim_White
        vimix-cursors
        bibata-cursors
        gnome-themes-extra
      ];
      pathsToLink = [ "/share/icons" ];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = [ "/share/fonts" ];
    };
  in {
    "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
    "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  # system.stateVersion = "22.11"; # Did you read the comment?

  # home-manager.users.${vars.user} = {
  #   home = {
  #     stateVersion = "22.11";
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
