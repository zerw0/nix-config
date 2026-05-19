{ config, ... }:
{
  services.fmatrix = {
    enable = true;
    matrix.homeserver = "https://matrix.org";
    matrix.userId = "@lfmatrixbot:matrix.org";
    settings.commandPrefix = "!";
    settings.logLevel = "INFO";
    secretsFile = config.age.secrets.fmbotEnv.path;
  };
}
