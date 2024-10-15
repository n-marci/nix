# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, unstable, vars, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.sops-nix.nixosModules.sops
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.timeout = 2;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.initrd.systemd.enable = true;                # what does this do?

  # update the kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "desktop"; # Define your hostname.

  # # open port in firewall for wireguard home connection
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

  gnome.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/desktop.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile= "/home/marci/.config/sops/age/keys.txt";

    secrets.syncthing-key = { };
    secrets.syncthing-cert = { };
    secrets.sync-id-inspirion = { };
    secrets.sync-id-desktop = { };
    secrets.sync-id-yoga = { };
    secrets.sync-id-note = { };
    secrets.sync-id-helix-a = { };
    secrets.sync-id-helix-b = { };
  };


  environment.systemPackages = with unstable; [
    # cli tools
    # qmk
    nvtopPackages.nvidia
    # mesa
    
    # games
    wineWowPackages.stagingFull
    jdk17
    # prismlauncher
    # optifine
    # lutris
    # steam

    # gpu
    # cudaPackages.cudatoolkit
    # cudaPackages.cudnn
    # cudaPackages.libnpp

    # blender with cuda
    # (blender.override {
    #   cudaSupport = true;
    # })

  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    acceleration = "cuda";
  };

  # nvidia options
  hardware.graphics = {
    enable = true;
    # driSupport = true;
    # driSupport32Bit = true;
  };

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];
  # services.xserver.videoDrivers = ["nouvea"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    # open = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  };

  # optimize for more battery life
  # powerManagement.powertop.enable = true;

  system.stateVersion = "22.11"; # Did you read the comment?

  home-manager.users.${vars.user} = {
    home = {
      stateVersion = "22.11";
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
