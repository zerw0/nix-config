{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.hostPlatform) system; };
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
      package = unstable.uptime-kuma;
      enable = true;
      settings = {
        PORT = "3001";
        HOST = "0.0.0.0";
      };
    };
    systemd.services.uptime-kuma.serviceConfig.SupplementaryGroups = [ "podman" ];

    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:3001";
  };
}
