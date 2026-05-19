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
        DISABLE_SSH = true;
        DOMAIN = "git.zerw.xyz";
        ROOT_URL = "https://git.zerw.xyz/";
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };
}
