# TWWP Ops App — Sprint Handoff
## Sprint: March 22–23, 2026 (Sessions 9–11)
## Status: Sprint complete — 25 tasks shipped across 3 sessions

---

## ⚠️ Immediate action required

**Google OAuth re-authorisation needed.**
The Rails OAuth scope was changed from `drive.file` to full `drive` this sprint. Any user who previously connected via Google OAuth must **re-connect** before Drive features will work:

> AI & Integrations → Connect via Rails API → follow Google sign-in

This is a one-time re-auth. After it, Drive upload, backup on logout, and auto-sync will all have the correct permissions.

---

## Project overview

Kenny Samkin runs The Wholey Water Project (TWWP) — a community reverse osmosis water filtration network in New Zealand with neighbourhood tap installations called "waterhouses".

The **TWWP Ops App** is a single-file HTML/CSS/JS browser app at `index.html` (currently ~10,800 lines). All data stored in localStorage. Rails API on Fly.io handles auth, Drive proxy, and multi-device sync.

---

## Repo and file locations

| What | Path |
|------|------|
| Frontend repo | `~/twwp-project/TWWP-opps-app/` |
| Main file | `~/twwp-project/TWWP-opps-app/index.html` |
| Live app | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Rails API local | `~/twwp-ops-api/` |
| Rails API live | https://twwp-ops-api.fly.dev |
| Fly.io app name | `twwp-ops-api` |

> **Important:** The working directory in Claude Code is `/home/kenny/twwp-project/TWWP-opps-app`.
> The file is `index.html` at the repo root — not `app-frontend/index.html`.

---

## Standing rules (CLAUDE.md)

Before every commit:
1. Update `docs/CURRENT_STATE.md`
2. Mark resolved backlog items ✅ in `docs/backlog.md`
3. Update `docs/known-issues.md` if bugs fixed
4. Include doc updates in the same commit as code

At the start of each new session: ask if the doc-update rule is still needed.

---

## What was built this sprint

### Session 9

| Task | What |
|------|------|
| Remove debug console.logs | Cleaned `doLogin()` |
| Wire `updateFinForm()` | Financial form adapts on type change (labels, waterhouse row, category default) |
| Wire `sendRptChatMsg()` | Full multi-turn AI chat in report modal, all 4 providers, KB injection |
| Fix Contacts CSV import | File picker, `parseCsvText()`, email dedup, confirm dialog |
| Role-based UI | `getUserRole()`, `isAdmin()`, `enforceRoleUI()` — staff: admin nav hidden; read-only: store writes blocked |

### Session 10

| Task | What |
|------|------|
| `.docx` extraction | mammoth.js loaded dynamically from CDN; text passed to `aiCallJSON()` |
| Doc Builder page | 3 templates (Host Agreement, Reimbursement Receipt, Waterhouse Report); prefills from live data; iframe preview modal; PDF print |
| Upload to Drive via Rails | `uploadDocBuilderToDrive()` in preview modal footer |
| KB import from Docs | "Import from Docs" button on KB tab; checkbox list; imports title + desc + tags |
| → KB button on doc cards | One-click KB entry from any document card |

### Session 11

| Task | What |
|------|------|
| Fix `/api/drive/upload` | Added `?fields=id,webViewLink,name`; default `text/html`; clean response |
| Fix OAuth scope | `drive.file` → `drive` in `auth_controller.rb`; deployed to Fly.io |
| Fix frontend drive upload | `uploadDocBuilderToDrive()` sends JSON body; uses `webViewLink` |
| Maintenance → financials | `completeMaintJob()` auto-creates reimbursement entry when total > 0 |
| Email Registry | Store, sidebar, page, compose modal, 3 templates with `{{name}}` substitution |
| Campaigns | Store, sidebar, page, modal, 6-stage pipeline, 2 demo records |
| Dashboard panels | Row 8: campaign status + inventory summary (4 stats, clickable) |
| Contact roles | `twwp_roles` multi-checkbox (9 roles), coloured badges on cards, filter support |
| Trustee fields | `appointment_date`, `term_length`, `term_expiry` (auto-calculated) in contact modal |
| Governance tab | Term expiry stat cards; per-trustee term cards with colour-coded status |

---

## Current integration status

