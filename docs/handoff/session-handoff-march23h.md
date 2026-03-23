# TWWP Ops App — Sprint Handoff
## Sprint: March 23, 2026 (Session 15)
## Status: 10 feature tasks shipped — SPEC_VERSION 4.5

---

## What was built this session

### Task 1 — Tooltip audit and sidebar data-tip pass

All 35 sidebar nav items now have `data-tip` attributes:

- Format: `"PageName — one-line description"`
- Covers every section: Operations, People, Projects, Finance, Documents, Developer, Admin
- Works with the existing `initGlobalTooltip()` 800ms hover system

---

### Task 2 — Calendar +Event button wired; Add-to-Calendar in Dev Tasks

| Feature | Implementation |
|---|---|
| Calendar header "+ Event" | Calls `openDateWizard('When is this event?', d => openCalEventMo(d))` |
| Dev Tasks calendar icon | Per-row 📅 button (only when task has due date); calls `syncTaskToCalendar('devtask', id)` |
| Backfill on load | `backfillDevTasksToCalendar()` in `initApp()` setTimeout — creates events for existing dev tasks with due dates but no linked event |

---

### Task 3 — Persistence banner in Growth Log / ADRs

- `#growthPersistBanner` in SPEC_GROWTH tab — shows "X entries are in localStorage only"
- `#adrsPersistBanner` in SPEC_ADRS tab — same pattern for ADRs
- **"📋 Copy for Claude Code"** button: formats user entries as ready-to-paste JSON
- `updatePersistBanners()` called from `switchSpecTab()` and from `initApp()` (800ms delay)
- Banners hidden when no localStorage-only entries exist

---

### Task 4 — SPEC_GROWTH backfilled (sessions 1–3 added, date gaps fixed)

| Entry | Date | Description |
|---|---|---|
| Session 15 | 2026-03-23 | 10 tasks: sidebar tooltips, Cal +Event, persist banners, SPEC_GROWTH backfill, resource bar, onboarding wizard, setup checklist, requiresSetup, org_config, SPEC_VERSION 4.5 |
| Session 14 | 2026-03-23 | 20 tasks: cal header buttons, global tooltip, tasks→cal sync, ledger multi-filter, SPEC_GROWTH/ADRS, date wizard, completion modal, backlog scheduling, dev task re-sync, dev history, DEVNOTES, session logger, tooltip pass, recurring edit, AQ expanded, dashboard live, resource bar, global search, version bump |
| Sessions 1a–3b | 2026-03-10–12 | Base build, spec planning, scaffolding (backfilled this session) |

Total: 16 entries in SPEC_GROWTH constant.

---

### Task 5 — Resource bar: tasks from stores + ↑X created-today indicator

- `updateResourceBar()` now reads `tasks` + `devtasks` stores directly for done-today count
  - Checks `status === 'complete'` and `completed_at.slice(0,10) === today`
  - Falls back to ledger count if stores have no `completed_at` data
- New cyan **↑X** indicator beside tasks-done: count of tasks + devtasks with `created` date = today

---

### Task 6 — Onboarding Wizard (7 steps)

First-run modal overlaid on the whole app:

| Step | Label | Fields |
|---|---|---|
| 1 | Welcome | Org name, admin name, purpose |
| 2 | Branding | App display name, brand colour, logo URL |
| 3 | First Location | Location name, address, type (waterhouse/office/site) |
| 4 | AI Assistant | Gemini key + model, Anthropic key + model, OpenAI key |
| 5 | Integrations | Rails API URL, Cloudflare proxy URL, Drive folder ID |
| 6 | Team | First team member name + email (creates contact record) |
| 7 | Done | Summary of completed steps; "Launch App" button sets `twwp_setup_complete` |

- Progress bar fills by step (14% / step)
- ✕ button sets `twwp_onboarding_skip` and dismisses without completing
- `checkRunOnboarding()` fires 800ms after app init if neither flag is set
- Config saved incrementally to `twwp_org_config_v1`

---

