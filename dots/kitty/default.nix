{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      # Font settings
      font_family = "CaskaydiaCove Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 12.0;

      # Cursor and scrollback
      cursor_shape = "beam";
      scrollback_lines = 4000;
      mouse_hide_wait = 2.5;

      # Opening links
      open_url_modifiers = "ctrl";
      open_url_with = "default";
      url_prefixes = "http https file ftp gemini irc gopher mailto news git";
      url_style = "single";

      # Tabs
      tab_bar_edge = "top";

      # V-Sync
      sync_to_monitor = "yes";

      # Disable bell
      enable_audio_bell = "no";

      # Copy on select
      copy_on_select = "yes";
    };

    keybindings = {
      "cmd+shift+c" = "copy_to_clipboard";
      "cmd+v"       = "paste_from_clipboard";
      "shift+insert" = "paste_from_clipboard";
    };

    extraConfig = ''
      foreground            #f8f8f2
      background            #282a36
      selection_foreground  #ffffff
      selection_background  #44475a

      url_color #8be9fd

      # black
      color0  #21222c
      color8  #6272a4

      # red
      color1  #ff5555
      color9  #ff6e6e

      # green
      color2  #50fa7b
      color10 #69ff94

      # yellow
      color3  #f1fa8c
      color11 #ffffa5

      # blue
      color4  #bd93f9
      color12 #d6acff

      # magenta
      color5  #ff79c6
      color13 #ff92df

      # cyan
      color6  #8be9fd
      color14 #a4ffff

      # white
      color7  #f8f8f2
      color15 #ffffff

      # Cursor colors
      cursor            #f8f8f2
      cursor_text_color background

      # Tab bar colors
      active_tab_foreground   #282a36
      active_tab_background   #f8f8f2
      inactive_tab_foreground #282a36
      inactive_tab_background #6272a4

      # Marks
      mark1_foreground #282a36
      mark1_background #ff5555
    '';
  };
}
