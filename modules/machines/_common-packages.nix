{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    eza
    fd
    ripgrep
    ncdu
    wget
    htop
  ];
}
