# TWWP Ops App — Build Backlog

**Last updated:** 2026-03-23 (session 15)

**Labels:** `[EXPLICIT]` `[IMPLIED]` `[FIX]` `[OPEN]` ✅ done

---

## GROUP A — Bug Fixes

- ✅ `[FIX]` Remove duplicate `buildRptFormModal` + `closeRptFormMo` — already resolved in current file
- ✅ `[FIX]` .docx AI extraction — DONE (session 10): mammoth.js loaded dynamically, text passed to aiCallJSON
- ✅ `[FIX]` Wire `sendRptChatMsg()` — DONE (session 9): all-provider AI chat with report context + KB injection
- ✅ `[FIX]` Wire `updateFinForm()` — DONE (session 9): contact label/placeholder + category + waterhouse row adapt to type
- ✅ `[FIX]` Contacts CSV import — DONE (session 9): file picker, parseCsvText, email dedup, confirm dialog
- `[FIX]` Duplicate `dtk_I1` dev task seed
- ✅ `[FIX]` `/api/drive/upload` Rails endpoint — fields=id,webViewLink,name, default mime_type text/html, clean response — DONE (session 11)
- ✅ `[FIX]` Google OAuth scope changed from drive.file to full drive — DONE (session 11)
- ✅ `[FIX]` Maintenance jobs auto-create reimbursement financial entry — DONE (session 11)
- `[FIX]` Wire `callModelForFeature()` into autofill, AI helper, import wizard, classify
- ✅ `[FIX]` CRITICAL — Rails API OAuth: oauth_states DB fix — DONE
- ✅ `[FIX]` Add Test button for Cloudflare Proxy URL field in AI & Integrations — DONE

---

## GROUP B — Dev Notes Panel ✅ DONE

---

## GROUP C — Task System ✅ DONE

- ✅ Capture widget Task → creates real task record — DONE (session 12)
- ✅ Capture widget Lead → creates real contact record — DONE (session 12)
- ✅ Capture widget Campaign → creates campaigns draft — DONE (session 12)
- ✅ Capture widget Project → creates projects idea — DONE (session 12)
- ⬜ Subtask support — `parent_task` field

---

## GROUP D — Import / Approval Workflow

- ✅ `approval_status` on financial entries — DONE (session 12): Approve/Reject buttons in Approval Queue set approval_status field
- ✅ Global Approval Queue page — DONE (session 12): aggregates captures, financials, maintenance jobs; expanded session 14 to also pull contacts, R&D, email drafts, campaign ideas
- ⬜ Wire Receipt Inbox AI Parse tab
- ✅ Approval items → Calendar events — DONE (session 12): reimbursement approval creates calendar event

---

## GROUP E — Multi-Entity Support

- ⬜ `entities` store + entity selector
- ⬜ `entity_id` on contacts, financials, projects, calEvents, tasks

---

## GROUP F — Waterhouse Digital Twin

- ⬜ `page-waterhouse-detail` — full page with tabs, sensor cards, history timeline
- ⬜ "Open in HA" button per waterhouse
- ⬜ Missing location form fields: `installer`, `commission_date`, `filter_configuration`,
  `device_node_id`, `ha_url`

---

## GROUP G — Home Assistant

- ✅ HA URL + token fields in AI & Integrations
- ⬜ Test connection button
- ⬜ Sensor cards pull live values from HA REST API

---

## GROUP H — Campaigns

- ✅ `campaigns` store + Campaigns page — 6-stage lifecycle — DONE (session 11)

---

## GROUP I — Dashboard ✅ DONE

- ✅ Campaign status panel — DONE (session 11)
- ✅ Inventory summary panel — DONE (session 11)

---

## GROUP K — Financials ✅ MOSTLY DONE

- ✅ 5-tab Financials, Services & Expenses, Import wizard, Ledger, Assets
- ⬜ `entity_id` on financial entries
- ✅ Wire maintenance reimbursements → auto-create financial entries — DONE (session 11)

---

## GROUP L — Contacts / CRM ✅ MOSTLY DONE

- ✅ `twwp_roles` multi-tag field (9 roles, checkboxes) — DONE (session 11)
- ⬜ `referrer_id` link
- ✅ Trustee-specific fields: `appointment_date`, `term_length`, `term_expiry` — DONE (session 11)

---

## GROUP M — Reports ✅ MOSTLY DONE

- ⬜ Reports duplicate bug confirmed fixed in v4.2
- ⬜ Auto-save report to Drive when generated (wired, needs OAuth fix)

---

