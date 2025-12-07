# nextcloud configuration

{ config, lib,  pkgs, unstable, name, ... }:

let
  datadir = "var/lib/immich";
  dbdir = "var/lib/postgresql";
  dbdump = "var/lib/postgresql-dump";
  snapdir = "var/btr/immich";
  bkpdir = "srv/btr/${name}/immich";
  inherit (lib) mkOption mkIf mkDefault types;
in
{
  options = {
    fleet.immich = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      backup = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.fleet.immich.enable) {

    ###########################
    # TODO Disko Config
    ###########################

    ###########################
    # Service Config
    ###########################

    services.immich = {
      enable = true;
      environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
      openFirewall = true;
      host = "0.0.0.0";
    };

    # TODO add Hardware Accelerated Transconding using VA-API
      # Explanation https://wiki.nixos.org/wiki/Immich

    # networking.firewall.allowedTCPPorts = [ 2283  3001 ];
    
    ###########################
    # Nginx Config
    ###########################

    services.nginx = {
      enable = mkDefault true;
      virtualHosts = {
        "immich.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://100.125.148.107:2283";
          # # For the moment I have it configured globally
          # # should also work with this config though
          extraConfig = ''
            client_max_body_size 1G;
          '';
        };
      };
    };

    ###########################
    # Postgres Database Export
    ###########################

    # services.postgresqlBackup = mkIf (config.fleet.immich.backup) {
    #   enable = true;
    #   startAt = "*-*-* 04:05:00";
    #   location = "/${dbdump}";
    #   databases = [ "immich" ];
    # };

    ###########################
    # Btrfs backup
    ###########################
    
    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (config.fleet.immich.backup) {
      "${datadir}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapdir}";
        target = "ssh://100.83.225.75/${bkpdir}";
      };
      "${dbdir}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapdir}";
        target = "ssh://100.83.225.75/${bkpdir}";
      };
      "${dbdump}" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapdir}";
        target = "ssh://100.83.225.75/${bkpdir}";
      };
    };

  };
}
