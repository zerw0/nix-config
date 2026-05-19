{ ... }:
{
  imports = [
    ./postgresql.nix
    ./forgejo.nix
    ./forgejo-runner.nix
    ./uptime-kuma.nix
    ./headscale.nix
    ./headplane.nix
    ./pocket-id.nix
    ./pangolin.nix
    ./gerbil.nix
    ./traefik.nix
    ./website.nix
    ./epicgames-freegames.nix
    ./fmbot.nix
  ];
}