## GROUP N — Google Drive Integration

- ✅ Phase 1 read-only (API key + folder ID)
- ✅ Sync Drive button in Documents tab
- ✅ Classify Folder button (AI reads filenames, proposes structure)
- ✅ Cloudflare Worker with /token and /refresh endpoints
- ✅ Rails API deployed at https://twwp-ops-api.fly.dev
- ✅ oauth_states fix applied — PKCE stored in DB not session
- ✅ Rails API OAuth confirmed working end to end (Mar 22 2026)
- ⬜ Auto-save backup JSON to Drive on logout (code written, scope fixed — activate next session)
- ⬜ Silent sync from server on login (code written, scope fixed — activate next session)
- ⬜ Auto-save every 30 minutes (timer set, scope fixed — activate next session)
- ✅ Upload HTML documents to Drive from Doc Builder — DONE (session 11)
- ⬜ Upload documents directly to Drive from Document Library (general)

---

## GROUP O — ESP32 / IoT

- ⬜ ESP32 PCB sensor module ordered — waiting on firmware
- ⬜ VS Code + PlatformIO setup for firmware
- ⬜ pH, TDS, purity readings from sensor to app
- ⬜ WiFi flow sensors installation (power unit received)

---

## GROUP P — Tap-Map Integration

- ⬜ Rails API sync endpoints exist
- ⬜ Wire Ops App → POST waterhouse data to twwp-app Rails API
- ⬜ Pull member data from twwp-app into Ops App contacts

---

## GROUP Q — Connection Status System ✅ DONE

- ✅ Status dot fixed top-right of page header
- ✅ Auto-checks every 5 minutes
- ✅ Status panel slides in from right
- ✅ 6 services: AI, Google Drive, Cloudflare Proxy, Rails API, Home Assistant, Local Storage
- ✅ Individual Test buttons + Test All button
- ✅ Test button for Cloudflare Proxy URL — DONE (AI & Integrations modal)

---

## GROUP R — Multi-Device Sync

- ✅ OAuth unblocked (Mar 22 2026)
- ⬜ Activate silent sync on login if server data is newer
- ✅ Save to Rails API on logout — DONE (was already wired)
- ✅ Save to Rails API when report generated — DONE (previewRptFromForm)
- ✅ Auto-save to Rails API every 30 minutes — DONE (setInterval in initApp)

---

## GROUP S — GitHub / Deployment

- ✅ GitHub Actions auto-deploy workflow — DONE (.github/workflows/deploy.yml)
  Triggers on push to main. **Manual step:** Settings → Pages → Source → GitHub Actions

---

## GROUP T — Security & User Management

- ✅ `users` table in Rails API — email, bcrypt password, role, org_id, active — DONE
- ✅ `has_secure_password` on User model — DONE
- ✅ POST `/auth/login` endpoint — returns JWT with user_id/email/role/org_id — DONE
- ✅ Login screen POSTs to Rails → receives JWT → stored in localStorage — DONE
- ✅ Falls back to local login if Rails unreachable — DONE
- ✅ JWT used for all subsequent API calls (Bearer token) — already wired
- ✅ First admin user created on Fly.io — DONE
- ✅ Roles: admin, staff, read-only (per org) — roles exist in DB, UI enforcement live
- ✅ Role-based UI — read-only: all S.upsert/S.rm blocked + banner; staff/read-only: admin nav items hidden
- ✅ Admin-only pages: Developer, AI & Integrations, Trustees/Legal — hidden for non-admin roles
- ⬜ User management page (admin only) — invite, deactivate, change role
- ⬜ API keys stored in Rails credentials server-side — not typed into browser
- ⬜ Document uploads routed through Rails → Google Drive (never raw in browser)
- ⬜ Session expiry + auto-logout after inactivity
- ⬜ Audit log — who changed what and when (store in Rails, surface in Developer page)

---

## GROUP U — Multi-Organisation Architecture

**North star:** TWWP is org #1 and the reference implementation. Every feature
must be designed so a second organisation can plug in with their own data,
branding, users and config — without touching the code.

- ⬜ `organisations` table in Rails — name, slug, logo_url, brand_colour, plan, active
- ⬜ `org_id` on all Rails tables: users, ops_sessions, ops_syncs
- ⬜ `org_id` on all localStorage stores: contacts, locations, financials, tasks,
  projects, inventory, deployments, kits, maintenance, calEvents, monitorData,
  services, assets, documents, campaigns
