{ config, lib, pkgs, user, ... }:

let
  cfg = config.marci.programs.mpv;
  inherit (lib) mkEnableOption mkIf;
in
{
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.programs.mpv = {
    enable = mkEnableOption "Enable configuration for the mpv program";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    home-manager.users.${user} = {
      programs = {
        mpv = {
          enable = true;

    ##############################################################################
    # WIP - OLD CONFIG
    ##############################################################################

          # input.conf
          # # use up & down to control volume instead of seeking forward/backward
          # UP add volume +2
          # DOWN add volume -2
          # # ignore mousewheel instead of seeking forward/backward
          # WHEEL_UP ignore
          # WHEEL_DOWN ignore

          # mpv.conf
          # install packages to fix slow hardware encoding:
          # libva-vdpau-driver libvdpau-va-gl mesa-vdpau-drivers
          # fix issue with black screen on wayland (fedora 37)
          # hwdec=auto
          # gpu-context=x11
          # fix issue for low mpv volume
          # also alsa is the high quality audio as far as I know?
          # audio-device=alsa
        };
      };
    };
  };
}
