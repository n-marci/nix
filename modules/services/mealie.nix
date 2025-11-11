# mealie recipe manager configuration

{ config, lib,  pkgs, unstable, host, ... }:

let
  datadir = "var/lib/private/mealie";
  snapdir = "var/btr/mealie";
  bkpdir = "srv/btr/${host.hostName}/mealie";
  bkparray = "linc-nvme-raid";
  inherit (lib) mkOption mkIf mkDefault types;
in
{
  options = {
    mealie = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      backup = mkOption {
        type = types.bool;
        default = false;
      };
      backupTarget = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.mealie.enable) {

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

    services.nginx = {
      enable = mkDefault true;
      virtualHosts = {
        "mealie.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:9925";
        };
      };
    };

    # setup disko subvolume for ${datadir}
     
    # setup btrbk
    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (config.mealie.backup) {
      "${datadir}" = {
        snapshot_create = "always";
      };
    };

    # setup disko subvolume for ${host}/${bkpdir}
    disko.devices.btrfs.${bkparray}.subvolumes = mkIf (config.mealie.backupTarget) {
      "${bkpdir}" = {
        mountpoint = "${bkpdir}";
      };
    };
  };
}
