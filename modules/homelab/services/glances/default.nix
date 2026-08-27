{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.glances;

  glances = pkgs.glances.overrideAttrs (old: {
    disabledTestPaths = (old.disabledTestPaths or [ ]) ++ [
      "tests/test_restful.py"
      "tests/test_browser_restful.py"
    ];
  });
in
{
  options.homelab.services.glances = {
    enable = lib.mkEnableOption "Glances system monitor with its REST API/web UI";

    port = lib.mkOption {
      type = lib.types.port;
      default = 61208;
      description = "Glances' own default; Home Assistant's integration assumes it.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Glances' web server has no authentication of its own, so the port stays
        shut by default. Home Assistant runs on this host under host
        networking and reaches it over loopback; only open this if something
        off-box needs to scrape it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.glances = {
      enable = true;
      package = glances;
      inherit (cfg) port openFirewall;
      extraArgs = [ "--webserver" ];
    };
  };
}
