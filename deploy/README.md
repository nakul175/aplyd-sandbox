# Deploying the Aplyd Sandbox to the saha-apps droplet

Droplet: `saha-apps` (DigitalOcean, blr1, 64.227.190.72), shared with the Saha apps and Aplyd Academy.

## What runs
- Caddy serves `https://aplyd.org` from `/var/www/aplyd-sandbox` with `file_server`, no basic auth.
  `https://www.aplyd.org` answers with a permanent redirect (301) to `https://aplyd.org`.
- The other hosts (`health|agriculture|academy|education.aplyd.org`) have their own files in `/etc/caddy/conf.d/` and are untouched.
- `aplyd-sandbox-update.timer` runs `/usr/local/bin/aplyd-sandbox-update` every 3 minutes. When `main` has a new commit it copies `site/` to the web root (`rsync --delete`). Only `site/` is published, never `.git` or `deploy/`.
- Status: `/var/lib/aplyd-sandbox/deploy-status.json`.

## DNS (set at the registrar)
`A aplyd.org -> 64.227.190.72` and `A www.aplyd.org -> 64.227.190.72` (or `CNAME www -> aplyd.org`).
Remove any `AAAA` record for either name that does not point at this droplet: Let's Encrypt validates over IPv6 when one exists.
Caddy requests the certificates by itself once both names resolve.

## Install / repair
`bash deploy/provision.sh` as root. It is idempotent. If the repository is private it first generates `/etc/saha/aplyd-sandbox.deploy-key` and prints the public half; add it as a read-only deploy key and run it again.

## Roll back
`git revert` on `main` publishes the previous site within 3 minutes. The previous Caddy file, if replaced, is kept as `/root/aplyd-sandbox.caddy.bak`.

## aplyd.si

`aplyd.si` and `www.aplyd.si` redirect permanently to the same path on `https://aplyd.org` (`deploy/aplyd-si-redirect.caddy`, installed as `/etc/caddy/conf.d/aplyd-si-redirect.caddy`). DNS for aplyd.si is at Namecheap (BasicDNS): A `@` and A `www` to 64.227.190.72, TTL 5 minutes. The file is a record of what is on the droplet; the update timer does not install it.
