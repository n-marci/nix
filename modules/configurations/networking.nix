# networking config

{ config, lib, name, ip, interface, ... }:

let
  cfg = config.fleet.networking;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types optionalAttrs;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.networking = {
    # enable = mkEnableOption "Enable networking";

    static = {
      enable = mkEnableOption "Enable static ip";
      ip = mkOption {
        type = types.str;
        default = ip;
      };
      interface = mkOption {
        type = types.str;
        default = interface;
      };
    };
    # static-ip = mkOption {
    #   type = types.str;
    #   default = ip;
    # };

    # interface = mkOption {
    #   type = types.str;
    #   default = interface;
    # };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.static.enable) {
    networking = {
      # hostName = name;
      # firewall.enable = true;
      
  ##############################################################################
  # STATIC IP
  ##############################################################################

      defaultGateway = mkIf (cfg.static.enable) {
        address = "192.168.66.1";
        interface = cfg.static.interface;
      };
      nameservers = mkIf (cfg.static.enable) [
        "127.0.0.1"
        "9.9.9.9"
      ];
      interfaces.${cfg.static.interface}.ipv4.addresses = mkIf (cfg.static.enable) [{
        address = cfg.static.ip;
        prefixLength = 24;
      }];
    };
  };
}
