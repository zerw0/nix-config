{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./system.nix ];

  home-manager.users.hdjenkov.imports = [ ../../../dots/ghostty ];

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
    vscode
    localsend
    prismlauncher
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
      "cyberduck"
      "helium-browser"
      "claude"
      "element"
      "spotify"
      "telegram-desktop"
      "viber"
      "raycast"
      "puremac"
      "heroic"
      "steam"
      "nheko"
      "orcaslicer"
      "codex"
      "vesktop"
      "blender"
      {
        name = "sikarugir-app/sikarugir/sikarugir";
        trusted = true;
      }
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
