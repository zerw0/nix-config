{ ... }:
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "3001";
      HOST = "0.0.0.0";
    };
  };

  services.caddy.virtualHosts."status.zerw.xyz".extraConfig = "reverse_proxy 127.0.0.1:3001";
}
