# Known Issues, Bugs, and Stubs

Last updated: 2026-03-24 (Sprint C — 9 sub-tasks)

---

## Fixed this sprint (Sprint C)

- ✅ `[FIX]` Rails STI type column conflict on TapMapTap — `self.inheritance_column = :_type_disabled` + `read_attribute(:type)` in controller
- ✅ `[FIX]` WH Monitor In/Out gauge split — readings now separated by `flow_type` field; filtration efficiency stat added

## Added this sprint (Sprint C)

- ✅ Calendar month view completion dots (dev tasks ✅ / sprint events 🚀)
- ✅ Week view clickable day headers → slide-in day detail panel
- ✅ Month chip inline ••• menu (Edit/Complete/Delete)
- ✅ logEvent() auto-creates sprint_complete calEvent (deduplicated)
- ✅ Dev Tasks "Progress" button with per-group bars popup
- ✅ WH Monitor manual reading modal (flow type, TDS/EC/pH/ORP, saves to tap_readings store)
- ✅ Source badge on sensor gauge header (Tap-Map Live / Manual Entry)
- ✅ Sensor readings history table in WH Monitor
- ✅ Contacts pipeline kanban view (5 stages, setPipelineStage())
- ✅ AI & Integrations modal restructured to 5-tab layout (700px × 92vh, persistent tab)
- ✅ Fly.io min_machines_running = 1 (prevents cold starts)

---

## Fixed this sprint (Sprint B)

- ✅ No bugs fixed this sprint — Sprint B was additive only

## Added this sprint (Sprint B)

- ✅ Tap-Map read-only DB connection (TapMapRecord base class, Neon Postgres via TAP_MAP_DATABASE_URL)
- ✅ Three Tap-Map endpoints deployed to Fly.io
- ✅ Pull buttons in Contacts / Locations / WH Monitor
- ✅ Live sensor gauges in WH Monitor (TDS/EC/pH/ORP with sparklines)
- ✅ Project Management tabbed restructure (Overview/Board/Timeline/Integrations)
- ✅ Kanban Board + Trello API key/token integration

---

## Fixed this sprint (Sprint A)

- ✅ `[FIX]` Tooltip flicker on sidebar nav — `mouseout` event delegation bug fixed with `relatedTarget` check
- ✅ `[FIX]` Calendar backfill — `backfillDevTasksToCalendar()` now called with 1.5s defer on startup

## Known issues as of Sprint A

- ⚠️ Outlook OAuth PKCE flow incomplete — client ID stored but OAuth redirect not wired (BACKLOG X7)
- ⚠️ Gmail email API scope — existing token has `drive` scope only; `gmail.send` + `gmail.readonly` scopes needed for live inbox/send via Gmail API
- ⚠️ IMAP credentials in Rails cache — will not survive dyno restart; set `TWWP_EMAIL_CONFIG` env var on Fly.io to persist (see session-handoff-march23i.md)
- ⚠️ Email thread grouping not implemented — inbox shows individual messages, not grouped by conversation (BACKLOG X6)

---

## Fixed in session 15 (10 tasks)

- ✅ All 35 sidebar items now have data-tip tooltips
- ✅ Calendar +Event button opens date wizard first
- ✅ backfillDevTasksToCalendar added (Sprint A)
- ✅ Onboarding wizard (7 steps)
- ✅ Setup status checklist Dashboard card
- ✅ requiresSetup() contextual interrupts

---

## Fixed this session (session 7 — Sprint 1)

- ✅ Duplicate `buildRptFormModal` / `closeRptFormMo` — already resolved; backlog entry was stale
- ✅ Cloudflare Proxy URL had no Test button — added (AI & Integrations modal)
- ✅ Rails API auto-save: logout (confirmed), report generation, 30-min timer — all wired
- ✅ GitHub Actions auto-deploy — `.github/workflows/deploy.yml` created (need to flip Pages source to GitHub Actions in repo settings)
- ✅ Hardcoded login replaced with Rails JWT auth — falls back to local if Rails unreachable
- ✅ Users table + has_secure_password deployed to Fly.io
- ✅ Admin user email updated to thewholeywaterproject@gmail.com on production
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

