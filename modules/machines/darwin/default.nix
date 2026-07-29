{ lib, self, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;

  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inputs = self.inputs;
      nixvimNixpkgs = self.inputs.nixpkgs-darwin;
    };
  };

  mkDarwinSystem =
    name:
    self.inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inputs = self.inputs;
        nixvimModule = self.inputs.nixvim-darwin.homeModules.nixvim;
      };
      modules = [
        {
          nixpkgs.pkgs = import self.inputs.nixpkgs-darwin {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
        # Keep Home Manager on the release matching the stable Darwin nixpkgs input.
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
