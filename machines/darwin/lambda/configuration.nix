{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Lambda-specific home-manager imports
  home-manager.users.hdjenkov.imports = [
    ../../../dots/ghostty
  ];

  # Packages available system-wide
  environment.systemPackages = with pkgs; [
    git-lfs
    coreutils
    htop
    iperf3
    docker
    docker-compose
    nodejs
    nil
    nixd
    ansible
    go
    claude-code
    telegram-desktop
    spotify
    vscode
    age
    localsend
    prismlauncher
    glab
    pwgen
    just
    awscli
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    (python313.withPackages (
      ps: with ps; [
        pip
        requests
        setuptools
        pyyaml
        pyopenssl
      ]
    ))
  ];

  # Homebrew configuration
  homebrew = {
    enable = true;
    onActivation = {
      # Automatically uninstall/zap casks and brews that are no longer listed
      cleanup = "zap";
    };
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
      "termius"
      "puremac"
      "element"
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

  # Security settings (Touch ID for sudo)
  security.pam.services.sudo_local.touchIdAuth = true;

  # System options (revision, platform, defaults, activation)
  system = {
    configurationRevision = null;
    stateVersion = 6;

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
      };

      dock = {
        orientation = "bottom";
        autohide = false;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.5;
        magnification = true;
        tilesize = 32;
        largesize = 64;
      };

      trackpad = {
        Clicking = true;
      };

      finder = {
        ShowHardDrivesOnDesktop = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        NewWindowTarget = "Home";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXRemoveOldTrashItems = true;
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
        FXDefaultSearchScope = "SCcf";
        ShowPathbar = true;
      };
    };

    defaults.dock.wvous-tl-corner = 2;
    defaults.dock.wvous-br-corner = 14;
  };

  system.primaryUser = "hdjenkov";
}
