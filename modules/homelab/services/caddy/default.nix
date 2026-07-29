{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.homelab.services.caddy;
in
{
  options.homelab.services.caddy = {
    enable = lib.mkEnableOption "Caddy reverse proxy";
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      email = "me@zerw.xyz";
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
      };
      globalConfig = ''
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.homelab.cloudflare.dnsCredentialsFile;
  };
}
