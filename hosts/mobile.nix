{ pkgs, ... }:

{
  ##############################################################################
  # mobile config
  ##############################################################################
  
  powerManagement.powertop.enable = true;
  hardware.sensor.iio.enable = true;
  environment.systemPackages = with pkgs; [
    gnome-power-manager
  ];
}
