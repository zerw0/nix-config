{ lib, config, ... }:
let
  cfg = config.homelab.services.epicgames-freegames;
in
{
  options.homelab.services.epicgames-freegames = {
    enable = lib.mkEnableOption "Epic Games free games auto-claimer";
    url = lib.mkOption {
      type = lib.types.str;
      default = "epic.${config.homelab.baseDomain}";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.epicgames-freegames = {
      image = "charlocharlie/epicgames-freegames:latest";
      environment = {
        SERVER_PORT = "3010";
        # Login/captcha links are generated against this; the default is
        # http://localhost:3000, which is useless from outside the container.
        BASE_URL = "https://${cfg.url}";
      };
      volumes = [ "/var/lib/epicgames-freegames:/usr/app/config" ];
      extraOptions = [ "--network=host" ];
    };

    # The web portal only listens during a scheduled run (CRON_SCHEDULE,
    # default 0 0,6,12,18 * * *), so the backend is down most of the time.
    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      reverse_proxy 127.0.0.1:3010

      handle_errors 502 503 {
        respond "No claim run in progress. The Epic portal is only up during a scheduled run." 503
      }
    '';
  };
}
