# audio config

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.audio= {
    enable = mkEnableOption "Enable audio";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (config.audio.enable) {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
    };
  };
}
