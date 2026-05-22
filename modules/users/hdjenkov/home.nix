{ pkgs, nixvimModule, inputs, config, ... }:
with pkgs;
{
  home-manager.users.hdjenkov.imports = [
    nixvimModule
    ../../dots/shell
    ../../dots/fastfetch
    ./gitconfig.nix
    ../../dots/nvim
  ];

  home-manager.users.hdjenkov.home.stateVersion = "25.11";
  home-manager.users.hdjenkov.programs.zsh.enable = true;

  home-manager.users.hdjenkov.home.packages = [
    nerd-fonts.caskaydia-cove
    inputs.claude-code.packages.${stdenv.hostPlatform.system}.default
  ] ++ lib.optionals stdenv.isDarwin [
    telegram-desktop
    spotify
    vscode
    localsend
    prismlauncher
  ] ++ lib.optionals (stdenv.isLinux && lib.hasSuffix "steamdeck" config.networking.hostName) [
    vscode
    heroic
    git-lfs
    iperf3
    nodejs
    go
    nil
    nixd
    ansible
    glab
    awscli
    pwgen
    age
    just
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    (python313.withPackages (ps: with ps; [
      pip
      requests
      setuptools
      pyyaml
      pyopenssl
    ]))
  ];

  home-manager.users.hdjenkov.home.file = { };

  home-manager.users.hdjenkov.home.sessionVariables = {
    EDITOR = "nvim";
  };

  home-manager.users.hdjenkov.programs.home-manager.enable = true;
}
