{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      bash = {
        enable = true;

        # bashrcExtra = ''
        #   # # >>> mamba initialize >>>
        #   # # !! Contents within this block are managed by 'mamba init' !!
        #   # export MAMBA_EXE='/nix/store/j54g2ccy0mgs74qgzpnz4chk4xpvba81-micromamba-1.5.4/bin/micromamba';
        #   # export MAMBA_ROOT_PREFIX='/home/marci/micromamba';
        #   # __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
        #   # if [ $? -eq 0 ]; then
        #   #     eval "$__mamba_setup"
        #   # else
        #   #     alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
        #   # fi
        #   # unset __mamba_setup
        #   # # <<< mamba initialize <<<

        #   eval "$(direnv hook bash)"     # this needs to be the last line of .bashrc file
        # '';

        shellAliases = {
          c4 = "sgpt --model gpt-4 --role custom-chat --chat";
          c3 = "sgpt --model gpt-3.5-turbo --role custom-chat --chat";
        };
      };
    };
  };
}
