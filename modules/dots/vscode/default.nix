{
  config,
  lib,
  pkgs,
  ...
}:
let
  settingsPath = "${config.home.homeDirectory}/Library/Application Support/Code/User/settings.json";
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;

    profiles.default.extensions =
      (with pkgs.vscode-extensions; [
        anthropic.claude-code
        bbenoist.nix
        esbenp.prettier-vscode
        jdinhlife.gruvbox
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.remote-explorer
        ms-vsliveshare.vsliveshare
        pkief.material-icon-theme
        redhat.vscode-yaml
        ritwickdey.liveserver
        vscodevim.vim
      ])
      ++ [ pkgs.vscode-extensions."4ops".terraform ];
  };
  home.activation.vscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${settingsPath}" ]; then
      run mkdir -p "$(dirname "${settingsPath}")"
      run install -m 644 $VERBOSE_ARG ${./settings.json} "${settingsPath}"
    fi
  '';
}
