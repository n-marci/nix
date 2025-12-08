{ secrets }:

# disable password login over ssh
# only allow ssh key login

let
  sync-ids = import "${secrets}/syncthing-ids.nix";
  emails = import "${secrets}/email-addresses.nix";
in
{
  ##############################################################################
  # DESKTOPS
  ##############################################################################

  yoga = {
    ip = "dynamic";
    user = "marci";
    graphics = "intel";
    tags = [
      "desktop"
    ];
    sync-id = sync-ids.yoga;
    bkp-target = "linc-n2";
    access = [ ];
    public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbTG0TMrD6NK8zO8pGzmL6ZybgrZhWJMsiFHvjhMpKH ${emails.web-de}";
  };

  desktop = {
    ip = "dynamic";
    user = "marci";
    graphics = "nvidia";
    tags = [
      "desktop"
    ];
    sync-id = sync-ids.desktop;
    bkp-target = "linc-n2";
    access = [ "yoga" ];
  };

  ##############################################################################
  # PHONES
  ##############################################################################

  s20-plus = {
    tags = [
      "phone"
    ];
    sync-id = sync-ids.s20-plus;
  };

  note-9 = {
    tags = [
      "phone"
    ];
    sync-id = sync-ids.note;
  };

  ##############################################################################
  # HOMELAB
  ##############################################################################

  inspirion = {
    ip = "192.168.66.21";
    interface = "enp0s20u3";
    user = "marci";
    tags = [
      "homelab"
    ];
    sync-id = sync-ids.inspirion;
    bkp-target = "linc-n2";
    access = [ "yoga" "desktop" ];
  };

  linc-n2 = {
    ip = "192.168.66.22";
    user = "marci";
    tags = [
      "homelab"
      "storage"
    ];
    sync-id = sync-ids.linc-n2;
    bkp-target = "linc-n2";
    access = [ "yoga" "desktop" "inspirion" ];
  };

  helix-s = {
    ip = "192.168.66.23";
    interface = "wlp6s0";
    user = "marci";
    tags = [
      "homelab"
      "storage"
      "bkp"
    ];
    sync-id = sync-ids.helix-s;
    bkp-target = "linc-n2";
    access = [ "yoga" "desktop" "linc-n2" ];
  };
}
