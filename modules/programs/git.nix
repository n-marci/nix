{ pkgs, user, ... }:

{
  home-manager.users.${user} = {
    programs = {
      git = {
        enable = true;
        settings = {
          user.name = "n-marci";
          user.email = "neugebauer.marcel@web.de";
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
}
