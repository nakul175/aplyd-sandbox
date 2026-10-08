#!/usr/bin/env bash
# One-time (idempotent) setup on the shared saha-apps droplet (Ubuntu 24.04, Caddy already installed by the other apps).
# Run as root:   bash provision.sh
# Git access: anonymous HTTPS when the repository is public; otherwise a read-only SSH deploy key at
# /etc/saha/aplyd-sandbox.deploy-key (the first run only generates it and prints the public half: add it under
# Settings > Deploy keys, read-only, then run this again). SAHA_GIT_TOKEN is also accepted.
set -euo pipefail

APP="aplyd-sandbox"
SLUG="nakul175/${APP}"
REPO="https://github.com/${SLUG}.git"
DEPLOY_KEY="/etc/saha/${APP}.deploy-key"
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y git rsync curl openssh-client
command -v caddy >/dev/null || { echo "Caddy is not installed; run another app's provision.sh first" >&2; exit 1; }

if [ -n "${SAHA_GIT_TOKEN:-}" ]; then
  REPO="https://x-access-token:${SAHA_GIT_TOKEN}@github.com/${SLUG}.git"
elif ! git ls-remote "$REPO" HEAD >/dev/null 2>&1; then
  install -d -m 0755 /etc/saha
  if [ ! -f "$DEPLOY_KEY" ]; then
    ssh-keygen -q -t ed25519 -N '' -C "${APP}@$(hostname)" -f "$DEPLOY_KEY"
    echo "Repository is private and no key exists: generated ${DEPLOY_KEY}. Add this read-only deploy key to ${REPO}, then run provision.sh again:"
    cat "${DEPLOY_KEY}.pub"
    exit 0
  fi
  grep -qs '^github.com ' /etc/ssh/ssh_known_hosts || python3 -c 'import json,urllib.request; r=urllib.request.Request("https://api.github.com/meta",headers={"User-Agent":"saha-provision"}); m=json.load(urllib.request.urlopen(r,timeout=20)); print("\n".join("github.com "+k for k in m["ssh_keys"]))' >> /etc/ssh/ssh_known_hosts || true
  POLICY=yes; grep -qs '^github.com ' /etc/ssh/ssh_known_hosts || POLICY=accept-new
  REPO="git@github.com:${SLUG}.git"
  export GIT_SSH_COMMAND="ssh -i ${DEPLOY_KEY} -o IdentitiesOnly=yes -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts -o StrictHostKeyChecking=${POLICY}"
fi

install -d -m 0755 "/opt/${APP}" /var/www/${APP} /var/lib/${APP}
if [ ! -d "/opt/${APP}/src/.git" ]; then
  git clone --depth 1 --branch main "$REPO" "/opt/${APP}/src"
fi
D="/opt/${APP}/src/deploy"
install -m 0755 "$D/update.sh" /usr/local/bin/aplyd-sandbox-update
install -m 0644 "$D/aplyd-sandbox-update.service" "$D/aplyd-sandbox-update.timer" /etc/systemd/system/

# First publish.
/usr/local/bin/aplyd-sandbox-update

# Caddy site (a separate file in conf.d; the other apps' files are not touched).
CONF="/etc/caddy/conf.d/${APP}.caddy"
[ -f "$CONF" ] && cp -p "$CONF" "/root/${APP}.caddy.bak"
install -m 0644 "$D/Caddyfile" "$CONF"
if caddy validate --config /etc/caddy/Caddyfile >/dev/null 2>&1; then
  systemctl reload caddy
else
  echo "Caddy config invalid; restoring previous file" >&2
  if [ -f "/root/${APP}.caddy.bak" ]; then cp -p "/root/${APP}.caddy.bak" "$CONF"; else rm -f "$CONF"; fi
  exit 1
fi

systemctl daemon-reload
systemctl enable --now aplyd-sandbox-update.timer
echo "provision done: https://aplyd.org/ (needs A records for aplyd.org and www.aplyd.org -> this droplet)"
