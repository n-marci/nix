{ config, lib, pkgs, name, user, ... }:

let
  cfg = config.marci.hosts.mesh;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{

  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.hosts.mesh = {
    enable = mkEnableOption "Enable configuration for mesh host";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    marci.services = {

    ##############################################################################
    # IMMICH
    ##############################################################################

      immich = {
        enable = true;
        host = "inspirion";
        backup = {
          enable = true;
          target = "helix-s";
        };
      };

    ##############################################################################
    # NEXTCLOUD
    ##############################################################################

      nextcloud = {
        enable = true;
        host = "inspirion";
        backup = {
          enable = true;
          target = "helix-s";
        };
      };

    ##############################################################################
    # SYNCTHING
    ##############################################################################

      syncthing = {
        enable = true;
        homes = [ "yoga" "unicorn" ];
        servers = [ "inspirion" ];
        phones = [ "s20-plus" "note-9" ];
        whatsapp = [ "s20-plus-wa" ];
        folders = [ "nix" "secrets" "wallpapers" "obsidian" "logseq" "phone" "signal" "whatsapp"];

        backup = {
          enable = true;
          target = "helix-s";
        };
      };

    };
  };
}
