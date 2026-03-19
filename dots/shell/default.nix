{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [ grc ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        fg = "#cad3f5";
        bg = "#24273a";
        hl = "#a6da95";
        "fg+" = "#cad3f5";
        "bg+" = "#363a4f";
        "hl+" = "#a6da95";
        pointer = "#ed8796";
        info = "#6e738d";
        spinner = "#6e738d";
        header = "#6e738d";
        prompt = "#8aadf4";
        marker = "#eed49f";
      };
    };
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        line_break = {
          disabled = true;
        };
        package = {
          disabled = true;
        };

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

    zsh = {
      enable = true;
      enableCompletion = false;
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "zsh-users/zsh-completions"; }
          { name = "zsh-users/zsh-history-substring-search"; }
          { name = "unixorn/warhol.plugin.zsh"; }
        ];
      };
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        cat = "bat";
        find = "fd -H";
        ls = "eza --color=always --group-directories-first";
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

      initContent = ''
        # Make Ctrl+W remove one path segment instead of the whole path
        WORDCHARS=''${WORDCHARS/\/}

        # Highlight the selected suggestion
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' menu yes=long select

        ${
          if (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") then
            ''
              path=("$HOME/.nix-profile/bin" "/run/wrappers/bin" "/etc/profiles/per-user/$USER/bin" "/nix/var/nix/profiles/default/bin" "/run/current-system/sw/bin" "/opt/homebrew/bin" "$HOME/.android-sdk-macosx" $path)
              export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
              export SSH_AUTH_SOCK=$HOME/.bitwarden-ssh-agent.sock
              alias lsblk="diskutil list"
              ulimit -n 2048
            ''
          else
            ""
        }

          export EDITOR=nvim || export EDITOR=vim
          export LANG=en_US.UTF-8
          export LC_CTYPE=en_US.UTF-8

          source $ZPLUG_HOME/repos/unixorn/warhol.plugin.zsh/warhol.plugin.zsh
      '';
    };
  };
}
