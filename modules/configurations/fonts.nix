# font config

{ config, lib, pkgs, user, ... }:

let
  cfg = config.fleet.fonts;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.fonts = {
    enable = mkEnableOption "Enable font configuration";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    fonts = {
      fontDir.enable = true;   # needed for flatpak to use the right cursor and fonts
      packages = (with pkgs; [
        comfortaa
        montserrat
        intel-one-mono
        newcomputermodern
        # (nerdfonts.override { fonts = [ "Monofur" "Agave" "AurulentSansMono" "CascadiaCode" "FantasqueSansMono" "Hermit" "OpenDyslexic" ]; })
      ]) ++ (with pkgs.nerd-fonts; [
        monofur
        agave
        aurulent-sans-mono
        caskaydia-mono
        fantasque-sans-mono
        open-dyslexic
      ]);
      fontconfig.defaultFonts.monospace = [ "Monofur Nerd Font" ];
    };
  };
}
