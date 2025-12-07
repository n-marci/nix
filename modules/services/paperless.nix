# paperless configuration
# TODO make secrets folder only accessible by root

{config, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    fleet.paperless = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.fleet.paperless.enable) {
    services = {
      paperless = {
        enable = true;
        # dataDir = "/home/marci/tmp/paperless";
        # mediaDir = "${dataDir}/media";
        address = "0.0.0.0"; # default is localhost - 0.0.0.0 makes the instance available in the whole network
        settings = {
          # PAPERLESS_DBHOST = "/run/postgresql";
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_ADMIN_USER = "caesar";
          # PAPERLESS_DEBUG = "true";
          PAPERLESS_URL = "https://paperless.marcelnet.com";
        };
        # passwordFile = "/home/marci/secrets/paperless.pass";
        passwordFile = config.sops.secrets.paperless-pass.path;
      };
    };

  ##############################################################################
  # SOPS
  ##############################################################################

    sops.secrets.paperless-pass = { };

  };
}
