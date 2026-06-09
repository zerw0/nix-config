{
  pkgs,
  osConfig,
  ...
}:
{
  home.packages = with pkgs; [ grc ];

  programs = {
    bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        fg = "#ebdbb2";
        bg = "#282828";
        hl = "#fabd2f";
        "fg+" = "#ebdbb2";
        "bg+" = "#3c3836";
        "hl+" = "#fabd2f";
        pointer = "#fb4934";
        info = "#928374";
        spinner = "#928374";
        header = "#928374";
        prompt = "#83a598";
        marker = "#d3869b";
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

        palette = "gruvbox_dark";

        palettes = {
          gruvbox_dark = {
            bg = "#282828";
            bg1 = "#3c3836";
            bg2 = "#504945";
            bg3 = "#665c54";
            bg4 = "#7c6f64";
            fg = "#ebdbb2";
            fg1 = "#ddc7a1";
            red = "#fb4934";
            red_dim = "#cc241d";
            green = "#b8bb26";
            green_dim = "#98971a";
            yellow = "#fabd2f";
            yellow_dim = "#d79921";
            blue = "#83a598";
            blue_dim = "#458588";
            purple = "#d3869b";
            purple_dim = "#b16286";
            aqua = "#8ec07c";
            aqua_dim = "#689d6a";
            orange = "#fe8019";
            orange_dim = "#d65d0e";
            gray = "#928374";
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

        # SSH completion: only Host aliases from ~/.ssh/config + ~/.ssh/config.d/*
        # Skip known_hosts and /etc/hosts noise.
        zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts off
        zstyle ':completion:*:(ssh|scp|sftp|rsync):*' users off
        zstyle ':completion:*:(ssh|scp|sftp|rsync):argument-1:hosts' \
          hosts ''${(uf)"''$(awk '/^Host [^*?#]/ {for(i=2;i<=NF;i++) print ''$i}' \
            ~/.ssh/config ~/.ssh/config.d/*(N) 2>/dev/null)"}

        ${
          if (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") then
            ''
              path=("$HOME/.nix-profile/bin" "/run/wrappers/bin" "/etc/profiles/per-user/$USER/bin" "/nix/var/nix/profiles/default/bin" "/run/current-system/sw/bin" "/opt/homebrew/bin" "$HOME/.android-sdk-macosx" "$HOME/.npm-global/bin" $path)
              export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
              export SSH_AUTH_SOCK=$HOME/.bitwarden-ssh-agent.sock
              alias lsblk="diskutil list"
              ulimit -n 2048
              forgejo-token() { cat "${osConfig.age.secrets.forgejoAccessToken.path}"; }
              export FORGEJO_TOKEN_FILE="${osConfig.age.secrets.forgejoAccessToken.path}"
            ''
          else if (osConfig.networking.hostName == "steamdeck") then
            ''
              # Bitwarden runs as a flatpak here; its SSH agent socket lives in
              # the flatpak's sandbox home, which is still on the host fs.
              export SSH_AUTH_SOCK=$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
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
