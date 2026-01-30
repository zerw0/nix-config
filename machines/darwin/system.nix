{ pkgs, system, username, nixpkgs, ... }:

{
  imports = [
    ./key-remap.nix
  ];
  # Packages available system-wide
  environment.systemPackages = with pkgs; [
    neovim
    eza
    yt-dlp
    ffmpeg
    git
    fd
    coreutils
    bat
    ripgrep
    ncdu
    fastfetch
    htop
      ];

  # Homebrew configuration
  homebrew = {
    enable = true;
    onActivation = {
      # Automatically uninstall/zap casks and brews that are no longer listed
      cleanup = "zap";
    };
    taps = [];
    brews = [];
    casks = [
      "bitwarden"
      "visual-studio-code"
      "vesktop"
      "tailscale-app"
      "zen"
      "iina"
      "keka"
      "spotify"
      "localsend"
      "rustdesk"
      "signal"
      "jellyfin-media-player"
      "cursor"
      "prismlauncher"
      "moonlight"
      "ungoogled-chromium"
      "heroic"
      "affinity"
      "viber"
      "windows-app"
      "dockey"
      "rectangle"
      "orbstack"
      "appcleaner"
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
        orientation = "left";
        autohide = true;
        autohide-time-modifier = 0.20;
        magnification = true;
        tilesize = 32;
        largesize = 64;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
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
  };

  nixpkgs.hostPlatform = system;

  # Users & shell
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
  system.primaryUser = "hdjenkov";

  # Ensure macOS login shell is updated for the user
  system.activationScripts.setDefaultShell.text = ''
    echo "Setting login shell to fish for ${username}..."
    # Make sure the shell is registered in /etc/shells
    if ! grep -q "^/run/current-system/sw/bin/fish$" /etc/shells; then
      echo "/run/current-system/sw/bin/fish" | sudo tee -a /etc/shells >/dev/null || true
    fi

    # Update the login shell in the directory service
    dscl . -create /Users/${username} UserShell /run/current-system/sw/bin/fish || true

    # Also try chsh as a fallback
    chsh -s /run/current-system/sw/bin/fish "${username}" || true
  '';
}
