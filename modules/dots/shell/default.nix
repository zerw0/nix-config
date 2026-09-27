{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  home.packages = with pkgs; [
    grc
    zsh-completions
  ];

  home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "/opt/homebrew/bin"
    "$HOME/.android-sdk-macosx"
    "$HOME/.npm-global/bin"
  ];
  programs.zsh.profileExtra = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

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
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;
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
        ipp = "curl -fsS https://ipinfo.io/ip";
        sudo = "sudo ";
        yt = "yt-dlp --add-metadata -i";
        playlist = "yt-dlp -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' ";
        playlist3 = "yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' ";
        ytv = "yt -f bestvideo";
        yta = "yt -x -f bestaudio/best";
        ytmp3 = "yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata ";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        free = "free -m";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        lsblk = "diskutil list";
      };

      initContent = ''
        WORDCHARS=''${WORDCHARS/\/}
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' menu yes=long select
        zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts off
        zstyle ':completion:*:(ssh|scp|sftp|rsync):*' users off
        zstyle ':completion:*:(ssh|scp|sftp|rsync):argument-1:hosts' \
          hosts ''${(uf)"''$(awk '/^Host [^*?#]/ {for(i=2;i<=NF;i++) print ''$i}' \
            ~/.ssh/config ~/.ssh/config.d/*(N) 2>/dev/null)"}

        ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
          ulimit -n 2048
          forgejo-token() { cat "${osConfig.age.secrets.forgejoAccessToken.path}"; }
          export FORGEJO_TOKEN_FILE="${osConfig.age.secrets.forgejoAccessToken.path}"
        ''}

      '';
    };
  };
}
