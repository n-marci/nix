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
    # nixpkgs.config.permittedInsecurePackages = [
    #   "olm-3.2.16"
    # ];
    imports = [
      ./mautrix-whatsapp.nix
    ];

    services = {
      matrix-synapse = {
        enable = true;
        # configureRedisLocally = true;
        settings = {
          # redis.enabled = true;
          server_name = "marcelnet.com";
          public_baseurl = "https://matrix.marcelnet.com";
          # enable_metrics = true;
          enable_registration = true;
          listeners = [{
            port = 8008;
            # bind_addresses = [ "::1" ];
            bind_addresses = [ "0.0.0.0" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [{
              names = [ "client" "federation" ];
              compress = true;
            }];
          }];
        };
        extraConfigFiles = [ config.sops.secrets.matrix-shared-secret.path ];
      };

      postgresql = {
        ensureUsers = [{
          name = "matrix-synapse";
          # ensureDBOwnership = true;
        # }
        # {
        #   name = "mautrix-whatsapp";
        #   ensureDBOwnership = true;
        }];
        # ensureDatabases = [ "mautrix-whatsapp" ];
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

      # mautrix-whatsapp = {
      #   enable = true;
        
      # };
      # + program ffmpeg to be able to send gifs? https://docs.mau.fi/bridges/go/setup.html?bridge=whatsapp
    };

    # might not be needed since the tutorial i was following, was setting up also riot (matrix web client) and jitsi (video calling/livestream)
    networking.firewall = {
      allowedUDPPorts = [ 5349 5350 ];
      allowedTCPPorts = [ 80 443 3478 3479 8008 ];
    };
    # users.users.matrix-synapse = {
    #   isSystemUser = true;
    #   createHome = true;
    #   group = "matrix-synapse";
    # };
  };
}