- ⬜ Org context set at login — JWT includes org_id
- ⬜ Org switcher in app header (for users who belong to multiple orgs)
- ⬜ Per-org branding — logo, app name, brand colour loaded from org config
- ⬜ Per-org feature flags — enable/disable modules per org
- ⬜ Per-org integration config — each org has own API keys, Drive folder, HA URL
- ⬜ Org admin role — can manage users and config for their org only
- ⬜ Super-admin role — can see and manage all orgs
- ⬜ White-label export — package a configured instance for a new org
- ⬜ Onboarding wizard for new orgs — name, logo, first admin user, modules
- ⬜ Tap-Map sync scoped per org (future)
- ⬜ Billing/plan awareness (future — Stripe integration scoped per org)

---

## GROUP Z — Unbuilt Tabs

- ✅ Email Registry tab — DONE (session 11)
- ⬜ Document Creation tab
- ✅ Campaigns page (GROUP H) — DONE (session 11)
- ⬜ Waterhouse digital twin (GROUP F)

---

## GROUP V — Calendar & Events Ledger

- ✅ Fix calendar CRUD (`openCalEventMo`, `editCalEvent`, `saveCalEvent`, `deleteCalEvent`) — DONE (session 13)
- ✅ Calendar recurrence field in modal — DONE (session 13)
- ✅ Calendar week/day views + Today button + view switcher — DONE (session 13)
- ✅ New CAL_TYPES: Meeting, Reminder, Reimbursement, Personal — DONE (session 13)
- ✅ Multi-provider calendar panel (Google Calendar live, iCloud/Proton/Outlook coming soon) — DONE (session 13)
- ✅ `eventLedger` store + `logEvent()` global function — DONE (session 13)
- ✅ Events Ledger page (admin-only) — DONE (session 13)
- ✅ Resource usage bar (fixed above capture FAB) — DONE (session 13)
- ✅ Calendar activity dots from ledger entries — DONE (session 13)
- ✅ Ledger auto-purge (90 days / 5000 entries) — DONE (session 13)
- ✅ Rails `POST /api/ledger/sync` endpoint — DONE (session 13, placeholder)
- ✅ Recurring calendar events (daily/weekly/monthly/yearly expand on render) — DONE (session 13)
- ⬜ Ledger Rails persistence (add `ledger_entries` table — currently logs only)

---

---

## GROUP W — Onboarding & Multi-Org Setup

- ✅ `[EXPLICIT]` Onboarding wizard (7 steps) — DONE (session 15): Welcome, Branding, First Location, AI Keys, Integrations, Team, Done
- ✅ `[EXPLICIT]` Persistent setup status checklist — DONE (session 15): 9 SETUP_KEYS, Dashboard card (admin), `twwp_setup_status_v1`
- ✅ `[EXPLICIT]` `requiresSetup()` contextual setup interrupts — DONE (session 15): wired into cal sync, Drive upload, email send, AI helper
- ✅ `[EXPLICIT]` `org_config` store + `getTerm()` terminology system — DONE (session 15): 6-key DEFAULT_TERMINOLOGY, sidebar labels, brand colour, terminology editor in AI & Integrations
- ⬜ User management page (admin only) — invite, deactivate, change role; needs `POST/PUT /api/users`
- ⬜ Per-org feature flags — enable/disable modules per org
- ⬜ White-label export — package a configured instance for a new org
- ⬜ Onboarding analytics — track which steps are completed/skipped
- ⬜ ESP32 config step in onboarding — firmware download link, pairing instructions
- ⬜ Stripe config step in onboarding — publishable key, webhook secret

---

## Recommended build sequence

1. ✅ Rails API OAuth (GROUP N) — DONE
2. ✅ Rails API connection + multi-device sync unblocked — DONE
3. ✅ Wire Rails API auto-save — logout, report generation, 30 min timer (GROUP R) — DONE
4. Fix GROUP A bugs — CSV import, sendRptChatMsg, updateFinForm (duplicates already resolved)
5. ✅ GitHub Actions auto-deploy (GROUP S) — DONE
6. ✅ Security foundations (GROUP T) — users table, JWT login, admin user, frontend wired
7. ✅ Onboarding wizard + setup status + org_config foundation (GROUP W, session 15) — DONE
8. Multi-Organisation Architecture (GROUP U) — org_id everywhere, org switcher
9. Email Registry + Document Creation tabs (GROUP Z)
10. Campaigns page (GROUP H)
11. Waterhouse digital twin (GROUP F)
12. ESP32 firmware + sensor integration (GROUP O)
13. Tap-Map sync (GROUP P)
