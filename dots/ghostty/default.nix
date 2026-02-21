{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      theme = "Gruvbox Dark";
      font-size = 16;
      font-family = "CaskaydiaCove Nerd Font";
      adjust-cell-height = "20%";
      background-opacity = "0.95";
      shell-integration-features = [ "ssh-terminfo" ];
      font-thicken = true;
      font-thicken-strength = 120;
    };
  };
}
