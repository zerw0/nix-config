{
  description = "hdjenkov's nix-darwin + NixOS config";

  inputs = {
    # Two tracks. The NixOS hosts (vps, htpc, hass) stay on the current release
    # branch; lambda runs unstable. Every flake that carries module semantics
    # (nix-darwin, Home Manager, nixvim) is pinned to the branch matching the
    # nixpkgs it is used with — mixing a master-branch module set with a release
    # nixpkgs breaks as soon as the modules reference a path that only exists in
    # unstable (this is how `${pkgs.path}/lib/services/lib.nix` broke before).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Darwin track: lambda is the only darwin host, so nix-darwin follows
    # unstable outright rather than carrying a second release-pinned copy.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      # The Git transport avoids transient missing-blob failures in GitHub's
      # lazy source accessor while still tracking the branch.
      url = "git+https://github.com/nix-community/nixvim.git?ref=nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-unstable = {
      url = "git+https://github.com/nix-community/nixvim.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    # lambda's Nix is installed and managed by Determinate, so nix-darwin's own
    # `nix.*` options are off there. This module is the supported way back in:
    # it forces `nix.enable = false`, owns /etc/nix/nix.custom.conf via
    # `determinateNix.customSettings`, and ships the Linux-builder VM support
    # that nix-darwin's `nix.linux-builder` refuses to provide without
    # `nix.enable`. Darwin-only, so it follows the unstable track.
    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Only lambda enables dots.dev-tools, so this is a lambda-only package —
    # follow unstable so it matches the system it is installed into.
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
