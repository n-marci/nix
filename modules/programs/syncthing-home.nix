# syncthing home config

{ config, lib, user, ... }:

let
  cfg = config.fleet.syncthing-home;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.syncthing-home = {
    enable = mkEnableOption {
      name = "Enable syncthing-home";
      default = config.fleet.syncthing.enable;
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    home-manager.users.${user}.home.file."sync/obsidian/.stignore".text = ''
      .obsidian
    '';
    # home-manager = {
    #   users = mkIf (config.fleet.syncthing.storeInBackupLocation == false) {
    #     "${user}" = {
    #       home.file."sync/obsidian/.stignore".text = ''
    #         .obsidian
    #       '';
    #     };
    #   };
    # };
  };
}
