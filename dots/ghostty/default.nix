{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      theme = "Gruvbox Dark";
      font-size = 16;
      font-family = "CaskaydiaCove Nerd Font";
      adjust-cell-height = "20%";
      font-thicken = true;
      font-thicken-strength = 120;
    };
  };
}
