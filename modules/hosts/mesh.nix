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
        nodes = {
          service = [ "inspirion" ];
          storage = [ "linc-n2" ]; # store in /srv/store
          backup = [ "helix-s" ]; # backup in /srv/backup
        };
      };

    ##############################################################################
    # OPENCLOUD
    ##############################################################################

      # opencloud = { # for a full setup with caldav/carddav sync look at https://wiki.nixos.org/wiki/OpenCloud
      #   enable = true;
      #   nodes = {
      #     service = [ "inspirion" ];
      #     storage = [ "linc-n2" ]; # store in /srv/store
      #     backup = [ "helix-s" ]; # backup in /srv/backup
      #   };
      # };

      owncloud = {
        enable = true;
        nodes.service = [ "inspirion" ];
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
        phones = [ "s20-plus" "note-9" "pixel-8" ];
        whatsapp = [ "s20-plus-wa" ];
        folders = [ "nix" "secrets" "wallpapers" "obsidian" "logseq" "phone" "signal" "whatsapp"];

        backup = {
          enable = true;
          target = "helix-s";
        };
      };

    ##############################################################################
    # ACTUAL
    ##############################################################################

      actualbudget = {
        enable = true;
        nodes = {
          service = [ "inspirion" ];
          backup = [ "helix-s" ]; # backup in /srv/backup
        };
      };

    ##############################################################################
    # PANGOLIN
    ##############################################################################
      
      pangolin = {
        enable = false;
        nodes = {
          newt = [ "inspirion" ];
          pangolin = [ "ovh-vps" ];
        };
      };
    };

    ##############################################################################
    # NETWORKING
    ##############################################################################

    # What I want
    # access[ . . ]

    # users.users = {
    #   ${user}.openssh.authorizedKeys.keys = mkIf (host elem ) [ # allow user marci to login with my devices
    #     hosts.yoga.public-key
    #   ];

    #   ${config.deployment.targetUser} = { # create priviliged user for the deployment of colmena
    #     isSystemUser = true;
    #     group = "${config.deployment.targetUser}";
    #     shell = pkgs.bashInteractive;
    #     openssh.authorizedKeys.keys = [
    #       hosts.yoga.public-key
    #     ];
    #   };
    # };


  };
}
