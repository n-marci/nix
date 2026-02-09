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

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
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

    colmena.url = "github:zhaofengli/colmena/?ref=v0.4.0";
    flatpaks.url = "github:gmodena/nix-flatpak/?ref=latest";
    secrets.url = "git+ssh://git@github.com/n-marci/secrets.git";
  };

  ##############################################################################
  # OUTPUTS
  ##############################################################################

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, sops-nix, home-manager, disko, microvm, colmena, flatpaks, secrets, ... }:
    let
      hosts = import ./hosts/hosts.nix { inherit secrets; };
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
            unicorn = unstable;
            yoga = unstable;
          };
          nodeSpecialArgs = {
            unicorn = {
              user = hosts.unicorn.user;
              graphics = hosts.unicorn.graphics;
            };
            yoga = {
              user = hosts.yoga.user;
              graphics = hosts.yoga.graphics;
            };
            inspirion = {
              user = hosts.inspirion.user;
              ip = hosts.inspirion.ip;
              interface = hosts.inspirion.interface;
              service-dir = "var/lib";
              snapshot-dir = "var/snap";
              backup-dir = "srv/bkp";
            };
            linc-n2 = {
              user = hosts.linc-n2.user;
              ip = hosts.linc-n2.ip;
              interface = hosts.linc-n2.interface;
            };
            helix-s = {
              user = hosts.helix-s.user;
              ip = hosts.helix-s.ip;
              interface = hosts.helix-s.interface;
            };
          };
          specialArgs = {
            stable = stable;
            sops-nix = sops-nix;
            secrets = secrets;
            hosts = hosts;
            lts-kernel = stable.linuxPackages_6_6;
            latest-kernel = unstable.linuxPackages_latest;
            quickshell = inputs.quickshell;
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

        # desktop = { name, ... }: {
        #   deployment = {
        #     allowLocalDeployment = true;
        #     targetHost = null;
        #     tags = hosts.desktop.tags;
        #   };

        #   imports = [
        #     ./hosts/desktop
        #     ./configuration.nix

        #     flatpaks.nixosModules.nix-flatpak
        #     home-manager.nixosModules.home-manager {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.extraSpecialArgs.flake-inputs = inputs;
        #     }
        #   ];
        # };

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
            # allowLocalDeployment = true;
            # targetUser = hosts.inspirion.user; 
            targetUser = "colmena";
            buildOnTarget = true;
            tags = hosts.inspirion.tags;
          };

          imports = [
            ./hosts/inspirion/configuration.nix
          ];
        };

        # linc-n2 = { name, ... }: {
        #   deployment = {
        #     # allowLocalDeployment = true;
        #     # targetUser = hosts.linc-n2.user; 
        #     targetUser = "colmena";
        #     buildOnTarget = true;
        #     tags = hosts.linc-n2.tags;
        #   };

        #   imports = [
        #     ./hosts/linc-n2/configuration.nix
        #   ];
        # };

        helix-s = { name, ... }: {
          deployment = {
            # allowLocalDeployment = true;
            # targetUser = hosts.helix-s.user; 
            targetUser = "colmena";
            buildOnTarget = true;
            tags = hosts.helix-s.tags;
          };

          imports = [
            ./hosts/helix-s/configuration.nix
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

  ##############################################################################
  # 
  ##############################################################################

      nixosConfigurations = {
        yoga = nixpkgs.lib.nixosSystem {
          # inherit system;
          specialArgs = {

            inherit inputs secrets hosts stable unstable;
            # host = {
            #   hostName = "yoga";
            # };
          };

          modules = [
            ./hosts/yoga/configuration.nix

            # disko.nixosModules.disko
            sops-nix.nixosModules.sops
            flatpaks.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs.flake-inputs = inputs;
            }
          ];
        };
        # yoga = { name, ... }: {
        #   deployment = {
        #     allowLocalDeployment = true;
        #     targetHost = null;
        #     tags = hosts.yoga.tags;
        #   };

        #   imports = [
        #     ./hosts/yoga/configuration.nix

        #     flatpaks.nixosModules.nix-flatpak
        #     home-manager.nixosModules.home-manager {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.extraSpecialArgs.flake-inputs = inputs;
        #     }
        #   ];
        # };
      };
    };
}
