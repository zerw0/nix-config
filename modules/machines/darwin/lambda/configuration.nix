{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./system.nix ];

  home-manager.users.hdjenkov = {
    imports = [
      ../../../dots/ghostty
      ../../../dots/karabiner
      ../../../dots/vscodium
    ];

    dots.dev-tools.enable = true;
    dots.cloud-tools.enable = true;

    home.packages = with pkgs; [
      eza
      fd
      ffmpeg
      htop
      localsend
      ncdu
      ripgrep
      wget
      yt-dlp
    ];
  };

  environment.systemPackages = with pkgs; [
    coreutils
    docker_29
    docker-compose
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = false;
    onActivation.autoUpdate = false;
    global.autoUpdate = false;
    global.brewfile = true;
    taps = [
      {
        name = "Sikarugir-App/sikarugir";
        trusted = true;
      }
    ];
    brews = [ "colima" ];
    casks = [
      "bitwarden"
      "karabiner-elements"
      "keka"
      "rustdesk"
      "tailscale-app"
      "element"
      "helium-browser"
      "libreoffice"
      "telegram-desktop"
      "vesktop"
      "vorssaint"
      "iina"
      "spotify"
      "transmission"
      "blender"
      "codex"
      "orcaslicer"
      "sikarugir"
      "steam"
    ];
  };
  determinateNix = {
    customSettings.trusted-users = [ "@admin" ];
    nixosVmBasedLinuxBuilder = {
      enable = true;
      package = pkgs.darwin.linux-builder-vz;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      ephemeral = true;
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
  age.identityPaths = [ "${config.users.users.hdjenkov.home}/.ssh/personal" ];
  age.secrets.forgejoAccessToken = {
    file = "${inputs.secrets}/forgejoAccessToken.age";
    owner = "hdjenkov";
  };

  system.primaryUser = "hdjenkov";
  system.stateVersion = 6;
}