| Service | Status | Notes |
|---------|--------|-------|
| Rails API JWT login | ✅ Working | POST /auth/login, 30-day JWT |
| Rails API data sync | ✅ Working | PUT/GET /api/sync |
| Rails API Drive upload | ✅ Fixed | Returns id + webViewLink |
| Google Drive (read-only) | ✅ Working | API key + folder ID |
| Google Drive (OAuth read/write) | ⚠️ Re-auth needed | Scope changed to `drive` — reconnect required |
| Cloudflare Worker | ✅ Deployed | /token, /refresh, /health |
| AI — Gemini | ✅ Working | gemini-2.5-flash |
| AI — Anthropic | ✅ Working | claude-haiku-4-5 |
| AI — OpenAI | ✅ Working | gpt-4o-mini |
| AI — OpenRouter | ✅ Working | |
| Home Assistant | ⚠️ Partial | Fields saved, no live test button |
| GitHub Actions deploy | ⚠️ Pending | Workflow written; flip Pages source to GitHub Actions in repo settings |
| Knowledge Base | ✅ Working | CRUD, injection in all AI paths |
| Email Registry | ✅ Built | Draft/sent/failed tracking, 3 templates |
| Campaigns | ✅ Built | 6 stages, demo seed |

---

## Rails API — current state

### Database tables

| Table | Purpose |
|-------|---------|
| `users` | Email + bcrypt password, role, org_id, active |
| `ops_sessions` | Google OAuth sessions (email, access/refresh token, expiry) |
| `ops_syncs` | App data snapshots (one row per user, JSON blob) |
| `oauth_states` | Temporary PKCE state for OAuth flow (15-min expiry) |

### Endpoints

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
| POST | /api/drive/upload | JWT | Upload HTML file to Drive — returns id, webViewLink |

### Infrastructure

| Resource | Value |
|----------|-------|
| Fly.io app | twwp-ops-api |
| Fly.io region | syd (Sydney) |
| Postgres | twwp-ops-api-db |
| Ruby | 3.3.0 |
| Rails | 8.0.4 |

### Useful commands

```bash
# Deploy Rails API
cd ~/twwp-ops-api && fly deploy

# Run migrations on Fly.io
fly machine start 7844dd5a434e68 --app twwp-ops-api
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"

# Create/update users
fly ssh console --app twwp-ops-api -C "bin/rails runner \"User.create!(...)\""

# View live logs
fly logs --app twwp-ops-api
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

## LocalStorage stores (KS map)

29 keys as of sprint end:

```
items, accounts, locations, inbox, kits, deps,
maintJobs, calEvents, monitorData, reports, contacts,
projects, rd, legal, financials, captures, tasks,
devtasks, inventory, purchase_orders, shop_destinations,
shop_listings, services, assets, ppsr, docs,
workflow_flags, knowledgeBase, emailRegistry, campaigns
```

---

## Recommended next tasks (priority order)

### Immediate
1. **Re-connect Google OAuth** — re-authorise with new `drive` scope (see top of this doc)
2. **Test Drive upload end-to-end** — Doc Builder → Preview → Upload to Drive → confirm `webViewLink` works
3. **Activate Drive auto-backup on logout** — code is written, unblocked by scope fix; remove `isOAuthConnected()` guard or route through Rails instead
4. **Activate silent sync on login** — `checkRailsAPISync()` is called, but Drive pull path needs OAuth check removed

### Near-term
5. **Flip GitHub Pages source to GitHub Actions** — one click: repo Settings → Pages → Source → GitHub Actions
6. **User management page** (admin only) — invite user, deactivate, change role; POST/PUT `/api/users` endpoints needed in Rails
7. **Wire `callModelForFeature()`** — already built but not connected to autofill, import wizard, or classify workflows
8. **Wire Receipt Inbox AI Parse tab** — tab exists with no AI call
9. **Home Assistant test connection button** — fields are saved, no live request made

### Feature work
10. **Campaigns → Email Registry link** — "Send email to contacts" action from campaign view
11. **`dtk_I1` duplicate dev task seed** (minor cleanup)
12. **Multi-Organisation Architecture (GROUP U)** — `org_id` on all stores, org switcher, per-org config
13. **Waterhouse digital twin (GROUP F)** — full page with tabs, sensor cards, history
14. **ESP32 / IoT (GROUP O)** — firmware setup, pH/TDS readings
15. **Tap-Map sync (GROUP P)** — POST waterhouse data to twwp-app Rails API

---

## Known open bugs

| ID | Description |
|----|-------------|
| A1 | Google OAuth Drive scope — changed to `drive`; re-auth resolves this |
| A7 | `dtk_I1` dev task seeded twice (minor) |
| A9 | Old OAuth tokens with `drive.file` scope will fail Drive operations — re-auth required |

---

## Google Cloud Console (OAuth reference)

| Setting | Value |
|---------|-------|
| Project | Opps App TWWP - Kenny |
| Active OAuth Client ID | ends in `...39mavd5fmtl0s688dcfa26gdq64sjvkd` |
| Old broken Client ID | ends in `...nljl` — do not use |
| Redirect URI | https://twwp-ops-api.fly.dev/auth/google/callback |
| Test users | thewholeywaterproject@gmail.com, kennymtbeach@gmail.com, kjsamkin@gmail.com |
| Scopes now requested | openid, userinfo.email, drive |

---

## Contacts

Kenny Samkin
thewholeywaterproject@gmail.com
02041333855
