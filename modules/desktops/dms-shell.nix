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

  ##############################################################################
  # PROGRAMS
  ##############################################################################

    programs.dms-shell = {
      enable = true;
      # enableSystemMonitoring = false; # disabled it because it showed high cpu usage, but apparently it is not too bad https://github.com/AvengeMedia/dgop/issues/23
      quickshell.package = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };

    programs.kdeconnect.enable = true; # need to enable it specifically because it is a dms plugin

    environment.systemPackages = with pkgs; [
      kdePackages.kdeconnect-kde
      sshfs
      pywalfox-native # enable pywalfox to theme firefox/librewolf with the dank colors
    ];

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO

  };
}
