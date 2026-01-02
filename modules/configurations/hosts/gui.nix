{ pkgs, stable, ... }:

{
  ##############################################################################
  # FLEET
  ##############################################################################

  fleet = {
    gnome.enable = true;
    virtualisation.enable = true;
    fonts.enable = true;
    flatpak = {
      enable = true;
      # gnome = true;
    };
    graphics.enable = true;
    audio.enable = true;
    printer.enable = true;
  };

  ##############################################################################
  # LOGITECH MOUSE
  ##############################################################################

  services.ratbagd.enable = true;

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

  ##############################################################################
  # NIX
  ##############################################################################

  nix = {
    gc.options = "--delete-older-than 7d";
  };

  ##############################################################################
  # BLUETOOTH
  ##############################################################################

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  ##############################################################################
  # PKGS
  ##############################################################################

  environment.systemPackages = (with pkgs; [

    ###################
    # playground
    ###################

    # kando # also need to add gnomeExtensions.kando-integration
    
    ###################
    # cli tools
    ###################
    
    pdfgrep
    wl-clipboard
    mpv
    ttyper
    ntfs3g
    ghostscript
    imagemagick
    ffmpeg
    fzf
    zellij
    colmena

    translate-shell  # move to script if i write a nixpkg for it
    # python311Packages.gtts
    python312Packages.langid
    keyd  # key remapper for my sweet super key on the mouse button
    piper-tts

    shell-gpt
    aichat
    # llm
    inotify-tools
    # waypipe
    mesa

    ###################
    # eye candy cli
    ###################

    # cli-visualizer  # it is no longer available on github :((
    scope-tui

    ###################
    # language servers
    ###################
    
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

    ###################
    # virtualisation
    ###################

    distrobox
    virt-manager
    winboat # windows apps
    freerdp

    ###################
    # terminals 
    ###################

    gnome-terminal
    ptyxis
    ghostty
    alacritty

    ###################
    # images
    ###################
    
    inkscape
    gimp
    oculante
    drawio
    gradia

    ###################
    # audio
    ###################
    
    spotify
    # helvum
    qpwgraph
    alsa-lib
    alsa-utils

    ###################
    # documents
    ###################
    
    libreoffice-still
    xournalpp
    rnote                  # https://github.com/flxzt/rnote
    zotero
    papers
    gscan2pdf
    naps2 # scanning application - wanted to try it out instead of gscan2pdf

    ###################
    # browser
    ###################
    
    brave
    firefox
    librewolf

    ###################
    # engineering
    ###################

    kicad-small
    simulide

    # LLMs
    # newelle
    
    ###################
    # gui program
    ###################

    thunderbird
    remmina
    keepassxc
    gnome-extension-manager
    # freecad
    # alpaca
    # (blender.override {
    #   cudaSupport = true;
    # })
    kdePackages.kasts
    
    ###################
    # cursors
    ###################

    comixcursors.Opaque_Black
    bibata-cursors-translucent
    
  ]) ++ (with stable; [
    htop # dummy pkg so I can have stable pkgs
    
    ###################
    # build problems in unstable
    ###################

    # gscan2pdf
    
    ###################
    # source build in unstable
    ###################

    # ...
  ]);

}
