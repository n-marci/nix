# nextcloud config

{ config, pkgs, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.nextcloud;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
  database-directory = "var/lib/postgresql";
  db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.nextcloud = {
    enable = mkEnableOption "Enable nextcloud";

    backup = mkOption {
      type = types.bool;
      default = false;
    };

    backupTarget = mkOption {
      type = types.str;
      default = "helix-s";
    };

    fail2ban = mkOption {
      type = types.bool;
      default = false;
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    services.nextcloud = {
      enable = true;
      hostName = "nextcloud.marcelnet.com";
      package = pkgs.nextcloud32;
      configureRedis = true;
      database.createLocally = true;
      maxUploadSize = "16G";
      https = true;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) calendar contacts mail notes tasks gpoddersync repod integration_paperless integration_deepl; # possible apps: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/servers/nextcloud/packages/nextcloud-apps.json

        # nextcloud tasks since the release was not updated
        # tasks = pkgs.fetchNextcloudApp {
        #   url = "https://github.com/nextcloud/tasks/releases/download/v0.17.0/tasks.tar.gz";
        #   sha256 = "sha256:877bbdc51df382e2af5565c0ec235275edac11dbe0b13d7c718007a7c74a3d28";
        #   license = "agpl3Plus";
        # };
      };

      config = {
        dbtype = "pgsql";
        # dbhost = "localhost";
        adminuser = "caesar";
        adminpassFile = config.sops.secrets.nextcloud-pass.path;
      };

      settings = {
        trusted_domains = [ "100.125.148.107" "192.168.66.21" ]; # add the tailscale server ip to the trusted domains
        overwriteProtocol = "https";
        maintenance_window_start = 2;
        opcache.interned_strings_buffer = 9;
        default_phone_region = "DE";
      };
    };

  ##############################################################################
  # SECRETS
  ##############################################################################

    sops.secrets.nextcloud-pass = {
      owner = "nextcloud";
    };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = {
      enable = mkDefault true;
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
          extraConfig = ''
            client_max_body_size 1G;
          '';
        };
      };
    };

  ##############################################################################
  # PROMETHEUS EXPORTER
  ##############################################################################

  # TODO
  
  ##############################################################################
  # FAIL2BAN
  ##############################################################################

    services.fail2ban = mkIf (cfg.fail2ban) {
      enable = mkDefault true;
      jails = {
        nextcloud.settings = {
          # START modification to work with syslog instead of logile
          backend = "systemd";
          journalmatch = "SYSLOG_IDENTIFIER=Nextcloud";
          # END modification to work with syslog instead of logile
          enabled = true;
          port = 443;
          protocol = "tcp";
          filter = "nextcloud";
          maxretry = 3;
          bantime = 86400;
          findtime = 43200;
        };
      };
    };

    environment.etc = mkIf (cfg.fail2ban) {
      # Adapted failregex for syslogs
      "fail2ban/filter.d/nextcloud.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^.*"remoteAddr":"&lt;HOST&gt;".*"message":"Login failed:
                    ^.*"remoteAddr":"&lt;HOST&gt;".*"message":"Two-factor challenge failed:
                    ^.*"remoteAddr":"&lt;HOST&gt;".*"message":"Trusted domain error.
      '');
    };
  
  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # POSTGRES DB EXPORT
  ##############################################################################

    services.postgresqlBackup = mkIf (config.fleet.nextcloud.backup) {
      enable = mkDefault true;
      startAt = "*-*-* 04:05:00";
      location = "/${db-export-directory}";
      databases = [ "nextcloud" ];
    };

  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO
  
  ##############################################################################
  # BTRFS
  ##############################################################################

    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (cfg.backup) {
      "${service-dir}/nextcloud" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/nextcloud";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/nextcloud";
      };
      "${database-directory}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/nextcloud";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/nextcloud";
      };
      "${db-export-directory}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/nextcloud";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/nextcloud";
      };
    };
  };
}
