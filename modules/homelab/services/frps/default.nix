{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.hostPlatform) system; };
  cfg = config.homelab.services.frps;
in
{
  options.homelab.services.frps = {
    enable = lib.mkEnableOption "frp server (frps)";

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the agenix-decrypted env file containing FRP_TOKEN.";
    };

    tunneledHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            port = lib.mkOption { type = lib.types.port; };
            caddyExtra = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Vhost-level Caddy directives, outside the reverse_proxy block.";
            };
            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra Caddy reverse_proxy block content for this host.";
            };
          };
        }
      );
      default = { };
      description = "Attrset of domain → {port, extraConfig} for tunneled services.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.frp.package = unstable.frp;
    services.frp.instances.server = {
      enable = true;
      role = "server";
      settings = {
        bindPort = 7000;
        proxyBindAddr = "127.0.0.1";
        auth.method = "token";
        auth.token = "{{ .Envs.FRP_TOKEN }}";
        allowPorts = [
          {
            start = 7001;
            end = 7100;
          }
        ];
      };
    };

    systemd.services.frp-server.serviceConfig.EnvironmentFile = cfg.tokenFile;

    services.caddy.virtualHosts = lib.mapAttrs (_domain: hostCfg: {
      extraConfig =
        hostCfg.caddyExtra
        + (
          if hostCfg.extraConfig != "" then
            ''
              reverse_proxy 127.0.0.1:${toString hostCfg.port} {
                ${hostCfg.extraConfig}
              }
            ''
          else
            "reverse_proxy 127.0.0.1:${toString hostCfg.port}"
        );
    }) cfg.tunneledHosts;
  };
}
