# TWWP Ops App — Sprint Handoff
## Sprint: March 23, 2026 (Session 13)
## Status: 10 feature tasks shipped

---

## What was built this session

### Task 1 — Fix calendar CRUD (live bug — ReferenceError on every click)

`openCalEventMo`, `editCalEvent`, `saveCalEvent`, `deleteCalEvent` were all called in the UI but never defined — causing ReferenceErrors. Now fully implemented:

| Function | What it does |
|---|---|
| `openCalEventMo(date, type, whId, title)` | Opens modal for new event, pre-fills date/type |
| `editCalEvent(id)` | Opens modal pre-filled from calEvents store record |
| `saveCalEvent()` | Validates title + date, upserts to calEvents, re-renders |
| `deleteCalEvent(id)` | Confirms, removes from store, re-renders |

**Additional modal changes:**
- Recurrence select added: None / Daily / Weekly / Monthly / Yearly
- Delete button added (hidden on create, shown on edit)
- `populateCeWh()` populates waterhouse dropdown on modal open
- Event type dropdown expanded: Financial, Meeting, Reminder, Reimbursement, Personal added
- Removed two duplicate `renderCalendar()` definitions (was 3, now 1)

---

### Task 2 — Calendar week/day views + new event categories

- View switcher pills (Month / Week / Day) added above source filter
- **Today** button added next to month nav arrows
- `renderCalendar()` now dispatches to `renderCalMonth()`, `renderCalWeek()`, `renderCalDay()`
- `calNav()` updated: month view = ±1 month, week view = ±7 days, day view = ±1 day
- `calNavToday()` resets all three views to today
- Week view: 7-column Mon–Sun grid, today highlighted cyan, event chips per day
- Day view: event list with type, time, Edit button for manual events
- `calState` extended with `view`, `weekDate`, `dayDate`
- New `CAL_TYPES`: Reimbursement (amber `#f39c12`), Meeting (blue `#74b9ff`), Reminder (cyan `#00cec9`), Personal (grey `#b2bec3`)

---

### Task 3 — Calendar multi-provider connection panel

**Connect button** added to calendar page header. Opens `calProviderMo` showing 4 providers:

| Provider | Status |
|---|---|
| Google Calendar | Actionable — fetches from Google Calendar API via existing OAuth token |
| iCloud Calendar | Coming soon (CalDAV + App-Specific Password) |
| Proton Calendar | Coming soon (CalDAV via Proton Bridge) |
| Outlook / Microsoft 365 | Coming soon (Microsoft Graph API) |

`syncGoogleCal()` fetches events from primary calendar (90-day window), deduplicates by `gcal_id`, imports as calEvents with type='Meeting'. Requires Google OAuth token already present from AI & Integrations connect flow.

Provider connection state stored in `localStorage.twwp_cal_providers`.

---

### Task 4 — Events Ledger store + global `logEvent()`

- `eventLedger: 'twwp_ledger_v1'` added to KS store map
- `ledgerEnabled` flag (default true)
- `logEvent(category, action, detail, meta)` — writes to eventLedger; never throws; caps at 5000 entries on write

**Wired into:**
- `saveTask` / `deleteTask` → category: task
- `saveContact` / `delContact` → category: contact
- `saveCalEvent` → category: calendar
- `doLogin` → category: auth (login)
- `doLogout` → category: auth (logout)
- `aiCallJSON` → category: ai (includes provider name)
- `go()` → category: nav (light — all page navigations)

---

### Task 5 — Events Ledger page (admin-only)

New sidebar item: **Events Ledger** (🗒, under Dev section, hidden from non-admin users).

**Features:**
- Stats bar: total entries, today's count, AI calls, top category, store size (KB)
- Storage % progress bar with colour coding (green/amber/red)
- Filters: category dropdown, text search, date picker
- Filterable table showing up to 500 rows (coloured category badge, time, action, detail)
- Pause / Resume recording toggle (with visual badge)
- Clear All (confirm dialog)
- Export CSV download

---

### Task 6 — Resource usage bar

Fixed bar at the very bottom of the viewport (above the capture FAB which was bumped to `bottom:32px`):

| Slot | Content |
|---|---|
| 💾 | localStorage % with mini colour-coded bar |
| ↻ | Age of last Rails API sync |
| 🤖 | AI calls today (from ledger) |
| ● | Ledger events today (dot is green if recording, grey if paused) |
| ● Drive | Google Drive connection dot |

- Collapses to 4px strip on click; hover re-expands; state persisted in `twwp_rb_collapsed`
- Updated every 60s via `setInterval`; also updated on every `updStats()` call

---

### Task 7 — Calendar + Ledger integration (activity dots + popover)

- **Activity toggle button** in calendar page header — stores preference in `twwp_cal_activity_log`
- When active: cyan dots appear on month view calendar cells that have ledger entries for that date (nav events excluded)
- Clicking a dot opens `ledgerPopover` — a floating popover showing up to 20 activity entries for that date
- Popover shows: category badge (colour-coded), detail text, time
- Popover positioned near the clicked dot; closes on outside click

---

