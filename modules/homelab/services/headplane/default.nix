{ lib, config, ... }:
let
  cfg = config.homelab.services.headplane;
in
{
  options.homelab.services.headplane = {
    enable = lib.mkEnableOption "Headplane (Headscale UI)";
    agent.enable = lib.mkEnableOption "Headplane agent node-information sync";
    requireExistingDatabase = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Refuse to start without the migrated Headplane user database.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.headplane = {
      image = "ghcr.io/tale/headplane:0.7.1@sha256:b2028fa45537c37ddc04dfe1eed513922b8d5236d6d7a2af53bb6fce065dda65";
      volumes = [
        "/var/lib/headplane/config:/etc/headplane:ro"
        "/var/lib/headplane/state:/var/lib/headplane"
        (
          if config.homelab.services.headscale.manageConfigInHeadplane then
            "/var/lib/headscale/config:/etc/headscale:rw"
          else
            "${config.services.headscale.configFile}:/etc/headscale/server.yaml:ro"
        )
      ];
      environment = {
        HEADPLANE_LOAD_ENV_OVERRIDES = "true";
        HEADPLANE_SERVER__HOST = "127.0.0.1";
        HEADPLANE_SERVER__PORT = "3002";
        HEADPLANE_SERVER__BASE_URL = "https://${config.homelab.services.headscale.url}";
        HEADPLANE_SERVER__DATA_PATH = "/var/lib/headplane";
        HEADPLANE_HEADSCALE__URL = "http://127.0.0.1:8080";
        HEADPLANE_HEADSCALE__CONFIG_PATH = "/etc/headscale/server.yaml";
        HEADPLANE_OIDC__SCOPE = "openid email profile";
        HEADPLANE_OIDC__USE_PKCE = "true";
        HEADPLANE_OIDC__DEFAULT_ROLE = "viewer";
      }
      // lib.optionalAttrs cfg.agent.enable {
        HEADPLANE_INTEGRATION__AGENT__ENABLED = "true";
        HEADPLANE_INTEGRATION__AGENT__HOST_NAME = "headplane-agent";
        HEADPLANE_INTEGRATION__AGENT__CACHE_TTL = "180000";
        HEADPLANE_INTEGRATION__AGENT__WORK_DIR = "/var/lib/headplane/agent";
        HEADPLANE_INTEGRATION__AGENT__EXECUTABLE_PATH = "/usr/libexec/headplane/agent";
        # The host-network container reaches Headscale directly over loopback.
        HEADPLANE_INTEGRATION__AGENT__TAILSCALE_NETNS = "false";
      };
      extraOptions = [ "--network=host" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/headplane/state 0700 root root -"
    ]
    ++ lib.optional cfg.agent.enable "d /var/lib/headplane/state/agent 0700 root root -";

    systemd.services.podman-headplane = {
      wants = [ "headscale.service" ];
      after = [ "headscale.service" ];
    };

    systemd.services.podman-headplane.preStart = lib.mkIf cfg.requireExistingDatabase ''
      if ! test -s /var/lib/headplane/state/hp_persist.db; then
        echo "Migrate Headplane state before deployment: just prepare-headplane-state" >&2
        exit 1
      fi
    '';
  };
}
