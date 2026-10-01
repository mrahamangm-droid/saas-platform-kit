# CLAUDE.md: saas-platform-kit

Shared, public kit of reusable GitHub Actions workflows and templates for all SaaS repos
owned by mrahamangm-droid. See README.md for layout.

## Conventions
- App repos consume workflows via `@v1`. Never break inputs/secrets of a `v1` workflow;
  add optional inputs with defaults instead. Breaking change means a new `v2` tag.
- Actions are pinned to major tags. Dependabot updates them weekly.
- Nothing here may contain secrets, real account IDs or project refs. The repo is public.
- Shell scripts must pass `shellcheck`. Workflows must pass `actionlint` (kit-ci runs both).
- Scripts must be non-destructive: never overwrite files, never delete.

## Local checks
```bash
bash <(curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)
./actionlint .github/workflows/*.yml templates/github/workflows/*.yml
shellcheck scripts/*.sh
```

## Status
- v0 (initial kit): CI, security, Supabase migrations, Cloudflare deploy, R2 backup,
  templates, bootstrap and settings scripts, docs.

## Next steps
1. Merge the initial PR, then tag `v1` on main.
2. Apply `scripts/apply-repo-settings.sh` to this repo.
3. Roll out to app repos one at a time via PRs (finloraq.com first).
4. Possible additions: Vercel preview-URL smoke test, Lighthouse/a11y check, Stripe
   webhook replay test, Sentry release + source-map upload workflow.
