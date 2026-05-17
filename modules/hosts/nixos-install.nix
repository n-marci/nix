{ config, lib, pkgs, user, hosts, ... }:

let
  cfg = config.marci.hosts.nixos-install;
  inherit (lib) mkEnableOption mkIf;
in
{
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.hosts.nixos-install = {
    enable = mkEnableOption "Enable configuration for first installation";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

    ##############################################################################
    # FLEET
    ##############################################################################

    fleet = {
      node-exporter.enable = true;
      virtualisation = {
        enable = true;
        tools = [ "docker" ];
      };
    };

    ##############################################################################
    # other services -REWRITE- ssh hardening as in newelle chat 5 server
    ##############################################################################

    # Disable suspend when closing the lid
    # systemd targets sleep.target, suspend.target, hibernate.target, hybrid-sleep.target
    # seem to already be masked for some reason
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    ##############################################################################
    # NIX
    ##############################################################################

    nix = {
      gc.options = "--delete-older-than 30d";
      # settings.trusted-users = [ "${user}" ]; # might be needed so I can enable colmena remote cache
    };

    ##############################################################################
    # SSH
    ##############################################################################

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users = {
      marci.openssh.authorizedKeys.keys = [ # allow user marci to login with my devices
        hosts.yoga.public-key
      ];

      # colmena = { # create priviliged user for the deployment of colmena
      #   isNormalUser = true;
      # };
      colmena = { # create priviliged user for the deployment of colmena
        isSystemUser = true;
        group = "colmena";
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          hosts.yoga.public-key
        ];
      };
    };

    users.groups.colmena = { };

    ##############################################################################
    # SECURITY
    ##############################################################################

    security.sudo.extraRules = [{
      users = [ "${config.deployment.targetUser}" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
    # security.sudo.extraRules = [{
    #   users = [ "${user}" ];
    #   commands = [{
    #     command = "/run/current-system/sw/bin/nixos-rebuild";
    #     options = [ "NOPASSWD" ];
    #   }
    #   {
    #     command = "/run/current-system/sw/bin/switch-to-configuration";
    #     options = [ "NOPASSWD" ];
    #   }
    #   {
    #     command = "/nix/store/*/bin/switch-to-configuration";
    #     options = [ "NOPASSWD" ];
    #   }
    #   {
    #     command = "/run/current-system/sw/bin/systemctl";
    #     options = [ "NOPASSWD" ];
    #   }];
    # }];

    ##############################################################################
    # NETWORKING
    ##############################################################################

    fleet.networking.static.enable = true;
    services.tailscale = {
      # enable = true; # already enabled in common.nix
      # authKeyFile = config.sops.secrets.tailscale-homelab-auth-key-one-time.path;
      # extraUpFlags = [ "--ssh" ];
      extraSetFlags = [ "--advertise-exit-node" "--advertise-routes=100.0.0.0/8,192.168.66.0/24" ]; # advertise routes for my tailnet and local network
      extraUpFlags = [ "--ssh" "--accept-routes" ];
      useRoutingFeatures = "server"; # enable ip forwarding needed for exit node
        # -> used it in proxmox and I was able to use nextcloud
        # - maybe different scenario tho, since there tailscale was inside container - now it is on the host
    };

    ##############################################################################
    # SECRETS
    ##############################################################################

    # sops = {
    #   secrets.tailscale-homelab-auth-key-one-time = { };
    # };

  };
}
