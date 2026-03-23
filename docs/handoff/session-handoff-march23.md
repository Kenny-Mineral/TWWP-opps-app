# TWWP Ops App — Session Handoff
## Sessions: March 22–23, 2026
## Status: Rails JWT auth live, Knowledge Base built, three wiring bugs identified (not yet fixed)

---

## Project overview

Kenny Samkin runs The Wholey Water Project (TWWP) — a community reverse osmosis
water filtration network in New Zealand with neighbourhood tap installations
called "waterhouses".

The **TWWP Ops App** is a single-file HTML/CSS/JS browser app for operational
reporting, reimbursements, maintenance tracking, and network management.

---

## Repo and file locations

| What | Path |
|------|------|
| Frontend repo | `~/twwp-project/TWWP-opps-app/` |
| Main file | `~/twwp-project/TWWP-opps-app/index.html` (~9,700 lines) |
| GitHub remote | https://github.com/Kenny-Mineral/TWWP-opps-app |
| Live app | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Rails API local | `~/twwp-ops-api/` |
| Rails API live | https://twwp-ops-api.fly.dev |
| Fly.io app name | `twwp-ops-api` |

> **Important:** The working directory in Claude Code is `/home/kenny/twwp-project/TWWP-opps-app`.
> The file is `index.html` at the repo root — not `app-frontend/index.html`.

---

## Standing rules for this repo (see also CLAUDE.md)

Before every commit:
1. Update `docs/CURRENT_STATE.md` to reflect what changed
2. Mark resolved backlog items in `docs/backlog.md` as ✅
3. Update `docs/known-issues.md` if bugs were fixed
4. Include all doc updates in the same commit as the code

At the start of each new session, ask if the doc-update rule is still needed.

---

## What was done this session (March 22–23)

### Sprint 1 — Activate what's already built

**Task 1 — Wire Rails API sync (GROUP R)**
- `saveToRailsAPI()` confirmed wired on logout
- Added to `previewRptFromForm()` — fires when a report is generated
- 30-minute `setInterval` added inside `initApp()`

**Task 2 — Stub visibility (GROUP A)**
- Audited for duplicate `buildRptFormModal`/`closeRptFormMo` — already gone, backlog was stale
- Added `console.warn` to empty `sendRptChatMsg()` and `updateFinForm()` so they surface in DevTools

**Task 3 — Cloudflare Proxy test button (GROUP A / GROUP Q)**
- Added Test Proxy button next to Worker URL field in AI & Integrations
- `testProxyUrl()` fetches `/?url=https://example.com` and shows ✓/✗ inline

---

### Sprint 2 — GitHub Actions auto-deploy (GROUP S)

**Task 4 — `.github/workflows/deploy.yml`**
- Triggers on every push to `main`
- Deploys repo root to GitHub Pages via `actions/deploy-pages@v4`
- **One manual step still needed:** repo Settings → Pages → Source → set to **GitHub Actions**
  (Until this is done, pushes trigger the workflow but it may fail or be skipped)

---

### Sprint 3 — Rails user auth (GROUP T)

**Task 5 — Users table**
- Uncommented `bcrypt` gem
- Migration `20260322000000_create_users`: email (unique), password_digest, role (default `staff`), org_id, active (default `true`)
- `User` model with `has_secure_password` + email uniqueness + `before_save` downcase

**Task 6 — POST /auth/login endpoint**
- `SessionsController#create` — authenticates with `has_secure_password`, returns JWT
- JWT payload: `user_id`, `email`, `role`, `org_id`, `exp` (30 days)
- Route: `POST /auth/login`
- `ApplicationController#authenticate_request!` updated to handle both `user_id` JWTs (new) and `session_id` JWTs (existing Google OAuth) — backward compatible
- Deployed and remote migration applied

