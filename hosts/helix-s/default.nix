# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, inputs, unstable, vars, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.sops-nix.nixosModules.sops
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # update the kernel
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "consoleblank=120" ];

  ##############################################################################
  # configured services
  ##############################################################################

  syncthing = {
    enable = true;
    versioning = lib.mkForce false;
    storeInBackupLocation = true;
  };

  paperless.enable = lib.mkForce false;
  nextcloud.enable = lib.mkForce false;
  immich.enable = lib.mkForce false;
  actualbudget.enable = lib.mkForce false;
  adguard.enable = lib.mkForce false;
  mealie.enable = lib.mkForce false;
  nginx.enable = lib.mkForce false;
  cockpit.enable = lib.mkForce false;


  ##############################################################################
  # backup services
  ##############################################################################

  btrbk = {
    enable = true;
    node = lib.mkForce "target";
  };

  # postgresql backup
  pg-bkp = {
    enable = lib.mkForce false;
    databases = [ "nextcloud" "immich" ];
  };

  ##############################################################################
  # storage setup
  ##############################################################################

  fileSystems."/media/bkp" = {
    device = "/dev/disk/by-uuid/a6237260-b23e-49c2-963c-c9a9b97b5190";
    fsType = "btrfs";
    options = [
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # disable controller wakeups
  # maybe helps with kernel panics
  # boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

  # add workaround for wifi chip
  # iwlwifi workaround to make bluetooth work?
  # boot.extraModprobeConfig = ''
  #   options rtw89_pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y
  #   options rtw89pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y
  #   options iwlwifi bt_coex_active=0
  # '';

  networking.hostName = "helix-s"; # Define your hostname.

  # open port in firewall for wireguard home connection
  # networking.firewall = {
  #   logReversePathDrops = true;
  #   extraCommands = ''
  #     ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51726 -j RETURN
  #     ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51726 -j RETURN
  #   '';
  #   extraStopCommands = ''
  #     ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51726 -j RETURN || true
  #     ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51726 -j RETURN || true
  #   '';
  # };

  # Configure console keymap
  console.keyMap = "de";

  # gnome.enable = true; # sshhhh you are a server box now

  # syncthing.enable = lib.mkForce false;
  # services.syncthing.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/helix-s.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile= "/home/marci/.config/sops/age/keys.txt";

    secrets.syncthing-key = { };
    secrets.syncthing-cert = { };

    # secrets.sync-id-inspirion = { };
    # secrets.sync-id-desktop = { };
    # secrets.sync-id-yoga = { };
    # secrets.sync-id-note = { };
    # secrets.sync-id-helix-a = { };
    # secrets.sync-id-helix-b = { };
  };

  environment.systemPackages = with unstable; [
    lshw
    # gnome-power-manager
    # nssmdns
    # intel-media-driver
    # radeontop      # utility to monitor graphics
    # blender
    # libdrm
  ];

  # screen rotation and stuff
  # hardware.sensor.iio.enable = true;

  # hardware.bluetooth.settings = {
  #   General = {
  #     Experimental = true;
  #   };
  # };

  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     intel-media-driver
  #     # intel-vaapi-driver
  #     libvdpau-va-gl
  #     vpl-gpu-rt # for intel quick sync video
  #   ];
  #   extraPackages32 = with pkgs.pkgsi686linux; [
  #     intel-media-driver
  #   ];
  # };
  # environment.sessionVariables = {
  #   LIBVA_DRIVER_NAME = "iHD";
  #   VDPAU_DRIVER = "va_gl";
  # };

  # optimize for more battery life
  powerManagement.powertop.enable = true;
  # powerManagement.cpuFreqGovernor = "schedutil";

  # services.xserver.displayManager.job.preStart = "${pkgs.libdrm}/bin/proptest -M amdgpu -D /dev/dri/card0 107 connector 109 7";

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

  system.stateVersion = "24.05"; # Did you read the comment?

  home-manager.users.${vars.user} = {
    home = {
      stateVersion = "24.05";
    };

    programs = {
      home-manager.enable = true;
    };

    nix = {
      settings.experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
