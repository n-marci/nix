# nginx configuration

{config, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    nginx = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.nginx.enable) {
    services.nginx = {
      enable = true;
      clientMaxBodySize = "1G";

      virtualHosts = {
        "nextcloud.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
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
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:2283";
        };
        "adguard.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:3000";
        };
        "paperless.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:28981";
        };
        "actual.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:5006";
        };
        "cockpit.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:9090";
        };
        "traccar.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:8082";
        };
        "matrix.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".extraConfig = ''
            return 404;
          '';
          locations."/_matrix".proxyPass = "http://[::1]:8008";
          locations."/_synapse/client".proxyPass = "http://[::1]:8008";
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
}
