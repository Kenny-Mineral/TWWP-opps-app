# TWWP Ops App — Build Backlog

**Last updated:** 2026-03-22 (session 7)

**Labels:** `[EXPLICIT]` `[IMPLIED]` `[FIX]` `[OPEN]` ✅ done

---

## GROUP A — Bug Fixes

- `[FIX]` Remove duplicate `buildRptFormModal` + `closeRptFormMo` functions
- `[FIX]` Wire `sendRptChatMsg()` — empty function
- `[FIX]` Wire `updateFinForm()` — empty function
- `[FIX]` Contacts CSV import — shows alert, not implemented
- `[FIX]` Duplicate `dtk_I1` dev task seed
- `[FIX]` Wire `callModelForFeature()` into autofill, AI helper, import wizard, classify
- ✅ `[FIX]` CRITICAL — Rails API OAuth: oauth_states DB fix — DONE
- `[FIX]` Add Test button for Cloudflare Proxy URL field in AI & Integrations

---

## GROUP B — Dev Notes Panel ✅ DONE

---

## GROUP C — Task System ✅ DONE

- ⬜ Capture widget Task → creates real task record (currently saves a capture)
- ⬜ Subtask support — `parent_task` field

---

## GROUP D — Import / Approval Workflow

- ⬜ `approval_status` on financial entries
- ⬜ Global Approval Queue page
- ⬜ Wire Receipt Inbox AI Parse tab
- ⬜ Approval items → Calendar events

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

- ⬜ `campaigns` store + Campaigns page — 11-step lifecycle

---

## GROUP I — Dashboard ✅ DONE

- ⬜ Campaign status panel (needs H)
- ⬜ Inventory summary panel

---

## GROUP K — Financials ✅ MOSTLY DONE

- ✅ 5-tab Financials, Services & Expenses, Import wizard, Ledger, Assets
- ⬜ `entity_id` on financial entries
- ⬜ Wire maintenance + monitor reimbursements → auto-create financial entries

---

## GROUP L — Contacts / CRM ✅ MOSTLY DONE

- ⬜ `twwp_role` multi-tag field
- ⬜ `referrer_id` link
- ⬜ Trustee-specific fields: `appointment_date`, `term_length`

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
- ⬜ Auto-save backup JSON to Drive on logout (code written, now unblocked)
- ⬜ Silent sync from server on login (code written, now unblocked)
- ⬜ Auto-save every 30 minutes (timer set, now unblocked)
- ⬜ Upload documents directly to Drive from Document Library

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
- ⬜ Status dot Test button for Cloudflare Proxy URL

---

## GROUP R — Multi-Device Sync

- ✅ OAuth unblocked (Mar 22 2026)
- ⬜ Activate silent sync on login if server data is newer
- ⬜ Activate save to Rails API on logout
- ⬜ Save to Rails API when report/receipt generated
- ⬜ Auto-save to Rails API every 30 minutes

---

## GROUP S — GitHub / Deployment

- ⬜ GitHub Actions auto-deploy workflow (discussed, not implemented)
  Would auto-deploy on every commit — removes manual upload step

---

## GROUP T — Security & User Management

- ⬜ Replace hardcoded admin/twwp2024 login with Rails-backed user auth
- ⬜ `users` table in Rails API — email, bcrypt password, role, org_id, active
- ⬜ Roles: admin, staff, read-only (per org)
- ⬜ Login screen POSTs credentials to Rails → receives JWT → stored in localStorage
- ⬜ JWT used for all subsequent API calls (already wired via Bearer token)
- ⬜ Role-based UI — read-only users cannot create/edit/delete records
- ⬜ Admin-only pages: Developer, AI & Integrations, Trustees/Legal
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

- ⬜ Email Registry tab
- ⬜ Document Creation tab
- ⬜ Campaigns page (GROUP H)
- ⬜ Waterhouse digital twin (GROUP F)

---

## Recommended build sequence

1. ✅ Rails API OAuth (GROUP N) — DONE
2. ✅ Rails API connection + multi-device sync unblocked — DONE
3. Wire Drive auto-save — logout, report generation, 30 min timer (GROUP N, R)
4. Fix GROUP A bugs — duplicate functions, empty wired functions
5. GitHub Actions auto-deploy (GROUP S) — quick win, saves manual uploads
6. Security & User Management (GROUP T) — proper login, roles, user DB
7. Multi-Organisation Architecture (GROUP U) — org_id everywhere, org switcher
8. Email Registry + Document Creation tabs (GROUP Z)
9. Campaigns page (GROUP H)
10. Waterhouse digital twin (GROUP F)
11. ESP32 firmware + sensor integration (GROUP O)
12. Tap-Map sync (GROUP P)
