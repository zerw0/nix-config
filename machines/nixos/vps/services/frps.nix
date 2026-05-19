{ config, ... }:
{
  services.frp.instances.server = {
    enable = true;
    role = "server";
    settings = {
      bindPort = 7000;
      proxyBindAddr = "127.0.0.1";
      auth.method = "token";
      auth.token = "{{ .Envs.FRP_TOKEN }}";
      allowPorts = [{ start = 7001; end = 7100; }];
    };
  };

  systemd.services.frp-server.serviceConfig.EnvironmentFile = config.age.secrets.frpsToken.path;

  services.caddy.virtualHosts."immich.chopapi.xyz".extraConfig = "reverse_proxy 127.0.0.1:7001";
  services.caddy.virtualHosts."nc.chopapi.xyz".extraConfig = ''
    reverse_proxy 127.0.0.1:7002 {
      transport http {
        tls
        tls_insecure_skip_verify
      }
    }
  '';
}
