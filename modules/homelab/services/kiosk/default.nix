{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.kiosk;

  clearCrashFlags = ''
    prefs="$HOME/.config/chromium/Default/Preferences"
    if [ -f "$prefs" ]; then
      ${lib.getExe pkgs.gnused} -i \
        -e 's/"exit_type":"[^"]*"/"exit_type":"Normal"/' \
        -e 's/"exited_cleanly":false/"exited_cleanly":true/' \
        "$prefs" || true
    fi
  '';

  debugFlags = lib.optionals (cfg.remoteDebugPort != null) [
    "--remote-debugging-port=${toString cfg.remoteDebugPort}"
    "--remote-allow-origins=*"
  ];

  browser = pkgs.writeShellScript "kiosk-browser" ''
    set -u
    ${clearCrashFlags}
    exec ${lib.getExe pkgs.chromium} ${
      lib.escapeShellArgs (cfg.chromiumFlags ++ debugFlags)
    } ${lib.escapeShellArg cfg.url}
  '';
in
{
  options.homelab.services.kiosk = {
    enable = lib.mkEnableOption "full-screen browser kiosk on the attached display";

    sourceAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.2";
      description = ''
        Loopback address the kiosk connects to, and therefore the source
        address Home Assistant sees it as. Added to lo as a /32 by
        kiosk-source-address.service — that part is not optional. Without an
        interface actually holding it, the only matching route is the kernel's
        local 127.0.0.0/8, whose preferred source is 127.0.0.1, so the kiosk
        would arrive looking exactly like Caddy and trusted_networks could not
        tell them apart.
      '';
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "http://${cfg.sourceAddress}:8123";
      description = ''
        Page the kiosk opens. Home Assistant over loopback rather than its
        Caddy vhost: no DNS override, no certificate and no reverse proxy in
        the path, so the panel keeps working even when name resolution on the
        LAN does not.

        Not 127.0.0.1, and the distinction is what lets the panel skip the
        login screen: Caddy proxies to 127.0.0.1, so anything arriving through
        the vhost looks like 127.0.0.1, while only a process on this host can
        present sourceAddress. That is what HA's trusted_networks provider
        keys on. See the configuration.yaml stanza in the README; that file is
        opaque runtime state, so it is not managed here.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "hdjenkov";
      description = ''
        User the session runs as. Its home holds the Chromium profile, which
        is what keeps the Home Assistant login across reboots.
      '';
    };

    remoteDebugPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      example = 9222;
      description = ''
        When set, Chromium exposes its DevTools protocol on this port, which
        is the only way to read a JS error off a panel with no keyboard.
        Chromium binds it to loopback only, so reach it with
        `ssh -L 9222:127.0.0.1:9222 hass.local` and then chrome://inspect.

        Leave null in normal operation. Anything that reaches this port drives
        the browser completely — it can read the page, navigate it, and run
        script in the Home Assistant origin, which includes the session the
        trusted_networks bypass hands out.
      '';
    };

    chromiumFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--kiosk"
        "--ozone-platform=wayland"
        "--no-first-run"
        "--no-default-browser-check"
        "--noerrdialogs"
        "--disable-infobars"
        "--disable-session-crashed-bubble"
        "--disable-features=Translate,TranslateUI"
        "--check-for-update-interval=31536000"
        "--password-store=basic"
        "--autoplay-policy=no-user-gesture-required"
        "--force-dark-mode"
      ];
      description = "Command line passed to Chromium, before the URL.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.cage = {
      enable = true;
      inherit (cfg) user;
      program = browser;
      extraArguments = [
        "-s"
        "-d"
      ];
    };

    systemd.services.kiosk-source-address = {
      description = "Loopback /32 identifying the kiosk to Home Assistant";
      wantedBy = [ "multi-user.target" ];
      before = [ "cage-tty1.service" ];
      after = [ "network-pre.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip address replace ${cfg.sourceAddress}/32 dev lo";
        ExecStop = "${pkgs.iproute2}/bin/ip address del ${cfg.sourceAddress}/32 dev lo";
      };
    };

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    systemd.services.cage-tty1.serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };

    systemd.services.cage-tty1.restartIfChanged = lib.mkForce true;

    boot.kernelParams = [ "consoleblank=0" ];

    environment.systemPackages = [ pkgs.chromium ];
  };
}
