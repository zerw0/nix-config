{ config, lib, ... }:
{
  # Karabiner-Elements rewrites karabiner.json in place whenever the GUI saves
  # (and on every profile switch), so it cannot be a read-only store symlink —
  # the app reports the config as unwritable and falls back to defaults.
  # Deploy a writable copy instead and treat this repo as the source of truth.
  # `just karabiner-import` pulls GUI edits back into the repo.
  home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${config.xdg.configHome}/karabiner
    run install -m 600 $VERBOSE_ARG ${./karabiner.json} \
      ${config.xdg.configHome}/karabiner/karabiner.json
  '';
}
