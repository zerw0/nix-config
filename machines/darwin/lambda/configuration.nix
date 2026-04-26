{
  pkgs,
  username,
  inputs,
  ...
}:

{
  # Lambda-specific home-manager imports
  home-manager.users.hdjenkov.imports = [
#inputs.spicetify-nix.homeManagerModules.spicetify
    ../../../dots/ghostty
#../../../dots/spicetify
  ];

  # Allow unfree packages for home-manager
  home-manager.users.hdjenkov.nixpkgs.config.allowUnfree = true;

  # Packages available system-wide
  environment.systemPackages = with pkgs; [
    eza
    yt-dlp
    ffmpeg
    git-lfs
    fd
    coreutils
    bat
    ripgrep
    ncdu
    htop
    iperf3
    wget
    docker
    docker-compose
    nodejs
    nil
    nixd
    ansible
    minikube
    kubectl
    go
    claude-code
    age
    inputs.agenix.packages.aarch64-darwin.default
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
    ];
    casks = [
      "bitwarden"
      "visual-studio-code"
      "vesktop"
      "tailscale-app"
      "iina"
      "keka"
      "localsend"
      "rustdesk"
      "signal"
      "jellyfin-media-player"
      "prismlauncher"
      "heroic"
      "viber"
      "linearmouse"
      "karabiner-elements"
      "telegram"
      "appcleaner"
      "cyberduck"
      "moonlight"
      "helium-browser"
      "hiddenbar"
      "claude"
      "termius"
      "spotify"
    ];
  };

  # Nix daemon / features
  nix = {
    settings.experimental-features = "nix-command flakes";
    enable = false;
  };

  # agenix identity — macOS uses personal SSH key (no host keys on darwin)
  age.identityPaths = [ "/Users/hdjenkov/.ssh/personal" ];
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
        autohide = true;
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

    activationScripts.postActivation.text = ''
      killall Finder || true
    '';

    activationScripts.hotCorners.text = ''
      echo "Configuring hot corners..."
      defaults write com.apple.dock wvous-tl-corner -int 2
      defaults write com.apple.dock wvous-br-corner -int 14
      killall Dock || true
    '';
  };

  system.primaryUser = "hdjenkov";
}
