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

### Headscale / Headplane

ACLs live in the Headscale database and are editable in Headplane. The VPS
policy in Nix is imported once; rebuilds preserve UI edits. The old database
policy is saved in `/var/lib/headscale/policy-before-import.json`.
All users can use approved exit nodes. Existing LAN rules remain scoped to family.

DNS and Headscale settings are managed in Headplane. The writable configuration
at `/var/lib/headscale/config/server.yaml` is seeded once from Nix. Rebuilds
preserve UI edits. `headscale-config.path` validates changes and restarts
Headscale to apply them. Each settings save briefly interrupts the control plane.
Initial backup: `/var/lib/headscale/server-config-before-headplane.yaml`.

Before the first deployment of persistent Headplane state:

```sh
just prepare-headplane-state
just deploy-vps
```

The preparation briefly pauses Headplane and preserves its Owner account and
database. State: `/var/lib/headplane/state`. Secret configuration:
`/var/lib/headplane/config/config.yaml`.

Create and edit OIDC identities in Pocket ID. Each user signs in once at
`https://hs.zerw.xyz/admin` to link their existing Headscale account. New users
receive Viewer access; the Owner assigns higher roles through Headplane.
Both Pocket ID clients allow the existing `users` and `admin` groups.
Headplane uses its existing Pocket ID client and matches Headscale users by OIDC
subject, with email as a fallback.

## Commands

```sh
just --list
just format
just check
just preflight-lambda
just diff-lambda
just deploy-lambda
just rollback-lambda
just clean

just deploy-htpc
just deploy-hass
just deploy-vps

just update
just update nixpkgs-unstable
```

`just update` updates public inputs and validates Lambda. Private inputs: `just update secrets fmatrix`.

nix-index: `nix-locate --whole-name --at-root /bin/<command>`. Zsh suggests packages for missing commands.

VSCodium: Nix IDE with nixd and nixfmt. Edit [settings.json](modules/dots/vscodium/settings.json); deployment reapplies it and keeps the original as `settings.json.before-nix-managed`.

Gruvbox: [palette](modules/dots/gruvbox/palette.nix), [app themes](modules/dots/gruvbox/default.nix). Theme imports: `~/.config/gruvbox/README.txt`.

Development shells: `nix develop ~/git/nix-config#<shell>`.

| Shell | Tools | Language servers |
| --- | --- | --- |
| `default` | Zsh, just, jq, nh, statix, agenix | nixd |
| `infra` | Ansible, OpenTofu, hcloud, OpenBao | YAML, Terraform |
| `web` | Node, pnpm, TypeScript | TypeScript/JavaScript, HTML, CSS, JSON |
| `go` | Go, golangci-lint | gopls |
| `python` | Python 3.13, ipykernel | basedpyright |

Every language shell inherits `default`. Direnv loads its tools into the existing
Zsh session, preserving aliases, completions, autosuggestions, and the prompt.
It does not start a nested shell or launch all language servers.

For automatic activation, add a project-local `.envrc` using the matching shell:

```sh
use flake "$HOME/git/nix-config#web"
```

Run `direnv allow` once after reviewing the file. The existing Home Manager Zsh
hook then loads the environment on entry and unloads it on exit. Use `#infra`,
`#go`, `#python`, or `#default` as appropriate. Personal `.envrc` and `.direnv/`
paths can be excluded in the project's `.git/info/exclude`.

Python notebooks: `nix develop ~/git/nix-config#python --command codium .`; the shell includes ipykernel.
