{
  lib,
  self,
  ...
}:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;
  systemForHost = name:
    let systemFile = ./. + "/${name}/system.nix";
    in if builtins.pathExists systemFile then (import systemFile).system else "x86_64-linux";
  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit (self) inputs; };
    home-manager.backupFileExtension = "bak";
  };
in
{
  flake.nixosConfigurations = lib.listToAttrs (
    builtins.map (
      name:
      lib.nameValuePair name (
        self.inputs.nixpkgs.lib.nixosSystem {
          system = systemForHost name;
          specialArgs = {
            inherit (self) inputs;
            self = { inherit (self) nixosModules; };
            nixvimModule = self.inputs.nixvim.homeModules.nixvim;
          };
          modules = [
            self.inputs.home-manager.nixosModules.home-manager
            self.inputs.agenix.nixosModules.default
            self.inputs.disko.nixosModules.disko
            (./. + "/${name}/configuration.nix")
            ../../users/hdjenkov
            ../../users/hdjenkov/home.nix
            homeManagerCfg
            { nixpkgs.config.allowUnfree = true; }
            ../../modules/common.nix
          ];
        }
      )
    ) configs
  );
}
