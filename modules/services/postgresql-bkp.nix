# postgresql backup configuration

{ config, lib,  pkgs, unstable, host, ... }:

with lib; {
  options = {
    pg-bkp = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      databases = mkOption {
        default = [];
        type = types.listOf types.str;
      };
    };
  };
  
  config = mkIf (config.pg-bkp.enable) {

    services.postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 04:05:00";
      location = "/var/bkp/pg-dump";
      databases = config.pg-bkp.databases;
    };
  };
}
