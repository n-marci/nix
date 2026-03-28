# opencloud config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.opencloud;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem;
  # database-directory = "var/lib/postgresql";
  # db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.opencloud = {
    enable = mkEnableOption "Enable opencloud";

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

    services.opencloud = mkIf (elem name cfg.nodes.service) {
      enable = true; # https://wiki.nixos.org/wiki/OpenCloud - here is a full to configure radicale for caldav/carddav sync
      url = "https://opencloud.marcelnet.com";
      # url = "https://0.0.0.0:9200";
      address = "0.0.0.0";
      # address = "127.0.0.1";
      port = 9200;
      environment = {
        PROXY_TLS = "false"; # disable https when behind reverse proxy
        INITIAL_ADMIN_PASSWORD = "Super*Secure*Signs";
      #   OC_DOMAIN = "opencloud.marcelnet.com";
      #   OC_INSECURE = "true";
      #   # PROXY_INSECURE_BACKENDS = "true";
      };

      environmentFile = config.sops.secrets.opencloud-env.path;

      settings = {
        # An override of the default CSP: every parameter has to be re-written, default can be found on opencloud's compose files
        csp = {                                      
          directives = {
            child-src = [
              "'self'"
            ];

            connect-src = [
              "'self'"
              "blob:"
              "https://\${COMPANION_DOMAIN|companion.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
              "wss://\${COMPANION_DOMAIN|companion.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
              "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
              "https://\${IDP_DOMAIN|keycloak.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
              "https://update.opencloud.eu/"
            ];
            default-src = [
              "'none'"
            ];
            font-src = [
              "'self'"
            ];
            frame-ancestors = [
              "'self'"
            ];
            frame-src = [
              "'self'"
              "blob:"
              "https://embed.diagrams.net"
      
              # Here is the culprit, put your own office service's URL
              "https://office.marcelnet.com"

              # This is needed for the external-sites web extension when embedding sites
              "https://docs.opencloud.eu"
            ];
            img-src = [
              "'self'"
              "data:"
              "blob:"
              "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
              "https://tile.openstreetmap.org/"
              "https://office.marcelnet.com/"
            ];
            manifest-src = [
              "'self'"
            ];

            media-src = [
              "'self'"
            ];

            object-src = [
              "'self'"
              "blob:"
            ];

            script-src = [
              "'self'"
              "'unsafe-inline'"
              "https://\${IDP_DOMAIN|keycloak.opencloud.test}\${TRAEFIK_PORT_HTTPS}/"
            ];

            style-src = [
              "'self'"
              "'unsafe-inline'"
            ];
          };
        };

        proxy = {
          # Tell your proxy to look at that CSP file you created
          csp_config_file_location = "/etc/opencloud/csp.yaml";           
        };
      };

      # settings = {
      #   proxy = {
      #     csp_config_file_location = "/etc/opencloud/csp.yaml";
      #   };
      # };
    };

    sops.secrets.opencloud-env = mkIf (elem name cfg.nodes.service) { };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = mkIf (elem name cfg.nodes.service) {
      enable = mkDefault true;
      virtualHosts = {
        "opencloud.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/" = {
            proxyPass = "http://127.0.0.1:9200";
            proxyWebsockets = true;
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
    #   databases = [ "opencloud" ];
    # };

  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO mkIf (name == cfg.backupTarget)
  
  ##############################################################################
  # BTRFS ON HOST
  ##############################################################################

    # services.btrbk.instances.opencloud.settings.volume."/".subvolume = mkIf (cfg.backup.enable && (name == cfg.host)) {
    #   "${service-dir}/opencloud" = {
    #     snapshot_create = "always";
    #   };
    #   "${database-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   "${db-export-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   snapshot_dir = "/${snapshot-dir}/opencloud";
    #   target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/opencloud";
    # };

    fleet.btrbk = {
      enable = true;

      instances."opencloud".settings = mkIf (elem name cfg.nodes.service) {
        volume."/".subvolume = {
          "${service-dir}/opencloud" = {
            snapshot_create = "always";
          };
          # "${database-directory}" = {
          #   snapshot_create = "always";
          # };
          # "${db-export-directory}" = {
          #   snapshot_create = "always";
          # };
          snapshot_dir = "/${snapshot-dir}/opencloud";
          target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/opencloud";
        };
      };

  ##############################################################################
  # BTRFS ON TARGET
  ##############################################################################

      target = mkIf (elem name cfg.nodes.backup) true;
    };

  };
}
