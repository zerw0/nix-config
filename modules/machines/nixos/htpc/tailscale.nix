{ pkgs, config, ... }:
{
  modules.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    subnetRouter = true;
    exitNode = true;
  };
  systemd.services.ethtool-tailscale = {
    description = "Configure ethtool offloading for Tailscale";
    bindsTo = [ "sys-subsystem-net-devices-eno1.device" ];
    after = [ "sys-subsystem-net-devices-eno1.device" ];
    wantedBy = [ "sys-subsystem-net-devices-eno1.device" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "-${pkgs.ethtool}/bin/ethtool -K eno1 rx-udp-gro-forwarding on rx-gro-list off";
      RemainAfterExit = true;
    };
  };
}
