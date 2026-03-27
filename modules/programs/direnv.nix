{ config, lib, pkgs, vars, ... }:

let
  cfg = config.marci.programs.direnv;
  inherit (lib) mkEnableOption mkIf;
in
{
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.programs.direnv = {
    enable = mkEnableOption "Enable configuration for the direnv program";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    home-manager.users.${vars.user} = {
      programs = {
        direnv = {
          enable = true;
          enableBashIntegration = true;
          nix-direnv.enable = true;
        };
      };
    };
  };
}
