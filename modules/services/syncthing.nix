# syncthing configuration
# TODO at some point maybe outsource the id's to a secret file  
# TODO add /dev and /secrets to sync
# TODO reorganise my files
# TODO setup only pull on server
# TODO setup versioning on server

{ config, lib, vars, pkgs, host, secrets, ... }:

with lib;
let
  devices-with-phone =
    if host.hostName == "yoga" then [ "inspirion" "helix-s" "marci_desktop" "marci_note" "s20-plus" ]
    else if host.hostName == "desktop" then [ "inspirion" "helix-s" "marci_yoga" "marci_note" "s20-plus" ]
    else if host.hostName == "helix-s" then [ "inspirion" "marci_desktop" "marci_yoga" "marci_note" "s20-plus" ]
    # else if host.hostName == "helix_b" then [ "inspirion" "marci_helix_s" "marci_desktop" "marci_yoga" "marci_note" ]
    else if host.hostName == "inspirion" then [ "helix-s" "marci_desktop" "marci_yoga" "marci_note" "s20-plus" ]
    else [];

  devices-without-phone = 
    if host.hostName == "yoga" then [ "inspirion" "helix-s" "marci_desktop" "s20-plus" ]
    else if host.hostName == "desktop" then [ "inspirion" "helix-s" "marci_yoga" "s20-plus" ]
    else if host.hostName == "helix-s" then [ "inspirion" "marci_desktop" "marci_yoga" "s20-plus" ]
    # else if host.hostName == "helix_b" then [ "inspirion" "marci_helix_a" "marci_desktop" "marci_yoga" ]
    else if host.hostName == "inspirion" then [ "helix-s" "marci_desktop" "marci_yoga" "s20-plus" ]
    else [];

  sync-ids = import "${secrets}/syncthing-ids.nix";
in {
  options = {
    syncthing = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      versioning = mkOption {
        type = types.bool;
        default = false;
      };
      storeInBackupLocation = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.syncthing.enable) {
    services.syncthing = {
      enable = true;
      user = "marci";
      dataDir = "/home/marci/sync";
      configDir = "/home/marci/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets.syncthing-key.path;
      cert = config.sops.secrets.syncthing-cert.path;
      settings = {
        devices = {
          "inspirion" = { id = sync-ids.inspirion; };
          # "marci_helix_b" = { id = sync-ids.helix-b; };
          "helix-s" = { id = sync-ids.helix-s; };
          "marci_desktop" = { id = sync-ids.desktop; };
          "marci_yoga" = { id = sync-ids.yoga; };
          "marci_note" = { id = sync-ids.note; };
          "s20-plus" = { id = sync-ids.s20-plus; };
        };
        folders = {
          "wallpapers" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/wallpapers"
              else "/home/marci/Pictures/wallpapers";
            devices = devices-with-phone;
          };
          "obsidian" = {
            # path = "/home/marci/sync/obsidian";
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/obsidian"
              else "/home/marci/sync/obsidian";
            devices = devices-with-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "logseq" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/logseq"
              else "/home/marci/logseq";
            devices = devices-with-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "live" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/live"
              else "/home/marci/sync/live";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "linux" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/linux"
              else "/home/marci/sync/linux";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "idle" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/idle"
              else "/home/marci/sync/idle";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "archive" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/archive"
              else "/home/marci/sync/archive";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "dev" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/dev"
              else "/home/marci/dev";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "phone" = {
            path =
              if config.syncthing.storeInBackupLocation then "/var/lib/syncthing/phone"
              else "/home/marci/phone";
            devices = devices-with-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "nix" = { # for nix I dont make a btrfs backup since it is version controlled by git
            path = "/home/marci/nix";
            devices = devices-with-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "secrets" = { # for secrets I dont make a btrfs backup since it is version controlled by git
            path = "/home/marci/secrets";
            devices = devices-with-phone;
          };
        };
      };
    };

    home-manager.users.${vars.user} = {
      # setup ignore files
      home.file."sync/obsidian/.stignore".text = if (config.syncthing.storeInBackupLocation == false) then '' 
        .obsidian
      ''
      else "";
      # home.file."nix/.stignore".text = ''
      #   .git
      # '';
      # home.file."nix/.gitignore".text = ''
      #   .stignore
      # '';
      # home.file."secrets/.stignore".text = ''
      #   .git
      # '';
    };
    systemd.tmpfiles.rules = if config.syncthing.storeInBackupLocation then [
      "f /var/lib/syncthing/obsidian/.stignore 755 marci syncthing"
      "w /var/lib/syncthing/obsidian/.stignore - - - - .obsidian"
    ]
    else [];
  };


  # config = mkIf (config.syncthing.versioning) {
  #   services.syncthing = {
  #     settings = {
  #       folders = {
  #         "linux" = {
  #           versioning = {
  #             type = "staggered";
  #             params = {
  #               cleanInterval = "3600";
  #               maxAge = "31536000";
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
