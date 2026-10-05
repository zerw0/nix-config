{ lib, config, ... }:
let
  cfg = config.homelab.services.mosquitto;
in
{
  options.homelab.services.mosquitto = {
    enable = lib.mkEnableOption "Mosquitto MQTT broker";

    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
      description = "Listen port. Also the port opened on the host.";
    };

    hassPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Cleartext password for the 'hass' MQTT user.";
    };

    frigatePasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Cleartext password for the 'frigate' MQTT user.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          inherit (cfg) port;
          users = {
            hass = {
              acl = [ "readwrite #" ];
              passwordFile = cfg.hassPasswordFile;
            };
            frigate = {
              acl = [ "readwrite frigate/#" ];
              passwordFile = cfg.frigatePasswordFile;
            };
          };
        }
      ];
    };
  };
}
