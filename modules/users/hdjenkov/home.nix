{
  pkgs,
  lib,
  nixvimModule,
  ...
}:
{
  home-manager.users.hdjenkov.imports = [
    nixvimModule
    ../../dots/shell
    ../../dots/fastfetch
    ../../dots/dev-tools
    ../../dots/cloud-tools
    ./gitconfig.nix
    ../../dots/nvim
    ../../dots/tmux
  ];

  home-manager.users.hdjenkov.home.stateVersion = "25.11";
  # The generated option-reference manpage is large, rarely useful locally,
  # and currently triggers Nix source-context warnings during every host eval.
  home-manager.users.hdjenkov.manual.manpages.enable = false;
  home-manager.users.hdjenkov.programs.zsh.enable = true;
  home-manager.users.hdjenkov.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home-manager.users.hdjenkov.home.packages = lib.optionals pkgs.stdenv.isLinux [
    pkgs.nerd-fonts.caskaydia-cove
  ];

  home-manager.users.hdjenkov.home.sessionVariables = {
    EDITOR = "nvim";
  };

  home-manager.users.hdjenkov.programs.home-manager.enable = true;
}
