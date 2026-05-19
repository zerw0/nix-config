{ ... }:
{
  services.forgejo = {
    enable = true;
    stateDir = "/var/lib/forgejo";

    database = {
      type = "postgres";
      socket = "/run/postgresql";
      createDatabase = true;
    };

    settings = {
      server = {
        SSH_PORT = 222;
        SSH_LISTEN_PORT = 22;
        DOMAIN = "git.zerw.xyz";
        ROOT_URL = "https://git.zerw.xyz/";
        START_SSH_SERVER = false;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  # Forgejo SSH port — host SSH stays on 22 (openssh), forgejo git SSH on 222
  networking.firewall.allowedTCPPorts = [ 222 ];
}
