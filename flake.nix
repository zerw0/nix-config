{
  description = "hdjenkov's nix-darwin + NixOS config";

  inputs = {
    # Every host tracks the current NixOS release. nix-darwin, Home Manager and
    # nixvim are pinned to the matching branch, so there is one nixpkgs and one
    # set of module semantics across lambda, htpc, hass and vps.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Used by modules/dots/vscode only. VS Code extensions are not backported to
    # the release branch, so the stable pins run many versions behind the
    # marketplace; the editor is taken from here too, since an extension built
    # against a newer VS Code can refuse to load on an older one.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      # The Git transport avoids transient missing-blob failures in GitHub's
      # lazy source accessor while still tracking the branch.
      url = "git+https://github.com/nix-community/nixvim.git?ref=nixos-26.05";
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
