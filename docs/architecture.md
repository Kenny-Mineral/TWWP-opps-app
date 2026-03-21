# Architecture — How the App is Built

Last updated: 2026-03-21 (session 6, reconciled)

---

## The single-file approach

The entire Ops App lives inside one file: `index.html`.
Deliberate constraint — GitHub Pages deployment, no build step, iOS compatible.
**Never split this file. Discuss before any architectural change.**

---

## File locations

| File | Location |
|------|----------|
| Ops App (live) | kenny-mineral.github.io/TWWP-opps-app/ |
| Ops App (local) | ~/Desktop/Opps App dev folder laptop/new2/index.html |
| Rails API (live) | https://twwp-ops-api.fly.dev |
| Rails API (local) | ~/twwp-ops-api/ |
| Cloudflare Worker | twwp-proxy.thewholeywaterproject.workers.dev |
| Tap-Map App | app.thewholeywaterproject.com (separate, do not touch) |

---

## Structure inside index.html

```
1. HTML Head       ~lines 1-12
2. CSS styles      ~lines 13-375    (one <style> block)
3. HTML Body       ~lines 376-1380  (login, modals, sidebar, pages)
4. JavaScript      ~lines 1381+     (one <script> block)
```

Current size: ~9,300 lines

---

## CSS variables

```css
--bg --surface --surface2 --border
--text --text2 --text3
--cyan (brand) --green --amber --red
--purple --orange --blue --mono
```

---

## Key JavaScript conventions

```javascript
S.get('items')         // get array
S.find('items', id)    // find one
S.upsert('items', obj) // add or update
S.set('items', array)  // replace all
S.rm('items', id)      // delete one
G('elementId')         // getElementById
uid()                  // unique ID
esc(str)               // HTML escape
fmtNZD(n)             // NZ dollar format
today()               // YYYY-MM-DD
go('pageName', el)    // navigate
OM('modalId')         // open modal
CM('modalId')         // close modal
```

---

## Safe onclick pattern (critical)

```javascript
// SAFE — always use this
html += '<button data-xid="' + esc(item.id) + '" onclick="deleteItem(this.dataset.xid)">Del</button>';

// UNSAFE — never do this
html += '<button onclick="deleteItem(\'' + item.id + '\')">Del</button>';
```

---

## Multi-service architecture

```
Browser (index.html — GitHub Pages)
    │
    ├── AI providers direct (Gemini, Claude, OpenAI, OpenRouter)
    │
    ├── Cloudflare Worker (twwp-proxy.thewholeywaterproject.workers.dev)
    │   ├── GET /?url=URL        product page scraper
    │   ├── POST /token          Google token exchange proxy
    │   ├── POST /refresh        Google token refresh proxy
    │   └── GET /health          worker health check
    │
    ├── Rails API (twwp-ops-api.fly.dev)
    │   ├── GET /health
    │   ├── GET /auth/google              redirect to Google
    │   ├── GET /auth/google/callback     handle callback
    │   ├── DELETE /auth/session          logout
    │   ├── GET/PUT /api/sync             multi-device data sync
    │   ├── GET /api/sync/status          check if newer data exists
    │   ├── GET /api/drive/files          list Drive files
    │   └── POST /api/drive/upload        upload to Drive
    │
    └── Google Drive API (browser, read-only, API key)
        └── list files in folder
```

---

## Rails API infrastructure

| Item | Value |
|------|-------|
| URL | https://twwp-ops-api.fly.dev |
| Fly.io app | twwp-ops-api |
| Fly.io DB | twwp-ops-api-db (Postgres unmanaged) |
| Region | syd (Sydney) |
| VM | shared-cpu-1x, 1GB RAM |
| Auto-stop | Yes — wakes on request, ~30-60s cold start |
| Ruby | 3.3.0 |
| Rails | 8.0.1 |

**fly.toml process override (critical — do not remove):**
```toml
[processes]
  app = './bin/rails server -b 0.0.0.0 -p 8080'
```
Without this, Thruster tries to bind port 80 and fails as non-root user.

---

## Google Cloud Console

| Setting | Value |
|---------|-------|
| Project | Opps App TWWP - Kenny |
| Active Client ID | 1096306613884-39mavd5fmtl0s688dcfa26gdq64sjvkd.apps.googleusercontent.com |
| Old broken Client ID | 1096306613884-n4on7nf4bgnqjrjjsiue4i2n1pq5nljl — do not use |
| Client Secret | Kenny's phone notes (starts GOCSPX-) |
| JS Origins | https://kenny-mineral.github.io, https://twwp-ops-api.fly.dev |
| Redirect URIs | https://twwp-ops-api.fly.dev/auth/google/callback |
|               | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Test users | thewholeywaterproject@gmail.com |
| Scopes | userinfo.email, drive.file |

---

## Deployment

**Ops App:**
1. Get updated index.html from Claude
2. github.com/kenny-mineral/TWWP-opps-app → upload → commit
3. Live in ~30 seconds

**Rails API:**
```bash
cd ~/twwp-ops-api && fly deploy
# After schema changes:
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"
```

**Cloudflare Worker:**
dash.cloudflare.com → Workers & Pages → twwp-proxy → Edit Code → replace → Deploy

---

## Session history

| Session | Date | Key work |
|---------|------|----------|
| 1-3 | Mar 10-11 | v3.1 planning and build |
| 4 | Mar 17 | v4.1→4.2 upgrade |
| 5 | Mar 18-19 | Dev page, financials, docs, PPSR, Drive Phase 1 |
| 6 | Mar 20-21 | Status dot/panel, Rails API build and deploy, OAuth debug |

