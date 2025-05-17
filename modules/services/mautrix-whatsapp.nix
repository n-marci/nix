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
    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];
    services = {
      mautrix-whatsapp = {
        enable = true;
        settings = {
          network.history_sync.request_full_sync = true;

          homeserver = {
            address = "http://localhost:8008";
            # address = "https://matrix.marcelnet.com";
            domain = "marcelnet.com";
            async_media = true;
          };

          bridge = {
            permissions = {
              "*" = "relay";
              "marcelnet.com" = "user";
              "@caesar:matrix.marcelnet.com" = "admin";
            };
          };

          database = {
            type = "postgres";
            uri = "postgresql:///mautrix-whatsapp?host=/var/run/postgresql";
          };

          backfill = {
            enabled = true;
            max_initial_messages = 2147483646;
            max_catchup_messages = 2147483646;
            threads.max_initial_messages = 2147483646;
          };

          encryption = {
            allow = true;
            default = true;
            require = true;
          };

          logging.writers = [{
            type = "journald";
          }];
      #     appservice = {
      #       # as_token = "autogen";
      #       # bot = {
      #       #   displayname = "WhatsApp Bridge Bot";
      #       #   username = "whatsappbot";
      #       # };
      #       database = {
      #         type = "sqlite3";
      #         uri = "/var/lib/mautrix-whatsapp/mautrix-whatsapp.db";
      #       };
      #       # hostname = "[::]";
      #       # hs_token = "autogen";
      #       id = "whatsapp";
      #       # port = 29318;
      #     };
      #     bridge = {
      #       # command_prefix = "!wa";
      #       # displayname_template = "{{if .BusinessName}}{{.BusinessName}}{{else if .PushName}}{{.PushName}}{{else}}{{.JID}}{{end}} (WA)";
      #       # double_puppet_server_map = { };
      #       # login_shared_secret_map = { };
      #       # permissions = {
      #       #   "*" = "relay";
      #       # };
      #       # relay = {
      #       #   enabled = true;
      #       # };
      #       # username_template = "whatsapp_{{.}}";
      #       # encryption = {
      #       #   allow = true;
      #       #   default = true;
      #       #   require = true;
      #       # };
      #       # history_sync = {
      #       #   request_full_sync = true;
      #       # };
      #       # private_chat_portal_meta = true;
      #       # provisioning = {
      #       #   shared_secret = "disable";
      #       # };
      #       permissions = {
      #         "*" = "relay";
      #         "marcelnet.com" = "user";
      #         "@caesar:matrix.marcelnet.com" = "admin";
      #       };
      #     };
      #     logging = {
      #       min_level = "info";
      #       writers = [
      #         {
      #           format = "pretty-colored";
      #           time_format = " ";
      #           type = "stdout";
      #         }
      #       ];
      #     };
      #     };
      # };
      postgresql = {
        ensureUsers = [{
          name = "mautrix-whatsapp";
          ensureDBOwnership = true;
        }];
        ensureDatabases = [ "mautrix-whatsapp" ];
      };

      # + program ffmpeg to be able to send gifs? https://docs.mau.fi/bridges/go/setup.html?bridge=whatsapp
    };

    # might not be needed since the tutorial i was following, was setting up also riot (matrix web client) and jitsi (video calling/livestream)
    # networking.firewall = {
    #   allowedUDPPorts = [ 5349 5350 ];
    #   allowedTCPPorts = [ 80 443 3478 3479 8008 ];
    # };
    # users.users.matrix-synapse = {
    #   isSystemUser = true;
    #   createHome = true;
    #   group = "matrix-synapse";
    # };
  };
}
