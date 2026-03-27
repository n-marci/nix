{ config, lib, pkgs, user, ... }:

let
  cfg = config.marci.programs.vscodium;
  inherit (lib) mkEnableOption mkIf;
in
{
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.programs.vscodium = {
    enable = mkEnableOption "Enable configuration for the vscodium program";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    home-manager.users.${user} = {
      programs = {
        vscode = {
          enable = true;
          package = pkgs.vscodium.fhsWithPackages (ps: with ps; [ python3Minimal libusb1 ]);
        };
      };
    };
  };
}
