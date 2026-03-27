# actualbudget config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.actualbudget;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.actualbudget = {
    enable = mkEnableOption "Enable actualbudget";

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

    services.actual = mkIf (elem name cfg.nodes.service) {
      enable = true;
      openFirewall = true;
      settings = {
        port = 5006;
        hostname = "0.0.0.0";
      };
    };

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = mkIf (elem name cfg.nodes.service) {
      enable = mkDefault true;
      virtualHosts = {
        "actual.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://127.0.0.1:5006";
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

    fleet.btrbk = {
      enable = true;

      instances.btrbk.settings = mkIf (elem name cfg.nodes.service) {
        volume."/".subvolume = {
          "${service-dir}/private/actual" = {
            snapshot_create = "always";
            snapshot_dir = "/${snapshot-dir}/private/actual";
            target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/private/actual";
          };
        };
      };

  ##############################################################################
  # BTRFS ON TARGET
  ##############################################################################

      target = mkIf (elem name cfg.nodes.backup) true;
    };

  };
}
