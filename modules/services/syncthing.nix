# syncthing configuration
# TODO at some point maybe outsource the id's to a secret file  
# TODO add /dev and /secrets to sync
# TODO reorganise my files
# TODO setup only pull on server
# TODO setup versioning on server

{ config, lib, user, pkgs, name, hosts, ... }:

with lib;
let
  devices-with-phone =
    if name == "yoga" then [ "inspirion" "helix-s" "marci_desktop" "marci_note" "s20-plus" ]
    else if name == "desktop" then [ "inspirion" "helix-s" "marci_yoga" "marci_note" "s20-plus" ]
    else if name == "helix-s" then [ "inspirion" "marci_desktop" "marci_yoga" "marci_note" "s20-plus" ]
    # else if name == "helix_b" then [ "inspirion" "marci_helix_s" "marci_desktop" "marci_yoga" "marci_note" ]
    else if name == "inspirion" then [ "helix-s" "marci_desktop" "marci_yoga" "marci_note" "s20-plus" ]
    else [];

  devices-without-phone = 
    if name == "yoga" then [ "inspirion" "helix-s" "marci_desktop" "s20-plus" ]
    else if name == "desktop" then [ "inspirion" "helix-s" "marci_yoga" "s20-plus" ]
    else if name == "helix-s" then [ "inspirion" "marci_desktop" "marci_yoga" "s20-plus" ]
    # else if name == "helix_b" then [ "inspirion" "marci_helix_a" "marci_desktop" "marci_yoga" ]
    else if name == "inspirion" then [ "helix-s" "marci_desktop" "marci_yoga" "s20-plus" ]
    else [];

  # sync-ids = import "${secrets}/syncthing-ids.nix";
in {
  options = {
    fleet.syncthing = {
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
  
  config = mkIf (config.fleet.syncthing.enable) {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true; # open firewall
      user = user;
      dataDir = "/home/${user}/sync";
      configDir = "/home/${user}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets.syncthing-key.path;
      cert = config.sops.secrets.syncthing-cert.path;
      settings = {
        devices = {
          "inspirion" = { id = hosts.inspirion.sync-id; };
          # "marci_helix_b" = { id = sync-ids.helix-b; };
          "helix-s" = { id = hosts.helix-s.sync-id; };
          "marci_desktop" = { id = hosts.desktop.sync-id; };
          "marci_yoga" = { id = hosts.yoga.sync-id; };
          "marci_note" = { id = hosts.note-9.sync-id; };
          "s20-plus" = { id = hosts.s20-plus.sync-id; };
        };
        folders = {
          "wallpapers" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/wallpapers"
              else "/home/marci/Pictures/wallpapers";
            devices = devices-with-phone;
          };
          "obsidian" = {
            # path = "/home/marci/sync/obsidian";
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/obsidian"
              else "/home/marci/sync/obsidian";
            devices = devices-with-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "logseq" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/logseq"
              else "/home/marci/logseq";
            devices = devices-with-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "live" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/live"
              else "/home/marci/sync/live";
            devices = devices-without-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "linux" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/linux"
              else "/home/marci/sync/linux";
            devices = devices-without-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "idle" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/idle"
              else "/home/marci/sync/idle";
            devices = devices-without-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "archive" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/archive"
              else "/home/marci/sync/archive";
            devices = devices-without-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "dev" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/dev"
              else "/home/marci/dev";
            devices = devices-without-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "phone" = {
            path =
              if config.fleet.syncthing.storeInBackupLocation then "/var/lib/syncthing/phone"
              else "/home/marci/phone";
            devices = devices-with-phone;
            versioning = mkIf (config.fleet.syncthing.versioning) {
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
            versioning = mkIf (config.fleet.syncthing.versioning) {
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

    ##############################################################################
    # SOPS-NIX SECRETS
    ##############################################################################

    sops = {
      secrets.syncthing-key = { };
      secrets.syncthing-cert = { };
    };

    ##############################################################################
    # IGNORE FILES
    ##############################################################################

    # home-manager.users.${user} = mkIf (config.fleet.syncthing.storeInBackupLocation == false) {
    #   home.file."sync/obsidian/.stignore".text = '' 
    #     .obsidian
    #   '';
    # };
    systemd.tmpfiles.rules = mkIf (config.fleet.syncthing.storeInBackupLocation) [
      "f /var/lib/syncthing/obsidian/.stignore 755 marci syncthing"
      "w /var/lib/syncthing/obsidian/.stignore - - - - .obsidian"
    ];
  };
}
