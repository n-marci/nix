# virtualisation config

{ config, lib, pkgs, user, ... }:

let
  cfg = config.fleet.virtualisation;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem filter;
  possibleTools = [ "docker" "podman" "waydroid" "libvirtd" ];
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.virtualisation = {
    enable = mkEnableOption "Enable virtualisation";

    user = mkOption {
      type = types.str;
      default = user;
    };
    tools = mkOption {
      type = types.listOf types.str;
      default = [
        "docker"
        "libvirtd"
      ];
      description = "my default virtualisation methods \n must be a list containing ${possibleTools}";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    virtualisation = {

  ##############################################################################
  # PODMAN
  ##############################################################################

      podman = mkIf (elem "podman" cfg.tools) {
        enable = true;
        # dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
      };

  ##############################################################################
  # DOCKER
  ##############################################################################

      docker = mkIf (elem "docker" cfg.tools) {
        enable = true;
        storageDriver = "btrfs";
        autoPrune.enable = true;
      };

  ##############################################################################
  # WAYDROID
  ##############################################################################

      waydroid.enable = mkIf (elem "waydroid" cfg.tools) true;

  ##############################################################################
  # LIBVIRTD
  ##############################################################################

      libvirtd = mkIf (elem "libvirtd" cfg.tools) {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    };

    programs.virt-manager.enable = mkIf (elem "libvirtd" cfg.tools) true;

  ##############################################################################
  # GENERAL
  ##############################################################################

    users.users.${cfg.user} = {
      # extraGroups = mkIf (elem "libvirtd" cfg.tools) [ "libvirtd" ];
      # extraGroups = mkIf (elem "docker" cfg.tools) [ "docker" ];
      # extraGroups = [
      #   mkIf (elem "libvirtd" cfg.tools) "libvirtd"
      #   mkIf (elem "docker" cfg.tools) "docker"
      # ];
      extraGroups = filter (g: elem g cfg.tools) possibleTools;
    };

  };
}
