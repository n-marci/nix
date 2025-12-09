# audiobookshelf config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.audiobookshelf;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.audiobookshelf = {
    enable = mkEnableOption "Enable audiobookshelf";

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

    services.audiobookshelf = {
      enable = true;
      port = 8000; # default port is 8000
      openFirewall = true;
      host = "0.0.0.0";
    };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = {
      enable = mkDefault true;
      virtualHosts = {
        "audiobookshelf.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/" = {
            proxyPass = "http://127.0.0.1:8000";
            proxyWebsockets = true;
          };
        };
      };
    };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO
  
  ##############################################################################
  # BTRFS
  ##############################################################################

    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (cfg.backup) {
      "${service-dir}/audiobookshelf" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/audiobookshelf";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/audiobookshelf";
      };
    };
  };
}
