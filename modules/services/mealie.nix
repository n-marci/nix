# mealie config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.mealie;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.mealie = {
    enable = mkEnableOption "Enable mealie";

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

    services.mealie = {
      enable = true;
      port = 9925;
      listenAddress = "0.0.0.0";
      settings = {
        BASE_URL = "https://mealie.marcelnet.com";
      };
    };

    # for now i needed to specifiy the mealie user myself, since the module did not do it apparently
    users.users.mealie = {
      name = "mealie";
      group = "mealie";
      isSystemUser = true;
    };
    users.groups.mealie = { };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = {
      enable = mkDefault true;
      virtualHosts = {
        "mealie.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://127.0.0.1:9925";
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
      "${service-dir}/private/mealie" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/private/mealie";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/private/mealie";
      };
    };
  };
}
