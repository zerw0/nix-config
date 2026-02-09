{ config, pkgs, ... }:

{
  # From `fish/config.fish`
  home.sessionVariables = {
    EDITOR = "nvim";
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "/usr/local/bin"
    "/sbin"
    "$HOME/.android-sdk-macosx/platform-tools/"
  ];

  programs.fish = {
    enable = true;

    # Keep the fish logic in fish syntax
    interactiveShellInit = ''
      # Disable fish welcome message
      set -g fish_greeting

      # Disable last login message (macOS)
      touch "$HOME/.hushlogin" 2>/dev/null || true

      # Source extra fish files if they exist
      test -f "$HOME/.config/fish/shortcuts.fish"; and source "$HOME/.config/fish/shortcuts.fish"
      test -f "$HOME/.config/fish/colors.fish"; and source "$HOME/.config/fish/colors.fish"

      # Set "bat" as manpager (only if installed)
      if type -q bat
          set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
      end
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      cat = "bat";
      find = "fd -H";
      ls = "eza  --color=always --group-directories-first";
      la = "eza -la --color=always --group-directories-first";
      ll = "eza -l --color=always --group-directories-first";
      lt = "eza -aT --color=always --group-directories-first";
      "l." = "eza -a | egrep '^\\.'";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      df = "df -h";
      free = "free -m";
      ipp = "curl ipinfo.io/ip";
      sudo = "sudo ";
      yt = "yt-dlp --add-metadata -i";
      playlist = "yt-dlp -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' ";
      playlist3 = "yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' ";
      ytv = "yt -f bestvideo";
      yta = "yt -x -f bestaudio/best";
      ytmp3 = "yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata ";
    };
  };

  # From `starship.toml`
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = false;
      line_break = { disabled = true; };
      package = { disabled = true; };

      palette = "catppuccin_macchiato";

      palettes = {
        catppuccin_macchiato = {
          rosewater = "#f4dbd6";
          flamingo = "#f0c6c6";
          pink = "#f5bde6";
          mauve = "#c6a0f6";
          red = "#ed8796";
          maroon = "#ee99a0";
          peach = "#f5a97f";
          yellow = "#eed49f";
          green = "#a6da95";
          teal = "#8bd5ca";
          sky = "#91d7e3";
          sapphire = "#7dc4e4";
          blue = "#8aadf4";
          lavender = "#b7bdf8";
          text = "#cad3f5";
          subtext1 = "#b8c0e0";
          subtext0 = "#a5adcb";
          overlay2 = "#939ab7";
          overlay1 = "#8087a2";
          overlay0 = "#6e738d";
          surface2 = "#5b6078";
          surface1 = "#494d64";
          surface0 = "#363a4f";
          base = "#24273a";
          mantle = "#1e2030";
          crust = "#181926";
        };
      };
    };
  };
}