### Task 8 — Ledger auto-purge + storage management + Rails sync

- **Settings in Ledger page:** max age (default 90 days) and max entries (default 5000)
- `autoPurgeLedger()` runs silently on app init
- `purgeLedger()` manual purge button in page header area
- `syncLedgerToRails()` — POSTs up to 1000 entries to `POST /api/ledger/sync` with Bearer JWT
- **Rails API:** `POST /api/ledger/sync → Api::LedgerController#sync` (placeholder — logs count, returns `{status:'ok', received:N}`)
- Route: `post 'ledger/sync', to: 'ledger#sync'` in `config/routes.rb`
- **To deploy:** `cd ~/twwp-ops-api && fly deploy`

---

### Task 9 — Recurring calendar events

- Recurrence field added to `calEventMo` modal (None/Daily/Weekly/Monthly/Yearly)
- `getUnifiedCalItems()` now expands recurring events within the current view range:
  - Month view: expands within the visible month
  - Week view: expands within the 7-day window
  - Day view: expands for the single day
- Each expanded instance gets composite ID `baseId_date`; chip clicks resolve to the base event for editing
- ↻ indicator on chips for recurring instances (visible in month, week, and day views)
- Safety cap: 400 expansions per event per render

---

## Current integration status

| Service | Status | Notes |
|---|---|---|
| Rails API JWT login | ✅ Working | POST /auth/login, 30-day JWT |
| Rails API data sync | ✅ Working | PUT/GET /api/sync |
| Rails API Drive upload | ✅ Fixed | Returns id + webViewLink |
| Rails API email send | ⚠️ Placeholder | `fly deploy` needed + SMTP |
| Rails API ledger sync | ⚠️ Placeholder | `fly deploy` needed; no DB persistence yet |
| Google Drive (read-only) | ✅ Working | API key + folder ID |
| Google Drive (OAuth read/write) | ⚠️ Re-auth needed | Scope changed to `drive` — reconnect |
| Google Calendar sync | ✅ UI live | Requires existing OAuth token |
| Cloudflare Worker | ✅ Deployed | /token, /refresh, /health |
| AI — Gemini | ✅ Working | gemini-2.5-flash |
| AI — Anthropic | ✅ Working | claude-haiku-4-5 |
| AI — OpenAI | ✅ Working | gpt-4o-mini |
| AI — OpenRouter | ✅ Working | |
| Home Assistant | ⚠️ Partial | Fields saved, no live test |
| GitHub Actions deploy | ⚠️ Pending | Flip Pages source in repo settings |

---

## Known open bugs / stubs

| ID | Description |
|---|---|
| A1 | Google OAuth Drive scope — re-auth resolves (scope now = `drive`) |
| A9 | Old OAuth tokens with `drive.file` scope will fail Drive operations |
| A7 | `dtk_I1` dev task seeded twice (minor) |
| NEW | Rails email + ledger endpoints need `fly deploy` |
| NEW | Ledger Rails endpoint is a placeholder — no `ledger_entries` DB table yet |

---

## Recommended next task queue

### Immediate
1. `cd ~/twwp-ops-api && fly deploy` — deploy ledger + email endpoints
2. Re-connect Google OAuth — re-authorise with `drive` scope for Drive features
3. **Flip GitHub Pages source to GitHub Actions** — repo Settings → Pages → Source → GitHub Actions

### High priority
4. **User management page** (admin only) — invite, deactivate, change role; `POST/PUT /api/users` needed
5. **Wire `callModelForFeature()`** — autofill, AI helper, import wizard, classify
6. **Wire Receipt Inbox AI Parse tab**
7. **Activate Drive auto-backup on logout** — code written, unblocked by OAuth scope fix
8. **Multi-device sync activation** — unblocked by OAuth fix

### Near-term
9. **Ledger Rails persistence** — add `ledger_entries` table; store entries instead of just logging
10. **Campaigns → Email Registry link** — "Send email to contacts" from campaign view
11. **Home Assistant test connection button**
12. **iCloud / Proton / Outlook CalDAV** — implement the coming-soon calendar providers

---

## LocalStorage stores (32 keys)

```
items, accounts, locations, inbox, kits, deps,
maintJobs, calEvents, monitorData, reports, contacts,
projects, rd, legal, financials, captures, tasks,
devtasks, inventory, purchase_orders, shop_destinations,
shop_listings, services, assets, ppsr, docs,
workflow_flags, knowledgeBase, emailRegistry, campaigns,
eventLedger
```
(rd and legal are virtual — filtered views of captures store)

---

## Repo and file locations

| What | Path |
|---|---|
| Frontend repo | `~/twwp-project/TWWP-opps-app/` |
| Main file | `~/twwp-project/TWWP-opps-app/index.html` (~11,900 lines) |
| Live app | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Rails API local | `~/twwp-ops-api/` |
| Rails API live | https://twwp-ops-api.fly.dev |

---

## Admin credentials (production)

| Field | Value |
|---|---|
| Email | thewholeywaterproject@gmail.com |
| Password | twwp2024 |
| Role | admin |
| Login shortcut | type `admin` in the email field |
