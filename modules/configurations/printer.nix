# printer config

{ config, lib, pkgs, user, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.printer = {
    enable = mkEnableOption "Enable additional printer drivers";

    user = mkOption {
      type = types.str;
      default = user;
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (config.printer.enable) {
    users.users.${config.printer.user} = {
      extraGroups = [ "scanner" "lp" ];
    };
  };
}
