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
      hostName = "localhost";
      # hostName = "www.nextcloud-marci.com";
      package = pkgs.nextcloud29;
      configureRedis = true;
      database.createLocally = true;
      maxUploadSize = "16G";
      # https = true;
      # enableBrokenCiphersForSSE = false;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) calendar contacts mail notes tasks;

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
        adminuser = "caesar";
        adminpassFile = config.sops.secrets.nextcloud-pass.path;
      };

      settings = {
        # trusted_domains = [ "192.168.66.24" ];
        trusted_domains = [ "100.111.69.31" "100.125.148.107" ]; # add the tailscale server ip to the trusted domains
      };
    };
    
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
  # users.users.nextcloud.extraGroups = [ config.users.groups.keys.name ];
}
