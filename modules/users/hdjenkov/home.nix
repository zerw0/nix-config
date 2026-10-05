{
  pkgs,
  lib,
  nixvimModule,
  inputs,
  ...
}:
{
  home-manager.users.hdjenkov = {
    imports = [
      nixvimModule
      inputs.nix-index-database.homeModules.default
      ../../dots/shell
      ../../dots/fastfetch
      ../../dots/dev-tools
      ../../dots/cloud-tools
      ./gitconfig.nix
      ../../dots/nvim
      ../../dots/tmux
    ];

    home.stateVersion = "25.11";
    manual.manpages.enable = false;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.nerd-fonts.caskaydia-cove
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.home-manager.enable = true;
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
