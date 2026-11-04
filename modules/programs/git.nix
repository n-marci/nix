{ config, lib, pkgs, user, private, ... }:

let
  cfg = config.marci.programs.git;
  inherit (lib) mkEnableOption mkIf;
  inherit (private) emails;
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
      home.packages = [ pkgs.git-crypt ]; # decrypts ./private in the nix repo

      programs = {
        git = {
          enable = true;
          signing.format = "openpgp";
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
