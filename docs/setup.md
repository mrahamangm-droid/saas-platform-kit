# Setup guide

Follow these steps for each app repo. Steps 1–3 take about 15 minutes.

## 1. Add the templates

```bash
bash scripts/bootstrap-repo.sh /path/to/your-app
```

- **Vercel apps:** Vercel's Git integration handles preview and production deploys.
  In `deploy.yml`, keep the `migrate-*` jobs and delete the `cloudflare-*` jobs
  (change `migrate-production` to `needs: migrate-staging`).
- **Cloudflare Workers apps:** keep everything. Your `wrangler.toml` needs `[env.staging]`
  and `[env.production]` sections.
- **No database yet:** delete `migrations-check` from `ci.yml`, the `migrate-*` jobs
  and `backup.yml` until Supabase is connected.
- **pnpm:** set `"packageManager": "pnpm@<version>"` in `package.json`.

Commit on a branch and open a PR.

## 2. Repo settings

```bash
gh auth login
bash scripts/apply-repo-settings.sh owner/repo --dry-run   # preview
bash scripts/apply-repo-settings.sh owner/repo             # apply
```

This creates `staging` and `production` Environments, turns on Dependabot alerts and
security updates and secret scanning with push protection, and protects `main`. On
`main`, PRs and passing `ci` checks are required, history stays linear, and force-pushes
and deletion are blocked.

Run it **after** the first CI run on the PR so the required check names already exist.

Plan limits on private repos with a free plan:

- Environment required reviewers are not available. The script falls back to limiting
  production to protected branches.
- Branch protection on private repos needs GitHub Pro or above.

## 3. Secrets

Add them under **Settings → Secrets and variables → Actions**, or per Environment.
See [secrets.md](secrets.md) for each one and where it comes from.

```bash
gh secret set CLOUDFLARE_API_TOKEN --env production
```

## 4. Services checklist

| Service | One-time setup |
|---|---|
| Cloudflare | Add the domain, set DNS proxied, SSL "Full (strict)", turn on Bot Fight Mode. Create an API token from the "Edit Cloudflare Workers" template. |
| Vercel | Import the repo, add env vars for Preview and Production, then point the domain's CNAME at Vercel through Cloudflare (DNS only, grey cloud). |
| Supabase | One project each for staging and production. Turn on RLS for every table and keep migrations in `supabase/migrations`. |
| R2 | Create one bucket for app files and one for backups. Add a lifecycle rule that expires backups after 30 days, and create an API token per bucket. |
| Stripe | Use test keys in staging and live keys in production. Webhook endpoint: `/api/stripe/webhook`. |
| Resend | Verify the sending domain (SPF/DKIM records in Cloudflare). |
| Sentry / PostHog | One project per app, with DSN and keys in env vars. Upload source maps from CI with `SENTRY_AUTH_TOKEN`. |

## 5. Backups

`backup.yml` runs nightly at 02:17 Dubai time. To restore:

```bash
aws s3 cp s3://<bucket>/<key> backup.dump.gpg --endpoint-url https://<account>.r2.cloudflarestorage.com
gpg -d backup.dump.gpg > backup.dump
pg_restore --no-owner --clean --if-exists -d "$TARGET_DATABASE_URL" backup.dump
```

Test a restore into staging at least once a quarter.

## Rules

- Never commit `.env` files or secrets. gitleaks and push protection back this up.
- Migrations are forward-only. Destructive SQL needs a reviewed backup and a
  `-- allow-destructive` comment on that line.
- Every change to `main` goes through a PR with green CI.
