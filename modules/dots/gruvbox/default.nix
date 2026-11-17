{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = import ./palette.nix;
  rgb =
    hex:
    map (offset: lib.fromHexString (builtins.substring offset 2 hex)) [
      1
      3
      5
    ];
  themeDir = "${config.home.homeDirectory}/.config/gruvbox";
  vesktopDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/vesktop"
    else
      "${config.xdg.configHome}/vesktop";
  chromiumTheme = {
    manifest_version = 3;
    name = "Gruvbox Dark Hard";
    version = "1.0.0";
    theme.colors = lib.mapAttrs (_: rgb) {
      frame = c.bg;
      frame_inactive = c.bg1;
      toolbar = c.bg1;
      tab_text = c.fg;
      tab_background_text = c.gray_light;
      bookmark_text = c.fg;
      ntp_background = c.bg;
      ntp_text = c.fg;
      ntp_link = c.blue;
      button_background = c.bg2;
    };
  };
  mozillaTheme = {
    manifest_version = 2;
    name = "Gruvbox Dark Hard";
    version = "1.0.0";
    browser_specific_settings.gecko.id = "gruvbox@local.invalid";
    theme.colors = {
      frame = c.bg;
      tab_background_text = c.fg;
      tab_selected = c.bg1;
      tab_text = c.fg;
      toolbar = c.bg1;
      toolbar_text = c.fg;
      toolbar_field = c.bg;
      toolbar_field_text = c.fg;
      toolbar_field_border = c.bg3;
      popup = c.bg1;
      popup_text = c.fg;
      popup_border = c.bg3;
      popup_highlight = c.bg2;
      popup_highlight_text = c.yellow;
      sidebar = c.bg;
      sidebar_text = c.fg;
      sidebar_border = c.bg2;
      icons = c.orange;
      tab_line = c.orange;
    };
  };
  mailTheme = pkgs.runCommand "gruvbox-betterbird.xpi" { nativeBuildInputs = [ pkgs.zip ]; } ''
    cp ${pkgs.writeText "manifest.json" (builtins.toJSON mozillaTheme)} manifest.json
    zip -q -X "$out" manifest.json
  '';
in
{
  programs = {
    ghostty.settings = {
      background = c.bg;
      foreground = c.fg;
      cursor-color = c.fg;
      cursor-text = c.bg;
      selection-background = c.bg3;
      selection-foreground = c.fg;
      palette = [
        "0=${c.bg1}"
        "1=${c.red_dim}"
        "2=${c.green_dim}"
        "3=${c.yellow_dim}"
        "4=${c.blue_dim}"
        "5=${c.purple_dim}"
        "6=${c.aqua_dim}"
        "7=${c.gray_light}"
        "8=${c.gray}"
        "9=${c.red}"
        "10=${c.green}"
        "11=${c.yellow}"
        "12=${c.blue}"
        "13=${c.purple}"
        "14=${c.aqua}"
        "15=${c.fg}"
      ];
    };

    fzf.colors.bg = lib.mkForce c.bg;
    starship.settings = {
      palettes.gruvbox_dark.bg = lib.mkForce c.bg;
      directory.style = "bold blue";
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold yellow)";
      };
      git_branch.style = "bold purple";
      git_status.style = "bold yellow";
      cmd_duration.style = "yellow";
      username.style_user = "bold orange";
      hostname.style = "bold aqua";
      nix_shell.style = "bold aqua";
      python.style = "bold yellow";
      nodejs.style = "bold green";
      rust.style = "bold orange";
      golang.style = "bold aqua";
      docker_context.style = "bold blue";
      aws.style = "bold orange";
      kubernetes.style = "bold blue";
      status.style = "bold red";
    };
    zsh = {
      autosuggestion.highlight = "fg=${c.gray}";
      syntaxHighlighting.styles = {
        default = "fg=${c.fg}";
        unknown-token = "fg=${c.red},bold";
        command = "fg=${c.green}";
        builtin = "fg=${c.green}";
        alias = "fg=${c.green}";
        path = "fg=${c.aqua},underline";
        single-quoted-argument = "fg=${c.yellow}";
        double-quoted-argument = "fg=${c.yellow}";
        dollar-double-quoted-argument = "fg=${c.orange}";
        comment = "fg=${c.gray}";
      };
    };
    tmux.extraConfig = lib.mkAfter ''
      set -g status-style "bg=${c.bg},fg=${c.fg}"
      set -g message-style "bg=${c.bg2},fg=${c.yellow}"
      set -g display-panes-colour "${c.gray}"
      set -g display-panes-active-colour "${c.yellow}"
    '';
    delta.options = {
      dark = true;
      minus-style = "syntax '#3c1f1e'";
      plus-style = "syntax '#283322'";
      line-numbers-left-style = c.gray;
      line-numbers-right-style = c.gray;
      hunk-header-style = "file line-number syntax";
    };
    lazygit = {
      enable = true;
      settings.gui.theme = {
        activeBorderColor = [
          c.orange
          "bold"
        ];
        inactiveBorderColor = [ c.bg3 ];
        searchingActiveBorderColor = [
          c.yellow
          "bold"
        ];
        optionsTextColor = [ c.blue ];
        selectedLineBgColor = [ c.bg2 ];
        cherryPickedCommitBgColor = [ c.bg3 ];
        cherryPickedCommitFgColor = [ c.aqua ];
        unstagedChangesColor = [ c.red ];
        defaultFgColor = [ c.fg ];
      };
    };

  };
  xdg.configFile = {
    "gruvbox/helium/manifest.json".text = builtins.toJSON chromiumTheme;
    "gruvbox/betterbird.xpi".source = mailTheme;
    "gruvbox/gruvbox.tdesktop-palette".source = ./telegram.tdesktop-palette;
    "gruvbox/README.txt".text = ''
      Helium: chrome://extensions -> Developer mode -> Load unpacked -> ${themeDir}/helium
      Betterbird: Add-ons and Themes -> gear -> Install Add-on From File -> ${themeDir}/betterbird.xpi
      Telegram Desktop: Settings -> Chat Settings -> menu -> Create new theme -> Import existing theme -> ${themeDir}/gruvbox.tdesktop-palette
      Vesktop: Settings -> Vencord -> Themes -> enable gruvbox.theme.css
    '';
  };
  home.file = {
    "${vesktopDir}/settings/quickCss.css".source = ./vesktop.theme.css;
    "${vesktopDir}/themes/gruvbox.theme.css".source = ./vesktop.theme.css;
  };
}
