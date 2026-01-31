{ username, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.hdjenkov.imports = { config, pkgs, ... }:
    {
      imports = [
        self.inputs.agenix.homeManagerModules.default
        self.inputs.nixvim.homeModules.nixvim
        ./dots/shell
        ./dots/ghostty
        ./dots/fastfetch
        ./gitconfig.nix
        ./dots/nvim
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
