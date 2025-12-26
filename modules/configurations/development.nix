# development environment config

{ config, lib, pkgs, ... }:

let
  cfg = config.fleet.development;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in
{
  
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.fleet.development = {
    enable = mkEnableOption "Enable different development environments";

    apps = mkOption {
      type = types.listOf types.str;
      default = [
        "qmk"
        "zmk"
        "arduino"
        "raspberry"
      ];
      description = "my default development environments";
    };
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {

  ##############################################################################
  # WORK IN PROGRESS - maybe put development into extra modules/development folder
  ##############################################################################

    nixpkgs.overlays = [
      (final: prev:
      {
        arduino-cli = prev.arduino-cli.overrideAttrs ( old: {
          src = prev.fetchFromGithub {
            owner = "arduino";
            repo = "arduino-cli";
            rev = "refs/tags/v1.1.0";
            hash = "";
          };
        });
      })
    ];

    nix.settings = {
      substituters = [ "https://tweag-jupyter.cachix.org" ];
      trusted-public-keys = [ "tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g=" ];
    };

    environment.systemPackages = with pkgs; [
      # poetry
      # conda # out of date
      # micromamba
      texliveFull
      arduino-cli
      pioasm
      minicom
      julia-bin
      qmk
      qmk-udev-rules
    ];

    services.udev.extraRules = ''
      # udev rule for user level access to Preonic keyboard connected with USB
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", MODE:="0666"

      # udev rule for user level access to Arduino Uno R4 connected with USB
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", MODE:="0666"

      # make raspberry pi pico accessible without sudo
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", MODE:="0666"
      # SUBSYSTEM!="usb_device", ACTION!="add", GOTO="rpi2_end"
      # Raspberry Pi Pico
      # ATTR{idVendor}=="2e8a", ATTRS{idProduct}=="000f", MODE="660", GROUP="plugdev"
      # LABEL="rpi2_end"

      # udev rules to make ubports installer work (installed in distrobox deb-13)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0e79", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0502", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="413c", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="091e", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="12d1", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="24e3", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2116", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0482", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="17ef", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1004", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="22b8", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0409", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2080", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2257", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="10a9", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1d4d", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0471", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04da", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1f53", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04dd", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fce", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0930", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="19d2", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2ae5", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2a45", MODE="0666", GROUP="plugdev"
    '';

  };
}
