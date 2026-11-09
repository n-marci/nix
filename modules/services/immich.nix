# immich config

{ config, pkgs, lib, name, hosts, service-dir, snapshot-dir, backup-dir, private, ... }:

let
  cfg = config.marci.services.immich;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault mkOverride types elem;
  database-directory = "var/lib/postgresql";
  db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.immich = {
    enable = mkEnableOption "Enable immich";

    nodes = {
      service = mkOption {
        type = types.listOf types.str;
        default = [ "inspirion" ];
      };

      storage = mkOption {
        type = types.listOf types.str;
        default = [ "linc-n2" ];
      };

      backup = mkOption {
        type = types.listOf types.str;
        default = [ "helix-s" ];
      };
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    services.immich = mkIf (elem name cfg.nodes.service) {
      enable = true;
      environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
      openFirewall = true;
      host = "0.0.0.0";
    };

  ##############################################################################
  # POSTGRES
  ##############################################################################

    # pinned: a major version change needs a pg_upgrade (see docs/inspirion-2026-11.md)
    services.postgresql.package = mkIf (elem name cfg.nodes.service) (mkOverride 998 pkgs.postgresql_18);

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = mkIf (elem name cfg.nodes.service) {
      enable = mkDefault true;
      virtualHosts = {
        "immich.${private.domains.home}" = {
          forceSSL = true;
          useACMEHost = "${private.domains.home}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:2283";
            # clientMaxBodySize = "1G";
            extraConfig = ''
              client_max_body_size 1G;
            '';
          };
          # # For the moment I have it configured globally
          # # should also work with this config though
        };
      };
    };

  ##############################################################################
  # SUBVOLUMES
  ##############################################################################

    marci.subvolumes.paths = mkIf (elem name cfg.nodes.service) {
      ${config.services.immich.mediaLocation} = {
        requiredBy = [ "immich-server.service" ];
        owner = "immich";
        group = "immich";
        mode = "0700";
      };
    };

  ##############################################################################
  # POSTGRES DB EXPORT
  ##############################################################################

    # services.postgresqlBackup = mkIf (cfg.backup.enable && (name == cfg.host)) {
    services.postgresqlBackup = mkIf (elem name cfg.nodes.service) {
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

    fleet.btrbk = {
      enable = true;

      instances."immich".settings = mkIf (elem name cfg.nodes.service) {
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

      target = mkIf (elem name cfg.nodes.backup) true;
    };

  };
}
