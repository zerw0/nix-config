{ lib, self, ... }:
let
  hosts = {
    htpc = "x86_64-linux";
    vps = "aarch64-linux";
  };

  homeManagerCfg = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inputs = self.inputs;
      nixvimNixpkgs = self.inputs.nixpkgs;
    };
  };

  mkNixosSystem =
    name: system:
    self.inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inputs = self.inputs;
        nixvimModule = self.inputs.nixvim.homeModules.nixvim;
      };
      modules = [
        { nixpkgs.hostPlatform = system; }
        { nixpkgs.config.allowUnfree = true; }
        self.inputs.home-manager.nixosModules.home-manager
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
  flake.nixosConfigurations = lib.mapAttrs mkNixosSystem hosts // {
    installer = self.inputs.nixpkgs.lib.nixosSystem {
      specialArgs.inputs = self.inputs;
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        ./installer/configuration.nix
      ];
    };
  };
}
