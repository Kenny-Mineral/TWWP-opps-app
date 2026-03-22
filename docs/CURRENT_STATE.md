# TWWP Ops App — Current State

**Last updated:** 2026-03-23 (session 10)

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

## Next up

1. Flip GitHub Pages source to GitHub Actions (manual step: repo Settings → Pages → Source → GitHub Actions)
2. Add `/api/drive/upload` endpoint to Rails API (accepts multipart HTML, uploads to Drive)
3. Resolve Google OAuth `drive.file` scope (external blocker — see known-issues A1)
4. `dtk_I1` duplicate seed (minor)
5. User management page (admin only) — invite, deactivate, change role
6. `callModelForFeature()` — wire into autofill and import wizard
