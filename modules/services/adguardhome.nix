# adguardhome config

{ config, lib, ... }:

let
  cfg = config.fleet.adguard;
  inherit (lib) mkEnableOption mkIf mkDefault;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.adguard = {
    enable = mkEnableOption "Enable adguard";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    services.adguardhome = {
      enable = true;
      port = 3000;
      openFirewall = true;
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

  ##############################################################################
  # NGINX
  ##############################################################################

    services.nginx = {
      enable = mkDefault true;
      virtualHosts = {
        "adguard.marcelnet.com" = {
          forceSSL = true;
          useACMEHost = "marcelnet.com";
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };
      };
    };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  };
}
