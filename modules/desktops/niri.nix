# niri config

{ config, lib, pkgs, ... }:

let
  cfg = config.marci.desktops.niri;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.desktops.niri = {
    enable = mkEnableOption "Enable niri";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # NIRI
  ##############################################################################

    programs.niri.enable = true;
    services.iio-niri.enable = true;

  ##############################################################################
  # NOCTALIA
  ##############################################################################

    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

  ##############################################################################
  # WAYBAR
  ##############################################################################

    # programs.waybar.enable = true;

  ##############################################################################
  # PKGS
  ##############################################################################

    environment.systemPackages = with pkgs; [
      noctalia-shell
      
      alacritty
      fuzzel
      cliphist
      brightnessctl
      adw-bluetooth
    ];

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO

  };
}
