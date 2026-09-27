{ self, ... }:
let
  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-bak";
    home-manager.extraSpecialArgs = {
      inputs = self.inputs;
      nixvimNixpkgs = self.inputs.nixpkgs-unstable;
    };
  };

in
{
  flake.darwinConfigurations.lambda = self.inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inputs = self.inputs;
      nixvimModule = self.inputs.nixvim-unstable.homeModules.nixvim;
    };
    modules = [
      {
        nixpkgs.pkgs = import self.inputs.nixpkgs-unstable {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        system.configurationRevision = self.rev or self.dirtyRev or null;
      }
      self.inputs.determinate.darwinModules.default
      self.inputs.home-manager-unstable.darwinModules.home-manager
      self.inputs.agenix.darwinModules.default
      ./_common
      ./lambda/configuration.nix
      ../../users/hdjenkov
      ../../users/hdjenkov/home.nix
      homeManagerCfg
    ];
  };
}
