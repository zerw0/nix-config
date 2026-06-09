{ lib, self, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;

  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inputs = self.inputs;
    };
    home-manager.backupFileExtension = "bak";
  };

  mkDarwinSystem =
    name:
    self.inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inputs = self.inputs;
        nixvimModule = self.inputs.nixvim.homeModules.nixvim;
      };
      modules = [
        {
          nixpkgs.pkgs = import self.inputs.nixpkgs-darwin {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        }
        # home-manager-darwin is release-25.11, version-matched to nixpkgs-darwin.
        # Using home-manager master here breaks because its modules/services-modular
        # references lib/services/lib.nix which doesn't exist in the darwin nixpkgs pin.
        self.inputs.home-manager-darwin.darwinModules.home-manager
        self.inputs.agenix.darwinModules.default
        ./_common
        (./. + "/${name}/configuration.nix")
        ../../users/hdjenkov
        ../../users/hdjenkov/home.nix
        homeManagerCfg
      ];
    };
in
{
  flake.darwinConfigurations = lib.listToAttrs (
    builtins.map (name: lib.nameValuePair name (mkDarwinSystem name)) configs
  );
}
