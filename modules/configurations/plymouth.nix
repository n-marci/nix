# plymouth config

{ config, lib, pkgs, user, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.plymouth = {
    enable = mkEnableOption "Enable plymouth boot screen";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (config.fleet.plymouth.enable) {
    boot = {
      plymouth = {
        enable = true;
        theme = "dna";
        # theme = "colorful_sliced";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "dna" ];
            # selected_themes = [ "colorful_sliced" ];
          })
        ];
      };

      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        #########################################
        # Silent Boot for plymouth boot animation
        #########################################
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "logLevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };
  };
}
