# TWWP Ops App — Current State

**Last updated:** 2026-03-23 (sprint end — sessions 9–11)

---

## What's live

Single-file app at `index.html` deployed on GitHub Pages.
Rails API at `https://twwp-ops-api.fly.dev`.

---

## Sprint 1 changes (2026-03-22)

### Task 1 — Rails API sync wired (GROUP R)
- `saveToRailsAPI()` + `checkRailsAPISync()` confirmed on logout (was already wired)
- `saveToRailsAPI()` added to `previewRptFromForm()` — fires when a report is generated
- 30-minute `setInterval` added in `initApp()` calling both functions

### Task 2 — Stub visibility + duplicate audit (GROUP A)
- Audited for duplicate `buildRptFormModal` / `closeRptFormMo` — **already resolved** in current file (backlog line numbers were stale)
- `sendRptChatMsg()` — `console.warn` added so it surfaces in DevTools until wired
- `updateFinForm()` — `console.warn` added so it surfaces in DevTools until wired

### Task 3 — Cloudflare Proxy test button (GROUP A / GROUP Q)
- **Test Proxy** button added below the Worker URL field in AI & Integrations modal
- `testProxyUrl()` fetches `/?url=https://example.com` and shows ✓/✗ inline
- Same pattern as existing `testAiKey()` / `testDriveConnection()`

---

## Integration status

| Service | Status |
|---------|--------|
| Google Drive (read-only API key) | ✅ Working |
| Google Drive (OAuth read/write) | ⚠️ OAuth drive.file scope failing — see known-issues A1 |
| Cloudflare Worker (/token, /refresh, /health) | ✅ Deployed |
| Rails API (Fly.io) | ✅ Deployed + OAuth confirmed |
| Home Assistant | ⚠️ Fields saved, no live test |
| Multi-device sync | ⚠️ Code wired, unblocked by OAuth fix |
| AI (Gemini/Anthropic/OpenAI/OpenRouter) | ✅ Working |

---

## Session 8 changes (2026-03-23)

### Knowledge Base — store, CRUD UI, AI injection

- `knowledgeBase` store added to KS (`twwp_kb_v1`)
- **Knowledge Base tab** added to Developer page (after Platform Spec)
- Each entry: `id`, `title`, `body`, `tags[]`, `always_inject`, `created`, `updated`
- Full CRUD: list with tag badges, body preview, add/edit modal, delete
- **Always Inject toggle** per entry — cyan left-border when on, button toggles on/off
- `getKBContext()` — collects all `always_inject:true` entries, formats as structured block
- `sendAIHelperMsg()` — KB context prepended into system prompt; Anthropic gets it in the `system` field, others in the prompt string
- `callModelForFeature()` — KB context prepended to prompt for all features (autofill, classify, etc.)

---

## Sprint 3 changes (2026-03-22)

### Tasks 5-8 — Rails user auth + frontend login wired

**Rails API (twwp-ops-api):**
- `bcrypt` gem enabled in Gemfile
- Migration `20260322000000_create_users` — `users` table with email (unique), password_digest, role (default staff), org_id, active (default true)
- `User` model with `has_secure_password` and email uniqueness validation
- `SessionsController#create` — POST `/auth/login`, returns JWT with user_id/email/role/org_id, 30-day expiry
- `ApplicationController#authenticate_request!` updated to handle both `user_id` JWTs (new login) and `session_id` JWTs (existing Google OAuth) — backward compatible
- Deployed to Fly.io, remote migration applied
- Admin user created: `admin@thewholeywaterproject.com` / `twwp2024`, role=admin, org_id=twwp

**Frontend (index.html):**
- `doLogin()` is now `async`
- If Rails API URL is configured: POSTs to `/auth/login`, stores JWT + role in `twwp_rails_session` and `SK` session, proceeds to app
- Wrong credentials from Rails: shows error, does **not** fall back to local
- Rails unreachable (network error): falls back silently to local admin/twwp2024 check
- Login field label changed from **Username** to **Email**; placeholder shows `admin@thewholeywaterproject.com`
- Typing `admin` in the email field auto-expands to `thewholeywaterproject@gmail.com` (production admin email)
- Temporary debug `console.log` in `doLogin()` — logs email sent, URL posted to, and full response status + body

---

## Sprint 2 changes (2026-03-22)

### Task 4 — GitHub Actions auto-deploy (GROUP S)
- `.github/workflows/deploy.yml` created
- Triggers on every push to `main`, deploys repo root to GitHub Pages
- Uses `actions/checkout@v4`, `configure-pages@v5`, `upload-pages-artifact@v3`, `deploy-pages@v4`
- **One-time manual step required:** repo Settings → Pages → Source → set to **GitHub Actions**

---

## Health check fixes (2026-03-23) — all applied

