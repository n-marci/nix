# pinchflat config

{ config, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.pinchflat;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.pinchflat = {
    enable = mkEnableOption "Enable pinchflat";

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

    services.actual = {
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

    services.nginx = {
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

    services.btrbk.instances.btrbk.settings.volume."/".subvolume = mkIf (cfg.backup) {
      "${service-dir}/private/actual" = {
        snapshot_create = "always";
        snapshot_dir = "/${snapshot-dir}/private/actual";
        target = "ssh://${hosts.${cfg.backupTarget}.tailscale-ip}/${backup-dir}/${name}/private/actual";
      };
    };

  ##############################################################################
  # YOUTUBE CHANNEL
  ##############################################################################

    # 3blue1brown
    # RealLifeLore
    # Veratasium
    # PBS Space Time
    # Real Engineering
    # Kurzgesagt
    # ScienceClic English
    # Prof. Dr. Christian Rieck

    # Mental Outlaw
    # Brodie Robertson
    # ChrisAtMachine
    # BugsWriter
    # Wolfgangs Channel
    # Techlore
    # ServeTheHome
    # Buschfunkistan
    # The Linux experiment
    # PBS Eons
    # 100 Sekunden Physik
    # The Thought Emporium
    # TomSka
    # VSauce
    # TED
    # minutephysics
    # Journey to the Microcosmos
    # Academy of Ideas
    # Little Star (Clothes repair)
    # Optimum Tech
    # Drew Gooden
    # Techlinked

    # ExplosmEntertainment
    # Game Grumps
    # Smallant
    # DougDougW
    # Lets Game It Out
    # Wirtual / WirtualTV
    # SovietWomble
    # cubfan
    # xisumavoid
    # Overwatch League
  };
}
