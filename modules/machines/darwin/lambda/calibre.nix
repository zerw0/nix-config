{ config, pkgs, ... }:
let
  home = config.users.users.hdjenkov.home;
  library = "${home}/Books/Calibre Library";
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
    launchd.agents.calibre = {
      enable = true;
      config = {
        Label = "org.nix-community.home.calibre";
        ProgramArguments = [
          "/Applications/calibre.app/Contents/MacOS/calibre"
          "--with-library"
          library
          "--start-in-tray"
        ];
        RunAtLoad = true;
        ProcessType = "Interactive";
        StandardOutPath = "${home}/Library/Logs/calibre.log";
        StandardErrorPath = "${home}/Library/Logs/calibre.error.log";
      };
    };
  };
}
