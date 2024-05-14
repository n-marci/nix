{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