1. `doLogin()` — `checkRailsAPISync()` now called via `setTimeout(..., 1000)` after JWT login success
2. `doLogout()` — made `async`, now `await saveToRailsAPI()` before page reload
3. `aiCallJSON()` — KB injection added at top of function; fixes doc upload AI, Classify Folder AI, receipt AI

---

---

## Session 9 changes (2026-03-23)

### Task 4 — Remove debug console.logs from `doLogin()`
- Removed three `console.log` statements from the Rails login path (email sent, URL, response body)
- `console.warn` for Rails-unreachable fallback is kept (intentional)

### Task 6 — Wire `updateFinForm()`
- Now adapts the financial entry form on type change:
  - **expense**: Contact label = "Paid To (optional)", waterhouse row shown
  - **donation**: Contact label = "Donor Name", waterhouse row hidden, category pre-selects "Community Donation"
  - **reimbursement**: Contact label = "Reimburse To", waterhouse shown, category pre-selects "Guardian Reimbursement"
  - **income**: Contact label = "Received From", waterhouse hidden, category pre-selects "Event Income"

### Task 7 — Wire `sendRptChatMsg()`
- Report AI chat modal now fully functional
- All four providers supported (Gemini, Anthropic, OpenAI, OpenRouter)
- System prompt includes report context (title, type, waterhouse) + KB injection
- Multi-turn: `rptChatHistory` maintained across messages

### Task 8 — Fix Contacts CSV import
- `impContactsCSV()` now opens a native file picker (no modal needed)
- Parses via `parseCsvText()` — handles comma/tab/semicolon delimiters, quoted fields, BOM
- Auto-maps columns: name, email, phone, type, org, addr, tags, notes
- Deduplicates by email — updates existing rather than creating duplicates
- Confirmation dialog shows first 3 names before import

### Task 10 — Role-based UI enforcement
- `getUserRole()` helper — reads role from session storage
- `isAdmin()` helper — true for admin role or local (no-role) login
- `enforceRoleUI()` called from `initApp()`:
  - **staff/read-only**: Developer, AI & Integrations, Trustees/Legal nav items hidden
  - **read-only**: amber bottom banner + `S.upsert` and `S.rm` blocked with alert
- AI & Integrations sidebar item now has `id="ni-ai-integrations"` for targeting

---

---

## Session 10 changes (2026-03-23)

### Task A — Word doc (.docx) extraction with mammoth.js
- `handleDocFile()` now handles `.docx` files
- Dynamically loads mammoth.js from CDN (`cdnjs.cloudflare.com/libs/mammoth/1.6.0`) on first use
- Extracts raw text via `mammoth.extractRawText()`, passes up to 4000 chars to `aiCallJSON()` with same extraction prompt as text files
- Status line guides user through loading → extracting → AI reading → result
- **"→ KB" button** added to every document card — creates a KB entry from title + description

### Task B — Doc Builder page
- New sidebar item "Doc Builder" under Trustees/Legal (`ni-docbuilder`, `page-docbuilder`)
- Three templates: **Host Agreement**, **Reimbursement Receipt**, **Waterhouse Report**
- Form populates from live app data: contact picker, waterhouse picker, date, amounts, readings
- `renderDbForm()` renders the correct fields per template; `dbWhChange()` auto-fills address from waterhouse record
- `previewDocBuilder()` renders a print-quality HTML document with TWWP branding into an iframe modal (`docBuilderPreviewMo`)
- `printDocBuilder()` opens doc in new window and calls `window.print()` for PDF download
- `saveDocBuilderToDocs()` saves the generated document to the Documents library

### Task C — Upload to Drive via Rails
- `uploadDocBuilderToDrive(btn)` in the preview modal footer
- POSTs HTML file to `{railsApiUrl}/api/drive/upload` with Bearer token
- Shows `showDbToast()` — green on success (with Drive link if returned), red on failure
- If Rails not connected: alert explains the three setup steps
- Note: `/api/drive/upload` endpoint needs to be added to the Rails API

### Task D — KB import from Document Library
- "Import from Docs" button in the Knowledge Base tab header
- `openKBImportDocsMo()` lists all docs with checkboxes; docs without descriptions are disabled + greyed
- `kbImportSelectedDocs()` creates one KB entry per selected doc: title + type + description + notes as body, tags carried over, `always_inject: false`

---

## Session 11 changes (2026-03-23)

### Task 1 — Fix `/api/drive/upload` Rails endpoint
- Added `?fields=id,webViewLink,name` to Drive API multipart upload URL
- Changed default `mime_type` from `application/json` to `text/html`
- Returns clean `{ id, webViewLink, filename }` response
- Deployed to Fly.io

### Task 2 — Fix Google OAuth scope
- Changed `SCOPES` in `auth_controller.rb` from `drive.file` to full `drive` scope
- Deployed to Fly.io (same deploy as Task 1)

### Task 3 — Frontend drive upload fix
- `uploadDocBuilderToDrive()` now sends JSON `{filename, content, mime_type}` instead of FormData blob
- Uses `webViewLink` (not `url`) from the response for the "Open in Drive" link

