# nextcloud configuration

{ config, lib,  pkgs, unstable, host, ... }:

with lib; {
  options = {
    nextcloud = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      # versioning = mkOption {
      #   type = types.bool;
      #   default = false;
      # };
    };
  };
  
  config = mkIf (config.nextcloud.enable) {

    # # Failed assertions:
    # #    - You must define `security.acme.certs.<name>.email` or
    # #    `security.acme.defaults.email` to register with the CA. Note that using
    # #    many different addresses for certs may trigger account rate limits.

    # #    - You must accept the CA's terms of service before using
    # #    the ACME module by setting `security.acme.acceptTerms`
    # #    to `true`. For Let's Encrypt's ToS see https://letsencrypt.org/repository/
    # services.nginx.virtualHosts = {
    #   "nextcloud-marci.com" = {
    #     forceSSL = true;
    #     enableACME = true;
    #   };
    #   "onlyoffice-marci.com" = {
    #     forceSSL = true;
    #     enableACME = true;
    #   };
    # };
    
    services.nextcloud = {
      enable = true;
      # hostName = "localhost";
      hostName = "nextcloud.marcelnet.com";
      package = pkgs.nextcloud30;
      configureRedis = true;
      database.createLocally = true;
      maxUploadSize = "16G";
      https = true;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) calendar contacts mail notes tasks;

        # # Nextcloud Gpodder Sync
        # # https://apps.nextcloud.com/apps/gpoddersync/releases
        # gpoddersync = pkgs.fetchNextcloudApp {
        #   url = "https://github.com/thrillfall/nextcloud-gpodder/releases/download/3.10.0/gpoddersync.tar.gz";
        #   sha256 = "sha256-OMH/pnDS/icDVUb56mzxowAhBCaVY60bMGJmwsjEc0k=";
        #   license = "gpl3";
        # };

        # # RePod Podcast Application
        # # https://apps.nextcloud.com/apps/repod/releases
        # repod = pkgs.fetchNextcloudApp {
        #   url = "https://git.crystalyx.net/Xefir/repod/releases/download/3.4.1/repod.tar.gz";
        #   sha256 = "sha256-RXMQKvoYmghKFRMA8WOrXyFrKx5ZEFHKzZ0IV1l8ef8=";
        #   license = "gpl3";
        # };

        ## Custom app installation example.
        # cookbook = pkgs.fetchNextcloudApp rec {
        #   url =
        #     "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
        #   sha256 = "sha256-XgBwUr26qW6wvqhrnhhhhcN4wkI+eXDHnNSm1HDbP6M=";
        # };
      };

      config = {
        # overwriteProtocol = "https";
        dbtype = "pgsql";
        # dbhost = "/var/lib/postgresql/nextcloud";
        adminuser = "caesar";
        adminpassFile = config.sops.secrets.nextcloud-pass.path;
      };

      settings = {
        # trusted_domains = [ "192.168.66.24" ];
        trusted_domains = [ "100.125.148.107" ]; # add the tailscale server ip to the trusted domains
        maintenance_window_start = 2;
        opcache.interned_strings_buffer = 9;
      };
    };

    services.nginx = {
      enable = true;

      ### test ###
      # recommendedProxySettings = true;
      # recommendedTlsSettings = true;
      ### test ###

      virtualHosts = {
        "nextcloud.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          # enableACME = false;
        #   locations."/" = {
        #     proxyPass = "http://localhost";
        #     proxyWebsockets = true;
        #     extraConfig = ''
        #       proxy_redirect http://$host https://$host; # apparently required for apps: https://codeberg.org/balint/nixos-configs/src/branch/main/hosts/vps/nextcloud.nix
        #     '';
        #   };
        };
        "immich.marcelnet.com" = {
          forceSSL = true;
          # enableACME = false;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:2283";
        };
        "adguard.marcelnet.com" = {
          forceSSL = true;
          # enableACME = false;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:3000";
        };
        "paperless.marcelnet.com" = {
          forceSSL = true;
          # enableACME = false;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:28981";
        };
        "actual.marcelnet.com" = {
          forceSSL = true;
          # enableACME = false;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:5006";
        };
        "immich.inspirion.bearded-bushi.ts.net" = {
          # forceSSL = true;
          # enableACME = false;
          # useACMEHost = "marcelnet.com";
          # sslCertificate = "/home/marci/inspirion.bearded-bushi.ts.net.crt";
          # sslCertificateKey = "/home/marci/inspirion.bearded-bushi.ts.net.key";
          locations."/".proxyPass = "http://localhost:2283";
        };
      };
      # sslCertificate = "/home/marci/inspirion.bearded-bushi.ts.net.crt";
      # sslCertificateKey = "/home/marci/inspirion.bearded-bushi.ts.net.key";
      # locations = {
      #   "/immich" = {
      #     proxyPass = "http://localhost:2283";
      #   };
      #   "/adguard" = {
      #     proxyPass = "http://localhost:3000";
      #   };
      #   "/paperless" = {
      #     proxyPass = "http://localhost:28981";
      #   };
      #   "/mealie" = {
      #     proxyPass = "http://localhost:9000";
      #   };
      #   "/actual" = {
      #     proxyPass = "http://localhost:5006";
      #   };
      # };
    };

    security.acme = {
      acceptTerms = true;   
      defaults.email = "neugebauer.marcel@web.de";
      certs."marcelnet.com" = { 
        # ${config.services.nextcloud.hostName} = {
        # "bearded-bushi.ts.net" = {
        domain = "*.marcelnet.com";
        # domain = "marcelnet.com";
        # extraDomainNames = [ "nextcloud.ts.marcelnet.com" "immich.ts.marcelnet.com" ];
        group = "nginx";
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        credentialsFile = config.sops.secrets.cloudflare-marcelnet.path;
        # };
      }; 
    };
    
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    users.users.nginx.extraGroups = [ "acme" ];
  };
  # users.users.nextcloud.extraGroups = [ config.users.groups.keys.name ];
}
