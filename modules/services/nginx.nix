# nginx configuration

{config, vars, lib, unstable, host, private, ...}:

let
  inherit (private) emails;
in
with lib; {
  options = {
    fleet.nginx = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.fleet.nginx.enable) {
    services.nginx = {
      enable = true;
      clientMaxBodySize = "1G";

      virtualHosts = {
        # "nextcloud.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   #   locations."/" = {
        #   #     proxyPass = "http://localhost";
        #   #     proxyWebsockets = true;
        #   #     extraConfig = ''
        #   #       proxy_redirect http://$host https://$host; # apparently required for apps: https://codeberg.org/balint/nixos-configs/src/branch/main/hosts/vps/nextcloud.nix
        #   #     '';
        #   #   };
        #   # extraConfig = ''
        #   #   client_max_body_size 1G;
        #   # '';
        # };
        # "adguard.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/".proxyPass = "http://100.125.148.107:3000";
        # };
        # "paperless.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/".proxyPass = "http://100.125.148.107:28981";
        #   # locations."/" = {
        #   #   proxyPass = "http://100.125.148.107:28981";
        #   #   proxyWebsockets = true;
        #   # };
        # };
        # "actual.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/".proxyPass = "http://100.125.148.107:5006";
        # };
        # "cockpit.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/".proxyPass = "http://100.125.148.107:9090";
        # };
        "traccar.${private.domains.home}" = {
          forceSSL = true;
          useACMEHost = "${private.domains.home}";
          locations."/".proxyPass = "http://100.125.148.107:8082";
        };
        # "audiobookshelf.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/" = {
        #     proxyPass = "http://100.125.148.107:8000";
        #     proxyWebsockets = true;
        #   };
        # };
        # "mealie.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/".proxyPass = "http://100.125.148.107:9925";
        # };
        # "matrix.${private.domains.home}" = {
        #   forceSSL = true;
        #   useACMEHost = "${private.domains.home}";
        #   locations."/".extraConfig = ''
        #     return 404;
        #   '';
        #   locations."/_matrix".proxyPass = "http://[::1]:8008";
        #   locations."/_synapse/client".proxyPass = "http://[::1]:8008";
        # };
      };
    };

    security.acme = {
      acceptTerms = true;   
      defaults.email = emails.web-de;
      certs."${private.domains.home}" = { 
        # ${config.services.nextcloud.hostName} = {
        # "bearded-bushi.ts.net" = {
        domain = "*.${private.domains.home}";
        # domain = "${private.domains.home}";
        # extraDomainNames = [ "nextcloud.ts.${private.domains.home}" "immich.ts.${private.domains.home}" ];
        group = "nginx";
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        credentialFiles = {
          CLOUDFLARE_DNS_API_TOKEN_FILE = config.sops.secrets.cloudflare-marcelnet.path;
        };
        # };
      }; 
    };
    
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    users.users.nginx.extraGroups = [ "acme" ];

  ##############################################################################
  # SOPS
  ##############################################################################

    sops.secrets.cloudflare-marcelnet = { };

  };
}
