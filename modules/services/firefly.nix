
# btrbk configuration

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
          DB_PORT = 3306;
        };
      };
    };
  };
}
