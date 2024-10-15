# nextcloud configuration

{ config, lib,  pkgs, unstable, host, ... }:

with lib; {
  options = {
    immich = {
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
  
  config = mkIf (config.immich.enable) {

    services.immich = {
      enable = true;
      environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
    };

    # TODO add Hardware Accelerated Transconding using VA-API
      # Explanation https://wiki.nixos.org/wiki/Immich
  };
}
