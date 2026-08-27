{ config, ... }:
{
  modules.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    # Accept the 10.0.1.0/24 subnet advertised by the OpenWrt node so
    # Uptime Kuma can reach the home Unraid Docker API (10.0.1.10:2375).
    acceptRoutes = true;
    # Keep the VPS on its own resolver: headscale now pushes 10.0.1.1, and the
    # VPS must not depend on the home router for ACME, Forgejo or pocket-id.
    acceptDns = false;
  };
}
