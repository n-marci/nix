# 
# Gnome configuration
# Enable with "gnome.enable = true;"
#

# TODO add keyboard shortcuts for run-or-raise extension
  # gaphor
  # floorp
  # blender (flatpak)
  # change current shortcuts to run-or-raise as well
# TODO generate ~/.config/run-or-raise/shortcuts.conf declaratively
# TODO go through extension settings again

{config, lib, pkgs, unstable, vars, host, ...}:

with lib; 
with host; {
  options = {
    gnome = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.gnome.enable) {
    programs = {
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };

      nautilus-open-any-terminal = {
        enable = true;
        terminal = "ptyxis";
      };
    };

    services = {
      xserver = {
        enable = true;

        xkb.layout = "us,de";

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      gnome.gnome-remote-desktop.enable = true; # enable remote desktop using pipewire
    };

    networking.firewall.allowedTCPPorts = [ 5900 3389 ]; # open ports for remote desktop?

    security.sudo.extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ${pkgs.coreutils-full}/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\:??/conservation_mode
    '';
    
    environment = {
      systemPackages = with pkgs; [      # I have to use stable pkgs here, otherwise there were problems
        nautilus-python            # with integration of nautilus-python for example
        gnome-tweaks
        dconf-editor
        adw-gtk3
        gettext           # needed for battery-charging-health and also ideapad controls extensions
      ];
      gnome.excludePackages = (with pkgs; [
        gnome-tour
        gnome-photos
        gnome-console
      ]) ++ (with pkgs; [
        epiphany
        geary
        gnome-contacts
        gnome-initial-setup
        yelp
        gnome-music
      ]);
    };

    home-manager.users.${vars.user} =
    let
      battery-opt =
        if hostName == "yoga" then "ideapad@laurento.frittella"
        else if hostName == "helix" then "thinkpad-battery-threshold@marcosdalvarez.org"
        else "";
    in {
      dconf.settings = {
        "org/gnome/shell" = {
          favorite-apps = [
            # "brave-browser.desktop"
            # "firefox.desktop"
            # "librewolf.desktop"
            "librewolf.desktop"
            "thunderbird.desktop"
            "spotify.desktop"
            "org.gnome.Nautilus.desktop"
            # "org.gnome.Console.desktop"
            # "com.raggesilver.BlackBox.desktop"
            "org.gnome.Ptyxis.desktop"
            "md.obsidian.Obsidian.desktop"
            "com.github.xournalpp.xournalpp.desktop"
            "org.gnome.Evince.desktop"
            "zotero.desktop"
          ];

          # disable-user-extensions = false;
          enabled-extensions = [
            "grand-theft-focus@zalckos.github.com"
            "gsconnect@andyholmes.github.io"
            "pano@elhan.io" # removed bc build problems - add again next build
            # "clipboard-indicator@tudmotu.com"
            "windowgestures@extension.amarullz.com"
            "gjsosk@vishram1123.com"
            # "gestureImprovements@gestures"
            "caffeine@patapon.info"
            "${battery-opt}"
            "run-or-raise@edvard.cz"
            "tilingshell@ferrarodomenico.com"
            "system-monitor@gnome-shell-extensions.gcampax.github.com"
          ];
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "yellow";
          enable-hot-corners = false;
          clock-show-seconds = true;
          show-battery-percentage = true;
          gtk-theme = "adw-gtk3";

          # gnome tweaks settings
          # cursor-theme = "Bibata_Ghost";
          cursor-theme = "ComixCursors-Opaque-Black";
          cursor-size = 32;
          font-name = "Montserrat 11";
          document-font-name = "Montserrat 11";
          monospace-font-name = "IntelOne Mono 10";
          titlebar-font = "Montserrat Bold 11";
        };

        "org/gnome/desktop/wm/preferences" = {
          resize-with-right-button = true;
        };

        "org/gnome/mutter" = {
          edge-tiling = true;
          dynamic-workspaces = true;
          workspaces-only-on-primary = true;
        };

        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 0.73;
        };
        
        "org/gnome/desktop/peripherals/touchpad" = {
          accel-profile = "default";
          speed = 0.3;
          tap-to-click = true;
        };

        "org/gnome/desktop/sound" = {
          allow-volume-above-100-percent = true;
          event-sounds = false;
        };

        "org/gtk/gtk4/settings/file-chooser" = {
           sort-directories-first = true;
        };

        "org/freedesktop/tracker/miner/files" = {
          index-recursive-directories = [
            "&DESKTOP"
            "&DOCUMENTS"
            "&MUSIC"
            "&PICTURES"
            "&VIDEOS"
            "/home/marci/sync"
          ];
        };

        # IMPERATIVELY setup wireguard in network manager with config file in secrets folder

        # IMPERATIVELY set the keyboard language
        # this does not seem to work :(
        # "org/gnome/desktop/input-sources" = {
        #   sources = ''
        #     [('xkb', 'de'), ('xkb', 'us')]
        #   '';
        # };

        "org/gnome/settings-daemon/plugins/power" = {
          ambient-enabled = false;                   # disable automatic screen brightness
        };

        # keyboard shortcuts
        "org/gnome/settings-daemon/plugins/media-keys" = {
          rotate-video-lock-static = ["X86RotationLockToggle"];    # disable super+o -> rotate-video-lock-static

          # home = ["<Shift><Super>f"];

          custom-keybindings = [
            # "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          ];
        };

        # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        #   binding = "<Shift><Super>t";
        #   command = "blackbox";
        #   name = "launch additional terminal windows";
        # };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>r";
          command = "/home/marci/sync/linux/scripts/speak_en.sh";
          name = "read out loud in english";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<Super>w";
          command = "/home/marci/sync/linux/scripts/ai_explain.sh";
          name = "ai pls explain";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          binding = "<Super>g";
          command = "/home/marci/sync/linux/scripts/run-selection.sh";
          name = "xdg open";
        };

        "org/gnome/mutter/keybindings" = {
          switch-monitor = ["@as []"];               # disable super+p
        };

        "org/gnome/shell/keybindings" = {
          toggle-overview = ["@as []"];              # disable super+s -> show the overview
          toggle-quick-settings = ["@as []"];        # now super+s is quick settings? -> disable aswell
          toggle-message-tray = ["@as []"];          # disable super+v
          focus-active-notification = ["@as []"];
          switch-to-application-1 = ["@as []"];      # disable super+1
          switch-to-application-2 = ["@as []"];      # disable super+2
          switch-to-application-3 = ["@as []"];      # disable super+3
          switch-to-application-4 = ["@as []"];      # disable super+4
          switch-to-application-5 = ["@as []"];      # disable super+5
          switch-to-application-6 = ["@as []"];      # disable super+6

          # switch-to-application-1 = ["<Super>b"];    # browser
          # switch-to-application-2 = ["<Super>e"];    # thunderbird email
          # switch-to-application-3 = ["<Super>m"];    # spotify
          # switch-to-application-4 = ["<Super>f"];    # files
          # switch-to-application-5 = ["<Super>t"];    # terminal / console
          # switch-to-application-6 = ["<Super>o"];    # obsidian
          # switch-to-application-7 = ["<Super>n"];    # xournal++
          # switch-to-application-8 = ["<Super>p"];    # evince pdf viewer
          # switch-to-application-9 = ["<Super>z"];    # zotero
        };

        "org/gnome/desktop/wm/keybindings" = {
          minimize = ["@as []"];                     # disable super+h
        
          switch-to-workspace-1 = ["<Super>1"];
          switch-to-workspace-2 = ["<Super>2"];
          switch-to-workspace-3 = ["<Super>3"];
          switch-to-workspace-4 = ["<Super>4"];
          switch-to-workspace-5 = ["<Super>5"];
          switch-to-workspace-6 = ["<Super>6"];

          lower = ["<Super>d"];
          raise = ["<Super>u"];
          close = ["<Super>q"];
          maximize-horizontally = ["<Super>x"];
          maximize-vertically = ["<Super>y"];
          always-on-top = ["<Super>s"];
        };

        # TODO test out espresso extension instead - is it simpler or can i change screen dim behavior
        "org/gnone/shell/extensions/caffeine" = {
          enable-fullscreen = false;
          show-indicator = "only-active";
          show-notifications = false;
        };

        "org/gnome/shell/extensions/windowgestures" = {
          three-finger = true;
          use-active-window = false;
          # taphold-move = true;
          swipe4-left = 5;
          swipe4-right = 4;
          swipe3-left = 7;
          swipe3-right = 6;
        };

        # gesture improvements still missing
        # because i am not sure if i will keep it

        # ideapad controls disabled for now
        # "org/gnone/shell/extensions/ideapad-controls" = {
        #   tray-location = false;
        # };

        "org/gnone/shell/extensions/pano" = {
          global-shortcut = ["<Super>v"];
          paste-on-select = false;
          send-notification-on-copy = false;
          play-audio-on-copy = false;
          history-length = 250;
        };

        "org/gnome/shell/extensions/clipboard-indicator" = {
          history-size = 50;
        };

        "system/locale" = {
          region = "de_DE.UTF-8";
        };
      };

      # setup the shortcuts.conf file for run-or-raise
      home.file.".config/run-or-raise/shortcuts.conf".text = ''
        <Super>b,librewolf,,
        <Super>e,thunderbird,,
        <Super>m,spotify.desktop,"",Spotify Premium
        <Super>f,nautilus,,
        <Super><Shift>f,nautilus
        <Super>t,ptyxis,,
        <Super><Shift>t,ptyxis --new-window
        <Super>o,md.obsidian.Obsidian.desktop,,
        <Super>n,xournalpp,,
        <Super><Shift>n,xournalpp
        <Super>p,evince,,
        <Super>z,zotero,,
        <Super>k:raise-or-register(0)
        <Super>h:raise-or-register(1)
      '';

      home.packages = with pkgs.gnomeExtensions; [
        grand-theft-focus
        gsconnect
        pano # removed bc build problems - add again next build 
        # clipboard-indicator
        window-gestures
        # gesture-improvements
        gjs-osk
        caffeine
        # battery-health-charging    # installing this on top outside home manager to see if this fixes problem (polkit rule not applying)
        # ideapad-controls
        ideapad
        thinkpad-battery-threshold
        run-or-raise
        # tiling shell is not in nix repos - I downloaded it from the extensions manager
      ];
    };
  };
}
