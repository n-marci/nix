
# actual budget configuration

{config, pkgs, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    actualbudget = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.actualbudget.enable) {

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        actualbudget = {
          autoStart = true;
          image = "docker.io/actualbudget/actual-server:latest";
          ports = [ "5006:5006" ];
          volumes = [ "/var/lib/actualbudget:/data" ];
          # extraOptions = [ "--pull=always" "--restart=unless-stopped" ];
        };
      };
    };
  };
}
