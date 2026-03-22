# TWWP Ops App — Current State

**Last updated:** 2026-03-23 (session 8)

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

## Next up (Sprint 1 remaining)

- Fix Contacts CSV import (shows alert — GROUP A)
- Wire `sendRptChatMsg()` using `sendAIHelperMsg()` pattern
- Wire `updateFinForm()` field show/hide
- GitHub Actions auto-deploy (GROUP S)
