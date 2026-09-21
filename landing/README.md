# Mess Fellows — landing page

Static site, no build step. Files: `index.html`, `styles.css`, `script.js`, `favicon.svg`.

## Web app at `/app/`

The "Open web app" buttons link to `app/`, which is the Flutter web build served from the same site. It is not committed (`landing/app/` is gitignored); build it from the repo root before previewing:

```
powershell -ExecutionPolicy Bypass -File scriptsuild_landing.ps1
```

(or `flutter build web --release --base-href /app/ --output landing/app`). Data stays in the visitor's browser (SQLite via drift/wasm), so it is per-browser and not synced.

## Deploying

Done by GitHub Actions on every push to `main` (APK, web app and this page); see [docs/deployment.md](../docs/deployment.md).

## Local preview

Any static file server works, e.g.:

```
npx serve landing
```

or just open `landing/index.html` directly in a browser (the theme toggle and scroll reveals both work from the local file).
