# TWWP Ops App — Sprint Handoff
## Sprint: March 23, 2026 (Session 14)
## Status: 20 feature tasks shipped — SPEC_VERSION 4.4

---

## What was built this session

### Task 1 — Calendar header buttons wired

All 4 calendar header buttons now functional:

| Button | Function called | What it does |
|---|---|---|
| ↻ Sync | `doCalHeaderSync(btn)` | Calls calSyncAll(), re-renders, fetches Google Calendar API if connected; shows toast |
| 📓 Activity | `toggleCalActivityLog()` | Toggles activity dot overlay on month view |
| + Event | `openCalEventMo()` | Opens new event modal |
| 🔗 Connect | `openCalProviderPanel()` | Opens provider connection modal |

All buttons also have `data-tip` attributes for the tooltip system.

---

### Task 2 — Global tooltip system

- `#globalTip` div added before status dot; CSS handles positioning + 0.15s fade
- `initGlobalTooltip()` called from `initApp()` — attaches mouseover/mouseout/click listeners
- 800ms hover delay before tooltip appears; clears on mouseout or any click
- Positioning is overflow-safe: tooltip stays within viewport bounds
- `data-tip` attributes added across all major action buttons

---

### Task 3 — Tasks → Calendar auto-sync

- `syncTaskToCalendar(src, taskId)` — creates/updates/removes calendar event linked by `_task_id`
- Called from: `saveTask()`, `deleteTask()`, `saveDevTask()`, `delDevTask()`
- Linked events have `_auto: true`; `[Dev]` prefix for devtasks; type = "Task Due" / "Dev Task Due"
- Tasks with no due date or status=complete/cancelled: linked calendar event is removed

---

### Task 4 — Event Ledger multi-select filter

- Category and Action selects replaced with checkbox dropdown panels
- `toggleLedgerDropdown(type)` opens/closes with outside-click dismissal
- All-checked = show all (no filter applied)
- Filter state persisted in `twwp_ledger_filter_v1` localStorage
- `loadLedgerFilterState()` called on `renderEventLedgerPage()`

---

### Task 5 — SPEC_GROWTH populated

- 12 entries covering sessions 1–14 (newest first)
- Runtime override from `twwp_spec_growth_v1` localStorage merged on render (user entries appear first)

---

### Task 6 — SPEC_ADRS populated (11 ADRs)

| ADR | Decision |
|---|---|
| ADR-001 | Single HTML file — zero build tooling, GitHub Pages compatible |
| ADR-002 | Rails API on Fly.io for auth, sync, Drive proxy |
| ADR-003 | PKCE + oauth_states DB table for Google OAuth |
| ADR-004 | GitHub Actions auto-deploy on push to main |
| ADR-005 | localStorage as primary data store (offline-first) |
| ADR-006 | JWT auth with 30-day expiry + local fallback |
| ADR-007 | Postgres JSON blob sync (one row per user) |
| ADR-008 | mammoth.js loaded dynamically from CDN |
| ADR-009 | Drive proxy via Rails (avoids CORS, hides credentials) |
| ADR-010 | Multi-org deferred to v2 (org_id stub on stores) |
| ADR-011 | Event Ledger capped at 5000 entries (localStorage budget) |

---

### Task 7 — Date Wizard modal

`openDateWizard(title, callback)` — reusable date picker modal:
- Presets: Today / This Week / This Month / This Year / Custom
- Callback receives YYYY-MM-DD string
- Used by: backlog item scheduling, task due date (extensible to any date input)

---

### Task 8 — Completion Note modal

`openCompletionModal(title, confirmMsg, callback)` — confirmation modal with optional note:
- Textarea for freeform note; ISO timestamp auto-shown
- `confirmCompletion()` calls callback with (note, timestamp)
- Wired into `toggleDevTask()` for dev task completion flow

---

### Task 9 — Backlog → Calendar scheduling

- `renderDevBacklog()` rewritten with filter pills: **All / Scheduled / Overdue**
- `scheduleBacklogItem(id, title)` — calls `openDateWizard()`, saves to `twwp_backlog_scheduled_v1`, creates calendar event tagged `_backlog_id`
- Scheduled items: calendar badge shown; overdue items: red highlight

---

### Task 10 — Dev Tasks: seed ALL backlog groups

- `syncBacklogToDevTasks()` iterates all `BACKLOG_GROUPS` (A through V)
- Idempotent: only adds items not already in devtasks store
- "Re-sync Backlog" button in Dev Tasks header

---

### Task 11 — Dev History: addGrowthEntry, Log Session, Import

- `addGrowthEntry(date, by, summary)` — prepends to `twwp_spec_growth_v1` localStorage
- `openSessionLogModal()` / `saveSessionLog()` — manual session logging form
- `aiExtractSessionSummary()` — paste a session summary text, AI extracts structured JSON entry
- Import modal: `sessionImportMo` with AI Extract button + manual paste
- Buttons shown contextually via `updateDevPageActions(tab)`

