{ pkgs, ... }:
{
  services.tailscale.enable = true;

  # Kernel parameters for Tailscale
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Ethtool offload settings for Tailscale
  systemd.services.ethtool-tailscale = {
    enable = true;
    description = "Configure ethtool offloading for Tailscale";
    after = [ "network-pre.target" ];
    before = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c '${pkgs.ethtool}/bin/ethtool -K eno1 rx-udp-gro-forwarding on rx-gro-list off || true'";
      RemainAfterExit = true;
    };
  };
}
