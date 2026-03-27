{ config, lib, pkgs, user, secrets, ... }:

let
  cfg = config.marci.programs.git;
  inherit (lib) mkEnableOption mkIf;
  emails = import "${secrets}/email-addresses.nix";
in
{
  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.programs.git = {
    enable = mkEnableOption "Enable configuration for the git program";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    home-manager.users.${user} = {
      programs = {
        git = {
          enable = true;
          settings = {
            user.name = "n-marci";
            user.email = emails.web-de;
            alias = {
              a = "add";
              c = "commit";
              co = "checkout";
              s = "status";
              cf = "config";
            };
          };
        };

        difftastic = {
          enable = true;      # https://github.com/Wilfred/difftastic
          git.enable = true;
        };
      };
    };
  };
}
