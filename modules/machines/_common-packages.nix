{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    eza
    ffmpeg
    fd
    ripgrep
    ncdu
    wget
    htop
  ];
}
