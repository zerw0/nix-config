{
  lib,
  self,
  ...
}:
let
  entries = builtins.attrNames (builtins.readDir ./.);
  configs = builtins.filter (dir: builtins.pathExists (./. + "/${dir}/configuration.nix")) entries;
  homeManagerCfg = userPackages: extraImports: {
    home-manager.useGlobalPkgs = false;
    home-manager.extraSpecialArgs = {
      inherit (self) inputs;
    };
    home-manager.users.hdjenkov.imports = [
      self.inputs.nixvim.homeModules.nixvim
      ../../dots/shell
      ../../dots/nvim
    ]
    ++ extraImports;
    home-manager.backupFileExtension = "bak";
    home-manager.useUserPackages = userPackages;
  };
in
{

  flake.nixosConfigurations =
    let
      nixpkgsMap = {
        htpc = "-unstable";
      };
      systemArchMap = {

      };
      myNixosSystem =
        name: self.inputs."nixpkgs${lib.attrsets.attrByPath [ name ] "" nixpkgsMap}".lib.nixosSystem;
    in
    lib.listToAttrs (
      builtins.map (
        name:
        lib.nameValuePair name (
          (myNixosSystem name) {
            system = lib.attrsets.attrByPath [ name ] "x86_64-linux" systemArchMap;
            specialArgs = {
              inherit (self) inputs;
              self = {
                nixosModules = self.nixosModules;
              };
            };

            modules = [
              self.inputs."home-manager${
                lib.attrsets.attrByPath [ name ] "" nixpkgsMap
              }".nixosModules.home-manager
              (./. + "/${name}/configuration.nix")
              ../../users/hdjenkov
              (homeManagerCfg false [ ])
              {
                nixpkgs.config.allowUnfree = true;
                nix.settings.experimental-features = [ "flakes" "nix-command" ];
                environment.systemPackages = with self.inputs."nixpkgs${lib.attrsets.attrByPath [ name ] "" nixpkgsMap}"; [
                  eza
                  ffmpeg
                  fd
                  bat
                  ripgrep
                  ncdu
                  wget
                ];
              }
            ];
          }
        )
      ) configs
    );
}
