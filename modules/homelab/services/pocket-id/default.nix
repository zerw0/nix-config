{ lib, config, ... }:
let
  cfg = config.homelab.services.pocket-id;
in
{
  options.homelab.services.pocket-id = {
    enable = lib.mkEnableOption "Pocket ID (OIDC provider)";
    url = lib.mkOption {
      type = lib.types.str;
      default = "id.${config.homelab.baseDomain}";
    };
    encryptionKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the agenix-decrypted env file containing ENCRYPTION_KEY.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.pocket-id = {
      image = "ghcr.io/pocket-id/pocket-id:latest";
      environment = {
        APP_URL = "https://${cfg.url}";
        TRUST_PROXY = "true";
        PUID = "1000";
        PGID = "1000";
      };
      environmentFiles = [ cfg.encryptionKeyFile ];
      volumes = [ "/var/lib/pocket-id/data:/app/data" ];
      extraOptions = [ "--network=host" ];
    };

    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:1411";
  };
}
