{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];
  xdg.configFile = {
    "fastfetch/config.jsonrc" = {
      source = ./config.jsonrc;
    };
  };
}
