{
  config,
  lib,
  pkgs,
  ...
}:
let
  userDir = "${config.home.homeDirectory}/Library/Application Support/VSCodium/User";
  oldUserDir = "${config.home.homeDirectory}/Library/Application Support/Code/User";
  settingsFile = pkgs.writeText "vscodium-settings.json" (
    builtins.toJSON (
      builtins.fromJSON (builtins.readFile ./settings.json)
      // {
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.serverSettings".nixd.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
      }
    )
  );
  openRemoteSsh = pkgs.vscode-utils.buildVscodeExtension {
    pname = "jeanp413.open-remote-ssh";
    version = "0.3.1";
    vscodeExtPublisher = "jeanp413";
    vscodeExtName = "open-remote-ssh";
    vscodeExtUniqueId = "jeanp413.open-remote-ssh";
    src = pkgs.fetchurl {
      url = "https://open-vsx.org/api/jeanp413/open-remote-ssh/0.3.1/file/jeanp413.open-remote-ssh-0.3.1.vsix";
      hash = "sha256-xvFrIlq4aSXyvZ6Mxbox5hSXjM+hIPFQm99umeW+8T8=";
    };
  };
in
{
  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = true;

    profiles.default.extensions =
      (with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        detachhead.basedpyright
        esbenp.prettier-vscode
        jdinhlife.gruvbox
        ms-python.python
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
        pkief.material-icon-theme
        redhat.vscode-yaml
        ritwickdey.liveserver
        vscodevim.vim
      ])
      ++ [
        pkgs.vscode-extensions."4ops".terraform
        openRemoteSsh
      ];
  };
  home.activation.vscodiumSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${userDir}"
    for file in keybindings.json tasks.json; do
      if [ ! -e "${userDir}/$file" ] && [ -f "${oldUserDir}/$file" ]; then
        run install -m 644 $VERBOSE_ARG "${oldUserDir}/$file" "${userDir}/$file"
      fi
    done
    if [ ! -e "${userDir}/snippets" ] && [ -d "${oldUserDir}/snippets" ]; then
      run cp -R "${oldUserDir}/snippets" "${userDir}/snippets"
    fi
    if [ -e "${userDir}/settings.json" ] && [ ! -e "${userDir}/settings.json.before-nix-managed" ]; then
      run cp "${userDir}/settings.json" "${userDir}/settings.json.before-nix-managed"
    fi
    run install -m 644 $VERBOSE_ARG ${settingsFile} "${userDir}/settings.json"
  '';
}
