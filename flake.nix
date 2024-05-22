  {
  description = "Configuration for all my computing devices (I am missing the NixOS Phone still)";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # url = "github:nix-community/home-manager/release-23.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/n-marci/secrets.git";
      # flake = false;
    };

    # modules
    # xremap-flake.url = "github:xremap/nix-flake";
    # firefly = {
    #   url = "github:timhae/firefly";
    #   inputs.nixpkgs.follows = "nixos";
    # };
    # nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager, secrets, ... }:
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
            inherit inputs system stable unstable vars;
            host = {
              hostName = "yoga";
            };
          };

          modules = [
            ./hosts/yoga
            ./configuration.nix 

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

        helix = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs system stable unstable vars;
            host = {
              hostName = "helix";
            };
          };

          modules = [
            ./hosts/helix
            ./configuration.nix 

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

        inspirion = lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs system stable unstable vars;
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
      };
    };
}