## Fixed 2026-03-23 (health check bugs)

- ✅ `doLogin()` — `checkRailsAPISync()` now called 1 s after JWT login success
- ✅ `doLogout()` — `saveToRailsAPI()` now awaited before `location.reload()`
- ✅ `aiCallJSON()` — KB injection added; doc upload, Classify Folder, and receipt AI now read the knowledge base

---

## Current bugs

### A1 — Google OAuth drive scope (scope changed, re-auth needed)
**Update (session 11):** Scope changed from `drive.file` to full `drive`. This may resolve the Google rejection.
**What to do:** Re-connect via "Connect via Rails API" in AI & Integrations. Users must re-authorise to get the new scope.
**Note:** There are TWO OAuth Client IDs in Cloud Console.
Active one: `...39mavd5fmtl0s688dcfa26gdq64sjvkd`
Old broken one: `...nljl` — do not use.

### ✅ A2 — Duplicate `buildRptFormModal` — RESOLVED
Already gone in current file. Backlog item was based on stale line numbers.

### ✅ A3 — Duplicate `closeRptFormMo` — RESOLVED
Same as A2.

### ✅ A4 — `sendRptChatMsg()` — FIXED (session 9)
Report AI chat now fully wired. Supports all four providers (Gemini, Anthropic, OpenAI, OpenRouter). Includes report context (title, type, waterhouse) and KB injection in system prompt. Maintains multi-turn `rptChatHistory`.

### ✅ A5 — `updateFinForm()` — FIXED (session 9)
Financial form now adapts on type change: contact label and placeholder update (Paid To / Donor Name / Reimburse To / Received From), waterhouse row hidden for donation and income types, category pre-selects a sensible default.

### ✅ A6 — Contacts CSV import — FIXED (session 9)
`impContactsCSV()` now opens a file picker, parses CSV via `parseCsvText()`, auto-maps columns (name, email, phone, type, org, addr, tags, notes), deduplicates by email, and imports with a confirmation dialog.

### ✅ A8 — Rails `/api/drive/upload` endpoint — FIXED (session 11)
Endpoint existed but returned raw Drive response without `webViewLink`. Fixed: added `?fields=id,webViewLink,name`, defaulted mime_type to `text/html`, returns clean `{id, webViewLink, filename}`. Frontend updated to send JSON body instead of FormData.

### A9 — Google OAuth scope re-authorisation required
Changed from `drive.file` to full `drive` scope (session 11). Any users who previously connected via Google OAuth must **re-connect** — old tokens have insufficient scope. The re-auth flow will request the new scope.

### A7 — `dtk_I1` seeded twice
Duplicate dev task ID.

### ✅ NEW — Calendar CRUD undefined — FIXED (session 13)
`openCalEventMo`, `editCalEvent`, `saveCalEvent`, `deleteCalEvent` were referenced in the UI but never defined. Now fully implemented with recurrence field, delete button, waterhouse dropdown population, and store upsert/remove.

---

## Stubs (built UI, not wired)

| Feature | Status |
|---------|--------|
| Receipt Inbox AI Parse tab | Tab exists, no AI call |
| Deployments → inventory auto-move | Checkbox not built |
| Shop Destinations management UI | Store exists, no UI |
| ✅ Report chat | Wired (session 9) |
| ✅ .docx extraction | mammoth.js (session 10) |
| Tap-Map sync | JSON export works, Rails endpoint not built |
| HA test connection | Fields saved, no test call |
| Slack / Zapier webhooks | Fields saved, no event wiring |
| Google Drive OAuth via Rails API | Deployed, drive.file scope failing |
| Multi-device sync | Needs OAuth fix first |
| Document Creation tab | Not built |
| ✅ Email Registry tab | Built (session 11); Send button added (session 12) |
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
