{ config, lib, ... }:
{
  home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${config.xdg.configHome}/karabiner
    run install -m 600 $VERBOSE_ARG ${./karabiner.json} \
      ${config.xdg.configHome}/karabiner/karabiner.json
  '';
}
