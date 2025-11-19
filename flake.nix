  {

  ##############################################################################
  # DESCRIPTION
  ##############################################################################

  description = "Configuration for all my computing devices (I am missing the NixOS Phone still)";

  ##############################################################################
  # INPUTS
  ##############################################################################

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # url = "github:nix-community/home-manager/release-23.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena.url = "github:zhaofengli/colmena";
    secrets.url = "git+ssh://git@github.com/n-marci/secrets.git";
  };

  ##############################################################################
  # OUTPUTS
  ##############################################################################

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager, disko, microvm, colmena, secrets, ... }:
    let
      vars = {
        user = "marci";
        location = "$HOME/nix";
        editor = "hx";
      };
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        # temporary allow old electron because of obsidian
        # config.permittedInsecurePackages = [
        #   "electron-25.9.0"
        # ];
      };

      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {

  ##############################################################################
  # DESKTOPS
  ##############################################################################

        desktop = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs secrets system stable unstable vars;
            host = {
              hostName = "desktop";
            };
          };

          modules = [
            ./hosts/desktop
            ./configuration.nix 

            disko.nixosModules.disko
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # home-manager.extraSpecialArgs = {
              #   inherit user inputs upkgs;
              # };
              # home-manager.users.${user} = {
              #   imports = [ ./home.nix ];
              # };
            }
          ];
        };

        yoga = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs secrets system stable unstable vars;
            host = {
              hostName = "yoga";
            };
          };

          modules = [
            ./hosts/yoga
            ./configuration.nix 

            disko.nixosModules.disko
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

  ##############################################################################
  # HOMELAB
  ##############################################################################

        helix-s = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs secrets system stable unstable vars;
            host = {
              hostName = "helix-s";
            };
          };

          modules = [
            ./hosts/helix-s
            ./server.nix 

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

        inspirion = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs secrets system stable unstable vars;
            host = {
              hostName = "inspirion";
            };
          };

          modules = [
            ./hosts/inspirion
            ./server.nix 

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

  ##############################################################################
  # VMs
  ##############################################################################

      };
    };
}
