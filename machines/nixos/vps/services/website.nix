{ ... }:
{
  services.nginx = {
    enable = true;
    # Port 8081: traefik (via pangolin/gerbil) proxies 80/443 → this backend
    virtualHosts."zerw.xyz" = {
      listen = [{ addr = "0.0.0.0"; port = 8081; }];
      root = "/var/www/site";
    };
  };
}
