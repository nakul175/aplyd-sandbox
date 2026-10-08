#!/usr/bin/env bash
# Pull `main`; when it has moved, copy site/ into the web root. Installed as /usr/local/bin/aplyd-sandbox-update
# and run by aplyd-sandbox-update.timer (every 3 minutes).
set -euo pipefail

APP="aplyd-sandbox"
BRANCH="main"
SRC="/opt/${APP}/src"
WEB="/var/www/${APP}"
STATE="/var/lib/${APP}"
STATUS="${STATE}/deploy-status.json"

DEPLOY_KEY="/etc/saha/${APP}.deploy-key"
if [ -f "$DEPLOY_KEY" ]; then
  export GIT_SSH_COMMAND="ssh -i ${DEPLOY_KEY} -o IdentitiesOnly=yes -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts -o StrictHostKeyChecking=accept-new"
fi

install -d "$STATE"
exec 9>"${STATE}/update.lock"; flock -n 9 || { echo "another update is running"; exit 0; }

record() { printf '{"commit":"%s","state":"%s","at":"%s"}\n' "${1:-unknown}" "$2" "$(date -u +%FT%TZ)" > "$STATUS"; }

git -C "$SRC" fetch --depth 1 origin "$BRANCH"
NEW="$(git -C "$SRC" rev-parse FETCH_HEAD)"
CUR="$(git -C "$SRC" rev-parse HEAD)"
if [ "$NEW" = "$CUR" ] && [ -f "${WEB}/index.html" ]; then exit 0; fi

trap 'record "$NEW" failed' ERR
git -C "$SRC" reset --hard "$NEW"
[ -f "${SRC}/site/index.html" ] || { echo "site/index.html missing in ${NEW}; not publishing" >&2; exit 1; }
install -d -m 0755 "$WEB"
rsync -a --delete --chmod=D755,F644 "${SRC}/site/" "${WEB}/"
grep -q '<title>' "${WEB}/index.html"
record "$NEW" ok
