# Pages — Every Tab and What It Does

The app has 26 pages organised into sidebar sections. This document covers all of them.

---

## Sidebar structure

```
Dashboard
Operations
  ├── Maintenance
  ├── Calendar
  ├── WH Monitor
  ├── Member Display
  └── Reports
People
  └── Contacts / CRM
Projects
  ├── Projects
  ├── Tasks
  ├── R&D
  └── Trustees / Legal
Finance
  ├── Financials
  └── Organisations
Inventory
  ├── Catalogue
  ├── Kit Templates
  ├── Deployments
  ├── Inventory
  └── Purchase Orders
Locations
  └── Locations
Procurement
  ├── Accounts
  └── Receipt Inbox
AI
  └── AI Helper / Notes
Dev
  └── Developer
```

---

## Dashboard (`page-dashboard`)

First page shown after login. Gives a full operational overview.

**Sections:**
- **Stat bar** — 6 clickable cards: Waterhouses, Contacts, Catalogue Items, Open Tasks, Total Reimbursed, Maintenance Jobs. Clicking navigates to that page.
- **Gauges + charts** — SVG arc gauge for total litres quenched, arc gauge for average VIP members, mini bar chart for monthly reimbursements (6 months), dev progress bar.
- **Waterhouse health cards** — one card per waterhouse, colour-coded by service status (green = active, amber = service due, red = overdue). Shows last service date, VIP count, litres this period.
- **Tasks due (14 days)** — project and dev tasks with due dates coming up, overdue in red.
- **Guardian reimbursements** — shows which guardians have unpaid periods calculated from monitor data.
- **Recent activity** — last 8 actions across maintenance, contacts, financials, projects.
- **Quick actions** — 8 tiles: Log Maintenance, Add Event, Add Item, Add Contact, Log Expense, Add Task, Log Period, New Report.
- **Upcoming calendar** — next 4 calendar events in compact cards.
- **Organisation cards** — Mana Fuente (Primary), TWWP PMA, GSD Collective, Pet Shop, plus user-added orgs. + Add card opens a 3-step org wizard.

**Refresh button** — re-renders the whole dashboard with latest data.

---

## Operations

---

### Maintenance (`page-maintenance`)

Full guided wizard for recording waterhouse maintenance visits and calculating guardian reimbursements.

**Three tabs:**

**Wizard** — 4 steps:
1. Select waterhouse
2. Choose maintenance categories (Filtration, Power/Solar, IoT/Sensors, Security, General)
3. Work through checklists per category — tick tasks, enter readings (pH, TDS, ORP, pressure)
4. Fill the report — dates, water usage, costs — app calculates reimbursement automatically

Completing saves a job record and generates a report + receipt (both printable to PDF). Auto-creates a Calendar event for the next visit.

**History** — table of all past jobs. Each row has View, Receipt, Delete.

**Schedule** — upcoming and overdue scheduled maintenance tasks across all waterhouses. Overdue = red, due soon = amber. Tracks: filter changes, meter calibration, alkaline cartridge, RO membrane, solar check, security inspection.

**Key store:** `maintJobs` (`twwp_maint_v1`)  
**Reimbursement formula:** water cost × 1.15 + power + guardian fee + goodwill gift

---

### Calendar (`page-calendar`)

Unified calendar showing events, project tasks, and dev tasks with due dates — all in one view.

**Source filter pills:** All / Events / Tasks / Dev Tasks / Maintenance  
**Month navigation** with prev/next arrows  
**Sidebar:** Upcoming events (next 30 days), legend  
**Event ledger** — full list below the grid, split into Upcoming and Past, with Source column (Event / Task / Dev Task)

**Event types + colours:** Maintenance Visit (cyan), Water Quality Test (green), Contractor Visit (amber), Report Due (red), Member Event (purple), Marketing (pink), Project Management (blue), Trustee/Legal (yellow), Fundraising (teal), Task Due (orange), Dev Task Due (purple), Custom (grey)

**Auto-sync on login:** `calSyncAll()` creates calendar entries for any task/devtask with a due date that doesn't have one yet. Removes stale entries for completed tasks.

**Sync button** — manually re-runs the sync.

**Key store:** `calEvents` (`twwp_cal_v1`)

---

### WH Monitor (`page-monitor`)

Per-waterhouse operational dashboard.

Select a waterhouse, then see: 5 arc-gauge dials (Total Quenched, Total Filtered, Avg Efficiency, VIP vs target, Total Reimbursed), 6 stat cards for most recent period, period history table, recent maintenance jobs.

**Log Period** — records a new operational period with dates, litres, costs. Auto-calculates reimbursement.  
**Generate Receipt** — printable reimbursement receipt from the most recent period.

**Key store:** `monitorData` (`twwp_monitor_v1`)  
**Demo data:** Three real periods from WH1 Raj (Oct 2024 – Jul 2025)

---

### Member Display (`page-member`)

Preview of the Tap-Map widget that will show on app.thewholeywaterproject.com. Shows waterhouse status, litres quenched, VIP count, component health indicators. Export Widget JSON downloads a Rails API-formatted payload (endpoint not yet built).

---

