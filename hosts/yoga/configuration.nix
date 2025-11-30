{ pkgs, name, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # inputs.sops-nix.nixosModules.sops
    ];

  ##############################################################################
  # boot
  ##############################################################################

  system.stateVersion = "23.11"; # Did you read the comment?

  home-manager.users."marci" = {
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
