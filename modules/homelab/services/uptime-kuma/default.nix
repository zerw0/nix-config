{ lib, config, ... }:
let
  cfg = config.homelab.services.uptime-kuma;
in
{
  options.homelab.services.uptime-kuma = {
    enable = lib.mkEnableOption "Uptime Kuma";
    url = lib.mkOption {
      type = lib.types.str;
      default = "status.${config.homelab.baseDomain}";
    };
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = "3001";
        HOST = "0.0.0.0";
      };
    };

    # Allow the DynamicUser service to reach the podman socket
    # (root:podman 0660) for the local Docker-type monitors.
    systemd.services.uptime-kuma.serviceConfig.SupplementaryGroups = [ "podman" ];

    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:3001";
  };
}
