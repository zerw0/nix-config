{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  c = import ../gruvbox/palette.nix;
in
{
  home.packages = with pkgs; [
    grc
    zsh-completions
  ];

  home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "/opt/homebrew/bin"
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
        inherit (c) fg;
        bg = c.bg1;
        hl = c.yellow;
        "fg+" = c.fg;
        "bg+" = c.bg2;
        "hl+" = c.yellow;
        pointer = c.red;
        info = c.gray;
        spinner = c.gray;
        header = c.gray;
        prompt = c.blue;
        marker = c.purple;
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
            inherit (c)
              fg
              fg1
              red
              red_dim
              green
              green_dim
              yellow
              yellow_dim
              blue
              blue_dim
              purple
              purple_dim
              aqua
              aqua_dim
              orange
              orange_dim
              gray
              ;
            bg = c.bg1;
            bg1 = c.bg2;
            bg2 = c.bg3;
            bg3 = c.bg4;
            bg4 = c.bg5;
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
