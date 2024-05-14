{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      git = {
        enable = true;
        userName = "n-marci";
        userEmail = "neugebauer.marcel@web.de";
        aliases = {
          a = "add";
          c = "commit";
          co = "checkout";
          s = "status";
          cf = "config";
        };

        difftastic.enable = true;      # https://github.com/Wilfred/difftastic
      };
    };
  };
}
