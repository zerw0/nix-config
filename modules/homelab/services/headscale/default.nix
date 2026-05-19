{ lib, config, ... }:
let
  cfg = config.homelab.services.headscale;
in
{
  options.homelab.services.headscale = {
    enable = lib.mkEnableOption "Headscale";
    url = lib.mkOption {
      type = lib.types.str;
      default = "hs.${config.homelab.baseDomain}";
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "ts.${config.homelab.baseDomain}";
      description = "Tailscale magic DNS base domain.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        server_url = "https://${cfg.url}";
        dns = {
          base_domain = cfg.baseDomain;
          nameservers.global = [ "1.1.1.1" "1.0.0.1" ];
        };
        log.level = "info";
      };
    };

    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      handle /admin* {
        reverse_proxy 127.0.0.1:3002
      }
      reverse_proxy 127.0.0.1:8080
    '';
  };
}
