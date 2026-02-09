# dms-shell config

{ config, lib, pkgs, user, quickshell, ... }:

let
  cfg = config.marci.desktops.dms-shell;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.desktops.dms-shell = {
    enable = mkEnableOption "Enable dms-shell";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # DMS-SHELL
  ##############################################################################

    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/${user}";
      
      # Save the logs to a file
      logs = {
        save = true; 
        path = "/tmp/dms-greeter.log";
      };
      quickshell.package = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };

    programs.dms-shell = {
      enable = true;
      enableSystemMonitoring = false;
      quickshell.package = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO

  };
}
