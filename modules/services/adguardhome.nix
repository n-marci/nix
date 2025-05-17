# adguardhome configuration

{ config, lib,  pkgs, unstable, host, ... }:

with lib; {
  options = {
    adguard = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      # versioning = mkOption {
      #   type = types.bool;
      #   default = false;
      # };
    };
  };
  
  config = mkIf (config.adguard.enable) {

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      port = 3000;
      # mutableSettings = false;
      settings = {
        address = "0.0.0.0:3000";
    #     rewrites:
    # - domain: '*.marcelnet.com'
    #   answer: 192.168.66.35
        rewrites = {
          domain = "*.marcelnet.com";
          answer = "192.168.66.21";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
