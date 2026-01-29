{ username, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${username} = { config, pkgs, ... }:
    {
      imports = [
        ./dots/shell/default.nix
        ./dots/ghostty/default.nix
        ./machines/darwin/key-remap.nix
        ./gitconfig.nix
      ];

      # Home Manager release compatibility
      home.stateVersion = "25.11";

      # User packages
      home.packages = [
        pkgs.nerd-fonts.caskaydia-cove
      ];

      # Managed files / dotfiles
      home.file = {
        # ".screenrc".source = dotfiles/screenrc;
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
      };

      # Session variables
      home.sessionVariables = {
        EDITOR = "nvim";
      };

      # Let Home Manager manage itself
      programs.home-manager.enable = true;
    };
}
