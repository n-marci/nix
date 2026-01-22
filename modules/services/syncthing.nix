# syncthing config

{ config, lib, user, pkgs, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.syncthing;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem;
  inherit (builtins) filter concatLists;
in
{
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.syncthing = {
    enable = mkEnableOption "Enable configuration for syncthing service";

    homes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of devices which should be configured as end user devices";
    };

    servers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of devices which should be configured as server devices with versioning and backup";
    };

    phones = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of devices which should be configured as phones";
    };

    whatsapp = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of devices which should be configured as a whatsapp device";
    };

    folders = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of folders which should be shared";
    };

    backup = {
      enable = mkEnableOption "Enable backup for syncthing directories";

      target = mkOption {
        type = types.str;
        default = "helix-s";
      };
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) (
  let
    # devices = filter (x: x != "${name}") (concatLists [ cfg.homes cfg.servers cfg.other ]); # concatenete together all devices in the mesh and filter out the host
    devices = (concatLists [ cfg.homes cfg.servers cfg.phones cfg.whatsapp ]);
    path =
      if (elem "${name}" cfg.homes) then "/home/${user}"
      else if (elem "${name}" cfg.servers) then "/${service-dir}/syncthing"
      else "/home/${user}";
  in
  {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true; # open firewall
      user = user;
      dataDir = path;
      # configDir = "/home/${user}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets.syncthing-key.path;
      cert = config.sops.secrets.syncthing-cert.path;
      settings = {
  
    ##############################################################################
    # DEVICES
    ##############################################################################

        devices = {
          "inspirion" = { id = hosts.inspirion.sync-id; };
          # "marci_helix_b" = { id = sync-ids.helix-b; };
          "helix-s" = { id = hosts.helix-s.sync-id; };
          "unicorn" = { id = hosts.unicorn.sync-id; };
          "yoga" = { id = hosts.yoga.sync-id; };
          "note-9" = { id = hosts.note-9.sync-id; };
          "s20-plus" = { id = hosts.s20-plus.sync-id; };
          "s20-plus-wa" = { id = hosts.s20-plus-wa.sync-id; };
        };

    ##############################################################################
    # FOLDERS
    ##############################################################################

        folders = {

      ##############################################################################
      # NIX
      ##############################################################################

          "nix" = mkIf (elem "nix" cfg.folders && elem "${name}" devices) {
            path = "${path}/nix";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones ]);
          };

      ##############################################################################
      # SECRETS
      ##############################################################################

          "secrets" = mkIf (elem "secrets" cfg.folders && elem "${name}" devices) {
            path = "${path}/secrets";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones ]);
          };

      ##############################################################################
      # WALLPAPERS
      ##############################################################################

          "wallpapers" = mkIf (elem "wallpapers" cfg.folders && elem "${name}" devices) {
            path =
              if (elem "${name}" cfg.homes) then "${path}/Pictures/wallpapers"
              else if (elem "${name}" cfg.servers) then "${path}/wallpapers"
              else "${path}/Pictures/wallpapers";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones cfg.whatsapp ]);
          };

      ##############################################################################
      # OBSIDIAN
      ##############################################################################

          "obsidian" = mkIf (elem "obsidian" cfg.folders && elem "${name}" devices) {
            path = "${path}/obsidian";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones ]);
            versioning = mkIf (elem "${name}" cfg.servers) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };

      ##############################################################################
      # LOGSEQ
      ##############################################################################

          "logseq" = mkIf (elem "logseq" cfg.folders && elem "${name}" devices) {
            path = "${path}/logseq";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones ]);
            versioning = mkIf (elem "${name}" cfg.servers) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };

      ##############################################################################
      # PHONE
      ##############################################################################

          "phone" = mkIf (elem "phone" cfg.folders && elem "${name}" devices) {
            path = "${path}/phone";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones ]);
            versioning = mkIf (elem "${name}" cfg.servers) {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };

      ##############################################################################
      # SIGNAL
      ##############################################################################

          "signal" = mkIf (elem "signal" cfg.folders && elem "${name}" devices) {
            path = "${path}/signal";
            devices = (concatLists [ cfg.homes cfg.servers cfg.phones ]);
          };

      ##############################################################################
      # WHATSAPP
      ##############################################################################

          "whatsapp" = mkIf (elem "whatsapp" cfg.folders && elem "${name}" devices) {
            path = "${path}/whatsapp";
            devices = (concatLists [ cfg.homes cfg.servers cfg.whatsapp ]);
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
    # systemd.tmpfiles.rules = mkIf (elem "${name}" cfg.servers) [
    #   "f /var/lib/syncthing/obsidian/.stignore 755 marci syncthing"
    #   "w /var/lib/syncthing/obsidian/.stignore - - - - .obsidian"
    # ];

    ##############################################################################
    # DISKO
    ##############################################################################

    # TODO

  ##############################################################################
  # BTRFS ON HOST
  ##############################################################################

    fleet.btrbk = mkIf (cfg.backup.enable) {
      enable = true;

      instances."btrbk".settings = mkIf (elem "${name}" cfg.servers)  {
        volume."/".subvolume = {
          "${service-dir}/syncthing" = {
            snapshot_create = "always";
          };
          snapshot_dir = "/${snapshot-dir}/syncthing";
          target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/syncthing";
        };
      };

  ##############################################################################
  # BTRFS ON TARGET
  ##############################################################################

      target = mkIf (name == cfg.backup.target) true;
    };

  });
}
