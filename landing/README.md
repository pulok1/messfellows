# Mess Fellows — landing page

Static site, no build step. Files: `index.html`, `styles.css`, `script.js`, `favicon.svg`.

## Web app at `/app/`

The "Open web app" buttons link to `app/`, which is the Flutter web build served from the same site. It is not committed (`landing/app/` is gitignored); build it from the repo root before previewing or deploying:

```
pwsh scripts/build_landing.ps1
```

(or `flutter build web --release --base-href /app/ --output landing/app`). Data stays in the visitor's browser (SQLite via drift/wasm), so it is per-browser and not synced.

## Deploy to Cloudflare Pages

**Option A — drag and drop (fastest, gives you a free `*.pages.dev` URL):**

1. Go to the Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Upload assets**.
2. Build the web app first (see above), then give it a project name and drag this `landing` folder's contents in (or a zip of them). The `app` folder must be included.
3. Deploy. You'll get `https://<project-name>.pages.dev` immediately.

**Option B — connect this git repo:**

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Pick this repository.
3. Build settings: leave **Build command** empty, set **Build output directory** to `landing`.
4. Deploy — Cloudflare rebuilds automatically on every push.

   Note: Cloudflare's build image has no Flutter and `landing/app/` isn't in git, so with Option B the `/app/` link will 404 unless you add a Flutter install + build step. Use Option A (or `wrangler pages deploy landing`) to ship the web app today.

## Local preview

Any static file server works, e.g.:

```
npx serve landing
```

or just open `landing/index.html` directly in a browser (the theme toggle and scroll reveals both work from the local file).
