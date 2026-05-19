{ config, inputs, ... }:
{
  age.secrets.tailscaleAuthKey.file = "${inputs.secrets}/tailscaleAuthKey.age";

  # Disabled until headscale is up and hs.zerw.xyz points to this host
  # services.tailscale.enable = true;
  # services.tailscale.authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  # services.tailscale.extraUpFlags = [ "--login-server=https://hs.zerw.xyz" "--reset" ];
}
