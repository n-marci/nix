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
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
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
    flatpaks.url = "github:gmodena/nix-flatpak/?ref=latest";
    secrets.url = "git+ssh://git@github.com/n-marci/secrets.git";
  };

  ##############################################################################
  # OUTPUTS
  ##############################################################################

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, sops-nix, home-manager, disko, microvm, colmena, flatpaks, secrets, ... }:
    let
      hosts = import ./hosts.nix { inherit secrets; };
      stable = import nixpkgs-stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      # nixosConfigurations = {
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;

      colmena = {
        meta = {
          nixpkgs = stable;
          nodeNixpkgs = {
            desktop = unstable;
            yoga = unstable;
          };
          nodeSpecialArgs = {
            desktop = {
              user = hosts.desktop.user;
              graphics = hosts.desktop.graphics;
            };
            yoga = {
              user = hosts.yoga.user;
              graphics = hosts.yoga.graphics;
            };
            inspirion = {
              user = hosts.inspirion.user;
              ip = hosts.inspirion.ip;
              interface = hosts.inspirion.interface;
              # graphics = hosts.inspirion.graphics;
            };
            helix-s = {
              user = hosts.helix-s.user;
              # graphics = hosts.helix-s.graphics;
            };
          };
          specialArgs = {
            stable = stable;
            sops-nix = sops-nix;
            secrets = secrets;
            hosts = hosts;
            lts-kernel = stable.linuxPackages_6_6;
            latest-kernel = unstable.linuxPackages_latest;
          };
        };
        
      # }

  ##############################################################################
  # DEFAULTS
  ##############################################################################

        defaults = {
          imports = [
            sops-nix.nixosModules.sops
          ];
        };

  ##############################################################################
  # DESKTOPS
  ##############################################################################

        # desktop = nixpkgs.lib.nixosSystem {
        desktop = { name, ... }: {
          deployment = {
            allowLocalDeployment = true;
            targetHost = null;
            tags = hosts.desktop.tags;
          };

          imports = [
            ./hosts/desktop
            ./configuration.nix

            flatpaks.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs.flake-inputs = inputs;
            }
          ];
        };

        yoga = { name, ... }: {
          deployment = {
            allowLocalDeployment = true;
            targetHost = null;
            tags = hosts.yoga.tags;
          };

          imports = [
            ./hosts/yoga/configuration.nix

            flatpaks.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs.flake-inputs = inputs;
            }
          ];
        };
        #   inherit system;

        #   specialArgs = {
        #     inherit inputs secrets system stable unstable vars;
        #     host = {
        #       hostName = "desktop";
        #     };
        #   };

        #   modules = [
        #     ./hosts/desktop
        #     ./configuration.nix 

        #     disko.nixosModules.disko
        #     home-manager.nixosModules.home-manager {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       # home-manager.extraSpecialArgs = {
        #       #   inherit user inputs upkgs;
        #       # };
        #       # home-manager.users.${user} = {
        #       #   imports = [ ./home.nix ];
        #       # };
        #     }
        #   ];
        # };

  #       yoga = nixpkgs.lib.nixosSystem {
  #         inherit system;

  #         specialArgs = {
  #           inherit inputs secrets system stable unstable vars;
  #           host = {
  #             hostName = "yoga";
  #           };
  #         };

  #         modules = [
  #           ./hosts/yoga
  #           ./configuration.nix 

  #           disko.nixosModules.disko
  #           home-manager.nixosModules.home-manager {
  #             home-manager.useGlobalPkgs = true;
  #             home-manager.useUserPackages = true;
  #           }
  #         ];
  #       };

  # ##############################################################################
  # # HOMELAB
  # ##############################################################################

        inspirion = { name, ... }: {
          deployment = {
            targetUser = hosts.inspirion.user; 
            buildOnTarget = true;
            tags = hosts.inspirion.tags;
          };

          imports = [
            ./hosts/inspirion/configuration.nix

            # home-manager.nixosModules.home-manager {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.extraSpecialArgs.flake-inputs = inputs;
            # }
          ];
        };

  #       helix-s = nixpkgs-stable.lib.nixosSystem {
  #         inherit system;

  #         specialArgs = {
  #           inherit inputs secrets system stable unstable vars;
  #           host = {
  #             hostName = "helix-s";
  #           };
  #         };

  #         modules = [
  #           ./hosts/helix-s
  #           ./server.nix 

  #           home-manager.nixosModules.home-manager {
  #             home-manager.useGlobalPkgs = true;
  #             home-manager.useUserPackages = true;
  #           }

  #           { nixpkgs.config.pkgs = import nixpkgs-stable { inherit system; }; } # use stable nixpkgs
  #         ];
  #       };

  #       inspirion = nixpkgs-stable.lib.nixosSystem {
  #         inherit system;

  #         specialArgs = {
  #           inherit inputs secrets system stable unstable vars;
  #           host = {
  #             hostName = "inspirion";
  #           };
  #         };

  #         modules = [
  #           ./hosts/inspirion
  #           ./server.nix 

  #           home-manager.nixosModules.home-manager {
  #             home-manager.useGlobalPkgs = true;
  #             home-manager.useUserPackages = true;
  #           }

  #           { nixpkgs.config.pkgs = import nixpkgs-stable { inherit system; }; } # use stable nixpkgs
  #         ];
  #       };

  ##############################################################################
  # VMs
  ##############################################################################

      };
    };
}
