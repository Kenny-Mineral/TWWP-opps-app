# TWWP Ops App — Current State
## Last updated: 2026-03-21
## Quick operational snapshot — update this after every session

---

## What works right now

| Feature | Status |
|---------|--------|
| Ops App frontend | ✅ Live at kenny-mineral.github.io/TWWP-opps-app/ |
| All 26 pages | ✅ Built and functional |
| AI integration (Gemini) | ✅ Working |
| Google Drive read-only | ✅ Working (API key, Phase 1) |
| Drive sync (Documents tab) | ✅ Working — recurses subfolders |
| Classify Folder | ✅ Working — AI proposes folder structure |
| Connection status dot | ✅ Working — top right header, 5 min auto-check |
| Cloudflare Worker | ✅ Live — /token /refresh /health /scraper |
| Rails API health check | ✅ https://twwp-ops-api.fly.dev/health |
| Rails API email OAuth | ✅ Confirmed working end to end |
| Maintenance wizard + reimbursements | ✅ |
| Calendar, WH Monitor, Reports | ✅ |
| Financials (5 tabs) | ✅ |
| Inventory, Kits, Deployments, POs | ✅ |
| Contacts/CRM | ✅ |
| Trustees/Legal (PPSR, Documents) | ✅ |
| Developer page | ✅ |

---

## What is blocked

### CRITICAL — Google OAuth drive.file scope
**Symptom:** "Something went wrong" at Google after selecting account
**Works:** email-only scope
**Fails:** drive.file scope causes Google server error before token issuance
**Zero traffic in Cloud Console** — rejected before any token issued

**Try in this order:**
1. Wait 30 min (consent screen propagation), retry in incognito
2. Confirm Google Drive API v3 is enabled (Cloud Console → APIs & Services)
3. Try `drive.readonly` scope instead of `drive.file`
4. Enable People API
5. Test with fresh Gmail added as test user
6. Check Workspace admin settings on thewholeywaterproject@gmail.com

**To change scope:**
```bash
cd ~/twwp-ops-api
nano app/controllers/auth_controller.rb
# Change SCOPES line
fly deploy
```

---

## What is not yet built

- Email Registry tab
- Document Creation tab
- Campaigns page
- Waterhouse digital twin page
- Multi-device sync (blocked by OAuth above)
- Drive auto-save on logout/report generation (code written, needs OAuth)

---

## Latest deploy info

| Item | Value | Date |
|------|-------|------|
| index.html | Deployed to GitHub Pages | Mar 21 2026 |
| twwp-worker.js | Deployed to Cloudflare | Mar 21 2026 |
| Rails API | Deployed to Fly.io | Mar 21 2026 |
| Rails migrations | All run | Mar 21 2026 |

---

## Rails API database tables

- ops_sessions — Google tokens, JWT state per user
- ops_syncs — full app state JSON per user
- oauth_states — temporary PKCE state (fixes Fly.io session wipe bug)

---

## Active OAuth Client ID

`1096306613884-39mavd5fmtl0s688dcfa26gdq64sjvkd.apps.googleusercontent.com`

⚠️ There is also an OLD broken client ending in `...nljl` — do not use it.

---

## Next session priorities

1. Resolve drive.file OAuth issue (options above)
2. Test full Drive write flow once OAuth works
3. Wire callModelForFeature() into autofill/import/classify
4. Build Email Registry tab
5. Build Document Creation tab

