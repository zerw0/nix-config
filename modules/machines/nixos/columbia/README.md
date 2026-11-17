# Columbia

HP EliteBook 8560p, Core i5-2520M, AMD Radeon HD 6470M graphics.
NixOS 26.05, Linux 6.18 LTS, Plasma 6 Wayland with SDDM. Intel CPU microcode,
Radeon/Mesa drivers, TLP, thermald, TRIM, and zstd
RAM swap are enabled. Kernel security mitigations stay enabled; the stock
binary-cached LTS kernel avoids expensive custom kernel rebuilds. Builds are
limited to one job with two cores to keep this laptop responsive.

Plasma keeps Dolphin, Ark, Okular, Gwenview, Spectacle and System Settings.
KDE PIM, Elisa, Kate, Konsole, remote desktop and the extra wallpaper package
are excluded. File content indexing is disabled.

Columbia uses the same Ghostty, VSCodium, Gruvbox, developer/cloud CLI
modules and utility packages as Lambda. Linux apps include Bitwarden,
RustDesk, Element, LibreOffice, Telegram, Vesktop, Blender, OrcaSlicer,
Calibre, Steam and the Codex CLI. Chromium replaces Helium, mpv replaces IINA,
Ark replaces Keka, Docker replaces Colima, and virt-manager/KVM replaces UTM.
macOS-only tools (Karabiner, RemoveMacAI, Sikarugir, Vorssaint and the Codex
desktop app) are not installed. Tailscale is available for manual enrollment:

```sh
sudo tailscale up --login-server=https://hs.zerw.xyz
```

## Install

Boot an x86_64 NixOS installer **in UEFI mode**, disable Secure Boot, connect
to the network, and obtain this checkout including its private flake inputs.
The installer needs an SSH identity authorized for `nix-private`; do not copy
private keys into this repository. Run the following from the checkout.

1. Identify the target disk with `lsblk -o NAME,SIZE,MODEL,SERIAL,MOUNTPOINTS`
   and `ls -l /dev/disk/by-id/`. The layout targets Columbia's 240 GB TEAM SSD
   by its stable disk ID in `disk-config.nix`. Verify that it matches the
   intended disk before continuing.
2. Inspect the evaluated disk selection:

   ```sh
   nix eval --raw path:.#nixosConfigurations.columbia.config.disko.devices.disk.main.device
   ```

3. **This erases the selected disk.** Run the pinned Disko script:

   ```sh
   nix build --no-link --print-out-paths path:.#nixosConfigurations.columbia.config.system.build.diskoScript
   sudo "$(nix build --no-link --print-out-paths path:.#nixosConfigurations.columbia.config.system.build.diskoScript)"
   ```

4. Install and set a login password before rebooting:

   ```sh
   sudo nixos-install --flake path:.#columbia --no-root-passwd
   sudo nixos-enter --root /mnt -c 'passwd hdjenkov'
   ```

   If private inputs are not cached for root, preserve the installer's SSH
   agent with `sudo --preserve-env=SSH_AUTH_SOCK` for `nixos-install`.
   The user's existing authorized SSH keys are included; no initial password
   is embedded in the configuration. Keep the checkout on the installed system
   for subsequent `sudo nixos-rebuild switch --flake path:.#columbia` rebuilds.

There is no encryption or disk swap in this layout. Hibernation is not
configured. Firmware and physical graphics/suspend behavior must be checked
on the laptop; this configuration does not include a hardware scan from it.

## Storage and snapshots

The disk has a 1 GiB FAT EFI partition and a Btrfs partition using
`compress=zstd:1,noatime`. Subvolumes:

| Subvolume | Mount |
| --- | --- |
| `@root` | `/` |
| `@home` | `/home` |
| `@nix` | `/nix` |
| `@log` | `/var/log` |
| `@cache` | `/var/cache` |
| `@containers` | `/var/lib/docker` |
| `@vms` | `/var/lib/libvirt/images` |
| `@snapshots` | `/.snapshots` |
| `@home-snapshots` | `/home/.snapshots` |

Snapper takes root and home snapshots hourly, retaining 6 hourly, 7 daily,
4 weekly and 3 monthly snapshots. Root also gets a boot snapshot, with up to
10 numbered snapshots retained after cleanup. Missed timeline snapshots run
after power-on; cleanup runs daily. Btrfs scrub runs monthly.

Nested subvolumes are excluded from parent snapshots: root snapshots include
`/var/lib` state, but exclude home, Nix store, logs, cache, containers, VM images
and snapshot storage. Home snapshots include user files and development
checkouts. Monitor free space with `sudo btrfs filesystem usage /`; retention
is count-based, not a disk-space guarantee. Snapshots share the same disk and
do not replace external backups.

```sh
sudo snapper -c root list
sudo snapper -c home list
sudo snapper -c home create --description 'before changes' --cleanup-algorithm number
sudo systemctl status snapper-timeline.timer snapper-cleanup.timer
```

Recover individual files from `/.snapshots/<number>/snapshot` or
`/home/.snapshots/<number>/snapshot`. For system configuration rollback, use
a previous NixOS generation in systemd-boot (10 retained boot entries) or
`sudo nixos-rebuild switch --rollback`. Btrfs snapshots are for file recovery;
automatic boot-menu snapshot rollback is not configured. A root snapshot alone
does not restore matching Nix store paths or the EFI partition.
