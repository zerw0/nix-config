{ username, inputs, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.hdjenkov.imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.spicetify-nix.homeManagerModules.default
    ../../dots/shell
    ../../dots/ghostty
    ../../dots/fastfetch
    ../../gitconfig.nix
    ../../dots/nvim
    ../../dots/spicetify
  ];

  # Home Manager release compatibility
  home-manager.users.hdjenkov.home.stateVersion = "25.11";

  # User packages
  home-manager.users.hdjenkov.home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
  ];

  # Managed files / dotfiles
  home-manager.users.hdjenkov.home.file = {
    # ".screenrc".source = dotfiles/screenrc;
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Session variables
  home-manager.users.hdjenkov.home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager manage itself
  home-manager.users.hdjenkov.programs.home-manager.enable = true;
}
