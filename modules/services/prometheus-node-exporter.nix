# prometheus node exporter config

{ config, lib, pkgs, ... }:

let
  cfg = config.fleet.node-exporter;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.node-exporter = {
    enable = mkEnableOption "Prometheus Node Exporter";

    port = mkOption {
      type = types.port;
      default = 9100;
      description = "Port for Node Exporter metrics";
    };

    enabledCollectors = mkOption {
      type = types.listOf types.str;
      default = [
        "systemd"
        "textfile"
        "filesystem"
        "loadavg"
        "meminfo"
        "netdev"
        "stat"
      ];
      description = "List of enabled collectors";
    };
  };

  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf cfg.enable {

    services.prometheus.exporters.node = {
      enable = true;
      port = cfg.port;
      enabledCollectors = cfg.enabledCollectors;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
