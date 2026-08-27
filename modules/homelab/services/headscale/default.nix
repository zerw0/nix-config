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

    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      description = ''
        Nameservers pushed to every tailnet client. override_local_dns is on,
        so these fully replace the client's own resolvers. Pointing these at a
        LAN resolver makes all tailnet DNS depend on that host being reachable
        over the tailnet.
      '';
    };

    policy = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
      default = null;
      description = ''
        Headscale ACL policy (policy v2), rendered to JSON at
        /etc/headscale/policy.json. Null means no policy, which is allow-all.
        Note that policy v2 requires usernames to carry a trailing "@".
      '';
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
          nameservers.global = cfg.nameservers;
        };
        log.level = "info";
        policy = lib.mkIf (cfg.policy != null) {
          mode = "file";
          path = "/etc/headscale/policy.json";
        };
        oidc = lib.mkIf cfg.oidc.enable {
          issuer = cfg.oidc.issuer;
          client_id = cfg.oidc.clientId;
          client_secret_path = cfg.oidc.clientSecretFile;
          scope = [
            "openid"
            "profile"
            "email"
          ];
          pkce = {
            enabled = true;
            method = "S256";
          };
        };
      };
    };

    environment.etc."headscale/policy.json" = lib.mkIf (cfg.policy != null) {
      text = builtins.toJSON cfg.policy;
      user = "headscale";
      mode = "0400";
    };

    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      handle /admin* {
        reverse_proxy 127.0.0.1:3002
      }
      reverse_proxy 127.0.0.1:8080
    '';
  };
}
