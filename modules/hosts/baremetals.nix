{ config, lib, ... }:

let
  cfg = config.marci.hosts.baremetal;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{

  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.hosts.baremetal = {
    enable = mkEnableOption "Enable configuration for baremetal host";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    powerManagement.powertop.enable = true;
    hardware.enableAllFirmware = true;
    services.fwupd.enable = true;
    services.fstrim.enable = true;
  };
}
