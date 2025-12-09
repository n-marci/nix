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

    services.immich = {
      enable = true;
      environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
      openFirewall = true;
      host = "0.0.0.0";
    };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = {
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

    services.postgresqlBackup = mkIf (config.fleet.immich.backup) {
      enable = true;
      startAt = "*-*-* 04:05:00";
      location = "/${db-export-directory}";
      databases = [ "immich" ];
    };

  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO
  
  ##############################################################################
  # BTRFS
  ##############################################################################

    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (cfg.backup) {
      "${service-dir}/immich" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/immich";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/immich";
      };
      "${database-directory}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/immich";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/immich";
      };
      "${db-export-directory}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/immich";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/immich";
      };
    };
  };
}
