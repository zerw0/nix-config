# Calibre and Kindle

Calibre is declared as a Homebrew cask in `calibre.nix`. Its Home Manager
activation installs pinned KOReader Sync 0.8.2 and configures the library,
custom reading columns, and password-protected wireless connections on 9090.
The user LaunchAgent opens Calibre in the tray at login.

Library: `~/Books/Calibre Library`.
Original Kindle backup: `~/Books/Kindle Backup/2026-10-22/books.tar.gz`.
Fourteen books were imported with corrected titles, authors, languages and tags.
Book bytes were checked against the original SHA-256 values. Existing progress,
notes/highlights and reading sidecars were imported into custom columns.

## Everyday use

Keep Calibre open on the Mac and KOReader awake on the same LAN with Wi-Fi on.
Select books in Calibre and use **Send to device**. Use the device view and
**Add books to library** to import new books acquired on the Kindle.
The native device catalog maps all fourteen existing filenames to this library.

`calibre-kindle-autoconnect.lua` is installed on the Kindle as
`/mnt/us/koreader/patches/2-calibre-autoconnect.lua`. It discovers Calibre on the
LAN and uses KOReader's native connection. It retries after startup, wake-up,
Wi-Fi connection, and every three minutes while running; it never turns Wi-Fi on.
To disable automatic connection, remove/rename that patch; the normal Calibre
shortcut remains available. There is no Syncthing service or folder mirroring.

KOReader Sync automatically imports reading progress, status, location,
highlights/notes and a sidecar backup when a device connection is established.
Books transfer in either direction through Calibre's device actions. This does
not merge simultaneous edits, mirror file deletions, or translate positions to
Calibre's separate ebook reader. Pushing sidecar backups back through the plugin
only restores missing sidecars; it is not automatic two-way annotation merging.
Never delete a Kindle reading sidecar just to force a sync.

The wireless password is generated in private Calibre preferences and copied
privately into the Kindle settings during pairing. It is not stored in Nix or
this repository. Re-pair through Calibre's Wireless device connection settings
and KOReader's Calibre wireless settings if the password is rotated.

## Validation and activation

Run `just preflight-lambda` before full activation. Initial setup applied only
this cask, the setup script, and the evaluated user LaunchAgent, preserving
unrelated dirty configuration. A full `just deploy-lambda` would also activate
other pending changes; review those separately.
