{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          theme = "snazzy-extended";
          editor = {
            line-number = "relative";
            # scrolloff = 15;        # number of lines of padding around edge when scrolling
            cursor-shape = {
              # insert = "bar";
              # normal = "block";
              # select = "underline";
            };
            cursorline = true;
            cursorcolumn = true;
            color-modes = true;
            indent-guides.render = true;
            soft-wrap.enable = true;
            # indent-guides.character = "┆";

            idle-timeout = 0;      # timeout before autocomplete kicks in

            bufferline = "multiple";
          };

          keys.normal = {
            X = "extend_line_above";
            # "A-x" = "shrink_line_below";
            # "A-X" = "shrink_line_above";
          };
        };

        themes = {
          snazzy-extended = {
            "inherits" = "snazzy";
            "ui.cursor.primary.normal" = { fg = "background"; bg = "white"; };
            "ui.cursor.primary.insert" = { fg = "background"; bg = "green"; };
            "ui.cursor.primary.select" = { fg = "background"; bg = "magenta"; };
            # "ui.cursor.primary" = { modifiers = [ "reversed" ]; };
            # "ui.virtual.indent-guide" = { fg = "grey"; };
            "ui.virtual.indent-guide" = "black";
          };
        };

        # language config for latex - did not build on save tho?
        # languages = {
        #   language = [{
        #     name = "latex";
        #   }];
        #   language-server.texlab = {
        #     config = {
        #       auxDirectory = "build";
        #       forwardSearch = {
        #         executable = "zathura";
        #         args = [ "--synctex-forward" "%l:%c:%f" "%p" ];
        #       };
        #       build = {
        #         forwardSearchAfter = true;
        #         onSave = true;
        #       };
        #     };
        #   };
        # };
      };
    };
  };
}
