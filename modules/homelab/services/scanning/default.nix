{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.scanning;

  # The scanservjs image has no brscan4 — it is proprietary, and the USB-only
  # DCP-1510E needs it. The container therefore reaches the scanner through
  # saned on the host rather than over USB, so `net` is the only backend it
  # needs. Under host networking, localhost is the host.
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
      default = "sbs20/scanservjs:v3.3.0";
      description = "Pinned scanservjs image.";
    };

    outputDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/scanservjs/output";
      description = "Host path scanservjs writes finished scans to.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      # brscan4 is unfree; mkNixosSystem already sets allowUnfree for every
      # NixOS host, so no allowUnfreePredicate here.
      extraBackends = [ pkgs.brscan4 ];
    };

    # Loopback only — the browser UI is the sole network-facing part.
    services.saned = {
      enable = true;
      extraConfig = ''
        localhost
      '';
    };

    systemd.sockets.saned.socketConfig.ListenStream = lib.mkForce "127.0.0.1:6566";

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
      ];
      environment.TZ = config.homelab.timeZone;
      # Host networking so the net backend reaches saned on loopback. The image
      # serves on 8080 and that is not remappable under host networking.
      extraOptions = [ "--network=host" ];
    };
  };
}
