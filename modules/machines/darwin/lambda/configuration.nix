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
    taps = [
      {
        name = "Sikarugir-App/sikarugir";
        # Third-party tap: Homebrew requires explicit trust before install.
        trusted = true;
      }
    ];
    brews = [ "colima" ];
    casks = [
      "bitwarden"
      "tailscale-app"
      "iina"
      "keka"
      "rustdesk"
      "karabiner-elements"
      "helium-browser"
      "element"
      "spotify"
      "telegram-desktop"
      "orcaslicer"
      "vesktop"
      "vorssaint"
      "libreoffice"
      "transmission"
      "codex"
      "blender"
      "steam"
      "sikarugir"
    ];
  };

  # Determinate Nix manages the daemon, so nix-darwin's `nix.*` options are out
  # of play — determinate.darwinModules.default forces `nix.enable = false` and
  # takes over /etc/nix/nix.custom.conf instead.
  determinateNix = {
    customSettings.trusted-users = [ "@admin" ];

    # Linux builder VM. The NixOS hosts are built here rather than on the
    # targets: vps is aarch64-linux natively, and htpc/hass are x86_64-linux,
    # which the VM translates through Rosetta. Determinate's own native builder
    # would be the lighter option, but it is still early-access only.
    #
    # linux-builder-vz uses Apple's Virtualization framework (no QEMU), which is
    # what makes the Rosetta passthrough for x86_64-linux available at all.
    nixosVmBasedLinuxBuilder = {
      enable = true;
      package = pkgs.darwin.linux-builder-vz;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      # Discard VM disk state on restart so config changes always take effect.
      ephemeral = true;
      # This machine has 10 cores / 16 GB, so the upstream example (8 GB, 6
      # cores, maxJobs 4) is too greedy: the VM must leave macOS enough to stay
      # responsive. 6 GB / 6 cores / 2 parallel jobs fits, and 60 GB of disk
      # covers a full NixOS closure (the 20 GB default does not).
      maxJobs = 2;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 60 * 1024;
            memorySize = 6 * 1024;
          };
          cores = 6;
        };
      };
    };
  };

  # agenix identity — macOS uses personal SSH key (no host keys on darwin)
  age.identityPaths = [ "${config.users.users.hdjenkov.home}/.ssh/personal" ];
  age.secrets.forgejoAccessToken = {
    file = "${inputs.secrets}/forgejoAccessToken.age";
    owner = "hdjenkov";
  };

  system.primaryUser = "hdjenkov";
  system.stateVersion = 6;
}
