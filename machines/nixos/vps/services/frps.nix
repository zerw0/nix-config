{ config, ... }:
{
  services.frp = {
    enable = true;
    role = "server";
    settings = {
      bindPort = 7000;
      proxyBindAddr = "127.0.0.1";
      auth.method = "token";
      # frp expands Go template env vars at runtime — token never hits the nix store
      auth.token = "{{ .Envs.FRP_TOKEN }}";
      allowPorts = [{ start = 7001; end = 7100; }];
    };
  };

  # Inject the secret token as an environment variable
  systemd.services.frp.serviceConfig.EnvironmentFile = config.age.secrets.frpsToken.path;

  services.caddy.virtualHosts."immich.zerw.xyz".extraConfig = "reverse_proxy 127.0.0.1:7001";
  services.caddy.virtualHosts."nc.zerw.xyz".extraConfig = "reverse_proxy 127.0.0.1:7002";
}
