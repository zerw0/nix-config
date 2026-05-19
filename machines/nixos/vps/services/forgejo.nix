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
        SSH_USER = "git";
        DOMAIN = "git.zerw.xyz";
        ROOT_URL = "https://git.zerw.xyz/";
        START_SSH_SERVER = false;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  services.openssh.authorizedKeysInHomedir = true;

  networking.firewall.allowedTCPPorts = [ 222 ];
}
