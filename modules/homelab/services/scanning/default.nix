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

      # brscan4 is unfree; mkNixosSystem already sets allowUnfree for every
      # NixOS host, so no allowUnfreePredicate here. Go through the module
      # rather than extraBackends: libsane-brother4 aborts with a double free
      # unless /etc/opt/brother/scanner/brscan4 (Brsane4.ini, models4,
      # brsanenetdevice4.cfg) exists, and only the module installs those.
      brscan4.enable = true;

      # The sane module writes `localhost` into the host's net.conf as soon as
      # services.saned is on, and dll.conf ships `net` enabled by default. Left
      # alone, saned enumerating its own backends reconnects to itself on 6566
      # and recurses until it dies — which is what the container sees as a
      # crashed `scanimage -L`. The host has no remote scanners, so drop net.
      disabledDefaultBackends = [ "net" ];
    };

    # Loopback only — the browser UI is the sole network-facing part.
    services.saned = {
      enable = true;
      extraConfig = ''
        localhost
      '';
    };

    # Upstream listens on 0.0.0.0 and [::]. Override listenStreams, not
    # socketConfig.ListenStream — the latter appends a third listener that
    # then collides with the wildcard bind.
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
        # Debian's sane-utils reads /etc/sane.d/dll.d/* on top of dll.conf, so
        # replacing dll.conf alone does not keep the image's other backends out.
        "${pkgs.emptyDirectory}:/etc/sane.d/dll.d:ro"
      ];
      environment.TZ = config.homelab.timeZone;
      # Host networking so the net backend reaches saned on loopback. The image
      # serves on 8080 and that is not remappable under host networking.
      extraOptions = [ "--network=host" ];
    };

    # scanservjs has no authentication of its own, so this must stay on a
    # LAN-only name — the cert comes from a DNS-01 challenge, not from the
    # host being reachable from the internet.
    services.caddy.virtualHosts.${cfg.url}.extraConfig = "reverse_proxy 127.0.0.1:8080";
  };
}
