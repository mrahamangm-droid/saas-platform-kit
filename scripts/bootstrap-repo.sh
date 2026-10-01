#!/usr/bin/env bash
# Copy the kit's templates into an app repo. Never overwrites existing files.
# Usage: bash scripts/bootstrap-repo.sh /path/to/your-app
set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:?usage: bootstrap-repo.sh /path/to/your-app}"
[ -d "$TARGET/.git" ] || { echo "error: $TARGET is not a git repo" >&2; exit 1; }

copy() {
  local src="$1" dst="$2"
  if [ -e "$TARGET/$dst" ]; then
    echo "skip   $dst (already exists)"
  else
    mkdir -p "$(dirname "$TARGET/$dst")"
    cp "$KIT_DIR/templates/$src" "$TARGET/$dst"
    echo "added  $dst"
  fi
}

copy github/workflows/ci.yml                  .github/workflows/ci.yml
copy github/workflows/deploy.yml              .github/workflows/deploy.yml
copy github/workflows/backup.yml              .github/workflows/backup.yml
copy github/dependabot.yml                    .github/dependabot.yml
copy github/CODEOWNERS                        .github/CODEOWNERS
copy github/PULL_REQUEST_TEMPLATE.md          .github/PULL_REQUEST_TEMPLATE.md
copy github/ISSUE_TEMPLATE/bug_report.yml     .github/ISSUE_TEMPLATE/bug_report.yml
copy github/ISSUE_TEMPLATE/feature_request.yml .github/ISSUE_TEMPLATE/feature_request.yml
copy github/ISSUE_TEMPLATE/config.yml         .github/ISSUE_TEMPLATE/config.yml
copy SECURITY.md                              SECURITY.md
copy env.example                              .env.example
copy gitignore                                .gitignore

echo
echo "Done. Review the diff, delete jobs you don't need (e.g. cloudflare-* on Vercel apps),"
echo "then commit on a branch and open a PR."
