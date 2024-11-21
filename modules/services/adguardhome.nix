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
      # port = 3000;
    };
  };
}
