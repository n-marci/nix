# btrbk config

{ config, pkgs, lib, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.fleet.btrbk-target;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.btrbk-target = {
    enable = mkEnableOption "Enable btrbk";

    publicKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+C3Nnd5EOTg52l8M3jJsfq8lr6tXXSgREaNP1Lx8OQ inspirion";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # USER
  ##############################################################################

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.btrbk = {
      isSystemUser = true;
      description = "Btrbk ssh user";
    };

  ##############################################################################
  # SECURITY
  ##############################################################################

    security.sudo = { # only needed on instance definition or also on the backup target?
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
