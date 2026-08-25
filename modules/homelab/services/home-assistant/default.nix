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

    # Mosquitto and zigbee2mqtt drop in as sibling modules; z2m additionally
    # needs its coordinator passed through with --device=/dev/serial/by-id/*.
  };
}
