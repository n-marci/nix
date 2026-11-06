# adguardhome config

{ config, lib, private, ... }:

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
    # - domain: '*.${private.domains.home}'
    #   answer: 192.168.66.35
        rewrites = {
          domain = "*.${private.domains.home}";
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
        "adguard.${private.domains.home}" = {
          forceSSL = true;
          useACMEHost = "${private.domains.home}";
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };
      };
    };

  ##############################################################################
  # SUBVOLUMES
  ##############################################################################

    marci.subvolumes.paths."/var/lib/private/AdGuardHome" = {
      requiredBy = [ "adguardhome.service" ];
    };

  };
}
