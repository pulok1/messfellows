# Cloud sync (Supabase)

Optional. Without the config below the app builds and runs exactly as before — offline-only, with the cloud
section hidden. With it, a manager can sign in (email + password) to back up their mess and use it on several
phones. Everything is still read from and written to the phone's SQLite database first; sync runs in the
background.

## One-time setup

### 1. Create the table

Supabase dashboard → your project → **SQL Editor** → *New query* → paste
[`migrations/20261012000000_sync_records.sql`](migrations/20261012000000_sync_records.sql) → **Run**.

It creates `public.sync_records` with row-level security (each account sees only its own rows) and adds it to
realtime. Safe to run again.

### 2. Auth settings

**Authentication → Sign In / Providers → Email**: keep it enabled.

> **Emails on the free plan.** Supabase's built-in mailer only delivers to the email addresses of your
> project's team members, and only a few per hour. For other people to receive confirmation and
> password-reset emails, set up custom SMTP (**Authentication → Emails → SMTP Settings**; Resend, Brevo, etc.
> have free tiers). Until then, either turn **Confirm email** off (so sign-up works without an email), or test
> with your own address only.

**Authentication → URL Configuration → Site URL**: set it to the landing site
(`https://messfellows.pulok.workers.dev/`). The "confirm your email" link sends people there after
confirming. They then go back to the app and sign in.

**Authentication → Emails → Reset Password**: the app resets passwords with a 6-digit code rather than a link,
so no deep-link setup is needed. Templates can only be edited once custom SMTP is set up (see above), and
until then "Forgot password?" can't work. Sign-in and sync are unaffected. Make the template include the
code, e.g.:

```html
<h2>Reset your Mess Fellows password</h2>
<p>Enter this code in the app:</p>
<p style="font-size:24px;font-weight:bold;letter-spacing:4px">{{ .Token }}</p>
```

### 3. Point the app at the project

**Project Settings → API Keys**: copy the **publishable** key (`sb_publishable_…`; the legacy `anon` key also
works). The project URL is `https://<project-ref>.supabase.co` (shown under **Data API**).

These are not secret: the key ships inside the app, and access is controlled by row-level security.

- **Local runs:** copy `supabase.example.json` (in the repo root) to `supabase.json` (git-ignored), fill both
  values in, then `flutter run --dart-define-from-file=supabase.json`. `scripts/build_landing.ps1` picks the
  file up automatically.
- **CI releases:** GitHub repo → Settings → Secrets and variables → Actions → **Variables** → add
  `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. `.github/workflows/deploy.yml` passes them to the APK and web
  builds.

## How it works

- **Capture:** SQLite triggers on every synced table record changed row ids in `sync_outbox`
  (`lib/sync/sync_triggers.dart`). Every write path is covered without the repositories knowing about sync.
- **Push:** queued rows are upserted into `sync_records` as JSON (raw SQLite values), deletes as tombstones.
- **Pull:** rows whose server-stamped `updated_at` is newer than the device's cursor are applied locally, without
  being queued again. Local rows with unpushed edits are left alone.
- **When:** at sign-in and app start, a couple of seconds after local edits, immediately on realtime events from
  other devices, when the app returns to the foreground, and every 5 minutes. Failures retry with backoff.
- **Conflicts:** last device to sync wins, per row. If two phones each create a meal entry for the same member and
  day while offline, the entry with the smaller id is kept on every device.
- **First sign-in on a device:** an empty phone just downloads the account's data. A fresh account takes the
  phone's data. If both have a mess, the app asks which to keep.
- **Sign out:** local data stays. Changes made while signed out upload the next time the same account signs in.

## Changing the local schema later

The server stores rows as JSON, so local migrations need no server migration. Two rules:

- A new **column** must be nullable or have a default, because rows from older app versions won't include it.
  Columns the app doesn't know about are ignored.
- A new **table** syncs only once it's added to `syncedTables` in `lib/sync/sync_triggers.dart` (parents
  before children).

## Free plan notes

Free projects pause after about a week without activity. The app keeps working offline and sync shows
"Offline" until the project is resumed from the dashboard. The data is tiny (a few hundred KB per mess per
year), well inside the 500 MB database limit.