### Task 4 — Maintenance → financial auto-create
- `completeMaintJob()` now auto-creates a `reimbursement` financial entry when `total > 0`
- Entry includes: type=reimbursement, category=Guardian Reimbursement, wh_id, contact_name, description, pay_method, status=pending
- Shows `showDbToast()` confirming entry created with amount

### Task 5 — Email Registry
- `emailRegistry` store added to KS (`twwp_email_v1`)
- Sidebar item "Email Registry" added under People section (`ni-emailregistry`)
- `page-emailregistry` page: list view with search + status filter
- Email compose modal: contact picker, subject, body, status, notes
- Three starter templates: Guardian Welcome, Maintenance Reminder, Reimbursement Approved
- `EMAIL_TEMPLATES` object with `{{name}}` / `{{amount}}` / `{{method}}` / `{{ref}}` substitution
- `renderEmailRegistry()`, `openEmailMo()`, `editEmail()`, `applyEmailTemplate()`, `saveEmail()`

### Task 6 — Campaigns page
- `campaigns` store added to KS (`twwp_campaigns_v1`)
- Sidebar item "Campaigns" added under Projects section (`ni-campaigns`)
- `page-campaigns` page: list view with search + stage filter
- Campaign modal: name, type, stage (6 stages), start/end, goal, owner, description, notes, delete button
- `CAMP_STAGES` and `CAMP_STAGE_COLORS` constants
- `seedCampaigns()` creates 2 demo campaigns on first visit
- `renderCampaigns()`, `openCampaignMo()`, `saveCampaign()`, `deleteCampaign()`

### Task 7 — Dashboard campaign + inventory panels (Row 8)
- Campaign panel: stage counts as coloured pills, most recent active campaign name + goal
- Inventory panel: 4 stats (parts, kits, active deployments, out-of-stock) as clickable cards
- Low stock warning shows if any items are at or below reorder qty
- Both panels sit in a 2-column row below the Organisations section

### Task 8 — Contact multi-tag roles (`twwp_roles`)
- New multi-checkbox `twwp_roles` field in contact modal (9 roles: Guardian, Host, Facilitator, Technician, Quencher, Sponsor, Supplier, Trustee, Member)
- `TWWP_ROLE_COLORS` map for coloured role badges on contact cards
- `ctGetRoles()`, `ctSetRoles()`, `ctToggleTrusteeFields()`, `ctCalcTermExpiry()`
- Contact cards now display role badges alongside the type badge
- Role filter now also matches `twwp_roles` array (in addition to `type`)
- `saveContact()` stores `twwp_roles` array

### Task 9 — Trustee-specific contact fields + Governance tab
- Contact modal shows `appointment_date`, `term_length`, `term_expiry` (auto-calculated) when Trustee role is checked
- `renderTrusteeSummary()` updated: includes contacts with `twwp_roles` containing 'Trustee', counts expired/expiring-soon terms, shows stat cards for those
- New `trusteeTarmCards` container in Governance tab shows trustee term cards with colour-coded expiry status (red=expired, amber=expires within 90 days)

---

---

## Session 12 changes (2026-03-23)

### Task 1 & 2 — Capture routing to real stores
- `saveCapture()` now creates real records when type matches:
  - **task** → `tasks` store (status: open, priority: normal) + toast "Task created — view in Tasks"
  - **lead** → `contacts` store (type: lead) + toast "Contact added — view in Contacts"
  - **campaign** → `campaigns` store (status: idea) + toast "Campaign idea added — view in Campaigns"
  - **project** → `projects` store (status: idea) + toast "Project idea added — view in Projects"
- Captures also saved for history regardless of type

### Task 3 — AI auto-classify on capture
- `classifyCapture(id)` runs in background (500ms delay) after every saveCapture()
- Calls `aiCallJSON()` with title + body, returns `{suggested_type, priority, tags, summary, suggested_action}`
- Results stored on capture record as `ai_suggested_type`, `ai_priority`, `ai_tags`, `ai_summary`, `ai_suggested_action`
- Developer → Captures table shows AI badge (cyan pill) next to title and AI priority warning if high/urgent

### Task 4 — Capture triage workflow
- `renderCapDetail()` redesigned: replaced triage dropdown with action buttons
- **Accept** → routes to natural home (task→Tasks, note→KB, feedback→Dev Tasks, rd→R&D, legal→Legal, campaign→Campaigns, lead→Contacts) — creates real records
- **→ KB** → promotes capture to Knowledge Base entry
- **Backlog** → existing Dev Tasks flow (unchanged)
- **Discard** → marks triage='discarded'
- Each action shows toast confirming destination
- Status column shows triage state + routed_to destination

### Task 5 — Capture Inbox card on Dashboard
- Row 9 added to Dashboard: amber badge with unreviewed count
- Lists 5 most recent unreviewed captures with type badge + date
- "Review All" button navigates to Developer → Captures
- Shows "All clear" when inbox is empty

