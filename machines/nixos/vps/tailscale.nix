{ config, inputs, ... }:
{
  age.secrets.tailscaleAuthKey.file = "${inputs.secrets}/tailscaleAuthKey.age";

  services.tailscale.enable = true;
  services.tailscale.authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  services.tailscale.extraUpFlags = [ "--login-server=https://hs.zerw.xyz" "--reset" ];
}
