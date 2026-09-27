{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.homelab.services.forgejo;
in
{
  options.homelab.services.forgejo = {
    enable = lib.mkEnableOption "Forgejo";
    url = lib.mkOption {
      type = lib.types.str;
      default = "git.${config.homelab.baseDomain}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      stateDir = "/var/lib/forgejo";
      database = {
        type = "postgres";
        socket = "/run/postgresql";
        createDatabase = true;
      };
      settings = {
        server = {
          DISABLE_SSH = true;
          DOMAIN = cfg.url;
          ROOT_URL = "https://${cfg.url}/";
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:3000";
  };
}
