{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Extensions are not backported to the nixpkgs release branch, so the pins
  # there run many versions behind the marketplace (claude-code 2.1.223 vs
  # 2.1.257, Pylance 2026.2.1 vs 2026.3.1). Take both VS Code and its extensions
  # from unstable instead — they have to move together, since an extension built
  # against 1.133 can declare an engine range that VS Code 1.119 refuses to
  # load. This is the only module in the repo that leaves the release branch.
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  settingsPath = "${config.home.homeDirectory}/Library/Application Support/Code/User/settings.json";
in
{
  programs.vscode = {
    enable = true;
    package = unstable.vscode;

    # VS Code and its extensions install extensions into this directory at
    # runtime, so it stays writable: Home Manager symlinks the pinned ones in
    # and leaves everything else alone. Extensions not packaged in nixpkgs
    # (currently only opentofu.vscode-opentofu) are installed from the
    # marketplace and survive activation.
    mutableExtensionsDir = true;

    profiles.default.extensions =
      (with unstable.vscode-extensions; [
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
      ++ [ unstable.vscode-extensions."4ops".terraform ];
  };

  # settings.json is not managed declaratively: extensions write to it
  # continuously (model pickers, tool approvals, view state), and a store
  # symlink makes every one of those writes fail. Seed it on a fresh machine
  # only, then leave it mutable. `just vscode-import` pulls it back here.
  home.activation.vscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${settingsPath}" ]; then
      run mkdir -p "$(dirname "${settingsPath}")"
      run install -m 644 $VERBOSE_ARG ${./settings.json} "${settingsPath}"
    fi
  '';
}
