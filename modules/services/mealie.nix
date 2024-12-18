# mealie recipe manager configuration

{ config, lib,  pkgs, unstable, host, ... }:

with lib; {
  options = {
    mealie = {
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
  
  config = mkIf (config.mealie.enable) {

    services.mealie = {
      enable = true;
      port = 9000;
    };
  };
}
