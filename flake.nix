{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "aarch64-darwin"
        ];
        flake = {
          darwinConfigurations = {
            lambda = nix-darwin.lib.darwinSystem {
              system = "aarch64-darwin";
              specialArgs = {
                inherit inputs;
                system = "aarch64-darwin";
                username = "hdjenkov";
              };
              modules = [
                inputs.home-manager.darwinModules.home-manager
                ./machines/darwin/lambda
                ./home.nix
                {
                  home-manager.extraSpecialArgs = {
                    inherit inputs;
                  };
                  home-manager.backupFileExtension = "bak";
                }
              ];
            };
          };
        };
      }
    );
}
