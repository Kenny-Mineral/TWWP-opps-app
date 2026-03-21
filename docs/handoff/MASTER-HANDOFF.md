# TWWP Ops Platform — Master Handoff Document
## Last updated: 2026-03-21 (reconciled from two chat sessions)
## For use when starting a new Claude chat or handing to a developer

---

## What is this project?

Kenny Samkin runs **The Wholey Water Project (TWWP)** — a community reverse
osmosis water filtration network in New Zealand with neighbourhood tap
installations called "waterhouses".

The **TWWP Ops App** is a single-file HTML/CSS/JS browser app that replaces
manual Word document workflows for operational reporting, reimbursements,
maintenance tracking, member management, financial ledger, document library,
inventory, and procurement.

---

## Live URLs

| Resource | URL |
|----------|-----|
| Ops App | https://kenny-mineral.github.io/TWWP-opps-app/ |
| GitHub Repo | github.com/Kenny-Mineral/TWWP-opps-app |
| Rails API | https://twwp-ops-api.fly.dev |
| Cloudflare Worker | https://twwp-proxy.thewholeywaterproject.workers.dev |
| Tap-Map App (separate) | https://app.thewholeywaterproject.com |
| TWWP Website (separate) | https://thewholeywaterproject.com |

---

## Development environment (Kenny's Toshiba)

| Item | Value |
|------|-------|
| OS | Ubuntu 24 |
| Editor | VS Code |
| Node | v22.22.1 |
| npm | v10.9.4 |
| Ruby | 3.3.0 (rbenv) |
| Rails | 8.0.1 |
| flyctl | v0.4.26 |
| Claude Code | v2.1.80 (sudo npm install -g @anthropic-ai/claude-code) |
| Rails app path | ~/twwp-ops-api/ |
| Frontend app path | ~/Desktop/Opps App dev folder laptop/new2/index.html |

To start Claude Code on the Rails API:
```bash
cd ~/twwp-ops-api && claude
```

---

## Current state

### Ops App (index.html)
- ~9,300 lines, syntax clean, deployed on GitHub Pages
- Login: admin / twwp2024 (leave blank for dev mode)
- 26 pages fully built and working
- AI integrations working (Gemini, Claude, OpenAI, OpenRouter)
- Google Drive Phase 1 working (read-only, API key)
- Connection status dot + panel working (top right of header)
- "Connect via Rails API" button in AI & Integrations

### Rails API (twwp-ops-api.fly.dev)
- Deployed and running — health check returns 200 OK
- oauth_states table exists (PKCE stored in DB, not session)
- Email-only OAuth confirmed working
- Drive scope OAuth failing — see current bug below

---

## Current critical bug — Google OAuth drive.file scope

### Symptom
After clicking "Connect via Rails API" → account chooser → "Google hasn't
verified this app" warning → clicking Continue → Google shows:
> "Something went wrong — accounts.google.com/info/unknownerror"

### What works
- ✅ Health check: https://twwp-ops-api.fly.dev/health
- ✅ Rails builds correct OAuth URL
- ✅ oauth_states DB table exists (PKCE fix applied)
- ✅ OAuth works with userinfo.email scope only (confirmed)
- ✅ drive.file added to consent screen Data Access
- ✅ Test user thewholeywaterproject@gmail.com added

### What fails
- ❌ drive.file scope causes "Something went wrong" at Google's side
- ❌ Zero OAuth traffic in Google Cloud Console metrics
- ❌ Google rejecting before issuing any tokens

### Theories to investigate (in order)
1. **Wait 30 minutes** — Google consent screen changes can take time to propagate.
   Try in incognito after waiting without touching anything.
2. **Confirm Google Drive API v3 is enabled** — Cloud Console → APIs & Services →
   Enabled APIs → confirm "Google Drive API" is listed (not just Drive Data API)
3. **Try drive.readonly scope instead** — narrower permission, rules out drive.file specific issue:
   ```ruby
   SCOPES = 'https://www.googleapis.com/auth/drive.readonly https://www.googleapis.com/auth/userinfo.email'
   ```
4. **Enable People API** — some flows require it alongside Drive
5. **Test with fresh Google account** — create new Gmail, add as test user, try connecting
6. **Check Google Workspace admin settings** — if thewholeywaterproject@gmail.com is
   Workspace (not standard Gmail), admin may have restricted third-party OAuth

### Current Rails code (deployed state)
```ruby
SCOPES = 'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/userinfo.email'
```

### To change scope and redeploy
```bash
cd ~/twwp-ops-api
nano app/controllers/auth_controller.rb
# change SCOPES line
fly deploy
```

---

## Credentials

| Item | Value |
|------|-------|
| Google OAuth Client ID | 1096306613884-39mavd5fmtl0s688dcfa26gdq64sjvkd.apps.googleusercontent.com |
| Google Client Secret | Kenny's phone notes (starts GOCSPX-) |
| Rails production key | ~/twwp-ops-api/config/credentials/production.key = 3c1cda80ab038529d03d3fceb4075dca |
| App login | admin / twwp2024 |
| TWWP email | admin@thewholeywaterproject.com |
| TWWP phone | 02041333855 |

