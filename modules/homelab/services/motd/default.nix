{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.motd;

  motdScript = pkgs.writeShellScript "motd" ''
    R='\033[0m'
    B='\033[1m'
    GRN='\033[0;32m'
    RED='\033[0;31m'
    YLW='\033[0;33m'
    CYN='\033[0;36m'
    DIM='\033[2m'

    svc() {
      local unit=$1 label=$2
      if systemctl is-active --quiet "$unit" 2>/dev/null; then
        printf "  ''${GRN}●''${R} %-26s  " "$label"
      else
        local state
        state=$(systemctl is-active "$unit" 2>/dev/null)
        printf "  ''${RED}●''${R} %-26s  ''${DIM}($state)''${R}" "$label"
      fi
    }

    bar() {
      local pct=$1
      local filled=$(( pct / 5 ))
      local empty=$(( 20 - filled ))
      printf "["
      if [ "$pct" -ge 90 ]; then printf "''${RED}"
      elif [ "$pct" -ge 70 ]; then printf "''${YLW}"
      else printf "''${GRN}"; fi
      printf '%0.s#' $(seq 1 $filled 2>/dev/null)
      printf "''${R}"
      printf '%0.s-' $(seq 1 $empty 2>/dev/null)
      printf "] %d%%" "$pct"
    }

    MEM_USED=$(free -m | awk '/^Mem:/{print $3}')
    MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
    MEM_PCT=$(awk "BEGIN{printf \"%.0f\", $MEM_USED/$MEM_TOTAL*100}")
    DISK_USED=$(df -h / | awk 'NR==2{print $3}')
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    DISK_PCT=$(df / | awk 'NR==2{gsub(/%/,""); print $5}')
    LOAD=$(awk '{print $1" "$2" "$3}' /proc/loadavg)
    CORES=$(nproc)
    UPTIME=$(${pkgs.procps}/bin/uptime -p | sed 's/up //')
    NIX_GEN=$(readlink /nix/var/nix/profiles/system | grep -oP '\d+' | tail -1)
    NIX_VER=$(nixos-version 2>/dev/null || echo unknown)

    echo ""
    echo -e "  ''${B}''${CYN}$(hostname -f)''${R}  ''${DIM}$(date '+%a %d %b %Y  %H:%M %Z')''${R}"
    echo ""
    echo -e "  ''${B}SYSTEM''${R}"
    echo -e "  Uptime    $UPTIME"
    echo -e "  Load      $LOAD  ($CORES cores)"
    printf  "  Memory    "; bar "$MEM_PCT"; echo " (''${MEM_USED} / ''${MEM_TOTAL} MB)"
    printf  "  Disk      "; bar "$DISK_PCT"; echo " (''${DISK_USED} / ''${DISK_TOTAL})"
    echo -e "  NixOS     $NIX_VER  ''${DIM}(gen $NIX_GEN)''${R}"
    echo ""
    echo -e "  ''${B}SERVICES''${R}"
    svc "caddy"                      "Caddy"
    svc "postgresql"                 "PostgreSQL"
    echo ""
    svc "forgejo"                    "Forgejo"
    svc "podman-forgejo-runner"      "Forgejo Runner"
    echo ""
    svc "headscale"                  "Headscale"
    svc "podman-headplane"           "Headplane"
    echo ""
    svc "podman-pocket-id"           "Pocket ID"
    svc "uptime-kuma"                "Uptime Kuma"
    echo ""
    svc "frp-server"                 "FRP Server"
    svc "nginx"                      "Nginx (website)"
    echo ""
    svc "podman-epicgames-freegames" "Epic Games Claimer"
    svc "fmatrix"                    "fmbot"
    echo ""
  '';
in
{
  options.homelab.services.motd = {
    enable = lib.mkEnableOption "dynamic SSH MOTD";
  };

  config = lib.mkIf cfg.enable {
    environment.loginShellInit = ''
      ${motdScript}
    '';

    users.motd = lib.mkForce "";
  };
}
