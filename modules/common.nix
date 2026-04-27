{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    eza
    ffmpeg
    fd
    bat
    ripgrep
    ncdu
    wget
  ];
}
