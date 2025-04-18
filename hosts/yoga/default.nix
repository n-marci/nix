# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs,  unstable, vars, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.sops-nix.nixosModules.sops
      # <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # update the kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_7;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.initrd.kernelModules = [ "amdgpu" ];

  boot = {
    plymouth = {
      enable = true;
      theme = "dna";
      # theme = "colorful_sliced";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "dna" ];
          # selected_themes = [ "colorful_sliced" ];
        })
      ];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      #########################################
      # Silent Boot for plymouth boot animation
      #########################################
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "logLevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"

      #########################################
      # Energy savings maybe?
      #########################################
      "mem_sleep_default=deep" 
      "pcie_aspm.policy=powersupersave" 
    ];
  };

  # add workaround for wifi chip
  # iwlwifi workaround to make bluetooth work?
  # boot.extraModprobeConfig = ''
  #   options rtw89_pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y
  #   options rtw89pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y
  #   options iwlwifi bt_coex_active=0
  # '';

  networking.hostName = "yoga"; # Define your hostname.

  # open port in firewall for wireguard home connection
  networking.firewall = {
    logReversePathDrops = true;
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51726 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51726 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51726 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51726 -j RETURN || true
    '';
  };

  # Configure console keymap
  console.keyMap = "de";

  gnome.enable = true;

  environment.systemPackages = with unstable; [
    gnome-power-manager
    nssmdns
    # radeontop      # utility to monitor graphics
    # blender
    # libdrm
  ];

  # screen rotation and stuff
  hardware.sensor.iio.enable = true;

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # amd specific stuff
  # systemd.tmpfiles.rules = [
  #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  # ];

  # hardware.opengl.extraPackages = with pkgs; [
  #   # rocm-opencl-icd
  #   # rocm-opencl-runtime
  #   rocmPackages.clr.icd
  #   amdvlk
  # ];
  # hardware.opengl.extraPackages32 = with pkgs; [
  #   driversi686Linux.amdvlk
  # ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      vpl-gpu-rt # for intel quick sync video
    ];
    extraPackages32 = with pkgs.pkgsi686linux; [
      intel-media-driver
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };

  # optimize for more battery life
  powerManagement.powertop.enable = true;
  # powerManagement.cpuFreqGovernor = "schedutil";

  sops = {
    defaultSopsFile = ../../secrets/yoga.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile= "/home/marci/.config/sops/age/keys.txt";

    secrets.syncthing-key = { };
    secrets.syncthing-cert = { };
  };

  # setup fingerprint scanner
  # services.fprintd = {
  #   enable = true;
  #   tod = {
  #     enable = true;
  #     driver = pkgs.libfprint-2-tod1-goodix;
  #   };
    
  # };
  
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