---

### Task 12 — DEVNOTES populated for all pages

15+ pages now have build intent notes:
calendar, campaigns, emailregistry, docbuilder, approvalqueue, eventledger, locations, inventory, kits, deployments, reports, monitor, member + all previously covered pages

---

### Task 13 — Sprint session logger

- `updateDevPageActions(tab)` called from `switchDevTab()` and `renderDevPage()`
- Injects context-sensitive buttons into `#devPageActions` container div
- History tab: **+ Log Session** + **↓ Import from Session Summary**
- KB tab: **+ Entry** + **↓ Import from Docs**
- Others: empty

---

### Task 14 — data-tip tooltip pass (all remaining pages)

`data-tip` added to: Maintenance → + Log Job, Contacts → + Add Contact, Projects → + New Project, Financials → + Log Entry (both occurrences), Email → + Compose, Campaigns → + New Campaign, Reports → + New Report, Locations → + Add Location, Dev Tasks → Re-sync + New Dev Task, Dashboard → Refresh, Calendar all 4 header buttons.

---

### Task 15 — Recurring event edit flow

- `editCalEvent(id)` now detects composite IDs (`baseId_YYYY-MM-DD`)
- If base event is recurring: opens `recurEditMo` with 3 choices:
  - **This event only** — creates exception record for that date
  - **This and future events** — updates base start date, removes past occurrences
  - **All events** — opens base event for full edit
- `openCalEventEditor(id)` extracted as the actual modal population function
- `getNextOccurrences(ev, count)` returns next N occurrence date strings

---

### Task 16 — Approval Queue expanded

New types pulled by `getAQItems()`:

| Type | Source | Actions |
|---|---|---|
| contact (lead/unverified) | contacts store | Verify |
| rdpromote (validated, not promoted) | captures store (type=rd) | Promote to Project |
| emaildraft | emailRegistry store | Send |
| campaignidea | campaigns store | Approve to Planning |

Helper functions: `aqVerifyContact(id)`, `aqMoveCampaignToPlanning(id)`

---

### Task 17 — Dashboard live data confirmed

All Dashboard panels confirmed live (already pulling from stores). Added:
- `#dashLastUpdated` span — shows last refresh timestamp in page header
- Dashboard Refresh button gets `data-tip`

---

### Task 18 — Resource bar expanded

New resource bar items:
| Item | Content |
|---|---|
| ⏱ Session | Time since login (`twwp_session_start` in sessionStorage) |
| ✅ Tasks done | Tasks completed today (from ledger action='complete') |
| 📷 Captures | Captures submitted today (from ledger category='capture') |
| Service dots | Rails / Drive / AI / HA — coloured dots with label, click → AI & Integrations |

Gear icon (⚙) opens `rbSettingsPn` — toggles each item on/off individually. Settings persist in `twwp_rb_cfg_v1`.

---

### Task 19 — Global search (Ctrl+K)

- `Ctrl+K` / `Cmd+K` opens `globalSearchMo` full-width search modal
- `runGlobalSearch(q)` debounced 150ms; `_doGlobalSearch(q)` does the work
- Searches: **tasks, contacts, financials, documents, captures, campaigns, inventory, knowledge base, projects**
- Results grouped by store with icon, name, subtitle
- Arrow key navigation; Enter selects; Escape closes
- All searches logged to ledger: `category=nav, action=search`
- `escH()` XSS-safe HTML escaping helper

---

### Task 20 — Version bump + docs

- `SPEC_VERSION = '4.4'`
- `SPEC_LAST_UPDATED = '2026-03-23'`
- `docs/CURRENT_STATE.md` updated with all 20 task summaries
- `docs/backlog.md` updated (session 14 date, Approval Queue expanded note)
- `docs/known-issues.md` date updated
- This handoff doc written

---

## Current integration status

| Service | Status | Notes |
|---|---|---|
| Rails API JWT login | ✅ Working | POST /auth/login, 30-day JWT |
| Rails API data sync | ✅ Working | PUT/GET /api/sync |
| Rails API Drive upload | ✅ Fixed | Returns id + webViewLink |
| Rails API email send | ⚠️ Placeholder | `fly deploy` needed + SMTP |
| Rails API ledger sync | ⚠️ Placeholder | `fly deploy` needed; no DB persistence |
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
| NEW | Ledger Rails endpoint is a placeholder — no `ledger_entries` DB table |

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
13. **Subtask support** — `parent_task` field on tasks

---

## LocalStorage stores (32+ keys)

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

Config keys: `twwp_ledger_filter_v1`, `twwp_rb_cfg_v1`, `twwp_cal_providers`, `twwp_backlog_scheduled_v1`, `twwp_spec_growth_v1`

---

## Repo and file locations

| What | Path |
|---|---|
| Frontend repo | `~/twwp-project/TWWP-opps-app/` |
| Main file | `~/twwp-project/TWWP-opps-app/index.html` (~12,500 lines) |
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
