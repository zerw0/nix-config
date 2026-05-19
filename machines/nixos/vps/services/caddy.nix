{ pkgs, config, ... }:
{
  services.caddy = {
    enable = true;
    email = "me@zerw.xyz";
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20250214141223-67e0a6c3e4bb" ];
      hash = "sha256-tGTkDPMSxBhIIkbybFYQVMlvtFJf2F2cwxAWXPUQn2Y=";
    };
    globalConfig = ''
      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.cloudflareApiToken.path;
}
