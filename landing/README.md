# Mess Fellows — landing page

Static site, no build step. Files: `index.html`, `styles.css`, `script.js`, `favicon.svg`.

## Deploy to Cloudflare Pages

**Option A — drag and drop (fastest, gives you a free `*.pages.dev` URL):**

1. Go to the Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Upload assets**.
2. Give it a project name, then drag this `landing` folder's contents in (or a zip of them).
3. Deploy. You'll get `https://<project-name>.pages.dev` immediately.

**Option B — connect this git repo:**

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Pick this repository.
3. Build settings: leave **Build command** empty, set **Build output directory** to `landing`.
4. Deploy — Cloudflare rebuilds automatically on every push.

## Local preview

Any static file server works, e.g.:

```
npx serve landing
```

or just open `landing/index.html` directly in a browser (the theme toggle and scroll reveals both work from the local file).