### Reports (`page-reports`)

Generate 6 types of periodic reports: Guardian/Host, Facilitator/Admin, Technician/Contractor, Sponsor/Impact, Member Update, Trustee/Governance.

Click a type → fill the form → preview → send via `mailto:` or download as HTML. Guardian reports auto-fill from monitor data. Saved reports listed below with Preview/Send/Delete.

**Key store:** `reports` (`twwp_reports_v1`)

---

## People

---

### Contacts / CRM (`page-contacts`)

Unified address book: guardians, members, suppliers, trustees, sponsors, contractors.

Stat bar, type filter pills, search. Contact cards show name, type, status, email (mailto link), phone, address, linked waterhouse, membership ID, tags.

**Send to Backlog** button on each capture in Developer → Captures promotes notes to dev tasks.

**Key store:** `contacts` (`twwp_contacts_v1`)  
**Demo data:** 7 contacts including Raj, Kendall, Sarah T., Mike W., Warrick D., Jane L., AliExpress account

---

## Projects

---

### Projects (`page-projects`)

Tracks initiatives across 9 types: WH Upgrade, Fundraising, Outreach, Competition, Legal, App Dev, IoT/Hardware, Research, Admin.

Cards show type icon, priority, name, status, owner, due date (overdue = red, due soon = amber), linked waterhouse, milestones.

**Key store:** `projects` (`twwp_projects_v1`)

---

### Tasks (`page-tasks`)

Unified task view combining project tasks and developer tasks.

**View pills:** Project Tasks / Dev Tasks / All Together  
**Group pills:** By Priority / By Status / By Module / By Waterhouse

Both types render in a grouped card layout with source icon (✅ project, ⚙ dev). Filter by waterhouse and status. All tasks auto-sync to Calendar when they have a due date.

**Key stores:** `tasks` (`twwp_tasks_v1`), `devtasks` (`twwp_devtasks_v1`)

---

### R&D (`page-rd`)

Captures research and development ideas. Items captured via the + button → R&D Idea.  
Status lifecycle: Idea → Testing → Validated → Promoted (click Status to cycle).

**Key store:** `captures` filtered by `type === 'rd'`

---

### Trustees / Legal (`page-trustees`)

Governance item tracking. Summary cards: trustee count (pulled from contacts with type = trustee), open legal items, resolved items. Legal item statuses: Open → In Progress → Resolved.

**Key store:** `captures` filtered by `type === 'legal'`

---

## Finance

---

### Financials (`page-financials`)

Records expenses, donations, reimbursements, and income.

**Payment Tools section** (top of page): Stripe Payment Links card (configure in AI & Integrations), Bank Transfer card.  
**Summary cards:** Total Income/Donations, Total Expenses, Total Reimbursements, Net Position.  
**Transaction log** — filterable table with Export CSV.

**Key store:** `financials` (`twwp_fin_v1`)

---

### Organisations (`page-shops`)

Lists all partner organisations and shops connected to the Ops App.

**Mana Fuente** appears first with a "Primary" badge — the main sales and purchasing entity for TWWP.  
Other built-ins: TWWP PMA, GSD Collective, Pet Shop.  
User-added orgs (from the org wizard) appear after with a delete button.

**+ Add Org** opens a 3-step wizard: Details → Modules → Confirm. Same wizard available from Dashboard.

**Commerce Tools section** (bottom): WooCommerce CSV export.

**Shop Connections** — each org can have one or more shop destinations configured. These are used by the Shop Push Wizard. *(UI for managing shop destinations to be added to this page.)*

**Key store:** `ORG_BUILTINS` constant + `twwp_orgs_v1` localStorage (user-added orgs)

---

## Inventory

---

### Catalogue (`page-catalogue`)

A **reference library** of items you might buy or use — not an inventory of what you have. Kit templates are built from catalogue items.

**Status lifecycle:** Unreviewed → Testing → Approved → Deprecated  
- *Approved* items are available for kit building and the Shop Push Wizard  
- *Deprecated* means no longer recommended for future use (a catalogue decision, not physical)

**Item fields:** name, component type, subcategory, supplier/store, estimated unit cost, lead time (days), shipping estimate, reliability rating, status, product URL, image URL, notes.

**No quantity fields** — quantity lives in Inventory, not the Catalogue.

**Approved items** show a 🔗 Shop button that opens the Shop Push Wizard.

**Quick Add + AI Fill** — paste a URL, AI extracts name, price, type, specs.  
**CSV Import** — bulk import with column auto-detection and preview.  
**Multi-select** — bulk status change or delete.  
**BOM** — items can still be assigned to locations for bill-of-materials purposes.

**Key store:** `items` (`twwp_items_v2`)

---

### Kit Templates (`page-kits`)

Reusable installation kits built from approved catalogue items.

Kit types: Taplock Install, Water Quality Sensor Install, Basic Filter Changeout, Full Waterhouse Build, Solar/Power System, Custom.

Each kit has: line items (catalogue items + qty + optional flag), sub-kits, option axes (configurable choices with price deltas). Cost is calculated automatically. Approved kits can be pushed to a shop via the Shop Push Wizard.

