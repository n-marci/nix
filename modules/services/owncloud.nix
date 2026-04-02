# owncloud config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.owncloud;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem;
  # database-directory = "var/lib/postgresql";
  # db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.owncloud = {
    enable = mkEnableOption "Enable owncloud";

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

    services.ocis = mkIf (elem name cfg.nodes.service) {
      enable = true;
      url = "https://owncloud.marcelnet.com";
      address = "0.0.0.0";
      # port = 9200;
      environment = {
        PROXY_TLS = "false";
        OWNCLOUD_OVERWRITE_PROTOCOL = "https";
      };
    };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = mkIf (elem name cfg.nodes.service) {
      enable = mkDefault true;
      virtualHosts = {
        "owncloud.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/" = {
            proxyPass = "http://127.0.0.1:9200";
            extraConfig = ''
              client_max_body_size 1G;

              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };

    networking.firewall.allowedUDPPorts = [ 9200 ]; # not sure if needed - just trying out
    networking.firewall.allowedTCPPorts = [ 9200 ]; # not sure if needed - just trying out
  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # POSTGRES DB EXPORT
  ##############################################################################

    # services.postgresqlBackup = mkIf (cfg.backup.enable && (name == cfg.host)) {
    # services.postgresqlBackup = mkIf (elem name cfg.nodes.service) {
    #   enable = mkDefault true;
    #   startAt = "*-*-* 04:05:00";
    #   location = "/${db-export-directory}";
    #   databases = [ "owncloud" ];
    # };

  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO mkIf (name == cfg.backupTarget)
  
  ##############################################################################
  # BTRFS ON HOST
  ##############################################################################

    # services.btrbk.instances.owncloud.settings.volume."/".subvolume = mkIf (cfg.backup.enable && (name == cfg.host)) {
    #   "${service-dir}/owncloud" = {
    #     snapshot_create = "always";
    #   };
    #   "${database-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   "${db-export-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   snapshot_dir = "/${snapshot-dir}/owncloud";
    #   target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/owncloud";
    # };

  #   fleet.btrbk = {
  #     enable = true;

  #     instances."owncloud".settings = mkIf (elem name cfg.nodes.service) {
  #       volume."/".subvolume = {
  #         "${service-dir}/owncloud" = {
  #           snapshot_create = "always";
  #         };
  #         "${database-directory}" = {
  #           snapshot_create = "always";
  #         };
  #         "${db-export-directory}" = {
  #           snapshot_create = "always";
  #         };
  #         snapshot_dir = "/${snapshot-dir}/owncloud";
  #         target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/owncloud";
  #       };
  #     };

  # ##############################################################################
  # # BTRFS ON TARGET
  # ##############################################################################

  #     target = mkIf (elem name cfg.nodes.backup) true;
  #   };

  };
}
