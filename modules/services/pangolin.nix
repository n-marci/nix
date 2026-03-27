# pangolin config

{ config, lib, unstable, name, hosts, secrets, service-dir, snapshot-dir, backup-dir, ... }:

let
  cfg = config.marci.services.pangolin;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault mkMerge types elem;
  emails = import "${secrets}/email-addresses.nix";
  # database-directory = "var/lib/postgresql";
  # db-export-directory = "var/lib/psql-export";
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.services.pangolin = {
    enable = mkEnableOption "Enable pangolin";

    nodes = {
      newt = mkOption {
        type = types.listOf types.str;
        default = [ "inspirion" ];
      };

      pangolin = mkOption {
        type = types.listOf types.str;
        default = [ "ovh-vps" ];
      };
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # PANGOLIN SERVICE
  ##############################################################################

    # services.pangolin = mkIf (elem name cfg.nodes.pangolin) {
    #   enable = true;
    # };
    services.pangolin = mkIf (elem name cfg.nodes.pangolin) {
      enable = true;
      package = unstable.pkgs.fosrl-pangolin;
      openFirewall = true;
      baseDomain = "neugebauer-marcel.com";
      letsEncryptEmail = emails.web-de;
      environmentFile = config.sops.secrets.pangolin-env.path;
      dnsProvider = "ovh";
      settings = {
        domains.domain1 = {
          prefer_wildcard_cert = true;
        };
      };
    };

    services.traefik = mkIf (elem name cfg.nodes.pangolin) {
      package = unstable.pkgs.traefik;
      environmentFiles = [ config.sops.secrets.traefik-env.path ];
    };

  # --- SECRETS ---
    sops.secrets.pangolin-env = mkIf (elem name cfg.nodes.pangolin) { };
    sops.secrets.traefik-env = mkIf (elem name cfg.nodes.pangolin) { };

  ##############################################################################
  # NEWT SERVICE
  ##############################################################################

    services.newt = mkIf (elem name cfg.nodes.newt) {
      enable = true;
      package = unstable.pkgs.fosrl-newt;
      environmentFile = config.sops.secrets.newt-env.path;
      settings.endpoint = "https://pangolin.neugebauer-marcel.com";
    };
    # networking.firewall.allowedUDPPorts = mkIf (elem name cfg.nodes.newt) [ 21820 ]; # I am not 100% if this is needed on newt or on pangolin - maybe revise later

  # --- SECRETS ---
    sops.secrets.newt-env = mkIf (elem name cfg.nodes.newt) { };

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
