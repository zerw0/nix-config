#!/usr/bin/env bash
set -euo pipefail
umask 077

state_dir=/var/lib/headplane/state
if test -s "$state_dir/hp_persist.db"; then
  echo "Headplane state already exists; leaving it unchanged."
  exit 0
fi

# Check the live database without printing sessions, tokens, or API keys.
podman exec headplane /nodejs/bin/node -e '
  const {DatabaseSync} = require("node:sqlite");
  const db = new DatabaseSync("/var/lib/headplane/hp_persist.db", {readOnly: true});
  const result = db.prepare("PRAGMA integrity_check").get();
  if (result.integrity_check !== "ok") throw new Error("Headplane database is corrupt");
  if (!db.prepare("SELECT 1 FROM users WHERE role = ?").get("owner")) {
    throw new Error("Headplane Owner account is missing");
  }
'

staging_dir=$(mktemp -d /var/lib/headplane/state-migration.XXXXXX)
paused=false
cleanup() {
  if "$paused"; then
    podman unpause headplane
  fi
  rm -rf "$staging_dir"
}
trap cleanup EXIT

# Copy SQLite and any WAL/journal together while all container writes are paused.
podman pause headplane
paused=true
podman cp headplane:/var/lib/headplane/. "$staging_dir/"
podman unpause headplane
paused=false
test -s "$staging_dir/hp_persist.db"
chmod 0700 "$staging_dir"
if test -d "$state_dir"; then
  rmdir "$state_dir"
fi
mv "$staging_dir" "$state_dir"
echo "Headplane state preserved. Deploy now to mount it into the new container."
