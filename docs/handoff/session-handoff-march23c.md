# TWWP Ops App — Session Handoff
## Session: March 23, 2026 (Session 11)
## Status: Drive upload fixed, OAuth scope updated, Email Registry + Campaigns built, contact roles + trustee terms added

---

## What was done this session

### Task 1 — Fix `/api/drive/upload` Rails endpoint

**File:** `~/twwp-ops-api/app/controllers/api/drive/files_controller.rb`

- Added `?fields=id,webViewLink,name` to the Drive multipart upload URL
- Changed default `mime_type` from `application/json` to `text/html`
- Returns clean `{ id: ..., webViewLink: ..., filename: ... }` instead of raw Drive response

**File:** `index.html` — `uploadDocBuilderToDrive()`

- Now sends JSON `{ filename, content, mime_type }` instead of FormData blob
- Uses `data.webViewLink` (not `data.url`) for the "Open in Drive" link

### Task 2 — Fix Google OAuth scope

**File:** `~/twwp-ops-api/app/controllers/auth_controller.rb`

- Changed `SCOPES` from `drive.file` to full `drive` scope
- Both changes deployed to Fly.io in one `fly deploy`
- **User action needed:** anyone who previously connected via Google OAuth must re-authorise (Settings → AI & Integrations → Connect via Rails API)

### Task 3 — Maintenance → financial entry auto-creation

**File:** `index.html` — `completeMaintJob()`

- After saving the job, if `total > 0`, auto-creates a `reimbursement` entry in `financials`
- Finds matching contact by `performed_by` name (case-insensitive)
- Shows `showDbToast()` confirming amount
- Entry: type=reimbursement, category=Guardian Reimbursement, status=pending

### Task 4 — Email Registry

New store: `emailRegistry` → `twwp_email_v1` in KS map

**Sidebar:** "Email Registry" (`ni-emailregistry`) under People section

**Page:** `page-emailregistry`
- Search + status filter (draft / sent / failed)
- Cards with left-border colour by status
- `renderEmailRegistry()`

**Modal:** `emailMo`
- Template selector (Guardian Welcome, Maintenance Reminder, Reimbursement Approved)
- Contact picker, subject, body textarea, status, notes
- `applyEmailTemplate()` does `{{name}}` / `{{amount}}` / `{{method}}` / `{{ref}}` substitution
- `saveEmail()`, `editEmail(id)`, `openEmailMo(id?)`

### Task 5 — Campaigns page

New store: `campaigns` → `twwp_campaigns_v1` in KS map

**Sidebar:** "Campaigns" (`ni-campaigns`) under Projects section

**Page:** `page-campaigns`
- Search + stage filter (6 stages: planning / outreach / active / review / complete / archived)
- `CAMP_STAGES` and `CAMP_STAGE_COLORS` constants
- `seedCampaigns()` inserts 2 demo campaigns on first visit
- `renderCampaigns()`, `openCampaignMo(id?)`, `saveCampaign()`, `deleteCampaign()`

**Modal:** `campaignMo`
- Name, type (6 options), stage, start/end dates, goal, owner, description, notes
- Delete button shown when editing

### Task 6 — Dashboard campaign status panel

Added to Row 8 of `renderDashboard()`:
- Left panel: campaign stage counts as coloured pills + most recent active campaign name/goal
- "View All →" link to Campaigns page

### Task 7 — Dashboard inventory summary panel

Added to Row 8 (right panel):
- Stats: total catalogue parts, kits, active deployments, out-of-stock items
- Each stat is a clickable card → navigates to relevant page
- Low-stock warning if any items are at or below reorder qty

### Task 8 — Contact multi-tag roles (`twwp_roles`)

**Contact modal:** new multi-checkbox section with 9 roles:
Guardian, Host, Facilitator, Technician, Quencher, Sponsor, Supplier, Trustee, Member

**New JS:**
- `TWWP_ROLE_COLORS` — colour map for role badges
- `ctGetRoles()`, `ctSetRoles(roles)`, `ctToggleTrusteeFields()`, `ctCalcTermExpiry()`
- Role checkboxes trigger `ctToggleTrusteeFields()` on change
- `saveContact()` stores `twwp_roles` array

**Contact cards:** role badges displayed alongside the type badge

**Filter:** `renderContacts()` now matches on `twwp_roles` array as well as `type`

### Task 9 — Trustee-specific contact fields

**Contact modal:** when Trustee role is checked, shows:
- `appointment_date` (date input)
- `term_length` (years, number input)
- `term_expiry` (auto-calculated, readonly — `appt_date + term_length years`)

**Governance tab:** `renderTrusteeSummary()` updated:
- Now includes contacts with `twwp_roles.includes('Trustee')` as well as `type==='trustee'`
- Counts and shows stat cards for expired terms and terms expiring within 90 days
- New `trusteeTarmCards` container in Governance tab HTML shows per-trustee cards with colour-coded expiry (red=expired, amber=<90 days, purple=ok)

---

## Deployment

Both Rails changes deployed in one `fly deploy`:
- `auth_controller.rb` — new SCOPES constant
- `api/drive/files_controller.rb` — fixed upload action

No migrations required.

---

## Next tasks (priority order)

1. **Re-connect Google OAuth** — users must re-authorise with new `drive` scope
2. **Test Drive upload end-to-end** — Doc Builder → Preview → Upload to Drive
3. **Flip GitHub Pages source to GitHub Actions** (manual: repo Settings → Pages → Source → GitHub Actions)
4. **`dtk_I1` duplicate seed** (minor)
5. **User management page** (admin only) — invite, deactivate, change role
6. **`callModelForFeature()`** — wire into autofill and import wizard
7. **Wire Receipt Inbox AI Parse tab**
8. **Campaigns → link to email registry** — create/send email from campaign view

---

## Stubs and partial features (not changed this session)

- Drive auto-backup on logout — code written, now unblocked by scope fix
- Silent sync from server on login — code written, now unblocked
- HA test connection
- Slack / Zapier webhooks

---

## Key file locations

| What | Path |
|------|------|
| Frontend | `~/twwp-project/TWWP-opps-app/index.html` |
| Rails drive upload | `~/twwp-ops-api/app/controllers/api/drive/files_controller.rb` |
| Rails OAuth | `~/twwp-ops-api/app/controllers/auth_controller.rb` |
| Live app | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Rails API | https://twwp-ops-api.fly.dev |
