{ lib, inputs, ... }:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;

  mkDarwinConfig = name: inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs;
      username = "hdjenkov";
    };

    modules = [
      inputs.home-manager.darwinModules.home-manager
      (./. + "/${name}/configuration.nix")
      {
        home-manager.useGlobalPkgs = false;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
        };
        home-manager.backupFileExtension = "bak";
        home-manager.users.hdjenkov = {
          imports = [
            inputs.nixvim.homeModules.nixvim
            ../../dots/shell
            ../../dots/nvim
            ../../dots/ghostty
            ../../dots/fastfetch
          ];
          home.homeDirectory = lib.mkForce "/Users/hdjenkov";
        };
      }
    ];
  };
in
{
  flake.darwinConfigurations = lib.genAttrs configs mkDarwinConfig;
}
