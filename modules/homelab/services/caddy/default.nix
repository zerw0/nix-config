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
        # Vendor tree of the plugin build, so this hash is tied to the nixpkgs
        # that resolves it — it changes whenever the hosts move between the
        # release and unstable branches, not just when the plugin is bumped.
        # This value is for nixos-26.05.
        hash = "sha256-PWadA5qr/gR2qDcT8l8u1Xku7LM2HIfWTLOkzezCYy0=";
      };
      globalConfig = ''
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.homelab.cloudflare.dnsCredentialsFile;
  };
}
