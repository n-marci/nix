{ config, pkgs, unstable, modulesPath, name, user, hosts, secrets, lts-kernel, ... }:

let
  emails = import "${secrets}/email-addresses.nix";
in
{
  imports = (
      # import ../../modules/configurations ++
      # import ../../modules/desktops ++
      # import ../../modules/programs ++
      import ../../modules/services
    ) ++ ([
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")

      # ../../modules/hosts/baremetals.nix
      # ../../modules/hosts/vms.nix
      ../../modules/hosts/common.nix
      ../../modules/hosts/servers.nix
      ../../modules/hosts/mesh.nix
      ./hardware-configuration.nix
      ./disk-config.nix

      # ../../modules/programs/helix.nix
      ../../modules/configurations/networking.nix
      ../../modules/configurations/virtualisation.nix
    ]);

  ##############################################################################
  # FLEET
  ##############################################################################

  marci = {

    # TODO: merge config from nixos-anywhere-example and my colmena config
    # TODO: with the merge just include the basic disko config
    # TODO: look through modules if everything the common configurations work out
    # TODO: configure pangolin
    
    hosts = {
      common.enable = true; # common enables sops and tailscale. May be not necessary for the vps
    #   server.enable = true;
    #   mesh.enable = true;
    };
  };

  fleet = {
    # TODO
  };

  nix.settings.trusted-users = [ "colmena" ];

  ##############################################################################
  # PANGOLIN
  ##############################################################################

  services.pangolin = {
    enable = true;
    package = unstable.pkgs.fosrl-pangolin;
    openFirewall = true;
    baseDomain = "neugebauer-marcel.com";
    letsEncryptEmail = emails.web-de;
    environmentFile = "/run/keys/pangolin-env";
    dnsProvider = "ovh";
    # settings = {
    #   domains.domain1 = {
    #     prefer_wildcard_cert = true;
    #   };
    # };
  };

  services.traefik = {
    package = unstable.pkgs.traefik;
    environmentFiles = [ "/run/keys/traefik-env" ];
  };

  ##############################################################################
  # BOOT
  ##############################################################################

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # set the timeout for the screen going dark - value in seconds
  boot.kernelParams = [ "consoleblank=120" ];

  boot.kernelPackages = lts-kernel;

  ##############################################################################
  # SSH
  ##############################################################################

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      # PermitRootLogin = "no";
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = [ # allow user marci to login with my devices
      hosts.yoga.public-key
    ];

    ${user}.openssh.authorizedKeys.keys = [ # allow user marci to login with my devices
      hosts.yoga.public-key
    ];

    colmena = { # create priviliged user for the deployment of colmena
    # ${config.deployment.targetUser} = { # create priviliged user for the deployment of colmena
      isSystemUser = true;
      group = "colmena";
      # group = "${config.deployment.targetUser}";
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = [
        hosts.yoga.public-key
      ];
    };
  };

  users.groups.colmena = { };
  # users.groups.${config.deployment.targetUser} = { };

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

  services.fail2ban.enable = true;

  ##############################################################################
  # STATE VERSION
  ##############################################################################

  system.stateVersion = "25.11"; # Did you read the comment?

}
