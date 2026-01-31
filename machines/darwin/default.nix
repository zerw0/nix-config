{ lib, inputs, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;

  mkDarwinConfig = name: inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs;
      system = "aarch64-darwin";
      username = "hdjenkov";
    };

    modules = [
      inputs.home-manager.darwinModules.home-manager
      (./. + "/${name}/configuration.nix")
      ../../users/hdjenkov
      {
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