**Task 7 — Admin user created on Fly.io**
- Email: `thewholeywaterproject@gmail.com`
- Password: `twwp2024`
- Role: `admin`, org_id: `twwp`
- Created via: `fly ssh console --app twwp-ops-api -C "bin/rails runner \"User.create!(...)\""

**Task 8 — Frontend login wired to Rails**
- `doLogin()` is now `async`
- If Rails API URL is configured: POSTs to `/auth/login`, stores JWT in `twwp_rails_session` (same key `railsAPIRequest` already reads), stores role in `SK` session
- Wrong credentials from Rails → shows error, does NOT fall back to local
- Rails unreachable (network error) → falls back silently to local `admin/twwp2024`
- Login field: label changed to Email, placeholder updated, `autocomplete="email"`
- Shortcut: typing `admin` expands to `thewholeywaterproject@gmail.com`
- Temporary debug `console.log` added to `doLogin()` (email sent, URL, response status+body) — **remove these once login is confirmed working**

---

### Session 8 — Knowledge Base (March 23)

**Store:** `knowledgeBase` added to `KS` map as `twwp_kb_v1`

**Each entry:** `id`, `title`, `body`, `tags[]`, `always_inject` (boolean), `created`, `updated`

**UI:** New tab "Knowledge Base" on the Developer page (last tab)
- List view: colour-coded tag badges, 160-char body preview, cyan left-border when injecting
- Always Inject toggle button per entry (fires immediately, no save needed)
- Add/edit modal: title, tags (comma-separated), body textarea, always_inject checkbox
- Delete with confirm

**AI injection:**
- `getKBContext()` — collects all `always_inject: true` entries, formats as `=== KNOWLEDGE BASE ===` block
- `sendAIHelperMsg()` — KB injected into system prompt; Anthropic gets it in the `system` field, others in the combined prompt string
- `callModelForFeature()` — KB prepended to prompt for every feature call (autofill, classify, etc.)

---

## Integration health check results (March 23)

Run against current codebase. Four bugs identified, none fixed yet.

### ✅ Working correctly

| Item | Notes |
|------|-------|
| Doc upload — file reading | Images/PDFs read as base64, text as UTF-8, graceful fallback |
| Sync from Drive | Uses API key + folder ID, independent of OAuth/JWT |
| Reports → Rails save | `if(isRailsConnected())saveToRailsAPI()` in `previewRptFromForm()` |
| 30-min timer | `setInterval` in `initApp()`, one timer per session |
| Login sync (OAuth path) | `checkRailsAPISync()` called 1s after Google OAuth callback |
| KB injection — AI helper | `getKBContext()` in `sendAIHelperMsg()` |
| KB injection — autofill + features | `getKBContext()` in `callModelForFeature()` |

### ⚠️ / ❌ Bugs identified — fix these next

**Bug 1 — `doLogin()` missing `checkRailsAPISync()` after JWT login** ❌
- `handleRailsAPICallback()` (Google OAuth path) calls it — but `doLogin()` (the path now in use) never does
- New devices won't pull server data until the 30-min timer fires
- Fix: add `setTimeout(function(){checkRailsAPISync();}, 1000);` to the Rails success branch of `doLogin()`

**Bug 2 — `doLogout()` doesn't await `saveToRailsAPI()`** ⚠️
- `saveToRailsAPI()` is called without `await`, then `location.reload()` fires immediately
- Since Drive OAuth is broken, the page reloads before the fetch completes — data may not save
- Fix: make `doLogout()` async, `await saveToRailsAPI()` before reload

**Bug 3 — `aiCallJSON()` has no KB injection** ❌
- `callModelForFeature()` gets KB — but `aiCallJSON()` is a separate parallel AI path that doesn't
- Affected: document upload AI extraction, Classify Folder AI, receipt/invoice AI extraction
- Fix: add `var kbCtx=getKBContext(); if(kbCtx)prompt=kbCtx+'\n\n'+prompt;` at the top of `aiCallJSON()`

**Bug 4 — Drive auto-save is dead** ⚠️ (external blocker)
- `driveAutoBackup()` is guarded by `isOAuthConnected()` which checks browser OAuth token
- The `drive.file` scope is failing at Google's end (see known-issues A1) — token never arrives
- Drive backup on logout and on report generation never fires in practice
- Fix: resolve Google OAuth scope issue (Cloud Console — see known-issues A1), OR route backup through Rails API instead

---

## Current integration status

| Service | Status | Notes |
|---------|--------|-------|
| Rails API JWT login | ✅ Working | POST /auth/login, 30-day JWT |
| Rails API data sync | ✅ Working | PUT/GET /api/sync |
| Rails API health | ✅ Working | GET /health |
| Google Drive (read-only) | ✅ Working | API key + folder ID, no OAuth needed |
| Google Drive (OAuth read/write) | ❌ Broken | `drive.file` scope failing at Google — see known-issues A1 |
| Cloudflare Worker | ✅ Deployed | /token, /refresh, /health endpoints |
| AI — Gemini | ✅ Working | gemini-2.5-flash |
| AI — Anthropic | ✅ Working | claude-haiku-4-5 |
| AI — OpenAI | ✅ Working | gpt-4o-mini |
| AI — OpenRouter | ✅ Working | |
| Home Assistant | ⚠️ Partial | Fields saved, no live test button |
| GitHub Actions deploy | ⚠️ Pending | Workflow written, Pages source needs switching to GitHub Actions in repo settings |
| Knowledge Base | ✅ Working | CRUD UI live, injection working in most AI paths |

---

## Rails API — database tables

| Table | Purpose |
|-------|---------|
| `users` | Email + bcrypt password, role, org_id, active |
| `ops_sessions` | Google OAuth sessions (email, access/refresh token, expiry) |
| `ops_syncs` | App data snapshots (one row per user, JSON blob) |
| `oauth_states` | Temporary PKCE state for OAuth flow (auto-expires 15 min) |

---

## Rails API — endpoints

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| GET | /health | none | Health check |
| POST | /auth/login | none | JWT login with email+password |
| GET | /auth/google | none | Start Google OAuth flow |
| GET | /auth/google/callback | none | OAuth callback |
| DELETE | /auth/session | JWT | Logout |
| GET | /api/sync/status | JWT | Check if server has newer data |
| GET | /api/sync | JWT | Download server data |
| PUT | /api/sync | JWT | Upload local data to server |
| GET | /api/drive/files | JWT | List Drive files |
| PUT | /api/drive/backup | JWT | Save Drive backup |

---

## Infrastructure

| Resource | Value |
|----------|-------|
| Fly.io app | twwp-ops-api |
| Fly.io region | syd (Sydney) |
| Postgres | twwp-ops-api-db |
| Ruby | 3.3.0 |
| Rails | 8.0.4 |
| Fly.io VM | shared-cpu-1x, auto-stop enabled |

**Useful commands:**
```bash
# Deploy Rails API after changes
cd ~/twwp-ops-api && fly deploy

