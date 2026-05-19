{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.pam.services.sudo_local.touchIdAuth = true;

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
