{
  pkgs,
  username,
  inputs,
  ...
}:

{
  # Lambda-specific home-manager imports
  home-manager.users.hdjenkov.imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
    ../../../dots/ghostty
    ../../../dots/spicetify
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
    colima
    docker
    docker-compose
    nodejs
    colima
    nil
    nixd
    ansible
    age
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
    brews = [ ];
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
      "zed"
      "moonlight"
      "helium-browser"
      "obsidian"
      "hiddenbar"
      "utm"
    ];
  };

  # Nix daemon / features
  nix = {
    settings.experimental-features = "nix-command flakes";
    enable = false;
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

  # Users & shell
  programs.zsh.enable = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
  system.primaryUser = "hdjenkov";
}
