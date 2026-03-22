# TWWP Ops App — Sprint Handoff
## Sprint: March 23, 2026 (Session 12)
## Status: 9 feature tasks shipped

---

## What was built this session

### Task 1 & 2 — Capture routing to real stores

`saveCapture()` now creates real records in the target store when the type implies one:

| Capture type | Store created | Toast |
|---|---|---|
| task | tasks (status: open, priority: normal) | "Task created — view in Tasks" |
| lead | contacts (type: lead) | "Contact added — view in Contacts" |
| campaign | campaigns (status: idea) | "Campaign idea added — view in Campaigns" |
| project | projects (status: idea) | "Project idea added — view in Projects" |
| note / feedback / rd / legal | captures only (existing behaviour) | — |

Captures are always saved for history regardless of type.

---

### Task 3 — AI auto-classify on capture

`classifyCapture(id)` runs 500ms after every save (background, non-blocking):
- Calls `aiCallJSON()` with title + body
- Returns `{suggested_type, priority, tags, summary, suggested_action}`
- Stored on the capture record as `ai_*` fields
- Developer → Captures table shows a cyan AI badge next to the title; amber `[urgent]`/`[high]` priority tag if elevated

Silently skips if no AI key is configured.

---

### Task 4 — Capture triage workflow

Developer → Captures triage UI redesigned:

| Button | Action |
|---|---|
| ✓ Accept | Routes to natural home; creates real records (same logic as Tasks 1–2) + marks triage='accepted' |
| → KB | Creates Knowledge Base entry from title + body + AI tags |
| Backlog | Existing flow — creates Dev Task (unchanged) |
| Discard | Sets triage='discarded' |
| Del | Permanently removes the capture |

Status column now shows triage state badge + routed_to destination. Accept/Discard/KB buttons hidden once item is already accepted or discarded.

---

### Task 5 — Capture Inbox card on Dashboard

Dashboard Row 9 — Capture Inbox panel:
- Amber badge showing unreviewed count
- List of 5 most recent unreviewed items with type icon + title + date
- "Review All" button → Developer → Captures
- Shows "All clear ✓" when empty

---

### Task 6 — Global Approval Queue page

New sidebar item "Approval Queue" (Operations section, top) with auto-updating badge.

Page aggregates three categories:
1. **Unreviewed captures** — triage undecided/empty
2. **Financial entries** — no `approval_status` or status='pending'
3. **Maintenance jobs** — no `sign_off_date`

Actions:
- Captures: Accept / → KB / Discard (delegates to capture triage functions)
- Financials: Approve (sets `approval_status: 'approved'` + creates calendar event for reimbursements) / Reject
- Maintenance: Sign Off (sets `sign_off_date`)

Badge updated via `updAQBadge()` called from `updStats()`.

---

### Task 7 — Calendar: auto-events from workflows

Three new auto-calendar-event triggers:

1. **Maintenance schedule saved** (`saveSchedDate()`) — calendar event created for the scheduled date
2. **Reimbursement approved** (`approveFinancialEntry()`) — calendar event: "Reimbursement approved — [contact]" type='Financial'
3. **Campaign moves to active** (`saveCampaign()`) — calendar event: "Campaign launched: [name]" type='Marketing / Campaign', date = campaign start date

'Financial' type added to CAL_TYPES with green colour.

---

### Task 8 — Email Registry: Send via Rails

Send button added to every non-sent email card in Email Registry.

`sendEmail(id)`:
- POSTs `{to, subject, body, contact_name}` to `{railsApiUrl}/api/email/send` with Bearer JWT
- On success: sets status='sent', records sent_at date, re-renders list
- On failure: sets status='failed', shows error toast

**Rails API changes:**
- New route: `POST /api/email/send → Api::EmailController#send_email`
- Controller: `~/twwp-ops-api/app/controllers/api/email_controller.rb`
- Placeholder implementation — logs email to Rails logger, returns `{status: 'ok'}`
- SMTP not yet configured — real delivery can be added later with ActionMailer

