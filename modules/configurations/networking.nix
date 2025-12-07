# networking config

{ config, lib, name, ip, interface, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.networking = {
    enable = mkEnableOption "Enable networking";

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

  config = mkIf (config.fleet.networking.enable) {
    networking = {
      enable = true;
      hostName = name;
      firewall.enable = true;
      
  ##############################################################################
  # STATIC IP
  ##############################################################################

      defaultGateway = mkIf (config.fleet.networking.static.enable) {
        address = "192.168.66.1";
        interface = config.fleet.networking.static.interface;
      };
      nameservers = mkIf (config.fleet.networking.static.enable) [
        "127.0.0.1"
        "9.9.9.9"
      ];
      interfaces.${config.fleet.networking.static.interface}.ipv4.addresses = mkIf (config.fleet.networking.static.enable) [{
        address = config.fleet.networking.static.ip;
        prefixLength = 24;
      }];
    };
  };
}
