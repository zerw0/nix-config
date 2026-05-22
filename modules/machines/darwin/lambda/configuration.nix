{ config, lib, pkgs, inputs, ... }:
{
  imports = [ ./system.nix ];

  home-manager.users.hdjenkov.imports = [ ../../../dots/ghostty ];

  environment.systemPackages = with pkgs; [
    git-lfs
    coreutils
    iperf3
    docker
    docker-compose
    nodejs
    nil
    nixd
    ansible
    go
    age
    glab
    pwgen
    just
    awscli
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    (python313.withPackages (ps: with ps; [
      pip
      requests
      setuptools
      pyyaml
      pyopenssl
    ]))
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    taps = [ ];
    brews = [
      "colima"
      "yt-dlp"
    ];
    casks = [
      "bitwarden"
      "iina"
      "keka"
      "rustdesk"
      "linearmouse"
      "karabiner-elements"
      "cyberduck"
      "helium-browser"
      "claude"
      "termius"
      "puremac"
      "element"
    ];
  };

  services.tailscale.enable = true;
  launchd.daemons.tailscaled.command = lib.mkForce
    "${lib.getExe' pkgs.tailscale "tailscaled"} --login-server=https://hs.zerw.xyz";

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
