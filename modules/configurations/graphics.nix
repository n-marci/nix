# graphics config

{ config, lib, pkgs, graphics, ... }:

let
  cfg = config.fleet.graphics;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.graphics = {
    enable = mkEnableOption "Enable graphics";

    hardware = mkOption {
      type = types.str;
      default = graphics;
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
  
  ##############################################################################
  # INTEL
  ##############################################################################

    hardware.graphics = mkIf (cfg.hardware == "intel") {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        vpl-gpu-rt # for intel quick sync video
      ];
      extraPackages32 = with pkgs.pkgsi686linux; [
        intel-media-driver
      ];
    };
    environment.sessionVariables = mkIf (cfg.hardware == "intel") {
      LIBVA_DRIVER_NAME = "iHD";
      VDPAU_DRIVER = "va_gl";
    };
  };
}
