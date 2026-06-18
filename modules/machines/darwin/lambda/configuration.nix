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
    vscode
    localsend
    prismlauncher
  ];

  environment.etc."pam.d/sudo_local".text = ''
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
    auth       sufficient     pam_tid.so
  '';

  environment.systemPackages = with pkgs; [
    pam-reattach
    coreutils
    docker
    docker-compose
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    global.autoUpdate = false;
    global.brewfile = true;
    caskArgs.no_quarantine = true;
    taps = [ ];
    brews = [
      "colima"
      "yt-dlp"
    ];
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
      "hiddenbar"
    ];
  };

  services.netbird.enable = true;

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
  system.configurationRevision = null;
}
