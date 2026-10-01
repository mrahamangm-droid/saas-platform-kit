# Secrets reference

Store secrets per **Environment** (`staging`, `production`) unless marked *repo*.
Never paste real values into issues, PRs or code.

| Secret | Used by | Where to get it |
|---|---|---|
| `CI_BUILD_ENV` *(repo, optional)* | ci | Multiline `KEY=value` of **public/build-time** vars needed by `next build` |
| `CLOUDFLARE_API_TOKEN` | deploy | Cloudflare → My Profile → API Tokens → "Edit Cloudflare Workers" |
| `CLOUDFLARE_ACCOUNT_ID` | deploy | Cloudflare dashboard → Workers & Pages → right sidebar |
| `SUPABASE_ACCESS_TOKEN` | migrations | Supabase → Account → Access Tokens |
| `SUPABASE_PROJECT_REF` | migrations | Project URL `https://<ref>.supabase.co` |
| `SUPABASE_DB_PASSWORD` | migrations | Set when the project was created (reset under Database settings) |
| `DATABASE_URL` | backup | Supabase → Connect → **Direct connection** string |
| `BACKUP_PASSPHRASE` | backup | Generate a long random value and also keep it in your password manager. Without it, backups can't be restored. |
| `R2_ACCOUNT_ID` | backup | Cloudflare account ID |
| `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` | backup | R2 → Manage API tokens → Object Read & Write, scoped to the backup bucket |
| `R2_BUCKET` | backup | Backup bucket name |

Runtime app secrets (Stripe, Resend, Sentry, PostHog, Supabase service role) belong in
Vercel or Cloudflare env settings, not GitHub, unless a workflow needs them.
`templates/env.example` lists them all.

## Rotation

Rotate a secret right away if it ever appears in a log, a commit or a chat. Otherwise
rotate yearly. Update it in the provider first, then in GitHub, then redeploy.