# Run migrations on Fly.io (wake machine first if stopped)
fly machine start 7844dd5a434e68 --app twwp-ops-api
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"

# Create/update users
fly ssh console --app twwp-ops-api -C "bin/rails runner \"User.create!(...)\""

# View live logs
fly logs --app twwp-ops-api

# Check machine status
fly status --app twwp-ops-api
```

---

## Admin credentials (production)

| Field | Value |
|-------|-------|
| Email | thewholeywaterproject@gmail.com |
| Password | twwp2024 |
| Role | admin |
| org_id | twwp |
| Login shortcut | type `admin` in the email field |

---

## Next tasks queued (in priority order)

### Immediate fixes (from health check)

1. **Fix `doLogin()` — add `checkRailsAPISync()` after JWT login success**
   - File: `index.html`, function `doLogin()`, Rails success branch
   - Add: `setTimeout(function(){checkRailsAPISync();}, 1000);` after `initApp()`

2. **Fix `doLogout()` — await `saveToRailsAPI()` before reload**
   - Make `doLogout` async, await the Rails save, then reload
   - Currently the page reloads immediately and cancels the in-flight request

3. **Fix `aiCallJSON()` — add KB injection**
   - Add `var kbCtx=getKBContext(); if(kbCtx)prompt=kbCtx+'\n\n'+prompt;` at top of function
   - Fixes doc upload AI, Classify Folder AI, receipt AI in one edit

4. **Remove debug `console.log` from `doLogin()`** (once login is confirmed working)

### After fixes

5. **Flip GitHub Pages source to GitHub Actions** (one click in repo settings)
6. **Wire `updateFinForm()`** — financial form field show/hide on type change
7. **Wire `sendRptChatMsg()`** — report AI chat using `sendAIHelperMsg()` pattern
8. **Fix Contacts CSV import** — shows alert, not implemented
9. **Resolve Google OAuth `drive.file` scope** — unblocks Drive backup, Drive upload, multi-device full sync
10. **Role-based UI enforcement** — roles exist in DB and JWT, UI doesn't enforce them yet

---

## Key files in this repo

```
TWWP-opps-app/
├── CLAUDE.md                          # Standing rules for Claude Code
├── index.html                         # The entire app (~9,700 lines)
├── .github/workflows/deploy.yml       # GitHub Actions auto-deploy
├── docs/
│   ├── CURRENT_STATE.md               # What's built and what's broken
│   ├── backlog.md                     # Full feature backlog with ✅ status
│   ├── known-issues.md                # Bugs and stubs
│   ├── architecture.md                # System design
│   ├── handoff/
│   │   ├── session-handoff-march21.md # Previous session handoff
│   │   └── session-handoff-march23.md # This file
│   └── ...
└── ~/twwp-ops-api/                    # Rails API (separate repo, not in this folder)
```

---

## Google Cloud Console (for OAuth fix reference)

| Setting | Value |
|---------|-------|
| Project | Opps App TWWP - Kenny |
| Active OAuth Client ID | ends in `...39mavd5fmtl0s688dcfa26gdq64sjvkd` |
| Old broken Client ID | ends in `...nljl` — do not use |
| Redirect URI (Rails) | https://twwp-ops-api.fly.dev/auth/google/callback |
| Test users | thewholeywaterproject@gmail.com, kennymtbeach@gmail.com, kjsamkin@gmail.com |

The `drive.file` scope failure (known-issues A1) is the main blocker for full Drive integration.
Theories to try: wait 30min for consent screen propagation, try `drive.readonly` scope, check Workspace admin settings.

---

## Contacts

Kenny Samkin
thewholeywaterproject@gmail.com
02041333855