**To deploy:** `cd ~/twwp-ops-api && fly deploy`

---

### Task 9 — R&D: Promote validated idea to Project

R&D cards now show a "🚀 Promote to Project" button when status is 'validated'.

`promoteRDToProject(id)`:
- Creates project record: type=research, status=planning, pre-filled with R&D title + body + AI tags
- Marks R&D capture as status='promoted', promoted_to_project=true
- Toast: "Project created from R&D idea"

---

## Current integration status

| Service | Status | Notes |
|---|---|---|
| Rails API JWT login | ✅ Working | POST /auth/login, 30-day JWT |
| Rails API data sync | ✅ Working | PUT/GET /api/sync |
| Rails API Drive upload | ✅ Fixed | Returns id + webViewLink |
| Rails API email send | ⚠️ Placeholder | Route + controller added; `fly deploy` needed; SMTP not wired |
| Google Drive (read-only) | ✅ Working | API key + folder ID |
| Google Drive (OAuth read/write) | ⚠️ Re-auth needed | Scope changed to `drive` — reconnect required |
| Cloudflare Worker | ✅ Deployed | /token, /refresh, /health |
| AI — Gemini | ✅ Working | gemini-2.5-flash |
| AI — Anthropic | ✅ Working | claude-haiku-4-5 |
| AI — OpenAI | ✅ Working | gpt-4o-mini |
| AI — OpenRouter | ✅ Working | |
| Home Assistant | ⚠️ Partial | Fields saved, no live test button |
| GitHub Actions deploy | ⚠️ Pending | Flip Pages source to GitHub Actions in repo settings |

---

## Known open bugs / stubs

| ID | Description |
|---|---|
| A1 | Google OAuth Drive scope — changed to `drive`; re-auth resolves |
| A7 | `dtk_I1` dev task seeded twice (minor) |
| A9 | Old OAuth tokens with `drive.file` scope will fail Drive operations |
| NEW | `openCalEventMo` / `saveCalEvent` / `editCalEvent` / `deleteCalEvent` — referenced in calendar UI but never defined; + Event button and chip clicks will throw ReferenceError |

---

## Recommended next task queue

### Immediate (unblock Rails email)
1. `cd ~/twwp-ops-api && fly deploy` — deploy the new email endpoint
2. Configure real SMTP in ActionMailer (or use a sendgrid/postmark API key)
3. Re-connect Google OAuth — re-authorise with new `drive` scope

### High priority
4. **`openCalEventMo` / `saveCalEvent` / `editCalEvent`** — implement these calendar CRUD functions (modal HTML exists at line ~755, functions are referenced but never defined — this is a live bug)
5. **User management page** (admin only) — invite user, deactivate, change role; POST/PUT `/api/users` endpoints needed
6. **Activate Drive auto-backup on logout** — code written, unblocked by OAuth scope fix
7. **Flip GitHub Pages source to GitHub Actions** — repo Settings → Pages → Source → GitHub Actions

### Near-term features
8. **Wire `callModelForFeature()`** into autofill, import wizard, classify
9. **Wire Receipt Inbox AI Parse tab** — tab exists but no AI call
10. **Home Assistant test connection button**
11. **Campaigns → Email Registry link** — "Send email to contacts" from campaign view
12. **Multi-device sync activation** — unblocked by OAuth fix

---

## LocalStorage stores (31 keys)

```
items, accounts, locations, inbox, kits, deps,
maintJobs, calEvents, monitorData, reports, contacts,
projects, rd, legal, financials, captures, tasks,
devtasks, inventory, purchase_orders, shop_destinations,
shop_listings, services, assets, ppsr, docs,
workflow_flags, knowledgeBase, emailRegistry, campaigns
```
(rd and legal are virtual — filtered views of captures store)

---

## Repo and file locations

| What | Path |
|---|---|
| Frontend repo | `~/twwp-project/TWWP-opps-app/` |
| Main file | `~/twwp-project/TWWP-opps-app/index.html` (~10,700 lines) |
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