⚠️ Note: There are TWO Google OAuth Client IDs in Cloud Console.
The correct/active one ends in `...39mavd5fmtl0s688dcfa26gdq64sjvkd`
The old broken one ends in `...nljl` — do not use.

---

## Google Cloud Console setup

| Setting | Value |
|---------|-------|
| Project | Opps App TWWP - Kenny |
| Owner | thewholeywaterproject@gmail.com |
| Active Client ID | 1096306613884-39mavd5fmtl0s688dcfa26gdq64sjvkd.apps.googleusercontent.com |
| JS Origins | https://kenny-mineral.github.io, https://twwp-ops-api.fly.dev |
| Redirect URIs | https://twwp-ops-api.fly.dev/auth/google/callback |
|               | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Test users | thewholeywaterproject@gmail.com |
| Data Access Scopes | userinfo.email, drive.file |
| App status | Testing / External (unverified) |
| Authorised domains | kenny-mineral.github.io, twwp-ops-api.fly.dev |

---

## Rails API infrastructure

| Item | Value |
|------|-------|
| URL | https://twwp-ops-api.fly.dev |
| Fly.io app | twwp-ops-api |
| Fly.io DB | twwp-ops-api-db (Postgres, unmanaged) |
| Region | syd (Sydney) |
| VM | shared-cpu-1x, 1GB RAM |
| Ruby | 3.3.0 |
| Rails | 8.0.1 |
| Auto-stop | Yes — machines stop after ~2 min idle, wake on request |

### Database tables
- **ops_sessions** — one row per user, Google tokens, JWT state, Drive folder ID
- **ops_syncs** — one row per user, full app state JSON
- **oauth_states** — temporary OAuth state (PKCE stored here, not session)

### Useful commands
```bash
# View live logs
fly logs --app twwp-ops-api

# Redeploy after changes
cd ~/twwp-ops-api && fly deploy

# Run migrations
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"

# Rails console on server
fly ssh console --app twwp-ops-api
# then: bin/rails console

# Edit production credentials
cd ~/twwp-ops-api
EDITOR="nano" rails credentials:edit --environment production
# Save: Ctrl+O → Enter → Ctrl+X
# Then: fly deploy

# Start Claude Code session
cd ~/twwp-ops-api && claude
```

---

## Hard-won lessons — do not deviate

| Problem | Fix |
|---------|-----|
| Rails 8.1.2 incompatible with Ruby 3.3 | Use Rails 8.0.1 |
| pg gem segfaults in Fly.io container | `gem "pg", "~> 1.1", force_ruby_platform: true` |
| release_command in fly.toml causes segfault | Remove it, run migrations manually via SSH |
| SQLite segfaults in Fly.io containers | Use Postgres |
| secret_key_base missing from credentials | Must be explicitly added to production YAML |
| Sessions middleware disabled in API mode | Add ActionDispatch::Session::CookieStore in application.rb |
| Thruster tries to bind port 80 (fails as non-root) | fly.toml: `[processes] app = './bin/rails server -b 0.0.0.0 -p 8080'` |
| OAuth state lost between request and callback | Use OauthState DB records not session |

---

## What happens after OAuth is fixed

1. User clicks "Connect via Rails API" → redirected to Google sign-in
2. Signs in → Google redirects to /auth/google/callback on Rails API
3. Rails exchanges code for token, stores in ops_sessions table
4. Rails issues JWT session token, redirects back to Ops App with token in URL
5. Ops App stores session token in localStorage
6. All API calls use Bearer token in Authorization header
7. On logout → app POSTs all data to /api/sync → saves to Postgres
8. On login from any device → GET /api/sync/status → silent sync if server newer
9. Drive file operations go through Rails → no CORS issues

---

## Reference waterhouse (for testing)

- WH1 Hillstone Realm, Guardian: Raj
- Address: 39 Cornwall St Gate Pa Tauranga, ID: WH-001

---

## Document index

| File | Purpose |
|------|---------|
| MASTER-HANDOFF.md | This file — give to any new Claude chat |
| session-handoff-march21.md | Deep dive on Rails build history and OAuth debugging |
| TWWP-ops-api-handoff.md | Other chat session handoff — Rails API specific |
| fresh-start-guide.md | Full rebuild guide if Rails API needs to start over |
| docs/README.md | Ops App overview and setup |
| docs/architecture.md | How everything is built and connected |
| docs/backlog.md | All outstanding work with build sequence |
| docs/known-issues.md | Current bugs and stubs |
| docs/data-storage.md | Every localStorage key and data shape |
| docs/how-to-extend.md | Developer guide for adding features |
| docs/pages.md | All 26 pages documented |
| ops-platform-distilled.md | Original spec distillation |
| index.html | The Ops App — current version |
| twwp-worker.js | Cloudflare Worker — current version |

---

## How to start a new Claude session

Paste this message:
> "I am continuing development of the TWWP Ops App. Here is the master handoff:"
> [paste this file]
> "What I want to work on: [describe task]"