### Task 7 — Persistent setup status checklist (Dashboard)

9 setup dimensions tracked in `twwp_setup_status_v1`:

| Key | Label |
|---|---|
| org_name | Organisation name |
| branding | Branding & logo |
| first_location | First location |
| ai_key | AI API key |
| google_calendar | Google Drive / Calendar |
| google_drive | Google Drive upload |
| rails_api | Rails API sync |
| first_team_member | First team member |
| esp32_config | ESP32 / IoT sensor |
| stripe_config | Stripe payments |

- Dashboard shows `#setupStatusCard` (admin only) with progress bar + checklist
- Card hides automatically when all dimensions complete
- `renderSetupStatusCard()` / `updateSetupStatusCard()` — refresh on each `updStats()` call

---

### Task 8 — Contextual setup interrupts

`requiresSetup(featureName, setupKey, wizardStep)`:
- If `getSetupStatus()[setupKey]` is falsy: shows confirm dialog
- User confirms → opens onboarding wizard at the given step; returns `true` (caller should return early)
- User cancels → returns `false` (caller may proceed anyway)

Wired into:

| Function | Setup key | Wizard step |
|---|---|---|
| `syncGoogleCal()` | `google_calendar` | 5 |
| `uploadDocBuilderToDrive()` | `google_calendar` | 5 |
| `sendEmail()` | `rails_api` | 5 |
| `sendAIHelperMsg()` | `ai_key` | 4 |

---

### Task 9 — Multi-org foundation: org_config + terminology

- `org_config` added to KS store map (`twwp_org_config_v1`)
- `DEFAULT_TERMINOLOGY` — 6 keys: `waterhouse`, `guardian`, `quencher`, `wh_id`, `locations_page`, `monitor_page`
- `getTerm(key)` — reads `org_config.terminology[key]` with fallback to `DEFAULT_TERMINOLOGY`
- `initOrgConfig()` in `initApp()`: applies brand colour CSS var + updates sidebar "Locations" + "WH Monitor" text labels
- Terminology editor in AI & Integrations modal: 6 text fields + Save button
- `renderTerminologyEditor()` / `saveTerminology()` — reload sidebar labels on save

---

### Task 10 — SPEC_VERSION 4.5 + ADRs + GROUP W

- `SPEC_VERSION = '4.5'`, `SPEC_LAST_UPDATED = '2026-03-23'`
- 3 new ADRs added (ADR-012 through ADR-014):
  - ADR-012: Onboarding wizard as the first-run setup flow
  - ADR-013: Setup status checklist with 9 dimensions + Dashboard card
  - ADR-014: org_config store as v1 multi-tenancy stub (terminology, brand, config)
- BACKLOG_GROUPS GROUP W: 10 items (W1–W10) — onboarding, setup checklist, requiresSetup, org_config, user management, feature flags, white-label, analytics, ESP32 step, Stripe step

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
14. **Multi-org architecture** (GROUP U) — org_id on all stores, org switcher

---

## LocalStorage stores (32+ keys)

```
items, accounts, locations, inbox, kits, deps,
maintJobs, calEvents, monitorData, reports, contacts,
projects, rd, legal, financials, captures, tasks,
devtasks, inventory, purchase_orders, shop_destinations,
shop_listings, services, assets, ppsr, docs,
workflow_flags, knowledgeBase, emailRegistry, campaigns,
eventLedger, org_config
```
(rd and legal are virtual — filtered views of captures store)

Config keys: `twwp_ledger_filter_v1`, `twwp_rb_cfg_v1`, `twwp_cal_providers`, `twwp_backlog_scheduled_v1`, `twwp_spec_growth_v1`, `twwp_setup_status_v1`, `twwp_setup_complete`, `twwp_onboarding_skip`

---

## Repo and file locations

| What | Path |
|---|---|
| Frontend repo | `~/twwp-project/TWWP-opps-app/` |
| Main file | `~/twwp-project/TWWP-opps-app/index.html` (~13,000 lines) |
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
