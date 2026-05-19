{ lib, config, ... }:
let
  cfg = config.homelab.services.website;
in
{
  options.homelab.services.website = {
    enable = lib.mkEnableOption "personal website";
    url = lib.mkOption {
      type = lib.types.str;
      default = config.homelab.baseDomain;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.url} = {
        listen = [{ addr = "0.0.0.0"; port = 8081; }];
        root = "/var/www/site";
      };
    };

    services.caddy.virtualHosts.${cfg.url}.extraConfig =
      "reverse_proxy 127.0.0.1:8081";
  };
}
