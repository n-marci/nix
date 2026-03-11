# pangolin config

{ config, lib, unstable, name, hosts, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.pangolin;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types elem;
  # database-directory = "var/lib/postgresql";
  # db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.pangolin = {
    enable = mkEnableOption "Enable pangolin";

    newt-nodes = mkOption {
      type = types.listOf types.str;
      default = [ "inspirion" ];
    };

    pangolin-nodes = mkOption {
      type = types.listOf types.str;
      default = [ "ovh-vps" ];
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # PANGOLIN SERVICE
  ##############################################################################

    services.pangolin = mkIf (elem name cfg.pangolin-nodes) {
      enable = true;
    };

  ##############################################################################
  # NEWT SERVICE
  ##############################################################################

    services.newt = mkIf (elem name cfg.newt-nodes) {
      enable = true;
      package = unstable.pkgs.fosrl-newt;
      environmentFile = config.sops.secrets.newt-env.path;
      settings.endpoint = "pangolin.neugebauer-marcel.com";
    };
    networking.firewall.allowedUDPPorts = mkIf (elem name cfg.newt-nodes) [ 21820 ]; # I am not 100% if this is needed on newt or on pangolin - maybe revise later

  # --- SECRETS ---
    sops.secrets.newt-env = mkIf (elem name cfg.newt-nodes) { };

  ##############################################################################
  # DISKO
  ##############################################################################

  # TODO
  
  ##############################################################################
  # BTRFS ON HOST
  ##############################################################################

    # services.btrbk.instances.pangolin.settings.volume."/".subvolume = mkIf (cfg.backup.enable && (name == cfg.host)) {
    #   "${service-dir}/pangolin" = {
    #     snapshot_create = "always";
    #   };
    #   "${database-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   "${db-export-directory}" = {
    #     snapshot_create = "always";
    #   };
    #   snapshot_dir = "/${snapshot-dir}/pangolin";
    #   target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/pangolin";
    # };

    # fleet.btrbk = mkIf (cfg.backup.enable) {
    #   enable = true;

    #   instances."pangolin".settings = mkIf (name == cfg.host) {
    #     volume."/".subvolume = {
    #       "${service-dir}/pangolin" = {
    #         snapshot_create = "always";
    #       };
    #       "${database-directory}" = {
    #         snapshot_create = "always";
    #       };
    #       "${db-export-directory}" = {
    #         snapshot_create = "always";
    #       };
    #       snapshot_dir = "/${snapshot-dir}/pangolin";
    #       target = "ssh://${hosts.${cfg.backup.target}.tailscale-ip}/${backup-dir}/${name}/pangolin";
    #     };
    #   };

  ##############################################################################
  # BTRFS ON TARGET
  ##############################################################################

      # target = mkIf (name == cfg.backup.target) true;
    # };

  };
}
