{ pkgs, name, user, ... }:

{

  fleet = {

  ##############################################################################
  # IMMICH
  ##############################################################################

    immich = {
      enable = true;
      host = "inspirion";
      backup = {
        enable = true;
        target = "helix-s";
      };
    };

  ##############################################################################
  # NEXTCLOUD
  ##############################################################################

    nextcloud = {
      enable = true;
      host = "inspirion";
      backup = {
        enable = true;
        target = "helix-s";
      };
    };

  ##############################################################################
  # SYNCTHING
  ##############################################################################

    # syncthing = {
    #   enable = true;
    #   home = [ "yoga" "unicorn" ];
    #   server = [ "inspirion" ];
    #   other = [ "s20-plus" "s20-plus-wa" "note-9" ];
    #   folders = [ "nix" "secrets" "wallpapers" "obsidian" "logseq" "live" "linux" "idle" "archive" "dev" "phone" "whatsapp"];

    #   backup = {
    #     enable = true;
    #     target = "helix-s";
    #   };
    # };

  };
}
