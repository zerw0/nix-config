{ config, ... }:
{
  modules.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    acceptRoutes = true;
  };
}
