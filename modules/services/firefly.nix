
# firefly configuration

{config, pkgs, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    firefly = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      # versioning = mkOption {
      #   type = types.bool;
      #   default = false;
      # };
    };
  };
  
  config = mkIf (config.firefly.enable) {

    services = {
      firefly-iii = {
        enable = true;
        settings = {
          APP_ENV = "production";
          APP_KEY_FILE = config.sops.secrets.firefly-pass.path;
          SITE_OWNER = "neugebauer.marce@web.de";
          # DB_CONNECTION = "mysql";
          # DB_HOST = "db";
          # DB_PORT = 3306;
          DB_CONNECTION = "pgsql";
          DB_HOST = "db";
          DB_PORT = 5432;
          DB_DATABASE = "firefly";
          # DB_USERNAME = "firefly";
          # DB_PASSWORD_FILE = config.sops.secrets.firefly-db-pass.path;
          # APP_URL = ''
          #   http(s)://''${config.services.firefly-iii.virtualHost}:5555
          # '';
        };
        # virtualHost = "localhost:5555";
        enableNginx = true;
      };

      # firefly does not create its own database - therefore we need to configure it ourselves
      # this configuration is severely lacking and NON-FUNCTIONAL tho
      postgresql = {
        enable = true;
        ensureDatabases = [ "firefly" ];
        ensureUsers = [{
          name = "firefly";
          ensureDBOwnership = true;
        }];
      };
    };

    # networking.firewall.allowedTCPPorts = [ 5555 ]; # not in documentation, just trying this to make it work - try without it later
  };
}
