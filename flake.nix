{
  description = "hdjenkov's nix-darwin + NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep Home Manager version-matched to the stable Darwin nixpkgs input.
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nixvim = {
      # The Git transport avoids transient missing-blob failures in GitHub's
      # lazy source accessor while still tracking the branch.
      url = "git+https://github.com/nix-community/nixvim.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-darwin = {
      url = "git+https://github.com/nix-community/nixvim.git?ref=nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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
      url = "git+https://git.zerw.xyz/hdjenkov/nix-private.git";
      flake = false;
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fmatrix = {
      url = "git+https://git.zerw.xyz/hdjenkov/fmatrix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "aarch64-darwin"
          "x86_64-linux"
          "aarch64-linux"
        ];
        imports = [
          ./modules/machines/darwin/default.nix
          ./modules/machines/nixos/default.nix
          ./modules/devshell.nix
        ];
      }
    );
}
