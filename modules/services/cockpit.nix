# cockpit configuration

{config, vars, lib, unstable, host, ...}:

with lib; {
  options = {
    cockpit = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  
  config = mkIf (config.cockpit.enable) {
    services = {
      cockpit = {
        enable = true;
        openFirewall = true;
        # port = 9090;
      };
    };
  };
}
