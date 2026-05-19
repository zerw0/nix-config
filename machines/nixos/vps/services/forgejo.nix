{ pkgs, ... }:
{
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
        SSH_PORT = 222;
        SSH_LISTEN_PORT = 222;
        DOMAIN = "git.zerw.xyz";
        ROOT_URL = "https://git.zerw.xyz/";
        START_SSH_SERVER = true;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  systemd.services.forgejo.serviceConfig.AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
  systemd.services.forgejo.serviceConfig.CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

  networking.firewall.allowedTCPPorts = [ 222 ];
}
