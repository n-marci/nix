# traccar configuration
# TODO make secrets folder only accessible by root

{config, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    traccar = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.traccar.enable) {
    services = {
      traccar = {
        enable = true;
      };
    };
  };
}
