# matrix synapse configuration
# TODO make secrets folder only accessible by root

{config, vars, lib, unstable, host, pkgs, ...}:

with lib; {
  options = {
    synapse = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.synapse.enable) {
    services = {
      postgresql = {
        ensureUsers = [{
          name = "matrix-synapse";
          # ensureDBOwnership = true;
        }];
        # ensureDatabases = [ "matrix-synapse" ];
        initialScript = pkgs.writeText "synapse-init.sql" ''
          CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
            TEMPLATE template0
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
        # enable = true;
        # initialScript = pkgs.writeText "synapse-init.sql" ''
        #   CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        #     TEMPLATE template0
        #     LC_COLLATE = "C"
        #     LC_CTYPE = "C";
        # '';
      };
      matrix-synapse = {
        enable = true;
        # configureRedisLocally = true;
        settings = {
          # redis.enabled = true;
          server_name = "marcelnet.com";
          public_baseurl = "https://matrix.marcelnet.com";
          listeners = [{
            port = 8008;
            bind_addresses = [ "::1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [{
              names = [ "client" "federation" ];
              compress = true;
            }];
          }];
          enable_registration = true;
        };
      };

      # mautrix-whatsapp = {
      #   enable = true;
        
      # };
      # + program ffmpeg to be able to send gifs? https://docs.mau.fi/bridges/go/setup.html?bridge=whatsapp
    };
    # users.users.matrix-synapse = {
    #   isSystemUser = true;
    #   createHome = true;
    #   group = "matrix-synapse";
    # };
  };
}
