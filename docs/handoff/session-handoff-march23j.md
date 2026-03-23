# Session Handoff — Sprint B (2026-03-23j)
**Theme:** Tap-Map read-only integration + Project Management restructure
**SPEC_VERSION:** 4.7
**Commit:** Sprint B (6 tasks): Tap-Map DB, endpoints, pull buttons, sensor gauges, PM tabs, Trello

---

## What was done

### B1 — Ops API: read-only Tap-Map DB connection
- `config/database.yml` — added `tap_map` database entry using `TAP_MAP_DATABASE_URL` (Fly.io secret)
- Neon Postgres confirmed as Tap-Map DB; `replica: true` in database config
- `app/models/tap_map_record.rb` — base class with `connects_to`, `readonly? true`
- `app/models/tap_map_user.rb` — table: `users`
- `app/models/tap_map_tap.rb` — table: `taps`
- `app/models/tap_map_reading.rb` — table: `readings`

### B2 — Ops API: Tap-Map read endpoints
- `app/controllers/api/tap_map_controller.rb` — three actions (members, taps, readings)
- Routes added: `GET /api/tap_map/members|taps|readings` under `/api` namespace
- Pagination (`?page=&per_page=`), tap_id filter, limit param (max 500)
- All require Bearer JWT

### B3 — Ops App: Pull from Tap-Map buttons
- Contacts header: `↓ Tap-Map` button → `pullTapMapContacts()`
  - Deduplicates by email; adds "Tap-Map" tag to new and existing contacts
  - Toast: "X new contacts synced from Tap-Map"
- Locations header: `↓ Tap-Map Taps` → `pullTapMapTaps()`
  - Deduplicates by name; sets `tap_id` on matched locations
- WH Monitor header: `↓ Live Readings` → `pullTapMapReadings()`
  - Stores 500 readings in `twwp_tap_readings_v1` (localStorage)
  - Triggers `renderMonitor()` refresh

### B4 — WH Monitor: live sensor gauges
- `renderSensorGauges(whId)` — checks `location.tap_id`, matches to readings store
- Cards for TDS / EC / pH / ORP with sparkline SVG (last 20 readings)
- Colour thresholds: pH 6.5-7.5 green/6.0-8.0 amber/outside red; TDS <50/<150; EC <100/<300
- "Last reading: X mins ago" timestamp
- Sensor section prepended above existing period history

### B5 — Project Management: rename + tabs
- Sidebar: "Project Management" (was "Projects")
- Page header: "Project Management"
- 4 tabs: Overview (existing list), Board (new), Timeline (new Gantt), Integrations (new)
- `switchPMTab(el)` — tab switcher, updates dynamic page actions per tab
- All existing project CRUD, stores, renderProjects() untouched

### B6 — PM Board + Trello
- **Board tab** kanban — tasks from `tasks` store + Trello cards (`twwp_trello_cards_v1`)
- Columns: To Do / In Progress / Blocked / Done
- HTML5 drag-and-drop updates `task.status` in store
- Project filter dropdown in board header
- "↑ Trello" button per internal task — pushes to first list on selected board
- **Integrations tab → Trello panel**: API Key + Token (from trello.com/app-key)
- `saveTrelloCredentials()` → fetches board list, saves to `twwp_trello_v1` + `org_config.integrations.trello`
- `pullTrelloCards()` → all cards from selected board, stored read-only in `twwp_trello_cards_v1`
- `pushTaskToTrello(taskId)` → creates card on board's first list
- **Timeline tab** — Gantt bars proportional to start/due dates
- ADR-016: read-only secondary DB (TapMapRecord pattern)
- ADR-017: Trello API key+token vs OAuth

### B7 — Sprint docs + sync scripts
- `scripts/post_sprint_to_ops.rb` — posts Sprint B completions to Rails API (devtasks + spec_growth + calEvent + ledger)
- `scripts/sprint_template.rb` — reusable template for future sprint wraps
- `docs/CURRENT_STATE.md` — Sprint B section added, integration status table updated
- `docs/backlog.md` — Sprint B group added (B1-B6 ✅, BX1-BX3 remaining)
- `docs/known-issues.md` — Sprint B section added
- `SPEC_VERSION` → 4.7, `SPEC_GROWTH` Sprint B entry, ADR-016/017, `BACKLOG_GROUPS` SprintB group

---

## Files changed

| File | Change |
|------|--------|
| `index.html` | B3-B7: buttons, PM tabs, Board, Timeline, Trello, sensor gauges, SPEC constants |
| `~/twwp-ops-api/config/database.yml` | Added `tap_map` DB entry |
| `~/twwp-ops-api/app/models/tap_map_record.rb` | New — base class |
| `~/twwp-ops-api/app/models/tap_map_user.rb` | New |
| `~/twwp-ops-api/app/models/tap_map_tap.rb` | New |
| `~/twwp-ops-api/app/models/tap_map_reading.rb` | New |
| `~/twwp-ops-api/app/controllers/api/tap_map_controller.rb` | New — 3 endpoints |
| `~/twwp-ops-api/config/routes.rb` | Added 3 tap_map routes |
| `docs/CURRENT_STATE.md` | Sprint B section + integration status |
| `docs/backlog.md` | Sprint B group |
| `docs/known-issues.md` | Sprint B section |
| `scripts/post_sprint_to_ops.rb` | New — sprint completion poster |
| `scripts/sprint_template.rb` | New — future sprint template |

---

## Known issues / next session

1. **TAP_MAP_DATABASE_URL** — must be set as Fly.io secret before tap_map endpoints work in production: `fly secrets set TAP_MAP_DATABASE_URL='postgres://...'`
2. **Trello credentials in localStorage** — consistent with JWT storage pattern; acceptable for internal tool (ADR-017)
3. **PM Board drag-and-drop** — uses HTML5 DnD which has known quirks on touch devices; may need Pointer Events fallback
4. **WH Monitor sensor gauges** — only shows if `location.tap_id` is set; user must run ↓ Tap-Map Taps first to link locations
5. **`scripts/.ops_token`** — gitignored (should be); never commit the JWT file
6. **Outlook OAuth PKCE** — still unimplemented (BACKLOG X7)
7. **Gmail email scope** — re-auth still needed for gmail.send scope

## Deployment status
- Rails API: ✅ Deployed to https://twwp-ops-api.fly.dev (Sprint B)
- Frontend: pending git push → GitHub Pages auto-deploy
