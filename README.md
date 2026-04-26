# nix-config

Personal Nix configuration for macOS (nix-darwin) and NixOS machines.

## Machines

| Host | Type | Description |
|------|------|-------------|
| **lambda** | nix-darwin (aarch64) | macOS workstation |
| **htpc** | NixOS (x86_64) | Home theater PC running Kodi + Jellyfin |

## Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix) and stored in a private repository. Each machine decrypts secrets using its SSH host key (NixOS) or personal SSH key (macOS).

## Installation

### macOS (lambda)

Install Nix via Determinate Systems:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Clone the repo:

```bash
git clone https://github.com/zerw0/nix-config.git ~/git/nix-config
```

Clone the private secrets repo:

```bash
git clone git@git.zerw.xyz:hdjenkov/nix-private.git ~/git/nix-private
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
  /path/to/nix-config/machines/nixos/htpc/disk-config.nix
```

Install git and clone the repo:

```bash
nix-env -f '<nixpkgs>' -iA git
mkdir -p /mnt/home/hdjenkov/git
git clone https://github.com/zerw0/nix-config.git /mnt/home/hdjenkov/git/nix-config
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
git clone https://github.com/zerw0/nix-config.git ~/git/nix-config
git clone git@git.zerw.xyz:hdjenkov/nix-private.git ~/git/nix-private  # SSH agent forwarded
cd ~/git/nix-config && git pull
sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake ~/git/nix-config#htpc --override-input secrets ~/git/nix-private
```

## Updating

**lambda:**

```bash
cd ~/git/nix-config && git pull
sudo darwin-rebuild switch --flake ~/git/nix-config#lambda --override-input secrets ~/git/nix-private
```

**htpc** (SSH in with `-A`, then):

```bash
cd ~/git/nix-config && git pull
sudo nixos-rebuild switch --flake ~/git/nix-config#htpc
```

> After the first successful deploy, htpc preserves `SSH_AUTH_SOCK` through sudo automatically, so it can fetch the secrets repo directly without `--override-input`.
