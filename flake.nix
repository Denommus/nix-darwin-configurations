{
  description = "John's darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, darwin, nixpkgs, nur, home-manager, nixpkgs-unstable, ... }@inputs:
  let
    system = "x86_64-darwin";
    nur-no-pkgs = import nur {
      pkgs = null;
      nurpkgs = import nixpkgs {
        inherit system;
      };
    };
  in {
    darwinConfigurations."192" = darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./darwin-configuration.nix
        {
          nixpkgs.overlays = [
            nur.overlay
            (final: prev: {
              unstable = (import nixpkgs-unstable { inherit system; }).pkgs;
            })
          ];
        }
        home-manager.darwinModules.home-manager ({
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.yurialbuquerque = {
              imports = [
                ./yurialbuquerque/home.nix
                nur-no-pkgs.repos.rycee.hmModules.emacs-init
              ];
            };
          };
        })
      ];
    };
  };
}