### Task 6 — Global Approval Queue page
- "Approval Queue" sidebar item added at top of Operations section with badge counter
- `page-approvalqueue` with `renderApprovalQueue()`
- Aggregates: unreviewed captures, financial entries with no approval_status, maintenance jobs without sign_off_date
- Actions: Accept/KB/Discard (captures), Approve/Reject (financials), Sign Off (maintenance)
- `approveFinancialEntry()` sets `approval_status: 'approved'` + auto-creates calendar event for reimbursements
- `rejectFinancialEntry()` sets `approval_status: 'rejected'`
- `signOffMaintJob()` sets `sign_off_date`
- `updAQBadge()` called from `updStats()` — badge count updates automatically
- 'Financial' type added to CAL_TYPES

### Task 7 — Calendar auto-events from workflows
- `saveSchedDate()` auto-creates a calendar event when a maintenance schedule date is saved
- `approveFinancialEntry()` creates a calendar event when a reimbursement is approved
- `saveCampaign()` creates a calendar event when campaign status moves to 'active'

### Task 8 — Email Registry: Send via Rails
- Send button added to each non-sent email card in Email Registry list
- `sendEmail(id)` POSTs to `{railsApiUrl}/api/email/send` with JWT auth
- Shows sent status + sent_at date on card after success; marks 'failed' on error
- Rails API: new route `POST /api/email/send` → `Api::EmailController#send_email`
- Controller logs email details and returns `{status:'ok'}` (placeholder — real SMTP later)

### Task 9 — R&D: Promote validated idea to Project
- R&D cards now show "Promote to Project" button when status is 'validated'
- `promoteRDToProject(id)` creates a project record (type: research, status: planning) pre-filled with R&D title/body
- Marks R&D item as 'promoted' with `promoted_to_project: true`
- Toast: "Project created from R&D idea"

---

## Session 13 changes (2026-03-23) — Tasks 1–5 of 10

### Task 1 — Fix calendar CRUD (live bug resolved)
- Defined `openCalEventMo(date, type, whId, title)` — opens modal for new event
- Defined `editCalEvent(id)` — opens modal pre-filled for editing
- Defined `saveCalEvent()` — upserts into calEvents store, re-renders calendar
- Defined `deleteCalEvent(id)` — confirm + remove from store
- Added `calEditId` state variable
- Added `populateCeWh()` — populates waterhouse dropdown in modal
- Modal updated: recurrence select (None/Daily/Weekly/Monthly/Yearly), Delete button (hidden on create)
- Event type dropdown updated: added Financial, Meeting, Reminder, Reimbursement, Personal
- Removed two duplicate `renderCalendar()` definitions (was 3, now 1)

### Task 2 — Calendar week/day views + categories
- `calState` extended with `view`, `weekDate`, `dayDate` fields
- `renderCalendar()` is now a dispatcher → `renderCalMonth()`, `renderCalWeek()`, `renderCalDay()`
- View switcher pills (Month / Week / Day) added above source filter
- **Today** button added to month nav bar
- `setCalView()` and `calNavToday()` functions added
- `calNav()` updated to navigate correctly per view (month: +/-1 month, week: +/-7 days, day: +/-1 day)
- Week view: 7-column grid, today highlighted in cyan, event chips per column
- Day view: event list with type + time, Edit button for manual events
- Week/day container (`calWeekDayView`) shows/hides based on view
- New `CAL_TYPES` entries: Reimbursement (amber), Meeting (blue), Reminder (cyan), Personal (grey)

### Task 3 — Calendar multi-provider connection panel
- **Connect button** added to calendar page header → opens `calProviderMo`
- Modal shows 4 providers: Google Calendar (actionable), iCloud / Proton / Outlook (Coming soon)
- `connectGoogleCal()` — checks for existing OAuth token, marks provider as connected, triggers sync
- `syncGoogleCal()` — fetches events from Google Calendar API (primary calendar, 90-day window), deduplicates by `gcal_id`, imports as calEvents
- `disconnectCalProvider(name)` — removes provider from `twwp_cal_providers` localStorage
- `updateCalProviderUI()` — updates connected/disconnected state in modal
- Provider state stored in `localStorage.twwp_cal_providers`

### Task 4 — Events Ledger store + global logEvent()
- `eventLedger: 'twwp_ledger_v1'` added to KS store map
- `ledgerEnabled` flag (default true) — can be paused
- `logEvent(category, action, detail, meta)` — writes entries to eventLedger store; never throws; caps at 5000 entries in-memory
- Wired into: `saveTask` / `deleteTask`, `saveContact` / `delContact`, `saveCalEvent`, `doLogin`, `doLogout`, `aiCallJSON`, `go()` (light nav logging)

