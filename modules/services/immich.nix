# immich config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.immich;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
  database-directory = "var/lib/postgresql";
  db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.immich = {
    enable = mkEnableOption "Enable immich";

    host = mkOption {
      type = types.str;
      default = "inspirion";
    };

    backup = {
      enable = mkEnableOption "Enable backup for immich data directory and database";

      target = mkOption {
        type = types.str;
        default = "helix-s";
      };
    };
    # backup = mkOption {
    #   type = types.bool;
    #   default = false;
    # };

    # backupTarget = mkOption {
    #   type = types.str;
    #   default = "helix-s";
    # };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    services.immich = mkIf (name == cfg.host) {
      enable = true;
      environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
      openFirewall = true;
      host = "0.0.0.0";
    };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = mkIf (name == cfg.host) {
      enable = mkDefault true;
      virtualHosts = {
        "immich.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://127.0.0.1:2283";
          # # For the moment I have it configured globally
          # # should also work with this config though
          extraConfig = ''
            client_max_body_size 1G;
          '';
        };
      };
    };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # POSTGRES DB EXPORT
  ##############################################################################

    services.postgresqlBackup = mkIf (cfg.backup.enable && (name == cfg.host)) {
      enable = mkDefault true;
      startAt = "*-*-* 04:05:00";
      location = "/${db-export-directory}";
      databases = [ "immich" ];
    };

  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO mkIf (name == cfg.backupTarget)
  
  ##############################################################################
  # BTRFS ON HOST
  ##############################################################################

    # services.btrbk.instances.immich.settings.volume."/".subvolume = mkIf (cfg.backup.enable && (name == cfg.host)) {
    #   "${service-dir}/immich" = {
    #     snapshot_create = "always";
    #   };
    #   "${database-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   "${db-export-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   snapshot_dir = "/${snapshot-dir}/immich";
    #   target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/immich";
    # };

    fleet.btrbk = mkIf (cfg.backup.enable) {
      enable = true;

      instances."immich".settings = mkIf (name == cfg.host) {
        volume."/".subvolume = {
          "${service-dir}/immich" = {
            snapshot_create = "always";
          };
          "${database-directory}" = {
            snapshot_create = "always";
          };
          "${db-export-directory}" = {
            snapshot_create = "always";
          };
          snapshot_dir = "/${snapshot-dir}/immich";
          target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/immich";
        };
      };

  ##############################################################################
  # BTRFS ON TARGET
  ##############################################################################

      target = mkIf (name == cfg.backup.target) true;
    };

  };
}
