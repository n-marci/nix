{ pkgs, ... }:

{
  ##############################################################################
  # boot
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
  # mobile config
  ##############################################################################
  
  powerManagement.powertop.enable = true;
  hardware.sensor.iio.enable = true;
  environment.systemPackages = with pkgs; [
    gnome-power-manager
  ];
}