### Task 5 — Events Ledger page
- `page-eventledger` HTML page added (admin-only, under Dev section)
- Sidebar item: Events Ledger (🗒 icon, `ni-eventledger`, hidden from non-admin)
- `renderEventLedgerPage()` — filterable table (category, text search, date), stats bar (total/today/AI calls/top cat/size), storage % bar
- `toggleLedger()` — Pause/Resume recording with visual badge update
- `clearLedger()` — confirm + clear all entries
- `exportLedger()` — CSV download
- `clearLedgerFilters()` — resets all filters
- Table shows up to 500 rows; pagination note when truncated
- `CAT_COLORS` colour map for category badges

### Task 6 — Resource usage bar
- Fixed bar above capture FAB (capture FAB moved from bottom:24px to bottom:32px)
- Shows: localStorage % with colour-coded mini-bar (green/amber/red), last Rails sync age, AI calls today, ledger events today with recording indicator dot, Google Drive connection dot
- Collapses to 4px strip on click; hover re-expands; collapsed state persisted in localStorage
- `updateResourceBar()` called from `updStats()` and every 60s via `setInterval`
- `toggleResourceBar()` toggles collapsed state

### Task 7 — Calendar + Ledger integration (activity dots)
- `toggleCalActivityLog()` — Activity toggle button in calendar header; persists in `twwp_cal_activity_log`
- `renderCalMonth()` now reads ledger and builds `ledByDate` map (nav events excluded)
- Cyan dot appears on calendar dates that have ledger entries when Activity mode is on
- Clicking dot opens `ledgerPopover` — floating popover showing up to 20 entries for that date with category badge + time + detail
- `showLedgerPopover(el, dateStr)` — positions popover near the clicked dot, prevents outside click propagation

### Task 8 — Ledger auto-purge + storage management + Rails sync
- `saveLedgerSettings()` / `loadLedgerSettings()` — max days (default 90) and max entries (default 5000) persisted in localStorage
- `purgeLedger()` — manual purge: removes entries older than max days and trims to max entries
- `autoPurgeLedger()` — runs silently on `initApp()` startup
- Settings UI in Events Ledger page: two inputs + Purge Now button
- `syncLedgerToRails()` — POSTs up to 1000 entries to `POST /api/ledger/sync`
- Rails API: `POST /api/ledger/sync → Api::LedgerController#sync` (placeholder, logs count)
- Route added to `config/routes.rb`

### Task 9 — Recurring calendar events
- `getUnifiedCalItems()` now expands recurring events within the calendar view range
- Supported frequencies: daily, weekly, monthly, yearly
- Each expansion gets a unique composite ID (`baseId_date`); chip clicks resolve to the base event for editing
- ↻ indicator on chips for recurring instances
- Expansion is view-range-bounded (month/week/day) with a 400-iteration safety cap
- `calState` already had the view/weekDate/dayDate fields needed for range calculation

---

---

## Session 14 changes (2026-03-23) — SPEC_VERSION 4.4

### Task 1 — Calendar header buttons wired
- Sync (↻) calls `doCalHeaderSync()`: triggers `calSyncAll()`, re-renders, fetches Google Calendar API if provider connected
- Activity (📓) calls `toggleCalActivityLog()` (was already defined, button onclick was wrong)
- + Event calls `openCalEventMo()` (already defined, button was missing onclick)
- 🔗 Connect calls `openCalProviderPanel()` (already defined, button was missing onclick)
- All 4 buttons also have `data-tip` attributes for the tooltip system

### Task 2 — Global tooltip system
- `#globalTip` div added before resource bar; CSS added for positioning + fade
- `initGlobalTooltip()` called from `initApp()` — listens for `mouseover` on `[data-tip]` elements
- 800ms hover delay before showing; clears on mouseout or click
- Positions near cursor with overflow-prevention (stays within viewport)
- `data-tip` added to all major action buttons across all pages

### Task 3 — Tasks → Calendar auto-sync
- `syncTaskToCalendar(src, taskId)` — creates or updates a calendar event linked to a task via `_task_id` field
- Called from `saveTask()` (pre-calculates taskId before upsert), `deleteTask()`, `saveDevTask()`, `delDevTask()`
- Tasks with no due date or status=complete/cancelled have their calendar event removed
- Calendar events tagged with `_auto:true`; title prefixed `[Dev]` for dev tasks
- Event type: "Task Due" or "Dev Task Due" (colour-coded)

### Task 4 — Event Ledger multi-select filter
- Category and action dropdowns replaced with checkbox multi-select panels
- `toggleLedgerDropdown(type)` opens/closes dropdown with outside-click dismissal
- `saveLedgerFilterState()` / `loadLedgerFilterState()` persist selection to `twwp_ledger_filter_v1`
- `renderEventLedgerPage()` reads checked boxes for filtering (supports all checked = show all)

### Task 5 — SPEC_GROWTH populated
- 12+ entries added covering sessions 1–14 (newest first)
- Runtime override from `twwp_spec_growth_v1` localStorage merged on render

