{ config, user, hosts,... }:

{
  ##############################################################################
  # custom services
  ##############################################################################

  fleet.monitoring.nodeExporter.enable = true;
  fleet = {
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
  };

  ##############################################################################
  # SSH
  ##############################################################################

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  users.users.${user}= {
    openssh.authorizedKeys.keys = [
      hosts.yoga.public-key
    ];
  };

  ##############################################################################
  # SECURITY
  ##############################################################################

  security.sudo.extraRules = [{
    users = [ "${user}" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }
    {
      command = "/nix/store/*/bin/switch-to-configuration";
      options = [ "NOPASSWD" ];
    }];
  }];

  ##############################################################################
  # NETWORKING
  ##############################################################################

  fleet.networking.static.enable = true;
  # networking = {
  #   defaultGateway = {
  #     address = "192.168.66.1";
  #     interface = "enp0s20u3";
  #   };
  #   nameservers = [
  #     "127.0.0.1"
  #     "9.9.9.9"
  #   ];
  #   interfaces.enp0s20u3.ipv4.addresses = [{
  #     address = "192.168.66.21";
  #     prefixLength = 24;
  #   }];
  # };

  services.tailscale = {
    # enable = true; # already enabled in common.nix
    authKeyFile = config.sops.secrets.tailscale-homelab-auth-key-one-time;
    extraUpFlags = [ "--ssh" ];
    # extraUpFlags = [ "--ssh" "--accept-routes" ];
      # -> used it in proxmox and I was able to use nextcloud
      # - maybe different scenario tho, since there tailscale was inside container - now it is on the host
  };

  ##############################################################################
  # SECRETS
  ##############################################################################

  sops = {
    secrets.tailscale-homelab-auth-key-one-time = { };
  };

}
