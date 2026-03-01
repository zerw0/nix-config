{ lib, inputs, ... }:
let
  # Explicitly list machine names to avoid builtins.toFile warning
  configs = [ "lambda" ];

  mkDarwinConfig = name: inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs;
      username = "hdjenkov";
    };

    modules = [
      inputs.home-manager.darwinModules.home-manager
      (./. + "/${name}/configuration.nix")
      ../../users/hdjenkov
      {
        nixpkgs.config.allowUnfree = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
        };
        home-manager.backupFileExtension = "bak";
      }
    ];
  };
in
{
  flake.darwinConfigurations = lib.genAttrs configs mkDarwinConfig;
}
