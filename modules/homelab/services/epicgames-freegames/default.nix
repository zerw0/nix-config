{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.epicgames-freegames;

  stateDir = "/var/lib/epicgames-freegames";
  unit = "podman-epicgames-freegames.service";
  ownershipPreload = pkgs.writeText "epic-ownership-preload.mjs" ''
    import { isMainThread } from 'node:worker_threads';
    if (isMainThread && process.argv[1] === '/usr/app/dist/src/index.js') {
      const { default: PuppetFreeGames } = await import('/usr/app/dist/src/puppet/free-games.js');
      const { getAccountAuth } = await import('/usr/app/dist/src/common/device-auths.js');
      const { installOwnershipFallback } = await import('/usr/app/ownership-fallback.mjs');
      installOwnershipFallback(PuppetFreeGames, getAccountAuth);
    }
  '';
  checkScript = pkgs.writeShellScript "epicgames-freegames-check" ''
    set -uo pipefail
    PATH=${
      lib.makeBinPath [
        pkgs.systemd
        pkgs.jq
        pkgs.curl
        pkgs.gnugrep
        pkgs.coreutils
      ]
    }

    cursor=${stateDir}/.check-cursor
    conf=${stateDir}/config.json

    [ -f "$conf" ] || exit 0
    errors=$(journalctl -u ${unit} --cursor-file="$cursor" --no-pager -o cat 2>/dev/null \
      | grep -E 'ERROR:' \
      | grep -vF 'Unable to delete folder' \
      | head -5)

    [ -n "$errors" ] || exit 0

    token=$(jq -r '.notifiers[]? | select(.type == "telegram") | .token' "$conf" | head -1)
    chat=$(jq -r '.notifiers[]? | select(.type == "telegram") | .chatId' "$conf" | head -1)
    api=$(jq -r '.notifiers[]? | select(.type == "telegram") | .apiUrl // "https://api.telegram.org"' "$conf" | head -1)

    if [ -z "$token" ] || [ "$token" = "null" ]; then
      echo "no telegram notifier configured in $conf; errors were:" >&2
      echo "$errors" >&2
      exit 0
    fi

    host="${config.networking.hostName}"
    message=$(printf 'epicgames-freegames run failed on %s:\n\n%s' "$host" "$errors")

    curl -sS -m 30 -X POST "$api/bot$token/sendMessage" \
      --data-urlencode "chat_id=$chat" \
      --data-urlencode "text=$message" \
      -o /dev/null
    echo "reported check failure:" >&2
    echo "$errors" >&2
  '';
in
{
  options.homelab.services.epicgames-freegames = {
    enable = lib.mkEnableOption "Epic Games free game checks and checkout notifications";
    url = lib.mkOption {
      type = lib.types.str;
      default = "epic.${config.homelab.baseDomain}";
    };
    notifyOnFailure = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Report failed checks over the container's own Telegram notifier.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.epicgames-freegames = {
      image = "charlocharlie/epicgames-freegames@sha256:c3caf4e667ac87c9fe50346421c5d7f68ccc13dfc1da3751aa50a2541e9054db";
      environment = {
        SERVER_PORT = "3010";
        BASE_URL = "https://${cfg.url}";
        NODE_OPTIONS = "--import=/usr/app/ownership-preload.mjs";
      };
      volumes = [
        "${stateDir}:/usr/app/config"
        "${./ownership.mjs}:/usr/app/ownership-fallback.mjs:ro"
        "${ownershipPreload}:/usr/app/ownership-preload.mjs:ro"
      ];
      extraOptions = [ "--network=host" ];
    };
    services.caddy.virtualHosts.${cfg.url}.extraConfig = ''
      reverse_proxy 127.0.0.1:3010

      handle_errors 502 503 {
        respond "No check in progress. The Epic portal is only up during a scheduled run." 503
      }
    '';

    systemd.services.epicgames-freegames-check = lib.mkIf cfg.notifyOnFailure {
      description = "Report failed epicgames-freegames checks";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = checkScript;
      };
    };
    systemd.timers.epicgames-freegames-check = lib.mkIf cfg.notifyOnFailure {
      description = "Periodically check epicgames-freegames runs";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "15m";
        Persistent = true;
      };
    };
  };
}
