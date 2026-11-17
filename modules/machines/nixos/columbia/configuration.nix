{ pkgs, ... }:
let
  retention = {
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 6;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 3;
    TIMELINE_LIMIT_YEARLY = 0;
    NUMBER_CLEANUP = true;
    NUMBER_LIMIT = 10;
  };
in
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
  ];

  system.stateVersion = "26.05";
  networking.hostName = "columbia";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  users.users.hdjenkov.extraGroups = [
    "networkmanager"
    "docker"
    "libvirtd"
  ];

  # Set the initial login password with nixos-enter + passwd during installation.
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  services.tailscale.enable = true;
  programs.steam.enable = true;
  programs.localsend.enable = true;

  home-manager.users.hdjenkov = {
    imports = [
      ../../../dots/ghostty
      ../../../dots/vscodium
      ../../../dots/gruvbox
    ];
    dots.dev-tools.enable = true;
    dots.cloud-tools.enable = true;
    programs.ghostty.settings.font-size = 12;
    # Linux counterparts of Lambda's Homebrew applications.
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
      bitwarden-desktop
      blender
      calibre
      chromium
      codex
      element-desktop
      libreoffice
      mpv
      orca-slicer
      rustdesk
      telegram-desktop
      transmission_4-qt
      vesktop
    ];
    # Baloo's background content indexing is costly on this dual-core laptop.
    xdg.configFile."baloofilerc".text = ''
      [Basic Settings]
      Indexing-Enabled=false
    '';
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    docker-compose
    pciutils
    usbutils
    libva-utils
  ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";
  programs.kde-pim.enable = false;
  services.orca.enable = false;

  # Retain Dolphin, Ark, Okular, Gwenview, Spectacle and System Settings.
  # Ghostty and VSCodium supply the terminal and editor.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    konsole
    khelpcenter
    krdp
    plasma-workspace-wallpapers
    plasma-keyboard
    qtvirtualkeyboard
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;
  services.xserver.xkb.layout = "us,bg";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  services.snapper = {
    snapshotRootOnBoot = true;
    persistentTimer = true;
    configs = {
      root = retention // {
        SUBVOLUME = "/";
      };
      home = retention // {
        SUBVOLUME = "/home";
      };
    };
  };
  # Disko mounts separate snapshot subvolumes; Snapper must not create them.
  systemd.tmpfiles.rules = [
    "d /.snapshots 0750 root root -"
    "d /home/.snapshots 0750 root root -"
  ];
}
