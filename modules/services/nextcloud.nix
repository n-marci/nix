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
      package = pkgs.nextcloud31;
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
        trusted_domains = [ "100.125.148.107" "192.168.66.21" ]; # add the tailscale server ip to the trusted domains
        maintenance_window_start = 2;
        opcache.interned_strings_buffer = 9;
      };
    };
  };
  # users.users.nextcloud.extraGroups = [ config.users.groups.keys.name ];
}
