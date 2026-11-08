{ pkgs, ... }:
let
  plugin = pkgs.fetchurl {
    url = "https://github.com/kyxap/koreader-calibre-plugin/releases/download/v0.8.2/KOReader_Sync_v0.8.2.zip";
    hash = "sha256-KWCoA6dD7EmoBrzNMNxiApRYZ3I2SmfslNTwYINvIwM=";
  };
in
{
  homebrew.casks = [ "calibre" ];

  home-manager.users.hdjenkov = { lib, ... }: {
    home.activation.calibreSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -x /Applications/calibre.app/Contents/MacOS/calibre-debug ]; then
        run /Applications/calibre.app/Contents/MacOS/calibre-debug \
          -e ${./calibre-setup.py} -- ${plugin}
      fi
    '';
  };
}
