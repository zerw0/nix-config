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

  services.openssh.extraConfig = ''
    Match User git
      AuthorizedKeysFile /var/lib/forgejo/.ssh/authorized_keys
  '';

  networking.firewall.allowedTCPPorts = [ 222 ];
}
