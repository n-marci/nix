# traccar configuration
# TODO make secrets folder only accessible by root

{config, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    fleet.traccar = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.fleet.traccar.enable) {
    services = {
      traccar = {
        enable = true;
      };
    };
  };
}
