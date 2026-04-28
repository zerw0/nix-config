{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    nixvim-unstable = {
      url = "github:nix-community/nixvim/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@git.zerw.xyz/hdjenkov/nix-private.git";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, nix-darwin, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "aarch64-darwin"
          "x86_64-linux"
        ];
        imports = [
          ./machines/darwin/default.nix
          ./machines/nixos/default.nix
          {
            flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inherit inputs; };
              modules = [ ./machines/installer/default.nix ];
            };
          }
        ];
      }
    );
}
