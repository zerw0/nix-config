# nix-config

Personal Nix configuration for macOS (nix-darwin) and NixOS machines.

## Structure

```
modules/
├── machines/
│   ├── nixos/          # Explicit NixOS host definitions
│   │   ├── _common/    # shared NixOS boilerplate
│   │   ├── htpc/
│   │   ├── hass/
│   │   ├── vps/
│   │   └── installer/
│   └── darwin/         # nix-darwin host definitions
│       ├── _common/    # shared darwin boilerplate
│       └── lambda/
├── homelab/            # homelab.services.* option modules (vps + hass services)
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
| **hass** | NixOS (x86_64) | Home automation + print/scan server (LAN only) |
| **vps** | NixOS (aarch64) | VPS — self-hosted services |

## Services

### htpc

| Service | Description |
|---------|-------------|
| [Kodi](https://kodi.tv) | Media center with Jellycon addon |

### hass

| Service | Description |
|---------|-------------|
| [Home Assistant](https://www.home-assistant.io) | Home automation, container (pinned tag, host network) |
| [CUPS](https://www.cups.org) | LAN print server for the Brother DCP-1510E (brlaser), AirPrint via Avahi |
| [scanservjs](https://github.com/sbs20/scanservjs) | Browser scanning UI, driven by the host's SANE/brscan4 over saned |
| [Glances](https://github.com/nicolargo/glances) | Host metrics over a loopback-only REST API, scraped by Home Assistant |
| [cage](https://github.com/cage-kiosk/cage) | Wayland kiosk on the attached monitor: Chromium full-screen on the HA dashboard |

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
just update                 # preview input updates without changing flake.lock
just update-one nix-darwin  # update one input, then validate lambda
just update-apply           # update everything, format, evaluate and build lambda
just preflight-lambda       # evaluate all systems and build lambda
just diff-lambda            # compare the next lambda closure with the live one
just deploy-lambda          # preflight, show the nh diff and activate
just generations-lambda     # list generations available for rollback
just rollback-lambda        # activate the previous generation
just deploy-vps             # remote build + switch on vps
just deploy-htpc            # remote build + switch on htpc
just deploy-hass            # remote build + switch on hass
just build-iso              # build installer ISO
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

### NixOS (hass)

Boot the official NixOS minimal ISO and work at the console (user `nixos`, no
password). On Wi-Fi, connect first with `nmtui`, or:

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "SSID"
> set_network 0 psk "PASSWORD"
> enable_network 0
> quit
```

Install git and clone the repo:

```bash
nix-env -f '<nixpkgs>' -iA git
git clone https://<git-host>/hdjenkov/nix-config.git /tmp/nix-config
```

