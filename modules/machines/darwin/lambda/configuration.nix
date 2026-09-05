{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./system.nix ];

  home-manager.users.hdjenkov.imports = [
    ../../../dots/ghostty
    ../../../dots/karabiner
    ../../../dots/vscode
  ];

  home-manager.users.hdjenkov.dots.dev-tools.enable = true;
  home-manager.users.hdjenkov.dots.cloud-tools.enable = true;

  home-manager.users.hdjenkov.home.packages = with pkgs; [
    eza
    ffmpeg
    fd
    ripgrep
    ncdu
    wget
    htop
    yt-dlp
    localsend
  ];

  environment.systemPackages = with pkgs; [
    coreutils
    docker_29
    docker-compose
  ];

  homebrew = {
    enable = true;
    # Keep Homebrew declarative without coupling system switches to upgrades.
    # Normal uninstall cleanup removes undeclared packages while preserving
    # application preferences and support files (unlike "zap").
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = false;
    onActivation.autoUpdate = false;
    global.autoUpdate = false;
    global.brewfile = true;
    brews = [ "colima" ];
    casks = [
      "bitwarden"
      "tailscale-app"
      "iina"
      "keka"
      "rustdesk"
      "linearmouse"
      "karabiner-elements"
      "helium-browser"
      "element"
      "spotify"
      "telegram-desktop"
      "raycast"
      "qbittorrent"
      "betterdisplay"
      "nheko"
      "orcaslicer"
      "vesktop"
      "vorssaint"
    ];
  };

  # Determinate Nix manages the daemon; nix-darwin should not
  nix.enable = false;

  # agenix identity — macOS uses personal SSH key (no host keys on darwin)
  age.identityPaths = [ "${config.users.users.hdjenkov.home}/.ssh/personal" ];
  age.secrets.forgejoAccessToken = {
    file = "${inputs.secrets}/forgejoAccessToken.age";
    owner = "hdjenkov";
  };

  system.primaryUser = "hdjenkov";
  system.stateVersion = 6;
}
