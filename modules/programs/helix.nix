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
            m.l = {
              t = [ "search_selection" ":insert-output echo '\\text{'" "ensure_selections_forward" "collapse_selection" "delete_selection" "search_next" "search_prev" ":append-output echo '}'" "ensure_selections_forward" "collapse_selection" "delete_selection" ];
              i = [ "search_selection" ":insert-output echo '\\textit{'" "ensure_selections_forward" "collapse_selection" "delete_selection" "search_next" "search_prev" ":append-output echo '}'" "ensure_selections_forward" "collapse_selection" "delete_selection" ];
              c = [ ":insert-output echo '\\textcolor{Blue}{}'" "ensure_selections_forward" "collapse_selection" "delete_selection" "move_char_left" "insert_mode" ];
              r = [ "search_selection" ":insert-output echo '\\textcolor{Blue}{needs ref}'" "ensure_selections_forward" "collapse_selection" "delete_selection" ];
            };
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

        languages= {

          language-server.ltex = {
            command = "${pkgs.ltex-ls}/bin/ltex-ls";
            config.ltex.dictionary."en-US" = [ "Modelica" "SysML" "aeroponic" ];
          };
          
          language = [{
            name = "latex";
            language-servers = [ "texlab" "ltex" ];
          }];
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
