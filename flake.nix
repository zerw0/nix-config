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

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    machinesDir = ./machines/darwin;
    entries = builtins.attrNames (builtins.readDir machinesDir);
    configs = builtins.filter (dir: builtins.pathExists (machinesDir + "/${dir}/configuration.nix")) entries;

    mkDarwinConfig = name: nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs;
        username = "hdjenkov";
      };

      modules = [
        inputs.home-manager.darwinModules.home-manager
        (machinesDir + "/${name}/configuration.nix")
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
          home-manager.backupFileExtension = "bak";
          home-manager.users.hdjenkov = {
            imports = [
              inputs.nixvim.homeModules.nixvim
              ./dots/shell
              ./dots/nvim
              ./dots/ghostty
              ./dots/fastfetch
            ];
            home.homeDirectory = nixpkgs.lib.mkForce "/Users/hdjenkov";
          };
        }
      ];
    };
  in {
    darwinConfigurations = nixpkgs.lib.genAttrs configs mkDarwinConfig;
  };
}
