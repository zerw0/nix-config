{ pkgs, nixvimModule, ... }:
{
  home-manager.users.hdjenkov.imports = [
    nixvimModule
    ../../dots/shell
    ../../dots/fastfetch
    ../../gitconfig.nix
    ../../dots/nvim
  ];

  home-manager.users.hdjenkov.home.stateVersion = "25.11";
  home-manager.users.hdjenkov.programs.zsh.enable = true;

  home-manager.users.hdjenkov.home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
  ];

  home-manager.users.hdjenkov.home.file = { };

  home-manager.users.hdjenkov.home.sessionVariables = {
    EDITOR = "nvim";
  };

  home-manager.users.hdjenkov.programs.home-manager.enable = true;
}
