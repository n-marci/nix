# syncthing configuration
# TODO at some point maybe outsource the id's to a secret file  
# TODO add /dev and /secrets to sync
# TODO reorganise my files
# TODO setup only pull on server
# TODO setup versioning on server

{ config, lib, vars, pkgs, host, ... }:

with lib;
let
  devices-with-phone =
    if host.hostName == "yoga" then [ "inspirion" "marci_helix_a" "marci_helix_b" "marci_desktop" "marci_note" ]
    else if host.hostName == "desktop" then [ "inspirion" "marci_helix_a" "marci_helix_b" "marci_yoga" "marci_note" ]
    else if host.hostName == "helix_a" then [ "inspirion" "marci_helix_b" "marci_desktop" "marci_yoga" "marci_note" ]
    else if host.hostName == "helix_b" then [ "inspirion" "marci_helix_a" "marci_desktop" "marci_yoga" "marci_note" ]
    else if host.hostName == "inspirion" then [ "marci_helix_a" "marci_helix_b" "marci_desktop" "marci_yoga" "marci_note" ]
    else [];

  devices-without-phone = 
    if host.hostName == "yoga" then [ "inspirion" "marci_helix_a" "marci_helix_b" "marci_desktop" ]
    else if host.hostName == "desktop" then [ "inspirion" "marci_helix_a" "marci_helix_b" "marci_yoga" ]
    else if host.hostName == "helix_a" then [ "inspirion" "marci_helix_b" "marci_desktop" "marci_yoga" ]
    else if host.hostName == "helix_b" then [ "inspirion" "marci_helix_a" "marci_desktop" "marci_yoga" ]
    else if host.hostName == "inspirion" then [ "marci_helix_a" "marci_helix_b" "marci_desktop" "marci_yoga" ]
    else [];

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
          "inspirion" = { id = "cat ${config.sops.secrets.sync-id-inspirion.path}"; };
          "marci_helix_b" = { id = "cat ${config.sops.secrets.sync-id-helix-b.path}"; };
          "marci_helix_a" = { id = "cat ${config.sops.secrets.sync-id-helix-a.path}"; };
          "marci_desktop" = { id = "cat ${config.sops.secrets.sync-id-desktop.path}"; };
          "marci_yoga" = { id = "cat ${config.sops.secrets.sync-id-yoga.path}"; };
          "marci_note" = { id = "cat ${config.sops.secrets.sync-id-note.path}"; };
        };
        folders = {
          "wallpapers" = {
            path = "/home/marci/Pictures/wallpapers";
            devices = devices-with-phone;
          };
          "obsidian" = {
            path = "/home/marci/sync/obsidian";
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
            path = "/home/marci/logseq";
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
            path = "/home/marci/sync/live";
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
            path = "/home/marci/sync/linux";
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
            path = "/home/marci/sync/idle";
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
            path = "/home/marci/sync/archive";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "nix" = {
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
          "dev" = {
            path = "/home/marci/dev";
            devices = devices-without-phone;
            versioning = mkIf (config.syncthing.versioning) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "secrets" = {
            path = "/home/marci/secrets";
            devices = devices-with-phone;
          };
        };
      };
    };

    home-manager.users.${vars.user} = {
      home.file."sync/obsidian/.stignore".text = ''
        .obsidian
      ''; # setup ignore file for obsidian
      # home.file."nix/.stignore".text = ''
      #   .sops.yaml
      # ''; # setup ignore file for nix
    };
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