**Key store:** `kits` (`twwp_kits_v3`)

---

### Deployments (`page-deployments`)

Records when a kit was deployed to a location. Creates an audit trail of what was installed, where, when.

Select kit → select location → set date and notes → save. The deployment record snapshots the kit's line items at time of deployment.

Status: Planned / Active / Decommissioned.

*Future:* Confirming a deployment will offer to move component items from In Stock → Deployed in Inventory.

**Key store:** `deps` (`twwp_deps_v3`)

---

### Inventory (`page-inventory`)

Tracks **physical stock** — what you have, where it is, and its lifecycle state.

**Status filter pills:** In Stock (default) / Deployed / Sold / Disposed / All  
**Group toggle:** By Item / By Location

By Item groups all locations for each catalogue item with total quantity.  
By Location groups all items at each site.

Inventory entries are created automatically when a Purchase Order is confirmed received. Can also be added manually.

**Inventory lifecycle:**
- *In Stock* — available in a storage location or vehicle
- *Deployed* — physically installed at a waterhouse (still tracked, not available stock)
- *Sold* — sold to a contact
- *Disposed* — written off (broken, expired, discarded)
- *Lost* — unaccounted for

**Key store:** `inventory` (`twwp_inv_v1`)

---

### Purchase Orders (`page-purchases`)

Tracks what you've ordered from suppliers.

**PO status flow:** Draft → Ordered → Partial → Received → Cancelled

**Confirm Receipt button** appears on Ordered/Partial POs. Clicking shows a confirmation dialog listing all line items, then auto-creates Inventory entries (status: In Stock) for each line and marks the PO as Received.

**Line items** link to catalogue items with quantity ordered and unit cost paid.

**Key store:** `purchase_orders` (`twwp_po_v1`)

---

## Locations

---

### Locations (`page-locations`)

Registry of all physical sites: Waterhouses, Stock rooms, Test Benches, Sold installations.

Each location card shows: name, type, WH ID, address, guardian, water rate, VIP target, item assignment count.

Location form fields: name, WH ID, address (with OpenStreetMap autocomplete + lat/lng auto-fill), guardian name/email, water rate (default $3.54/m³), VIP target, notes.

**BOM button** — shows all items assigned to this location.

**Key store:** `locations` (`twwp_locations_v2`)

---

## Procurement

---

### Accounts (`page-accounts`)

Buyer accounts for procurement: AliExpress, Alibaba, etc. Links accounts to catalogue items for traceability. Fields: label, platform, email, email type, username, notes.

**Key store:** `accounts` (`twwp_accounts_v2`)

---

### Receipt Inbox (`page-inbox`)

Pipeline for getting purchase records into the catalogue. Add items via paste/AI parse, CSV import, or manual entry. Then push to Catalogue (creates an Unreviewed item) or skip.

**Key store:** `inbox` (`twwp_inbox_v2`)

---

## AI

---

### AI Helper / Notes (`page-aihelper`)

Central place for captured feedback and AI chat. Feedback table shows all `type === 'feedback'` captures with bucket filter. Embedded AI chat uses the same floating panel assistant.

**Key store:** `captures` filtered by `type === 'feedback'`

---

## Dev

---

### Developer (`page-developer`)

Five-tab developer workspace:

**Dev History** — growth log entries from `SPEC_GROWTH` constant + user-added entries. Dated record of what changed each session.

**Dev Tasks** — developer and build tasks from the backlog. Pre-seeded from Groups A–T. Grouped by backlog group. Tick to mark complete. Add/edit/delete. Fully persistent in localStorage. Linked to Calendar via due dates.

**Captures** — type cards for every capture type (Notes, Tasks, Feedback, R&D, Legal, Campaign, Leads). Click a card to see that type's full history with triage dropdown (Added to Backlog / Discarded / Undecided) and **+ Backlog** button to promote a capture to a dev task.

**Backlog** — all backlog groups (A–T) readable inline with checkboxes. Progress persists between sessions.

**Platform Spec** — ADRs (Architecture Decision Records), Block Index (stable system IDs), Growth Log, Dev Notes per page. ADRs and growth entries can be added via modals; Claude adds them to JS constants at end of sessions.

**Key stores:** `devtasks` (`twwp_devtasks_v1`), `captures` (`twwp_captures_v1`)

---

## Global UI elements

### Capture Widget (floating `+` button, bottom right)
Always visible. Opens a menu with: Note / Idea, Lead / Contact, Task, Project Idea, R&D Idea, Legal / Admin, Campaign Idea, App Feedback, Ask AI Helper.

### AI Helper Panel (floating chat)
Slide-in chat panel. Page-aware. Multi-provider (Gemini, Anthropic, OpenAI, OpenRouter).

### Dev Notes Panel (floating `⚙` tab, right edge)
Slide-in panel showing DEVNOTES for the current page, linked ADRs, and a note input. Notes saved from the panel appear as type `note` in captures and are visible in the panel's "Your Notes" section on return visits.

### Sidebar (3 stages)
Full (200px) → Icons only (44px) → Hidden (0px, ☰ peek tab appears top-left). Stage remembered between sessions.
