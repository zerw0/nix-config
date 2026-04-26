{ username, inputs, pkgs, lib, ... }:

{
  nix.settings.trusted-users = [ "hdjenkov" ];

  users.users.hdjenkov = lib.mkMerge [
    {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHggBw49Gg0kyKKp2H44rqhlBEH1z1RdYPQIAU7AJiWe me@zerw.xyz"
      ];
    }
    (lib.mkIf pkgs.stdenv.isDarwin {
      name = "hdjenkov";
      home = "/Users/hdjenkov";
    })
    (lib.mkIf (!pkgs.stdenv.isDarwin) {
      isNormalUser = true;
      group = "hdjenkov";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
      ];
    })
  ];

  users.groups = lib.mkIf (!pkgs.stdenv.isDarwin) {
    hdjenkov = { };
  };

  programs.zsh.enable = true;

  home-manager.users.hdjenkov.imports = [
    inputs.nixvim.homeModules.nixvim
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
