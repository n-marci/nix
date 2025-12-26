# searxng configuration

{ config, unstable, host, ... }:

{
  services.searx = {
    enable = true;
    environmentFile = "/home/marci/secrets/searx.env";
    settings = {
      server.secret_key = "";
    };
    # redisCreateLocally = true;
    # runInUwsgi = true;
  };
}
