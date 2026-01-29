{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    system = "aarch64-darwin";
    username = "hdjenkov";

    specialArgs = {
      inherit inputs system username;
    };
  in
  {
    darwinConfigurations."lambda" =
      nix-darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          ./machines/darwin/system.nix
          home-manager.darwinModules.home-manager
          ./home.nix
        ];
      };
  };
}
