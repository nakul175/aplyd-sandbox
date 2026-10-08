# Aplyd Sandbox (aplyd.org)

Static landing page for APLYD prototypes, served at the root of https://aplyd.org from the shared `saha-apps` DigitalOcean droplet. No build step.

## Layout
- `site/` is the web root. Only this folder is published.
- `deploy/` is the droplet kit (Caddy site, installer, updater). It is never served.

## Add an app
1. Edit `site/assets/js/apps.js`: copy one object in the `APPS` array (name, category, description, url, icon, loginRequired).
2. Add a matching `<li>` link to the `<noscript>` list in `site/index.html`.
Icons available: `health`, `agriculture`, `education`, `academy`, `spark`.

## Files in `site/`
- `index.html`: markup, meta and Open Graph tags
- `assets/css/styles.css`: styles (APLYD brand tokens at the top)
- `assets/js/apps.js`: app list and card rendering
- `assets/img/`: APLYD wordmark (navy/white), logomark, Open Graph image
- `favicon.svg`, `favicon.ico`, `apple-touch-icon.png`

Brand: Lato (Google Fonts), navy #232B65, gold #D19C33, sourced from aplyd.com.

## Deploy
Merging to `main` publishes the site: the droplet checks `main` every 3 minutes and copies `site/` into `/var/www/aplyd-sandbox`. See `deploy/README.md`.
