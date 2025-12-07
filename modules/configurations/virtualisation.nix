# virtualisation config

{ config, lib, pkgs, user, ... }:

let
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

  config = mkIf (config.fleet.virtualisation.enable) {
    virtualisation = {

  ##############################################################################
  # PODMAN
  ##############################################################################

      podman = mkIf (elem "podman" config.fleet.virtualisation.tools) {
        enable = true;
        # dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
      };

  ##############################################################################
  # DOCKER
  ##############################################################################

      docker = mkIf (elem "docker" config.fleet.virtualisation.tools) {
        enable = true;
        storageDriver = "btrfs";
        autoPrune.enable = true;
      };

  ##############################################################################
  # WAYDROID
  ##############################################################################

      waydroid.enable = mkIf (elem "waydroid" config.fleet.virtualisation.tools) true;

  ##############################################################################
  # LIBVIRTD
  ##############################################################################

      libvirtd = mkIf (elem "libvirtd" config.fleet.virtualisation.tools) {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    };

    programs.virt-manager.enable = mkIf (elem "libvirtd" config.fleet.virtualisation.tools) true;

  ##############################################################################
  # GENERAL
  ##############################################################################

    users.users.${config.fleet.virtualisation.user} = {
      # extraGroups = mkIf (elem "libvirtd" config.fleet.virtualisation.tools) [ "libvirtd" ];
      # extraGroups = mkIf (elem "docker" config.fleet.virtualisation.tools) [ "docker" ];
      # extraGroups = [
      #   mkIf (elem "libvirtd" config.fleet.virtualisation.tools) "libvirtd"
      #   mkIf (elem "docker" config.fleet.virtualisation.tools) "docker"
      # ];
      extraGroups = filter (g: elem g config.fleet.virtualisation.tools) possibleTools;
    };

  };
}
