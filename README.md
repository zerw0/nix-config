# nix-config

Personal macOS and NixOS configuration.

## Hosts

| Host | System | Use |
| --- | --- | --- |
| [lambda](modules/machines/darwin/lambda) | macOS · aarch64 | MacBook Pro |
| [htpc](modules/machines/nixos/htpc) | NixOS · x86_64 | Media center |
| [hass](modules/machines/nixos/hass) | NixOS · x86_64 | Home Assistant, printing, scanning |
| [vps](modules/machines/nixos/vps) | NixOS · aarch64 | Self-hosted services |

macOS tracks unstable. NixOS tracks 26.05.

## Services

### vps

- Caddy
- PostgreSQL
- Forgejo + runner
- Headscale + Headplane
- Pocket ID
- Uptime Kuma
- frp
- FMBot
- Epic Games Free Games
- Static website

### hass

- Home Assistant
- Mosquitto
- CUPS / AirPrint
- scanservjs
- Glances
- Caddy
- Chromium kiosk

### htpc

- Kodi + Jellycon

### Home server (via frp)

- Immich
- Nextcloud

## Files

- [machines](modules/machines) — host configurations
- [dots](modules/dots) — shell, terminal, editors
- [users](modules/users) — accounts and Home Manager
- [homelab](modules/homelab) — services
- [flake.nix](flake.nix) — inputs
- [justfile](justfile) — commands

Secrets: agenix, private repository.

## Commands

```sh
just --list
just format
just preflight-lambda
just diff-lambda
just brew-cleanup-preview
just deploy-lambda
just rollback-lambda

just deploy-htpc
just deploy-hass
just deploy-vps

just update
just update-one nixpkgs-unstable
just update-apply
```
