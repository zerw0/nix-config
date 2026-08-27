{ lib, config, ... }:
let
  cfg = config.homelab.services.home-assistant;
in
{
  options.homelab.services.home-assistant = {
    enable = lib.mkEnableOption "Home Assistant (container)";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/home-assistant/home-assistant:2026.8.3";
      description = "Pinned image — HA ships breaking changes monthly.";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/home-assistant";
      description = ''
        Bound to the container's /config. Opaque runtime state (.storage, the
        recorder DB, HACS); has its own btrfs subvolume in disk-config.nix.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8123;
      description = "Informational — fixed by HA under host networking.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "ha.${config.homelab.baseDomain}";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.stateDir} 0700 root root -" ];

    virtualisation.oci-containers.containers.home-assistant = {
      image = cfg.image;
      volumes = [ "${cfg.stateDir}:/config" ];
      environment.TZ = config.homelab.timeZone;
      # Required, not cosmetic: HA's discovery integrations use mDNS and SSDP
      # multicast, which does not cross podman's bridge.
      extraOptions = [ "--network=host" ];
    };

    # Caddy terminates TLS via the Cloudflare DNS-01 challenge, so this needs
    # no inbound port from the internet.
    #
    # X-Forwarded-For is stripped rather than forwarded: HA 400s on the header
    # unless http.use_x_forwarded_for is set in configuration.yaml, and on this
    # host that setting parses correctly but is not honoured at runtime. On a
    # LAN-only vhost the only cost is that HA logs every client as 127.0.0.1.
    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.port} {
        header_up -X-Forwarded-For
      }
    '';

    # Mosquitto and zigbee2mqtt drop in as sibling modules; z2m additionally
    # needs its coordinator passed through with --device=/dev/serial/by-id/*.
  };
}
