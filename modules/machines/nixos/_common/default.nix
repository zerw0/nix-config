{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  time.timeZone = "Europe/Sofia";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1week
  '';

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = "Defaults env_keep+=SSH_AUTH_SOCK";

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    eza
    ffmpeg
    fd
    bat
    ripgrep
    ncdu
    wget
    htop
  ];
}
