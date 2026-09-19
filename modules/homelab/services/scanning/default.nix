{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.scanning;
  saneDllConf = pkgs.writeText "sane-dll.conf" ''
    net
  '';

  saneNetConf = pkgs.writeText "sane-net.conf" ''
    connect_timeout = 60
    localhost
  '';
in
{
  options.homelab.services.scanning = {
    enable = lib.mkEnableOption "SANE scanning (brscan4) with a scanservjs web UI";

    image = lib.mkOption {
      type = lib.types.str;
      default = "docker.io/sbs20/scanservjs:v3.3.0";
      description = "Pinned scanservjs image. Podman needs the registry prefix.";
    };

    outputDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/scanservjs/output";
      description = "Host path scanservjs writes finished scans to.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "scan.${config.homelab.baseDomain}";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      brscan4.enable = true;
      disabledDefaultBackends = [ "net" ];
    };
    services.saned = {
      enable = true;
      extraConfig = ''
        localhost
      '';
    };
    systemd.sockets.saned.listenStreams = lib.mkForce [ "127.0.0.1:6566" ];

    users.users.hdjenkov.extraGroups = [
      "scanner"
      "lp"
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/scanservjs 0755 root root -"
      "d ${cfg.outputDir} 0777 root root -"
    ];

    virtualisation.oci-containers.containers.scanservjs = {
      image = cfg.image;
      volumes = [
        "${cfg.outputDir}:/var/lib/scanservjs/output"
        "${saneDllConf}:/etc/sane.d/dll.conf:ro"
        "${saneNetConf}:/etc/sane.d/net.conf:ro"
        "${pkgs.emptyDirectory}:/etc/sane.d/dll.d:ro"
      ];
      environment.TZ = config.homelab.timeZone;
      extraOptions = [ "--network=host" ];
    };
    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:8080";
  };
}
