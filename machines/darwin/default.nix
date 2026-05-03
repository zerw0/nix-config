{ lib, inputs, ... }:
let
  # Explicitly list machine names to avoid builtins.toFile warning
  configs = [ "lambda" ];

  mkDarwinConfig = name: inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; nixvimModule = inputs.nixvim.homeModules.nixvim; };

    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.agenix.darwinModules.default
      (./. + "/${name}/configuration.nix")
      ../../users/hdjenkov
      ../../users/hdjenkov/home.nix
      ../../modules/common.nix
      {
        nixpkgs.pkgs = import inputs.nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.backupFileExtension = "bak";
      }
    ];
  };
in
{
  flake.darwinConfigurations = lib.genAttrs configs mkDarwinConfig;
}
