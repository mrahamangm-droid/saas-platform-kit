# saas-platform-kit

Reusable GitHub Actions workflows, repo templates and setup scripts for every SaaS app
on the standard stack:

**GitHub → Cloudflare → Vercel / Cloudflare Workers → Supabase Postgres → Cloudflare R2 → Stripe → Resend → Sentry / PostHog**

The aim is a secure, low-cost setup that any new or existing repo can adopt in minutes.

## What's inside

| Path | Purpose |
|---|---|
| `.github/workflows/reusable-ci-node.yml` | Install from the lockfile (npm/pnpm/yarn), then lint, typecheck, test, build |
| `.github/workflows/reusable-security.yml` | gitleaks secret scan, dependency review on PRs, CodeQL |
| `.github/workflows/reusable-supabase-migrations.yml` | Dry-run or apply Supabase migrations; blocks destructive SQL |
| `.github/workflows/reusable-deploy-cloudflare.yml` | Deploy Workers/Pages with wrangler through a GitHub Environment |
| `.github/workflows/reusable-db-backup-r2.yml` | Nightly encrypted `pg_dump` to Cloudflare R2 |
| `templates/` | Caller workflows, Dependabot, CODEOWNERS, PR/issue templates, `SECURITY.md`, `.env.example`, `.gitignore` |
| `scripts/bootstrap-repo.sh` | Copies the templates into an app repo (never overwrites) |
| `scripts/apply-repo-settings.sh` | Environments, security features and `main` branch protection via `gh` |
| `docs/` | [Setup guide](docs/setup.md) and [secrets reference](docs/secrets.md) |

## Quick start for an app repo

```bash
git clone https://github.com/mrahamangm-droid/saas-platform-kit.git
cd your-app && git checkout -b chore/platform-kit
bash ../saas-platform-kit/scripts/bootstrap-repo.sh .
# review, trim jobs you don't need, commit, open a PR
bash ../saas-platform-kit/scripts/apply-repo-settings.sh mrahamangm-droid/your-app --dry-run
```

Then add secrets per [docs/secrets.md](docs/secrets.md). Full walkthrough: [docs/setup.md](docs/setup.md).

## Using a reusable workflow

```yaml
jobs:
  ci:
    uses: mrahamangm-droid/saas-platform-kit/.github/workflows/reusable-ci-node.yml@v1
```

App repos pin to the `v1` tag. Changes land here through PRs, then `v1` is moved forward
once CI is green. Breaking changes get a new major tag (`v2`).

## Cost

Everything here runs on free tiers. CodeQL and secret scanning are free for public repos.
Private repos need GitHub Advanced Security for them, so set `run-codeql: false` there.
gitleaks and dependency review still run.
