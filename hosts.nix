{ secrets }:

# disable password login over ssh
# only allow ssh key login

let
  sync-ids = import "${secrets}/syncthing-ids.nix";
in
{
  # ==============================================
  # desktops
  # ==============================================

  yoga = {
    ip = "dynamic";
    user = "marci";
    tags = [
      "desktop"
    ];
    sync-id = sync-ids.yoga;
    bkp-target = "linc-n2";
    access = [ ];
  };

  desktop = {
    ip = "dynamic";
    user = "marci";
    tags = [
      "desktop"
    ];
    sync-id = sync-ids.desktop;
    bkp-target = "linc-n2";
    access = [ "yoga" ];
  };

  # ==============================================
  # homelab
  # ==============================================

  inspirion = {
    ip = "192.168.66.21";
    user = "marci";
    tags = [
      "server"
    ];
    sync-id = sync-ids.inspirion;
    bkp-target = "linc-n2";
    access = [ "yoga" "desktop" ];
  };

  linc-n2 = {
    ip = "192.168.66.22";
    user = "marci";
    tags = [
      "server"
      "storage"
    ];
    sync-id = sync-ids.linc-n2;
    bkp-target = "linc-n2";
    access = [ "yoga" "desktop" "inspirion" ];
  };

  helix-s = {
    ip = "192.168.66.23";
    user = "marci";
    tags = [
      "server"
      "storage"
    ];
    sync-id = sync-ids.helix-s;
    bkp-target = "linc-n2";
    access = [ "yoga" "desktop" "linc-n2" ];
  };
}
