# btrfs-create-subvolumes config

{ config, lib, pkgs, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.btrfs-create-subvolumes;
  inherit (lib) concatStringsSep unique mkEnableOption mkOption mkIf mkDefault types escapeShellArg elem;
  
  # de-duplicate while keeping determinism
  uniq = unique;

  subvols = uniq cfg.subvolumes;

  mkCreateLines = concatStringsSep "\n" (map (sv: ''
    if [ ! -d "${cfg.topLevelMount}/${sv}" ]; then
      echo "Creating subvolume ${sv}"
      ${pkgs.btrfs-progs}/bin/btrfs subvolume create "${cfg.topLevelMount}/${sv}"
    else
      echo "Subvolume ${sv} already exists"
    fi
  '') subvols);

  # # Device for the *btrfs filesystem* that contains your subvolumes.
  # # Use something stable: by-label is great if you set label="nixos" in disko.
  # btrfsDevice = "/dev/disk/by-label/nixos";

  # # Where to mount the top-level (subvolid=5) temporarily:
  # top = "/run/btrfs-top";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.btrfs-create-subvolumes = {
    enable = mkEnableOption "Create missing btrfs subvolumes at boot (idempotent)";

    subvolume = mkOption {
      type = types.str;
      default = "inspirion";
    };

    device = mkOption {
      type = types.str;
      example = "/dev/disk/by-label/nixos";
      description = ''
        Block device (or mapper path) for the btrfs filesystem whose top-level
        contains the subvolumes. Typically /dev/disk/by-label/<label>.
      '';
    };

    topLevelMount = mkOption {
      type = types.str;
      default = "/run/btrfs-top";
      description = "Temporary mount point for the btrfs top-level (subvolid=5).";
    };

    # This is the key: other modules can add to this list
    subvolumes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "@immich" "@postgresql" ];
      description = "List of btrfs subvolume names to ensure exist at the filesystem top-level.";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # SERVICE
  ##############################################################################

    assertions = [{
      assertion = cfg.device != "";
      message = "services.btrfs-create-subvolumes.device must be set (e.g. /dev/disk/by-label/nixos).";
    }];

    # Create before mounting real filesystems that might depend on them
    systemd.services.btrfs-create-subvolumes = {
      description = "Create missing btrfs subvolumes (idempotent)";
      wantedBy = [ "local-fs-pre.target" ];
      before = [ "local-fs.target" ];
      unitConfig.DefaultDependencies = false;

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "btrfs-create-subvolumes" ''
          set -euo pipefail

          mkdir -p ${escapeShellArg cfg.topLevelMount}

          mount -t btrfs -o subvolid=5 ${escapeShellArg cfg.device} ${escapeShellArg cfg.topLevelMount}

          ${mkCreateLines}

          umount ${escapeShellArg cfg.topLevelMount}
        '';
      };
    };
  };
}
