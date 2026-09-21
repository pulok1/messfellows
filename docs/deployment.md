# Deployment

Every push to `main` runs `.github/workflows/deploy.yml`, which:

1. builds and signs the Android APK and publishes it as the newest GitHub release (`messfellows.apk`),
2. builds the Flutter web app into `landing/app/`,
3. deploys `landing/` (landing page + web app at `/app/`) to Cloudflare Workers as `messfellows`.

The landing page's download button points at
`https://github.com/pulok1/messfellows/releases/latest/download/messfellows.apk`, so it always serves the newest build.

## Updating in place

Android installs a new APK over the old one (keeping data) when the package name and signing key match and the
`versionCode` is higher. CI signs with one fixed key and uses the commit count as `versionCode`, so both hold.
Never change the key or the application id (`com.pulok.messfellows`) after users have installed the app.

## One-time setup

Nothing secret is stored in the repo or on a work machine; the secrets live in GitHub.

1. **Signing key:** run `pwsh scripts/create_keystore.ps1`, add the two values as GitHub secrets
   `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEYSTORE_PASSWORD`, back up `messfellows.jks`, delete the temp folder.
2. **Cloudflare token:** dash.cloudflare.com → My Profile → API Tokens → Create Token → template
   *Edit Cloudflare Workers* → account resources: your account → create. Add it as secret `CLOUDFLARE_API_TOKEN`.
3. **Cloudflare account id:** the long hex id in the dashboard URL. Add it as secret `CLOUDFLARE_ACCOUNT_ID`.
4. Repo Settings → Actions → General → Workflow permissions → *Read and write permissions*.
5. Push to `main` (or Actions → *Release & deploy* → Run workflow).

The site is then live at `https://messfellows.<your-subdomain>.workers.dev`.

## Local preview

`pwsh scripts/build_landing.ps1`, then `npx serve landing`.
