# paperless config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.paperless;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.paperless = {
    enable = mkEnableOption "Enable paperless";

    backup = mkOption {
      type = types.bool;
      default = false;
    };

    backupTarget = mkOption {
      type = types.str;
      default = "helix-s";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    services.paperless = {
      enable = true;
      port = 28981;
      address = "0.0.0.0"; # default is localhost - 0.0.0.0 makes the instance available in the whole network
      settings = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_ADMIN_USER = "caesar";
        # PAPERLESS_DEBUG = "true";
        PAPERLESS_URL = "https://paperless.marcelnet.com";
      };
      passwordFile = config.sops.secrets.paperless-pass.path;

      # database.createLocally = true; # creates postgresql database - maybe transition at some point
    };

  ##############################################################################
  # SAMBA
  ##############################################################################

    # NON DECLARITIVE SETUP : run 'sudo smbpasswd -a paperless-consume' once
    
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "invalid users" = [
            "root"
          ];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          security = "user";
        };

        paperless-consume = {
          path = "/var/lib/paperless/consume";
          "valid users" = "paperless-consume";
          "create mask" = "0664";
          "directory mask" = "2775";
          browseable = "yes";
          "guest ok" = "no";
          "read only" = "no";
          comment = "private samba share for the paperless consume directory";
        };
      };
    };

    systemd.tmpfiles.rules = [ # had to set it manually in existing setup - this should set it declaratively
      "d /var/lib/paperless/consume 2775 paperless paperless - -"
    ];

    # --- SAMBA USER ---

    users.users.paperless-consume = {
      name = "paperless-consume";
      group = "paperless-consume";
      extraGroups = [ "paperless" ];
      isSystemUser = true;
    };
    users.groups.paperless-consume = { };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = {
      enable = mkDefault true;
      virtualHosts = {
        "paperless.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://127.0.0.1:28981";
        };
      };
    };

  ##############################################################################
  # SECRETS
  ##############################################################################

    sops.secrets.paperless-pass = { };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # POSTGRES DB EXPORT
  ##############################################################################

    # services.postgresqlBackup = mkIf (config.fleet.paperless.backup) {
    #   enable = true;
    #   startAt = "*-*-* 03:05:00";
    #   location = "/${db-export-directory}";
    #   databases = [ "paperless" ];
    # };

  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO
  
  ##############################################################################
  # BTRFS
  ##############################################################################

    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (cfg.backup) {
      "${service-dir}/paperless" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/paperless";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/paperless";
      };
      # "${database-directory}" = {
      #   snapshot_create = "always";
      #   snapshot_dir = "/${snapshot-dir}/paperless";
      #   target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/paperless";
      # };
      # "${db-export-directory}" = {
      #   snapshot_create = "always";
      #   snapshot_dir = "/${snapshot-dir}/paperless";
      #   target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/paperless";
      # };
    };
  };
}
