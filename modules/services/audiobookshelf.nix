# audio bookshelf configuration
# TODO make secrets folder only accessible by root

{config, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    audiobookshelf = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.audiobookshelf.enable) {
    services = {
      audiobookshelf = {
        enable = true;
        # dataDir = "/home/marci/tmp/paperless";
        # mediaDir = "${dataDir}/media";
        host = "0.0.0.0"; # default is localhost - 0.0.0.0 makes the instance available in the whole network
        # port = 8000; # default port is 8000
        openFirewall = true;
      };
    };
  };
}