### Task 6 — SPEC_ADRS populated
- 11 ADRs added (ADR-001 through ADR-011):
  Single-file architecture, Rails API, PKCE, GitHub Pages, localStorage, JWT, Postgres sync, mammoth.js, Drive proxy, multi-org (deferred), Event Ledger 5000-entry cap

### Task 7 — Date Wizard modal
- `openDateWizard(title, callback)` — opens `dateWizardMo` modal with preset buttons
- Presets: Today / This Week / This Month / This Year / Custom date picker
- Callback receives YYYY-MM-DD string; used for backlog scheduling and task due dates

### Task 8 — Completion Note modal
- `openCompletionModal(title, confirmMsg, callback)` — opens `completionNoteMo` modal
- Optional note textarea + auto-filled ISO timestamp
- `confirmCompletion()` calls callback with (note, timestamp)
- Wired into `toggleDevTask()` for dev task completion

### Task 9 — Backlog → Calendar scheduling
- `renderDevBacklog()` rewritten with filter pills: All / Scheduled / Overdue
- `scheduleBacklogItem(id, title)` calls `openDateWizard()` then saves to `twwp_backlog_scheduled_v1` and creates a calendar event with `_backlog_id`
- Scheduled items show calendar badge; overdue items highlighted red

### Task 10 — Dev Tasks: seed ALL backlog groups
- `syncBacklogToDevTasks()` rewritten to iterate ALL `BACKLOG_GROUPS` (A–V)
- Only adds items not already present (idempotent); returns count of newly added
- `seedDevTasks()` calls `syncBacklogToDevTasks()` on every init
- "Re-sync Backlog" button added to Dev Tasks page header

### Task 11 — Dev History: addGrowthEntry, Log Session, Import
- `addGrowthEntry(date, by, summary)` — prepends to `twwp_spec_growth_v1` localStorage
- `openSessionLogModal()` / `saveSessionLog()` — manual session log modal with date + author + summary
- `aiExtractSessionSummary()` — paste session text → AI extracts structured entry via `aiCallJSON()`
- Log Session + Import buttons appear in Dev History tab header via `updateDevPageActions()`

### Task 12 — DEVNOTES populated for all pages
- Added DEVNOTES entries for: calendar, campaigns, emailregistry, docbuilder, approvalqueue, eventledger, locations, inventory, kits, deployments, reports, monitor, member
- All 15+ pages now have descriptive dev notes in the slide-out panel

### Task 13 — Sprint session logger
- `updateDevPageActions(tab)` called from `switchDevTab()` and `renderDevPage()`
- Injects context-sensitive action buttons into `devPageActions` div
- History tab: Log Session + Import; KB tab: + Entry + Import from Docs; others: empty

### Task 14 — data-tip tooltip pass on all pages
- `data-tip` attributes added to: Maintenance + Log Job, Contacts + Add Contact, Projects + New Project, Financials + Log Entry, Email + Compose, Campaigns + New Campaign, Reports + New Report, Locations + Add Location, Re-sync Backlog, Dev Tasks + button, Dashboard Refresh, Calendar all 4 header buttons

### Task 15 — Recurring event edit flow
- `editCalEvent(id)` now detects composite IDs (`baseId_YYYY-MM-DD`), checks if base event is recurring
- If recurring: opens `recurEditMo` modal with 3 options: This event only / This and future / All events
- `recurEditMode(mode)` handles single (creates exception date record), future (updates start date + clears recurrence note), all (edits base event directly)
- `openCalEventEditor(id)` extracted from editCalEvent — does actual modal population
- `getNextOccurrences(ev, count)` returns next N occurrence strings for display

### Task 16 — Approval Queue expanded
- `getAQItems()` now also pulls: contacts (type=lead or unverified), R&D captures (validated, not promoted), email drafts, campaign ideas
- `renderApprovalQueue()` handles all new types with per-type action buttons
- `aqVerifyContact(id)` sets contact status='active'; `aqMoveCampaignToPlanning(id)` moves stage to planning
- Type colour map expanded

### Task 17 — Dashboard live data
- Dashboard already pulls live data from all stores; confirmed all panels populated
- `dashLastUpdated` span added to page header showing last refresh time
- Dashboard Refresh button gets `data-tip`

### Task 18 — Resource bar expanded
- Session duration: `twwp_session_start` stored in sessionStorage on login (both Rails + local paths)
- New resource bar items: ⏱ session duration, ✅ tasks completed today (from ledger), 📷 captures today, service dots (Rails/Drive/AI/HA)
- Service dots are clickable → navigates to AI & Integrations page
- `openRbSettings()` / `toggleRbItem()` — gear icon opens settings panel; each item individually show/hide-able
- Settings persisted in `twwp_rb_cfg_v1` localStorage

### Task 19 — Global search (Ctrl+K)
- `Ctrl+K` (or Cmd+K) opens `globalSearchMo` — full-width search modal
- `runGlobalSearch(q)` searches: tasks, contacts, financials, documents, captures, campaigns, inventory, knowledge base, projects
- Results grouped by store with icon + label; click to navigate to that page
- Arrow key navigation through results; Enter selects; Escape closes
- Search events logged to ledger as `nav / search`
- `escH()` helper for XSS-safe HTML rendering of search results

