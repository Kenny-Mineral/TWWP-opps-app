# TWWP Ops App — Project Context
## The primary AI and developer handoff document
## Last updated: 2026-03-21

---

## What this project is

An internal operations platform for **The Wholey Water Project (TWWP)** — a
community reverse osmosis water network in New Zealand with neighbourhood
tap installations called "waterhouses".

Replaces manual Word documents for: guardian reimbursements, waterhouse
maintenance, member management, financial ledger, inventory, governance,
and document management.

**Owner:** Kenny Samkin | admin@thewholeywaterproject.com | 02041333855

---

## Repository structure

This repo contains the **frontend app only**.
The Rails backend is a separate repo at `~/twwp-ops-api/` on Kenny's Toshiba.

```
TWWP-opps-app/  (this repo)
  README.md
  PROJECT_CONTEXT.md      ← you are here
  CURRENT_STATE.md        ← operational snapshot
  .gitignore
  app-frontend/
    index.html            ← THE live app (single file, ~9,300 lines)
  integrations/
    twwp-worker.js        ← Cloudflare Worker code
  docs/
    architecture.md       ← how the app is built
    pages.md              ← every page documented
    data-storage.md       ← localStorage stores and shapes
    how-to-extend.md      ← safe extension patterns
    backlog.md            ← all outstanding work
    known-issues.md       ← current bugs and stubs
```

---

## Live URLs

| Resource | URL |
|----------|-----|
| Ops App | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Rails API | https://twwp-ops-api.fly.dev |
| Cloudflare Worker | https://twwp-proxy.thewholeywaterproject.workers.dev |
| Tap-Map (separate) | https://app.thewholeywaterproject.com |

---

## The frontend app

`app-frontend/index.html` is the entire app — all CSS, HTML, and JS in one
file. This is intentional. Do not split it without explicit discussion.

- **Deploy:** commit index.html to GitHub → live in 30 seconds
- **Login:** admin / twwp2024 (blank = dev mode)
- **Size:** ~9,300 lines

### Key JavaScript conventions
```javascript
S.get/find/upsert/set/rm  // localStorage wrapper
G('id')                   // getElementById shorthand
uid()                     // unique ID generator
esc(str)                  // HTML escape
OM/CM('modalId')          // open/close modal
go('pageName', el)        // navigate to page
```

### Safe onclick pattern (critical — never deviate)
```javascript
// CORRECT
'<button data-xid="' + esc(id) + '" onclick="fn(this.dataset.xid)">'
// WRONG — breaks iOS and syntax checking
'<button onclick="fn(\'' + id + '\')">'
```

---

## The three-layer architecture

The app is currently evolving through three stages. All three exist simultaneously:

### Layer 1 — Browser only (original, mostly working)
- Single HTML file, localStorage, no server
- AI calls direct to Gemini/Claude/OpenAI
- Google Drive read-only via API key (working)

### Layer 2 — Cloudflare Worker (existing, stable)
- Proxies token exchange for OAuth (avoids CORS)
- Scrapes product pages for catalogue AI fill
- Endpoints: `/?url=`, `/token`, `/refresh`, `/health`

### Layer 3 — Rails API (new, partially working)
- Handles Google OAuth server-side (avoids PKCE/session issues)
- Multi-device data sync via PostgreSQL
- Drive write access via server-side tokens
- **Status:** deployed, email OAuth working, drive.file scope blocked

---

## Current critical issue

Google OAuth via Rails API fails with `drive.file` scope.
Email-only scope works. See `CURRENT_STATE.md` for debug status.

---

## Google Cloud Console

| Setting | Value |
|---------|-------|
| Project | Opps App TWWP - Kenny |
| Active OAuth Client | ends in `...39mavd5fmtl0s688dcfa26gdq64sjvkd` |
| Old broken Client | ends in `...nljl` — do not use |
| Test users | thewholeywaterproject@gmail.com |
| Scopes | userinfo.email, drive.file |
| Redirect URIs | https://twwp-ops-api.fly.dev/auth/google/callback |
|               | https://kenny-mineral.github.io/TWWP-opps-app/ |

Gemini API keys come from **aistudio.google.com** — NOT Google Cloud Console.
Current working model: **gemini-2.5-flash**

---

## Rails API (separate repo)

| Item | Value |
|------|-------|
| Local path | ~/twwp-ops-api/ |
| Live URL | https://twwp-ops-api.fly.dev |
| Fly.io app | twwp-ops-api |
| Ruby | 3.3.0 |
| Rails | 8.0.1 |

```bash
# Redeploy
cd ~/twwp-ops-api && fly deploy

# Migrations
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"

# Logs
fly logs --app twwp-ops-api

# Claude Code session
cd ~/twwp-ops-api && claude
```

---

## What NOT to do

- Do not split index.html into multiple files
- Do not use the old OAuth Client ID ending in `...nljl`
- Do not commit real secrets to this repo
- Do not touch app.thewholeywaterproject.com (separate app)
- Do not assume Rails API is deployed before testing

---

## Reference waterhouse (for testing/demo)

WH1 Hillstone Realm | Guardian: Raj | 39 Cornwall St Gate Pa Tauranga | WH-001

