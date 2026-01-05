{ config, lib, pkgs, ... }:

let
  cfg = config.marci.hosts.mobile;
  inherit (lib) mkEnableOption mkIf;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.hosts.mobile = {
    enable = mkEnableOption "Enable configuration for mobile host";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

    ##############################################################################
    # BOOT
    ##############################################################################
  
    boot = {
      kernelParams = [
        #########################################
        # Energy savings maybe?
        #########################################
        "mem_sleep_default=deep" 
        "pcie_aspm.policy=powersupersave" 
      ];
    };

    ##############################################################################
    # MOBILE CONFIG
    ##############################################################################
  
    hardware.sensor.iio.enable = true;
    environment.systemPackages = with pkgs; [
      gnome-power-manager
    ];
  };
}
