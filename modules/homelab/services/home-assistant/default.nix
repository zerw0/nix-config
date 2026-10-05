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
      inherit (cfg) image;
      volumes = [ "${cfg.stateDir}:/config" ];
      environment.TZ = config.homelab.timeZone;
      extraOptions = [ "--network=host" ];
    };
    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.port} {
        header_up -X-Forwarded-For
      }
    '';
  };
}
