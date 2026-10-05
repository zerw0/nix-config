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
          DISABLE_SSH = false;
          START_SSH_SERVER = true;
          SSH_DOMAIN = cfg.url;
          SSH_PORT = 22;
          SSH_LISTEN_PORT = 22;
          BUILTIN_SSH_SERVER_USER = "git";
          DOMAIN = cfg.url;
          ROOT_URL = "https://${cfg.url}/";
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
    systemd.services.forgejo.serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
      PrivateUsers = lib.mkForce false;
    };

    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:3000";
  };
}
