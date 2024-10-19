# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, vars, inputs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.sops-nix.nixosModules.sops
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.configurationLimit = 3;
  # boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # set the timeout for the screen going dark - value in seconds
  boot.kernelParams = [ "consoleblank=120" ];

  # update the kernel
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  # boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "inspirion"; # Define your hostname.

  # Configure console keymap
  console.keyMap = "de";

  # users.users.marci.createHome = true;
  # users.users.marci.homeMode = "750";

  # gnome.enable = true;

  # secrets
  sops = {
    defaultSopsFile = ../../secrets/inspirion.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/marci/.config/sops/age/keys.txt";

    secrets.syncthing-key = { };
    secrets.syncthing-cert = { };
    secrets.paperless-pass = { };
    # secrets.firefly-pass = { 
    #   owner = "firefly-iii";
    # };
    # secrets.firefly-db-pass = {
    #   owner = "firefly-iii";
    # };
    # secrets.nextcloud-pass = {
    #   owner = "nextcloud";
    # };
    secrets.sync-id-inspirion = { };
    secrets.sync-id-desktop = { };
    secrets.sync-id-yoga = { };
    secrets.sync-id-note = { };
    secrets.sync-id-helix-a = { };
    secrets.sync-id-helix-b = { };
  };

  environment.systemPackages = with unstable; [
    lshw
  ];

  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  # };

  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = true;
  #   open = false;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # };

  # optimize for more battery life
  powerManagement.powertop.enable = true;
  # powerManagement.cpuFreqGovernor = "schedutil";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "23.05"; # Did you read the comment?
  system.stateVersion = "23.11"; # Did you read the comment?

  home-manager.users.${vars.user} = {
    home = {
      stateVersion = "23.11";
    };

    programs = {
      home-manager.enable = true;
    };

    nix = {
      # package = pkgs.nix;
      settings.experimental-features = [ "nix-command" "flakes" ];
    };
  };

}
