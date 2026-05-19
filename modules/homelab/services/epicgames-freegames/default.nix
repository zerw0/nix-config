{ lib, config, ... }:
let
  cfg = config.homelab.services.epicgames-freegames;
in
{
  options.homelab.services.epicgames-freegames = {
    enable = lib.mkEnableOption "Epic Games free games auto-claimer";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.epicgames-freegames = {
      image = "charlocharlie/epicgames-freegames:latest";
      environment.SERVER_PORT = "3010";
      volumes = [ "/var/lib/epicgames-freegames:/usr/app/config" ];
      extraOptions = [ "--network=host" ];
    };
  };
}
