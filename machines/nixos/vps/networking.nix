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
    allowedTCPPorts = [ 80 443 222 ];
    allowedUDPPorts = [ 51820 21820 ];
    # Allow container networks to reach host services (forgejo:3000, pocket-id:1411, uptime-kuma:3001, headscale:8080)
    extraInputRules = ''
      ip saddr 10.89.0.0/16 accept
    '';
  };
}
