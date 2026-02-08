{ lib, inputs, ... }:
let
  # Explicitly list machine names to avoid builtins.toFile warning
  configs = [ ];

  mkNixOSConfig = name: inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      username = "hdjenkov";
    };

    modules = [
      inputs.home-manager.nixosModules.home-manager
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
  flake.nixosConfigurations = lib.genAttrs configs mkNixOSConfig;
}