Partition and format using [disko](https://github.com/nix-community/disko):

```bash
lsblk    # confirm the target disk
nix-shell -p disko --run \
  "disko -m destroy,format,mount /tmp/nix-config/modules/machines/nixos/hass/disk-config.nix"
```

> `disk-config.nix` targets `/dev/nvme0n1` and wipes it unconditionally.

> Use `nix-shell` here, not `nix run github:nix-community/disko`. The ISO store
> is a ~2GB tmpfs and the flake pulls its own nixpkgs (330MB unpacked) into it,
> which runs out of space on 4GB; `nix-shell` uses the channel already on the
> ISO. `mount -o remount,size=3G /nix/.rw-store` buys headroom if still tight.

Install. No `--no-root-passwd` here — set a root password, it is the only way
back in if the box boots without network:

```bash
sudo nixos-install --root /mnt --flake /tmp/nix-config#hass -j 2 --cores 2
```

> `nixos-install` builds with `--store /mnt`, so the closure lands on the NVMe,
> not the ISO's RAM overlay. It also rejects `--override-input`.

On Wi-Fi, copy the connection profile over before rebooting, or the installed
system comes up with no network:

```bash
sudo cp /etc/NetworkManager/system-connections/*.nmconnection \
        /mnt/etc/NetworkManager/system-connections/
sudo chmod 600 /mnt/etc/NetworkManager/system-connections/*.nmconnection
```

Reboot, then SSH in and add the host key to the secrets repo:

```bash
ssh hdjenkov@hass.local
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Add the host key to `secrets.nix` in the private repo, re-encrypt, and push:

```bash
cd ~/git/nix-private
agenix -r
git add -A && git commit -m "add hass host key" && git push
```

Then `just deploy-hass` from the workstation.

> `hashedUserPassword` decrypts with the SSH host key, which does not exist
> until first boot, so console login for `hdjenkov` only works after this
> deploy. SSH key auth and passwordless sudo work immediately.

Manual steps outside Nix, once:

- **Printer** — `http://hass:631` → Administration → Add Printer, pick the
  brlaser PPD. Writes `/etc/cups/printers.conf`. `lpinfo -v` gives the device
  URI if you later want `hardware.printers.ensurePrinters`.
- **Scanner** — check `scanimage -L`. If brscan4 misses the device, register it
  with `brsaneconfig4 -a`. The scanservjs UI at `http://hass:8080` only sees
  what the host sees, since it goes through saned rather than USB.
- **Home Assistant** — onboard at `http://hass:8123`.
- **Kiosk login** — the panel skips the login screen entirely, so no keyboard
  is ever plugged into it. Add to `/var/lib/home-assistant/configuration.yaml`
  and restart the container:

  ```yaml
  homeassistant:
    auth_providers:
      # trusted_networks MUST come first. The frontend starts the flow for the
      # first provider in this list and offers the rest behind "log in with
      # other providers", so with homeassistant first the panel shows a
      # password form even though the bypass works.
      - type: trusted_networks
        trusted_networks:
          - 127.0.0.2/32
        allow_bypass_login: true
        # allow_bypass_login only skips the prompt when the address maps to
        # exactly one user; pinning the id keeps that true if another HA
        # account is ever added. Ids come from .storage/auth.
        trusted_users:
          127.0.0.2: <user_id>
      # Listing trusted_networks replaces the default provider list, so
      # homeassistant must be named explicitly or password login disappears
      # everywhere — phone included.
      - type: homeassistant
  ```

  Verify the provider is offered, and only to the kiosk:

  ```bash
  curl -s http://127.0.0.2:8123/auth/providers   # includes trusted_networks
  curl -s http://127.0.0.1:8123/auth/providers   # homeassistant only
  ```

  The kiosk browses `http://127.0.0.2:8123`. `kiosk-source-address.service`
  adds `127.0.0.2/32` to `lo`, which makes it the preferred source for that
  destination — without the `/32` the only match is the kernel's
  `local 127.0.0.0/8`, whose preferred source is `127.0.0.1`, and the kiosk
  would be indistinguishable from Caddy. Caddy proxies to `127.0.0.1`, so LAN
  clients arriving through the vhost stay untrusted and still get a login
  screen.

  Confirm with a real socket, not `ip route get` — the latter answers with the
  `local 127.0.0.0/8` route's `prefsrc` (`127.0.0.1`) and will look like a
  failure even when everything is correct:

  ```bash
  bash -c 'exec 3<>/dev/tcp/127.0.0.2/8123; ss -tn "dst 127.0.0.2"'
  ```

  The `Local Address` column is what HA sees. It must read `127.0.0.2`.

  Do not swap `127.0.0.2` for `127.0.0.1` here. Caddy strips `X-Forwarded-For`
  (see `modules/homelab/services/home-assistant/default.nix`), so HA sees every
  proxied client as `127.0.0.1`; trusting it would auto-log-in the whole
  network.
- **Glances integration** — Settings → Devices & Services → Add Integration →
  Glances, once per host: `127.0.0.1` (this box), the Unraid box and the
  OpenWRT router, all on port 61208. Then build the dashboard from the
  resulting sensors.
- **Wi-Fi** — the copied profile is mutable state; move the PSK into an agenix
  secret and `networking.networkmanager.ensureProfiles` to make it declarative.

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

### Package ownership

- nix-darwin owns macOS settings, services, fonts, and system integration.
- Home Manager owns user CLI tools and their configuration.
- Homebrew owns native macOS applications and Colima.
- Project-specific language toolchains belong in project dev shells.

Darwin activation installs missing Homebrew declarations and uninstalls
undeclared packages. It uses Homebrew's normal uninstall mode, not `zap`, so
application preferences and support data are preserved. Activation does not
update or upgrade installed packages; run `just brew-maintenance` explicitly
when you want to do that. Run `just brew-cleanup-preview` to see what activation
would remove before deploying.

Sikarugir is declared with per-cask trust because it comes from a third-party
tap. The rest of that tap is not trusted.

### System updates

**lambda:**

```bash
cd ~/git/nix-config && git pull
sudo darwin-rebuild switch --flake ~/git/nix-config#lambda --override-input secrets ~/git/nix-private
```

Or with `just`:

```bash
just preflight-lambda
just diff-lambda
just deploy-lambda
```

If the new generation causes a regression, `just rollback-lambda` activates the
previous generation. `just generations-lambda` shows the retained history.

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
