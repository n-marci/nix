{ config, lib, pkgs, user, ... }:

let
  cfg = config.marci.programs.bash;
  inherit (lib) mkEnableOption mkIf;
in
{

  ##############################################################################
  # OPTIONS
  ##############################################################################

  options.marci.programs.bash = {
    enable = mkEnableOption "Enable configuration for the bash shell";
  };
  
  ##############################################################################
  # CONFIG
  ##############################################################################

  config = mkIf (cfg.enable) {
    home-manager.users.${user} = {
      programs = {
        bash = {
          enable = true;

          bashrcExtra = ''
            # shows the current startup art in new terminal window
            echo '
              ／l、"
           🗦（ﾟ๓ ｡ ７ " 
            ⠀ l、ﾞ~ヽ"
            ⠀ じしf_, )ノ"
            '

            # setup vi keybindings in bash
            # set -o vi
          '';

          shellAliases = {
            c4 = "sgpt --model gpt-4 --role custom-chat --chat";
            c3 = "sgpt --model gpt-3.5-turbo --role custom-chat --chat";
          };
        };

        readline.extraConfig = ''
          "\C-h": backward-kill-word
        '';
      };
    };
  };
}
