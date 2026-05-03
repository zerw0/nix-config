{ pkgs, config, inputs, ... }:
{
  age.secrets.tailscaleAuthKey.file = "${inputs.secrets}/tailscaleAuthKey.age";

  services.tailscale.enable = true;
  services.tailscale.authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  services.tailscale.extraUpFlags = [ "--login-server=https://hs.zerw.xyz" "--reset" ];
  # extraSetFlags run via `tailscale set` unconditionally on every boot
  services.tailscale.extraSetFlags = [
    "--accept-routes"
    "--advertise-routes=192.168.0.0/24"
    "--advertise-exit-node"
  ];

  # Kernel parameters for Tailscale
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Ethtool offload settings for Tailscale — bound to the eno1 device unit so it
  # only runs after the interface exists, not racily against network.target.
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
