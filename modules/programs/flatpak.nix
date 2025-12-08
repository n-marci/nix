# flatpak config

{ config, lib, pkgs, ... }:

let
  cfg = config.fleet.flatpak;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.flatpak = {
    enable = mkEnableOption "Enable flatpak application usage";

    apps = mkOption {
      type = types.listOf types.str;
      default = [
        "app.zen_browser.zen"
        "com.github.tchx84.Flatseal"
        "io.github.kelvinnovais.Kasasa"
        "io.github.qwersyk.Newelle"
        "md.obsidian.Obsidian"
        "org.blender.Blender"
        "org.gaphor.Gaphor"
        "space.gaiasky.GaiaSky"
        "org.gtk.Gtk3theme.adw-gtk3"
      ];
      description = "my default flatpak apps";
    };

    # gnome = mkOption {
    #   type = types.bool;
    #   default = config.fleet.gnome.enable;
    # };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    fonts.fontDir.enable = true; # needed for flatpak to use the right cursor and fonts
    services.flatpak.enable = true;
    # non-declarative steps (only needed without the nix-flatpak module)
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
    
    # Required to install flatpak - apparently - never used it before the nix-flatpak module
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
      extraPortals = with pkgs; [
        # xdg-desktop-portal-wlr
        # xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
    };

  ##############################################################################
  # nix-flatpak module
  ##############################################################################

    services.flatpak = {
      packages = cfg.apps;

      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };

      overrides = {
        global = {
          Environment = {
            # Force Wayland by default
            # Context.sockets = [ "wayland" "!x11" "!fallback-x11" ];
            Context = [ "wayland" "!x11" "!fallback-x11" ];
            # Context = [ "wayland" "/nix/store:ro" ];

            # Fix un-themed cursor in some Wayland apps
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
            # XCURSOR_SIZE= "32";
            # XCURSOR_THEME= "Bibata_Ghost";

            # Force correct theme for some GTK apps
            # GTK_THEME = "Adwaita:dark";
            # GTK_THEME = "Adw-gtk3";
          };
        };

        # # example for per app configuration
        # "com.visualstudio.code".Context = {
        #   filesystems = [
        #     "xdg-config/git:ro" # Expose user Git config
        #     "/run/current-system/sw/bin:ro" # Expose NixOS managed software
        #   ];
        #   sockets = [
        #     "gpg-agent" # Expose GPG agent
        #     "pcsc" # Expose smart cards (i.e. YubiKey)
        #   ];
        # };

        # "org.onlyoffice.desktopeditors".Context.sockets = ["x11"]; # No Wayland support
      };
    };

  ##############################################################################
  # GNOME WORKAROUND
  ##############################################################################

    # This should enable the right cursor and fonts in flatpak applications
    # system.fsPackages = mkIf (cfg.gnome) [ pkgs.bindfs ];
    # fileSystems = let mkRoSymBind = path: {
    #     device = path;
    #     fsType = "fuse.bindfs";
    #     options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    #   };
    #   aggregatedIcons = pkgs.buildEnv {
    #     name = "system-icons";
    #     paths = with pkgs; [
    #       #libsForQt5.breeze-qt5  # for plasma
    #       # bibata-cursors-translucent
    #       comixcursors.Opaque_Black
    #       comixcursors.Opaque_Slim_Black
    #       comixcursors.Opaque_White
    #       comixcursors.Opaque_Slim_White
    #       vimix-cursors
    #       bibata-cursors
    #       gnome-themes-extra
    #     ];
    #     pathsToLink = [ "/share/icons" ];
    #   };
    #   aggregatedFonts = pkgs.buildEnv {
    #     name = "system-fonts";
    #     paths = config.fonts.packages;
    #     pathsToLink = [ "/share/fonts" ];
    #   };
    # in {
    #   "/usr/share/icons" = mkIf (cfg.gnome) mkRoSymBind "${aggregatedIcons}/share/icons";
    #   "/usr/local/share/fonts" = mkIf (cfg.gnome) mkRoSymBind "${aggregatedFonts}/share/fonts";
    # };
  };
}