### Task 20 — Version bump + docs
- `SPEC_VERSION` updated to `'4.4'`
- `SPEC_LAST_UPDATED` updated to `'2026-03-23'`

---

---

## Session 15 changes (2026-03-23) — SPEC_VERSION 4.5

### Task 1 — Tooltip audit and sidebar data-tip pass
- All 35 sidebar items now have `data-tip` attributes with descriptive tooltips
- Tooltips cover: Overview/Dashboard, all operational pages, developer tools, admin pages
- Format: `"PageName — one-line description of what the page does"`

### Task 2 — Calendar +Event button wired; Add-to-Calendar in Dev Tasks
- Calendar header "+ Event" button now uses `openDateWizard()` first, then `openCalEventMo(date)`
- Dev Tasks list: each task row with a due date now shows a calendar icon button (📅) — calls `syncTaskToCalendar('devtask', id)` on click
- One-time backfill on load: `backfillDevTasksToCalendar()` runs in `initApp()` via setTimeout — creates calendar events for all dev tasks that have due dates but no linked calendar event

### Task 3 — Persistence banner in Growth Log / ADRs
- `#growthPersistBanner` added to SPEC_GROWTH tab — shows count of localStorage-only entries
- `#adrsPersistBanner` added to SPEC_ADRS tab — shows count of localStorage-only ADRs
- "📋 Copy for Claude Code" button on each banner — formats user-added entries as JSON and copies to clipboard
- `updatePersistBanners()` called from `switchSpecTab()` and on app init (800ms delay)
- `copyGrowthForClaude()` / `copyAdrsForClaude()` helper functions

### Task 4 — SPEC_GROWTH backfilled (sessions 1–3, date gaps fixed)
- Sessions 1a, 1b, 2a, 2b, 3a added covering 2026-03-10 to 2026-03-12 (base build, spec planning, scaffolding)
- Sessions 5, 6, 7 split into individual entries (were merged as one block)
- Session 15 entry added at top: all 10 tasks summarised
- Total SPEC_GROWTH: 16 entries (sessions 1a through 15)

### Task 5 — Resource bar: tasks from stores + ↑X created-today indicator
- Tasks-done count now reads directly from `tasks` + `devtasks` stores (checks `status==='complete'` + `completed_at` date match), falls back to ledger count
- New ↑X indicator: shows count of tasks created today in cyan text beside the tasks-done count
- `tasksCreatedToday` reads `created` field from both stores filtered to today's date

### Task 6 — Onboarding Wizard (7-step first-run setup)
- `#onboardingWizard` overlay: full-screen dark modal, progress bar, step label, content area, Back/Next buttons, ✕ skip
- `OW_STEPS` array: 7 step objects each with `render()` and `save()` methods
  - Step 1 Welcome: org name, admin name, purpose dropdown
  - Step 2 Branding: app name, brand colour picker, logo URL
  - Step 3 First Location: location name, address, type
  - Step 4 AI Assistant: Gemini / Anthropic / OpenAI key fields with model selectors
  - Step 5 Integrations: Rails API URL, Cloudflare proxy URL, Drive folder ID
  - Step 6 Team: first team member name + email (creates contact record)
  - Step 7 Done: summary of what was configured, "Launch App" button
- `checkRunOnboarding()` fires if neither `twwp_setup_complete` nor `twwp_onboarding_skip` is set
- `openOnboarding()`, `skipOnboarding()`, `renderOwStep()`, `owStep(dir)` — wizard lifecycle functions
- Config saved to `twwp_org_config_v1`; completion flag set in `twwp_setup_complete`

### Task 7 — Persistent setup status checklist (Dashboard card)
- `SETUP_KEYS` map: 9 dimensions (org_name, branding, first_location, ai_key, google_calendar, google_drive, rails_api, first_team_member, esp32_config, stripe_config)
- `getSetupStatus()` / `setSetupStatus(key, val)` — read/write `twwp_setup_status_v1` localStorage
- `renderSetupStatusCard()` — renders progress bar + checklist into `#setupStatusCard`
- Dashboard shows card only for admin users with incomplete setup (hides when all 9 complete)
- `updateSetupStatusCard()` called from `updStats()` for live refresh

### Task 8 — Contextual setup interrupts
- `requiresSetup(featureName, setupKey, wizardStep)` — checks setup status; if missing, confirms with user then opens wizard at the relevant step
- Wired into:
  - `syncGoogleCal()` → checks `google_calendar` (wizard step 5)
  - `uploadDocBuilderToDrive()` → checks `google_calendar` (wizard step 5)
  - `sendEmail()` → checks `rails_api` (wizard step 5)
  - `sendAIHelperMsg()` → checks `ai_key` (wizard step 4) if no key configured

