# TWWP Ops App — Build Backlog

**Last updated:** 2026-03-21 (end of session 6)

**Labels:** `[EXPLICIT]` `[IMPLIED]` `[FIX]` `[OPEN]` ✅ done

---

## GROUP A — Bug Fixes

- `[FIX]` Remove duplicate `buildRptFormModal` + `closeRptFormMo` functions
- `[FIX]` Wire `sendRptChatMsg()` — empty function
- `[FIX]` Wire `updateFinForm()` — empty function
- `[FIX]` Contacts CSV import — shows alert, not implemented
- `[FIX]` Duplicate `dtk_I1` dev task seed
- `[FIX]` Wire `callModelForFeature()` into autofill, AI helper, import wizard, classify
- `[FIX]` CRITICAL — Rails API OAuth: apply oauth_states DB fix (see session-handoff-march21.md)
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
- ⬜ CRITICAL: Apply oauth_states fix to Rails API (see session-handoff-march21.md)
- ⬜ After OAuth fix: test full Connect → Drive write flow
- ⬜ Auto-save backup JSON to Drive on logout (code written, needs OAuth)
- ⬜ Silent sync from server on login (code written, needs OAuth)
- ⬜ Auto-save every 30 minutes (timer set, needs OAuth)
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

- ⬜ Depends on GROUP N OAuth fix
- ⬜ Silent sync on login if server data is newer
- ⬜ Save to Rails API on logout
- ⬜ Save to Rails API when report/receipt generated
- ⬜ Save to Rails API every 30 minutes

---

## GROUP S — GitHub / Deployment

- ⬜ GitHub Actions auto-deploy workflow (discussed, not implemented)
  Would auto-deploy on every commit — removes manual upload step

---

## GROUP Z — Unbuilt Tabs

- ⬜ Email Registry tab
- ⬜ Document Creation tab
- ⬜ Campaigns page (GROUP H)
- ⬜ Waterhouse digital twin (GROUP F)

---

## Recommended build sequence

1. Apply Rails API oauth_states fix (GROUP N) — unblocks everything
2. Test full OAuth flow end to end
3. Wire Drive auto-save (logout, report generation, 30 min timer)
4. Fix GROUP A bugs (code quality / UX polish)
5. Build Email Registry + Document Creation tabs (GROUP Z)
6. ESP32 firmware when hardware arrives (GROUP O)
7. Campaigns page (GROUP H)
8. Waterhouse digital twin (GROUP F)
9. Tap-Map sync (GROUP P)

