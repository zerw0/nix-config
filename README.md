# nix-config

Personal macOS and NixOS configuration. macOS tracks unstable; NixOS tracks 26.05.

## Hosts

| Host | System | Services |
| --- | --- | --- |
| [lambda](modules/machines/darwin/lambda) | macOS · aarch64 | MacBook Pro |
| [htpc](modules/machines/nixos/htpc) | NixOS · x86_64 | Kodi + Jellycon |
| [hass](modules/machines/nixos/hass) | NixOS · x86_64 | Home Assistant, Mosquitto, CUPS / AirPrint, scanservjs, Glances, Caddy, Chromium kiosk |
| [vps](modules/machines/nixos/vps) | NixOS · aarch64 | Caddy, PostgreSQL, Forgejo + runner, Headscale + Headplane, Pocket ID, Uptime Kuma, frp, FMBot, Epic Games Free Games, static website |

Home server via frp: Immich and Nextcloud.

## Files

- [machines](modules/machines): host configurations
- [dots](modules/dots): shell, terminal, editors, themes
- [users](modules/users): accounts and Home Manager
- [homelab](modules/homelab): services
- [flake.nix](flake.nix): inputs
- [justfile](justfile): commands

Secrets: agenix and a private repository.
Headscale ACLs and DNS are managed in Headplane; rebuilds preserve UI changes.
Persistent Headscale configuration: `/var/lib/headscale/config/server.yaml`.
Before the first VPS deployment using persistent Headplane state, run
`just prepare-headplane-state`.

## Commands

```sh
just --list
just format
just check
just preflight-lambda
just diff-lambda
just deploy-lambda
just rollback-lambda
just deploy-htpc
just deploy-hass
just deploy-vps
just clean

just update
just update nixpkgs-unstable
```

`just update` updates public inputs and validates Lambda.
Private inputs: `just update secrets fmatrix`.

## Development

```sh
nix develop ~/git/nix-config#<shell>
```

| Shell | Tools |
| --- | --- |
| `default` | Zsh, just, jq, nh, statix, agenix, nixd |
| `infra` | Ansible, OpenTofu, hcloud, OpenBao, YAML / Terraform language servers |
| `web` | Node, pnpm, TypeScript, web language servers |
| `go` | Go, golangci-lint, gopls |
| `python` | Python 3.13, ipykernel, basedpyright |

Each shell inherits `default`. For direnv, add
`use flake "$HOME/git/nix-config#<shell>"` to the project's `.envrc`, then run
`direnv allow`.

VSCodium settings: [settings.json](modules/dots/vscodium/settings.json).
Gruvbox palette: [palette.nix](modules/dots/gruvbox/palette.nix).
App theme imports: `~/.config/gruvbox/README.txt`.
Package lookup: `nix-locate --whole-name --at-root /bin/<command>`.
