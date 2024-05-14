
# paperless configuration
# TODO make secrets folder only accessible by root

{config, unstable, host, firefly, ...}:

{
  services = {
    firefly-iii = {
      enable = true;
      appKeyFile = "";
      nginx = {
        forceSSL = false;
        enableACME = false;
      };
      group = "nginx";
      database.createLocally = true;
    };
  };
}
