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

Oh My Pi (Lambda): `omp`, then `/login openai-codex` to sign in with ChatGPT.
Use `/model` to choose a model. The pinned binary is in
[dev-tools](modules/dots/dev-tools/default.nix); activation seeds writable settings
once in `~/.omp/agent/config.yml` with the ChatGPT provider as the default.
OMP instructions direct it to consult `~/.codex/memories/` without changing it.
This is an agent instruction, not a filesystem sandbox. To import a saved Codex
conversation, run `omp --from-codex` and select it. Imports are manual; the Nix
setup does not import sessions. OMP's own memory backend starts disabled.

`omp update` cannot replace the Nix-managed binary. To upgrade, update `version`,
the immutable build URL, and `sha256` in [dev-tools](modules/dots/dev-tools/default.nix)
using the release metadata at
`https://build.stencil.so/api/products/omp/versions/<version>/macos-arm64`.
Run `just preflight-lambda` to validate without activation, then, when ready to
activate the system configuration, run `just deploy-lambda`. Restart OMP afterward.

With direnv active, launch `omp` directly from the project directory. Without
direnv, use `nix develop ~/git/nix-config#web --command omp`. For a manual
interactive development shell, use `nix develop ~/git/nix-config#web --command zsh`.

Restart an OMP session launched outside the environment; reloading LSP alone
does not add binaries to its startup `PATH`. Server discovery also requires
matching project-root markers (for example `.git`, `package.json`, `go.mod`,
or `pyproject.toml`, depending on the server). Servers start on demand.

Personal OMP advisors: `~/.omp/agent/WATCHDOG.yml`. The Correctness and Security
reviewers use read-only tools and review final yields of the main session only.
Shared and role-specific instructions append to OMP's built-in advisor prompt.
Each review is additional model usage; subagents do not inherit this roster's
reviewers. Use `/advisor status` to inspect them and `/advisor off` to disable
them for the current session. Global activation is `advisor.enabled` in the
writable OMP config.
