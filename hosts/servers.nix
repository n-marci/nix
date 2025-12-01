{ pkgs, vars, ... }:

{
  imports = (
    import ./modules/services
  ) ++ ([
    # ./modules/programs/helix.nix
  ]);

  ##############################################################################
  # custom services
  ##############################################################################

  fleet.monitoring.nodeExporter.enable = true;

  ##############################################################################
  # other services -REWRITE- ssh hardening as in newelle chat 5 server
  ##############################################################################

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  # Disable suspend when closing the lid
  # systemd targets sleep.target, suspend.target, hibernate.target, hybrid-sleep.target
  # seem to already be masked for some reason
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  services.tailscale = {
    # enable = true; # already enabled in common.nix
    extraUpFlags = [ "--ssh" ];
    # extraUpFlags = [ "--ssh" "--accept-routes" ];
      # -> used it in proxmox and I was able to use nextcloud
      # - maybe different scenario tho, since there tailscale was inside container - now it is on the host
  };

  ##############################################################################
  # virtualisation -REWRITE- only configure when actually running a docker app?
  ##############################################################################

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      # dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
    };
  };

  ##############################################################################
  # nix
  ##############################################################################

  nix = {
    settings.trusted-users = [ "@wheel" ];
    gc.options = "--delete-older-than 30d";
  };

  ##############################################################################
  # users
  ##############################################################################

  users.users.${vars.user}= {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzLokg14/USYIlrHwqWavA3DVPiLk+l9PlqwSi3l8Pa logan@franklin"
    ];
  };

  ##############################################################################
  # security -REWRITE- really needed to deploy with colmena? seems unsafe to me
  ##############################################################################

  security.sudo.wheelNeedsPassword = false;

  ##############################################################################
  # networking
  ##############################################################################
}
