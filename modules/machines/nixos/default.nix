{ lib, self, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;

  # Per-host architecture overrides; default is x86_64-linux.
  systemArchMap = { };

  # Per-host nixpkgs suffix overrides (e.g. "-unstable") — reserved for future use.
  nixpkgsMap = { };

  systemForHost = name:
    let systemFile = ./. + "/${name}/system.nix";
    in if systemArchMap ? ${name}
       then systemArchMap.${name}
       else if builtins.pathExists systemFile
       then (import systemFile).system
       else "x86_64-linux";

  nixpkgsSuffix = name: nixpkgsMap.${name} or "";

  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inputs = self.inputs; };
    home-manager.backupFileExtension = "bak";
  };

  mkNixosSystem = name:
    let suffix = nixpkgsSuffix name;
    in (self.inputs."nixpkgs${suffix}").lib.nixosSystem {
      specialArgs = {
        inputs = self.inputs;
        nixvimModule = self.inputs.nixvim.homeModules.nixvim;
      };
      modules = [
        { nixpkgs.hostPlatform = systemForHost name; }
        { nixpkgs.config.allowUnfree = true; }
        (self.inputs."home-manager${suffix}").nixosModules.home-manager
        self.inputs.agenix.nixosModules.default
        self.inputs.disko.nixosModules.disko
        ./_common
        ../../homelab
        ../../misc/tailscale
        (./. + "/${name}/configuration.nix")
        ../../users/hdjenkov
        ../../users/hdjenkov/home.nix
        homeManagerCfg
      ];
    };
in
{
  flake.nixosConfigurations = lib.listToAttrs (
    builtins.map (name: lib.nameValuePair name (mkNixosSystem name)) configs
  );
}
