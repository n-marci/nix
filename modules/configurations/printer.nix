# printer config

{ config, lib, pkgs, user, ... }:

let
  cfg = config.fleet.printer;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.printer = {
    enable = mkEnableOption "Enable additional printer drivers";

    user = mkOption {
      type = types.str;
      default = user;
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    users.users.${cfg.user} = {
      extraGroups = [ "scanner" "lp" ];
    };
    
    # Enable SANE to scan documents
    # hardware.sane = {
    #   enable = true;
    #   extraBackends = [ pkgs.sane-airscan ];
    #   brscan4 = {
    #     enable = true;
    #   };
    # };

    # enables network printers? - so far not used?
    services.ipp-usb.enable = true;
  
    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = with pkgs; [ /*mfcl2700dnlpr*/ brlaser ]; # brlaser 
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  
    environment.systemPackages = with pkgs; [
      nssmdns
    ];
  };
}
