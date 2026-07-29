{ ... }:
{
  imports = [
    ./caddy
    ./postgresql
    ./forgejo
    ./forgejo-runner
    ./uptime-kuma
    ./headscale
    ./headplane
    ./pocket-id
    ./frps
    ./website
    ./epicgames-freegames
    ./fmbot
    ./motd
  ];
}
