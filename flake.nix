{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/3edc4a30ed3903fdf6f90c837f961fa6b49582d1";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/d351d0653aeb7877273920cd3e823994e7579b0b";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+file:///Users/hdjenkov/git-tmp/nix-private.git?ref=main";
      flake = false;
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fmatrix = {
      url = "git+file:///Users/hdjenkov/git/fmatrix";
      inputs.nixpkgs.follows = "nixpkgs";
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
          "aarch64-linux"
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