### Task 9 — Multi-org foundation: org_config + terminology
- `org_config` store added to KS map (`twwp_org_config_v1`)
- `DEFAULT_TERMINOLOGY` map: waterhouse, guardian, quencher, wh_id, locations_page, monitor_page
- `getOrgCfg()` / `saveOrgCfg(c)` — read/write org config
- `getTerm(key)` — returns terminology value from org_config, falling back to DEFAULT_TERMINOLOGY
- `initOrgConfig()` — called from `initApp()`: applies brand colour + updates sidebar labels for Locations + WH Monitor
- Terminology editor added to AI & Integrations modal — 6 fields, Save button
- `renderTerminologyEditor()` / `saveTerminology()` functions

### Task 10 — SPEC_VERSION 4.5 + SPEC_ADRS + BACKLOG_GROUPS GROUP W
- `SPEC_VERSION` → `'4.5'`, `SPEC_LAST_UPDATED` → `'2026-03-23'`
- 3 new ADRs: ADR-012 (Onboarding wizard as first-run flow), ADR-013 (Setup status checklist), ADR-014 (org_config as multi-tenancy stub)
- BACKLOG_GROUPS GROUP W added: 10 items covering onboarding, setup checklist, requiresSetup, org_config, user management, feature flags, white-label export, onboarding analytics, ESP32 config, Stripe config steps

---

---

## Sprint A changes (2026-03-23) — SPEC_VERSION 4.6

### A1 — Tooltip event delegation fix
- Fixed `initGlobalTooltip()` mouseout bug: tooltip was hiding when mouse moved between child elements (e.g. `sb-icon` → `sb-lbl` within an `sb-item`).
- Fix: `if(el.contains(e.relatedTarget)) return;` in mouseout handler.
- Added `_current` guard — no timer restart when already showing for same element.
- Added `data-tip` to dynamically created "Clear Demo Data" sidebar button.

### A2 — Calendar startup backfill
- Added `backfillDevTasksToCalendar()` — wraps `calSyncAll()`, runs deferred 1.5s after `initApp()`.
- Ensures tasks with due dates get calendar events even if stores load after initial render.

### A3 — SPEC constants updated
- SPEC_VERSION → `4.6`, SPEC_GROWTH Sprint A entry added, ADR-015 added, BACKLOG GROUP X added.

### A4 — Email Provider Picker UI
- `emailProviderMo` modal: Gmail OAuth (one click), Outlook OAuth (client ID + stub), IMAP/SMTP manual form (host/port/user/pass), Proton coming-soon banner.
- Test Connection button for IMAP calls Rails `/api/email/connect/imap`.
- Polling interval selector: 2min / 5min / 15min / 1hr / 6hr / 24hr.
- Config in `twwp_email_config_v1` localStorage + `org_config.email_config`.
- Provider status banner on Email Registry page header.

### A5 — Rails unified EmailService
- `app/services/email_service.rb` — routes to Gmail REST API, Microsoft Graph API, or Net::IMAP/SMTP.
- New routes: `GET /api/email/inbox`, `POST /api/email/connect/imap`.
- `POST /api/email/send` updated — now routes via EmailService.
- Deployed to Fly.io ✅.

### A6 — Email Inbox page
- Sidebar: "Email Inbox" (📬) under People, with unread badge (`inboxBadge`).
- Page: thread list, search, unread/read filter, auto-poll on first visit.
- Sender auto-matched to contacts by email; "+ Add Contact" for unknowns.
- Manual refresh button.

### A7 — AI Suggested Replies
- Email thread view modal: full body, contact card, AI Reply panel.
- Reply tone: Professional / Friendly / Brief — saved to `org_config.ai_reply_tone`.
- `generateAiReply()` — message + contact + KB context → AI provider (all 4 providers supported).
- `sendAiReply()` — sends via Rails + logs to emailRegistry store.

---

## Next up

1. **Outlook OAuth PKCE flow** — `connectEmailOutlook()` stores client ID but doesn't initiate OAuth. Needs Rails `/api/email/connect/outlook` endpoint (BACKLOG X7).
2. **Gmail email scope** — existing OAuth token has `drive` scope only; re-auth needed for Gmail API (`gmail.send` + `gmail.readonly`).
3. **Persist IMAP config on Fly.io** — set `TWWP_EMAIL_CONFIG` env var: `fly secrets set TWWP_EMAIL_CONFIG='...'`
4. **Email thread grouping** — show full conversation threads (BACKLOG X6).
5. **Re-authorise Google OAuth** — scope was already changed `drive.file` → `drive`; email scopes also needed now.
6. **User management page** (admin only) — invite, deactivate, change role.
7. **Ledger Rails endpoint persistence** — add `ledger_entries` table to Rails.
8. **Activate Drive auto-backup on logout** — unblocked by OAuth scope fix.

See `docs/handoff/session-handoff-march23i.md` for Sprint A full summary.
