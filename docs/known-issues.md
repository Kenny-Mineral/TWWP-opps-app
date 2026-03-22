# Known Issues, Bugs, and Stubs

Last updated: 2026-03-22 (session 7 — Sprint 1)

---

## Fixed this session (session 7 — Sprint 1)

- ✅ Duplicate `buildRptFormModal` / `closeRptFormMo` — already resolved; backlog entry was stale
- ✅ Cloudflare Proxy URL had no Test button — added (AI & Integrations modal)
- ✅ Rails API auto-save: logout (confirmed), report generation, 30-min timer — all wired
- ✅ GitHub Actions auto-deploy — `.github/workflows/deploy.yml` created (need to flip Pages source to GitHub Actions in repo settings)
- ⚠️ `sendRptChatMsg()` and `updateFinForm()` — still stubs, `console.warn` added for visibility

---

## Fixed in session 6

- ✅ Connection status dot added to page header (top right, fixed position)
- ✅ Status panel (slide-in from right, 6 services, individual Test buttons)
- ✅ Drive sync recurses into subfolders
- ✅ Drive sync shows total files found vs new
- ✅ Status dot HTML placement bug fixed
- ✅ Print function newline bug fixed
- ✅ Redirect URI trailing slash fixed
- ✅ Rails API "Connect via Rails API" button in AI & Integrations
- ✅ Cloudflare Worker updated (/token, /refresh, /health endpoints)
- ✅ Rails API deployed to Fly.io
- ✅ oauth_states DB table created (PKCE stored in DB, not session)
- ✅ Email-only OAuth confirmed working end to end

---

## Fixed in previous sessions

- ✅ AI & Integrations modal broken by function hoisting
- ✅ Login dev-mode bypass (empty fields)
- ✅ Login credentials set to admin / twwp2024
- ✅ Phase 2 OAuth Client ID field enabled
- ✅ Gemini model updated to gemini-2.5-flash
- ✅ Test AI Key button in AI & Integrations
- ✅ Per-feature model selector
- ✅ Google Drive Phase 1 connected (read-only)
- ✅ GitHub Pages live

---

## Current bugs

### A1 — CRITICAL: Google OAuth drive.file scope fails
**Symptom:** "Something went wrong" at Google after account selection
**What works:** email-only OAuth confirmed working
**What fails:** drive.file scope causes Google error before token issuance
**Zero traffic in Cloud Console metrics** — Google rejecting server-side
**Theories (try in order):**
1. Wait 30 min for consent screen propagation, retry in incognito
2. Confirm Google Drive API v3 is enabled in Cloud Console
3. Try drive.readonly scope to narrow down
4. Enable People API
5. Test with fresh Gmail account added as test user
6. Check Workspace admin settings if thewholeywaterproject@gmail.com is Workspace

**Note:** There are TWO OAuth Client IDs in Cloud Console.
Active one: `...39mavd5fmtl0s688dcfa26gdq64sjvkd`
Old broken one: `...nljl` — do not use.

### ✅ A2 — Duplicate `buildRptFormModal` — RESOLVED
Already gone in current file. Backlog item was based on stale line numbers.

### ✅ A3 — Duplicate `closeRptFormMo` — RESOLVED
Same as A2.

### A4 — `sendRptChatMsg()` stub
Report AI chat does nothing. `console.warn` added — visible in DevTools. Full wiring pending.

### A5 — `updateFinForm()` stub
Financial form doesn't adapt to type. `console.warn` added — visible in DevTools. Full wiring pending.

### A6 — Contacts CSV import shows alert
Not implemented.

### A7 — `dtk_I1` seeded twice
Duplicate dev task ID.

---

## Stubs (built UI, not wired)

| Feature | Status |
|---------|--------|
| Receipt Inbox AI Parse tab | Tab exists, no AI call |
| Deployments → inventory auto-move | Checkbox not built |
| Shop Destinations management UI | Store exists, no UI |
| Report chat | Empty function |
| Tap-Map sync | JSON export works, Rails endpoint not built |
| HA test connection | Fields saved, no test call |
| Slack / Zapier webhooks | Fields saved, no event wiring |
| Google Drive OAuth via Rails API | Deployed, drive.file scope failing |
| Multi-device sync | Needs OAuth fix first |
| Document Creation tab | Not built |
| Email Registry tab | Not built |
| Drive backup on logout | Code written, needs OAuth |
| Auto-save to Drive every 30 min | Timer set, needs OAuth |
| `callModelForFeature()` | Built but not wired into autofill/import/classify |

---

## Data model gaps

**Locations:** ha_url, device_node_id, filter_configuration, installer, commission_date
**Contacts:** twwp_role, referrer_id, appointment_date, term_length
**Calendar events:** is_approval_item, related_record, recurrence
**Maintenance jobs:** entity_id, technician_id, installer_id

---

## Important notes

- **Gemini model:** gemini-2.5-flash — deprecates frequently, use Test AI Key to verify
- **Gemini keys from aistudio.google.com** — NOT Google Cloud Console
- **Service Account JSON must never go in browser** — private key exposed in DevTools
- **Fly.io auto-stop** wakes machines on request (~30-60 sec first request)
- **Two OAuth Client IDs exist** — use the newer one ending in ...39mavd5
- **Rails production key:** 3c1cda80ab038529d03d3fceb4075dca — keep safe

---

## Deferred (out of v1 scope)

GSD University, public API, subscription billing, ecommerce, OTA firmware, multi-region
