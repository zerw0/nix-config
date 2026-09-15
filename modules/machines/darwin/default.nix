{ lib, self, ... }:
# lambda tracks unstable: nixpkgs-unstable plus the master branches of
# nix-darwin, Home Manager and nixvim. The NixOS hosts stay on the release
# branch (see modules/machines/nixos/default.nix).
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;

  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    # Home Manager refuses to clobber a file it does not already own, which
    # aborts activation partway through. Back the file up and carry on instead.
    home-manager.backupFileExtension = "hm-bak";
    home-manager.extraSpecialArgs = {
      inputs = self.inputs;
      nixvimNixpkgs = self.inputs.nixpkgs-unstable;
    };
  };

  mkDarwinSystem =
    name:
    self.inputs.nix-darwin.lib.darwinSystem {
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
