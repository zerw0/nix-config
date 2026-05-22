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
    oidc = {
      enable = lib.mkEnableOption "OIDC authentication (via pocket-id)";
      issuer = lib.mkOption {
        type = lib.types.str;
        default = "https://id.${config.homelab.baseDomain}";
      };
      clientId = lib.mkOption {
        type = lib.types.str;
        description = "OIDC client ID registered in pocket-id.";
      };
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the agenix-decrypted OIDC client secret.";
      };
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
        oidc = lib.mkIf cfg.oidc.enable {
          issuer = cfg.oidc.issuer;
          client_id = cfg.oidc.clientId;
          client_secret_path = cfg.oidc.clientSecretFile;
          scope = [ "openid" "profile" "email" ];
        };
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
