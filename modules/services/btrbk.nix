# btrbk config

{ config, pkgs, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.btrbk;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault mkMerge mapAttrsToList attrNames types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.btrbk = {
    enable = mkEnableOption "Enable btrbk";

    instances = mkOption {
      # type = types.str;
      # default = "btrbk";
      type = types.attrsOf (types.submodule ({
        options = {
          # instance = mkOption {
          #   type = types.str;
          #   default = "btrbk";
          # };
          # 
          # enable = mkEnableOption "Enable specific instance of btrbk";

          settings = mkOption {
            type = types.attrs;
            default = { };
          };

        };
      }));
      default = { };
    };

    target = mkEnableOption "Enable target configuration for btrbk";

    publicKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+C3Nnd5EOTg52l8M3jJsfq8lr6tXXSgREaNP1Lx8OQ inspirion";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

    # assertions = [{
    #   assertion = !(cfg.source && cfg.target);
    #   message = "Node must be either `source` or `target`, not both";
    # }];

  ##############################################################################
  # SOURCE SERVICE
  ##############################################################################

    services.btrbk.instances = mkMerge (
      mapAttrsToList (instance: cfg: mkIf (attrNames cfg.settings == []) {
        ${instance} = {
          onCalendar = "hourly";
          settings = cfg.settings // {
            # good explanation on gentoo wiki https://wiki.calculate-linux.org/btrbk
            preserve_hour_of_day = "0"; # the daily backup is the first one after midnight
            preserve_day_of_week = "monday"; # Monday is the first day of week
            snapshot_preserve_min = "1d"; # preserve all temporary snapshots for at least one day
            snapshot_preserve = "14d 8w 6m 1y"; # preserve 14 latest daily, 8 weekly, 6 monthly, 1 annual snapshots
            target_preserve_min = "no"; # do not preserve temporary snapshots
            target_preserve = "6d 4w 6m 1y"; # preserve 6 latest daily, 4 weekly, 6 monthly, 1 annual snapshots
            stream_compress = "zstd";
            backend_remote = "btrfs-progs-sudo"; # so that i dont need root login for send
            ssh_user = "btrbk"; # so that i dont need root login for send

            # volume."/".subvolume = {

            # };
          };
        };
      })
      cfg.instances
    );

  ##############################################################################
  # SOURCE SECURITY
  ##############################################################################

    security.sudo = mkIf (!cfg.target) {
      enable = true;
      extraRules = [{
        commands = [{
        command = "${pkgs.coreutils-full}/bin/test";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.coreutils-full}/bin/readlink";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.btrfs-progs}/bin/btrfs";
        options = [ "NOPASSWD" ];
      }];
        users = [ "btrbk" ];
      }];
      extraConfig = with pkgs; ''
        Defaults:picloud secure_path="${lib.makeBinPath [
          btrfs-progs coreutils-full
       ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # DISKO ON BTRFS TARGET
  ##############################################################################

  # TODO
  
  ##############################################################################
  # TARGET USER
  ##############################################################################

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.btrbk = mkIf (cfg.target) {
      isSystemUser = true;
      description = "Btrbk ssh user";
      hashedPassword = "$y$j9T$zLd4QQEe0StSokJHXbxby1$v.7TpY9aVKPGHC.rYoMmHKZnIDny7ZiKjQ9BvUs19v7";
    };

    services.btrbk.sshAccess = mkIf (cfg.target) [{
      key = cfg.publicKey;
      roles = [ "info" "source" "target" "delete" "snapshot" "send" "receive" ];
    }];
  };
}
