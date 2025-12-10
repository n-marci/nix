# btrbk config

{ config, pkgs, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.btrbk-instance;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.btrbk-instance = {
    enable = mkEnableOption "Enable btrbk";

    instance = mkOption {
      type = types.str;
      default = "btrbk";
    };

    # node = mkOption {
    #   description = "Specifies if the device should send or receive backups in the case of ssh target";
    #   type = types.enum [
    #     "source"
    #     "target"
    #     "both"
    #   ];
    #   default = "source";
    # };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    services.btrbk = {
      instances.${cfg.instance} = {
        onCalendar = "hourly";
        settings = {
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
    };

  ##############################################################################
  # USER
  ##############################################################################

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.btrbk = mkIf (config.fleet.btrbk.node == "target" ) {
      isSystemUser = true;
      description = "Btrbk ssh user";
    };

  ##############################################################################
  # SECURITY
  ##############################################################################

    security.sudo = {
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
  
  };
}
