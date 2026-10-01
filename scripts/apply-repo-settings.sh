#!/usr/bin/env bash
# Apply the standard GitHub settings to an app repo using the GitHub CLI.
# Requires: gh auth login (as a repo admin).
# Usage: bash scripts/apply-repo-settings.sh owner/repo [--dry-run]
#
# What it does:
#   - creates "staging" and "production" Environments (production limited to main,
#     with you as required reviewer)
#   - enables Dependabot alerts + security updates, secret scanning + push protection
#   - protects main: PRs required, the "ci" checks must pass, no force-push/deletion
set -euo pipefail

REPO="${1:?usage: apply-repo-settings.sh owner/repo [--dry-run]}"
DRY="${2:-}"
OWNER="${REPO%%/*}"

run() { if [ "$DRY" = "--dry-run" ]; then echo "[dry-run] gh $*"; else gh "$@"; fi; }

echo "== Environments"
run api -X PUT "repos/$REPO/environments/staging" --silent
USER_ID=$(gh api "users/$OWNER" --jq .id)
# Required reviewers on private repos need a paid plan; fall back to branch-only protection.
PROD_WITH_REVIEWERS=$(printf '{"wait_timer":0,"reviewers":[{"type":"User","id":%s}],"deployment_branch_policy":{"protected_branches":true,"custom_branch_policies":false}}' "$USER_ID")
PROD_BRANCH_ONLY='{"deployment_branch_policy":{"protected_branches":true,"custom_branch_policies":false}}'
if ! echo "$PROD_WITH_REVIEWERS" | run api -X PUT "repos/$REPO/environments/production" --silent --input -; then
  echo "warn: reviewers not available on this plan; production limited to protected branches only"
  echo "$PROD_BRANCH_ONLY" | run api -X PUT "repos/$REPO/environments/production" --silent --input -
fi

echo "== Security features"
run api -X PUT "repos/$REPO/vulnerability-alerts" --silent
run api -X PUT "repos/$REPO/automated-security-fixes" --silent
# Secret scanning is free on public repos; on private repos it needs Advanced Security,
# so a failure here is reported but does not stop the script.
run api -X PATCH "repos/$REPO" --silent --input - <<'JSON' || echo "warn: could not enable secret scanning (private repo without Advanced Security?)"
{
  "security_and_analysis": {
    "secret_scanning": { "status": "enabled" },
    "secret_scanning_push_protection": { "status": "enabled" }
  }
}
JSON

echo "== Merge settings"
run api -X PATCH "repos/$REPO" --silent -F delete_branch_on_merge=true -F allow_auto_merge=true

echo "== Branch protection on main"
run api -X PUT "repos/$REPO/branches/main/protection" --silent --input - <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["ci / ci", "security / Secret scan (gitleaks)"] },
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0, "dismiss_stale_reviews": true },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON

echo "Done for $REPO."
