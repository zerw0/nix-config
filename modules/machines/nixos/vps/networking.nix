{ ... }:
{
  networking.hostName = "vps";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      7000
    ];
    # Allow container networks to reach host services (forgejo:3000, pocket-id:1411, uptime-kuma:3001, headscale:8080)
    extraCommands = ''
      iptables -I nixos-fw 1 -s 10.89.0.0/16 -j nixos-fw-accept
    '';
  };
}
