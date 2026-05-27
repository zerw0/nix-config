# nix-config

Personal Nix configuration for macOS (nix-darwin) and NixOS machines.

## Structure

```
modules/
├── machines/
│   ├── nixos/          # NixOS hosts (auto-discovered)
│   │   ├── _common/    # shared NixOS boilerplate
│   │   ├── htpc/
│   │   ├── vps/
│   │   └── installer/
│   └── darwin/         # darwin hosts (auto-discovered)
│       ├── _common/    # shared darwin boilerplate
│       └── lambda/
├── homelab/            # homelab.services.* option modules (vps services)
├── misc/               # reusable cross-host modules (tailscale, …)
├── users/hdjenkov/     # user account + home-manager entry
├── dots/               # home-manager dotfile modules
└── devshell.nix        # flake-parts perSystem: treefmt + dev shell
justfile                # deploy/check/update shortcuts
```

## Machines

| Host | Type | Description |
|------|------|-------------|
| **lambda** | nix-darwin (aarch64) | MacBook Pro workstation |
| **htpc** | NixOS (x86_64) | Home theater PC |
| **vps** | NixOS (aarch64) | VPS — self-hosted services |

## Services

### htpc

| Service | Description |
|---------|-------------|
| [Kodi](https://kodi.tv) | Media center with Jellycon addon |

### vps

| Service | Description |
|---------|-------------|
| [Caddy](https://caddyserver.com) | Reverse proxy with automatic TLS (Cloudflare DNS) |
| [frp](https://github.com/fatedier/frp) | Tunnel server (frps) for home-hosted services |
| [Forgejo](https://forgejo.org) | Self-hosted git |
| [Forgejo Runner](https://forgejo.org) | CI runner (docker-in-docker) |
| [Headscale](https://headscale.net) | Self-hosted Tailscale control server |
| [Headplane](https://github.com/tale/headplane) | Headscale web UI |
| [Pocket ID](https://github.com/pocket-id/pocket-id) | OIDC/SSO provider |
| [Uptime Kuma](https://github.com/louislam/uptime-kuma) | Uptime monitoring |
| [FMBot](https://fmbot.xyz) | Last.fm Discord bot (via fmatrix) |
| [Epic Games Free Games](https://github.com/claabs/epicgames-freegames-node) | Auto-claim free Epic Games |
| Website | Static site |

Home-hosted services tunneled via frp (frpc runs on Unraid):

| Service | Description |
|---------|-------------|
| [Immich](https://immich.app) | Photo library |
| [Nextcloud](https://nextcloud.com) | File storage |

## Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix) and stored in a private repository. Each machine decrypts secrets using its SSH host key (NixOS) or personal SSH key (macOS).

## Deploy

Use `just --list` to see all available targets. Common workflows:

```bash
just update          # update flake inputs
just check           # nix flake check --no-build
just dry-run vps     # dry-build without switching
just deploy-vps      # remote build + switch on vps
just deploy-htpc     # local rebuild on htpc
just deploy-lambda   # darwin-rebuild switch
just build-iso       # build installer ISO
```

## Installation

### macOS (lambda)

Install Nix via Determinate Systems:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Clone the repo:

```bash
git clone https://<git-host>/hdjenkov/nix-config.git ~/git/nix-config
```

Clone the private secrets repo:

```bash
git clone git@<git-host>:hdjenkov/nix-private.git ~/git/nix-private
```

Apply the configuration:

```bash
sudo darwin-rebuild switch --flake ~/git/nix-config#lambda --override-input secrets ~/git/nix-private
```

---

### NixOS (htpc)

Boot from the installer ISO, then from your workstation copy your SSH key to the target:

```bash
export NIXOS_HOST=192.168.x.x
ssh-copy-id -i ~/.ssh/personal hdjenkov@$NIXOS_HOST
```

SSH in with agent forwarding:

```bash
ssh -A hdjenkov@$NIXOS_HOST
```

Enable flakes:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Partition and format using [disko](https://github.com/nix-community/disko):

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko \
  -- -m destroy,format,mount \
  /path/to/nix-config/modules/machines/nixos/htpc/disk-config.nix
```

Install git and clone the repo:

```bash
nix-env -f '<nixpkgs>' -iA git
mkdir -p /mnt/home/hdjenkov/git
git clone https://<git-host>/hdjenkov/nix-config.git /mnt/home/hdjenkov/git/nix-config
```

Install:

```bash
nixos-install --root /mnt --no-root-passwd \
  --flake git+file:///mnt/home/hdjenkov/git/nix-config#htpc
```

Reboot, then SSH in with agent forwarding and add the host to the secrets repo:

```bash
ssh -A hdjenkov@$NIXOS_HOST
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Add the host key to `secrets.nix` in the private repo, re-encrypt, and push:

```bash
cd ~/git/nix-private
agenix -r
git add -A && git commit -m "add htpc host key" && git push
```

Pull and deploy:

```bash
git clone https://<git-host>/hdjenkov/nix-config.git ~/git/nix-config
git clone git@<git-host>:hdjenkov/nix-private.git ~/git/nix-private  # SSH agent forwarded
cd ~/git/nix-config && git pull
sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake ~/git/nix-config#htpc --override-input secrets ~/git/nix-private
```

---

### NixOS (vps)

From your workstation, copy your SSH key to the VPS:

```bash
export NIXOS_HOST=<vps-ip>
ssh-copy-id -i ~/.ssh/personal root@$NIXOS_HOST
```

SSH in with agent forwarding:

```bash
ssh -A root@$NIXOS_HOST
```

Enable flakes:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Partition and format using [disko](https://github.com/nix-community/disko):

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko \
  -- -m destroy,format,mount \
  /path/to/nix-config/modules/machines/nixos/vps/disk-config.nix
```

Install git and clone the repo:

```bash
nix-env -f '<nixpkgs>' -iA git
mkdir -p /mnt/home/hdjenkov/git
git clone https://<git-host>/hdjenkov/nix-config.git /mnt/home/hdjenkov/git/nix-config
```

Install:

```bash
nixos-install --root /mnt --no-root-passwd \
  --flake git+file:///mnt/home/hdjenkov/git/nix-config#vps
```

Reboot, then SSH in and add the host key to the secrets repo:

```bash
ssh hdjenkov@$NIXOS_HOST
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Add the host key to `secrets.nix` in the private repo, re-encrypt, and push:

```bash
cd ~/git/nix-private
agenix -r
git add -A && git commit -m "add vps host key" && git push
```

## Updating

**lambda:**

```bash
cd ~/git/nix-config && git pull
sudo darwin-rebuild switch --flake ~/git/nix-config#lambda --override-input secrets ~/git/nix-private
```

Or with `just`:

```bash
just deploy-lambda
```

**htpc** (SSH in with `-A`, then):

```bash
cd ~/git/nix-config && git pull
sudo nixos-rebuild switch --flake ~/git/nix-config#htpc
```

> After the first successful deploy, htpc preserves `SSH_AUTH_SOCK` through sudo automatically, so it can fetch the secrets repo directly without `--override-input`.

**vps** (built and deployed remotely from workstation):

```bash
cd ~/git/nix-config && git pull
just deploy-vps
```

Or manually:

```bash
nixos-rebuild switch --flake .#vps \
  --target-host hdjenkov@<vps-host> \
  --build-host hdjenkov@<vps-host> \
  --sudo --ask-sudo-password
```
