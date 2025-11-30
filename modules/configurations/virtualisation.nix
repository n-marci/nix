# virtualisation config

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.virtualisation = {
    enable = mkEnableOption "Enable virtualisation";

    user = mkOption {
      type = types.str;
      default = "marci";
    };
    tools = mkOption {
      type = types.listOf types.str;
      default = [
        "docker"
        "libvirtd"
      ];
      description = "my default virtualisation methods";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (config.fleet.virtualisation.enable) {
    virtualisation = {
      podman = mkIf (elem "podman" config.fleet.virtualisation.tools) {
        enable = true;
        # dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
      };

      docker.enable = mkIf (elem "docker" config.fleet.virtualisation.tools) true;
    users.users.${config.fleet.virtualisation.user} = mkIf (elem "libvirtd" config.fleet.virtualisation.tools) {
      extraGroups = [ "libvirtd" ];
    };

      waydroid.enable = mkIf (elem "waydroid" config.fleet.virtualisation.tools) true;

      libvirtd = mkIf (elem "libvirtd" config.fleet.virtualisation.tools) {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    };


  };
}
