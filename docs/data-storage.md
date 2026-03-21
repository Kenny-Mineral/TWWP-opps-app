# Data Storage — What Gets Saved and Where

All data lives in the browser's `localStorage`. No server, no cloud. Multi-device sync is planned via Google Drive Phase 2 (see below).

---

## The `S` wrapper

```javascript
S.get('items')          // → array
S.find('items', id)     // → record or null
S.upsert('items', obj)  // add or update by id
S.set('items', array)   // replace whole array
S.rm('items', id)       // delete one record
```

Key names are versioned (`twwp_items_v2`) so shape changes don't collide with old stored data.

---

## Complete localStorage key map

### Main data stores (via `S`)

| `S` key | localStorage key | What it stores |
|---------|-----------------|----------------|
| `items` | `twwp_items_v2` | Catalogue items (reference library — no qty fields) |
| `accounts` | `twwp_accounts_v2` | Buyer accounts |
| `locations` | `twwp_locations_v2` | Waterhouses and storage locations |
| `inbox` | `twwp_inbox_v2` | Receipt inbox pipeline |
| `kits` | `twwp_kits_v3` | Kit templates with BOMs |
| `deps` | `twwp_deps_v3` | Deployment records (includes `owner_entity`) |
| `inventory` | `twwp_inv_v1` | Physical stock with lifecycle state |
| `purchase_orders` | `twwp_po_v1` | Supplier orders → confirmation → inventory |
| `shop_destinations` | `twwp_shopd_v1` | Shop connection records |
| `shop_listings` | `twwp_shopl_v1` | Items/kits pushed via Shop Wizard |
| `assets` | `twwp_assets_v1` | Manually registered assets |
| `ppsr` | `twwp_ppsr_v1` | PPSR registration records |
| `docs` | `twwp_docs_v1` | Document library metadata |
| `services` | `twwp_svc_v1` | Recurring/one-off operating costs |
| `workflow_flags` | `twwp_wf_flags_v1` | Sidebar badge flags from deployment workflows |
| `maintJobs` | `twwp_maint_v1` | Maintenance job records |
| `calEvents` | `twwp_cal_v1` | Calendar events (manual + auto-synced) |
| `monitorData` | `twwp_monitor_v1` | Waterhouse operational period records |
| `reports` | `twwp_reports_v1` | Generated reports |
| `contacts` | `twwp_contacts_v1` | CRM contacts |
| `projects` | `twwp_projects_v1` | Projects and initiatives |
| `tasks` | `twwp_tasks_v1` | Operational tasks |
| `devtasks` | `twwp_devtasks_v1` | Developer/build tasks |
| `financials` | `twwp_fin_v1` | Financial transactions |
| `captures` | `twwp_captures_v1` | Quick-capture items (notes, R&D, legal, feedback) |
| `rd` | `twwp_rd_v1` | *Defined, unused — R&D items live in captures* |
| `legal` | `twwp_legal_v1` | *Defined, unused — legal items live in captures* |

### Direct localStorage keys (not via `S`)

| Key | What it stores |
|-----|---------------|
| `twwp_creds_v1` | Login credentials `{u, p}` — both empty = dev mode bypass |
| `twwp_ai_cfg_v1` | AI settings: provider, API keys, feature toggles |
| `twwp_integrations_v1` | Cloud storage URLs, API keys, webhooks, HA settings (see shape below) |
| `twwp_sched_v1` | Maintenance schedule overrides `{'whId.taskId': 'YYYY-MM-DD'}` |
| `twwp_demo_seeded_v3` | Flag — prevents re-seeding demo data |
| `twwp_sb_stage` | Sidebar stage (0=full, 1=icons, 2=hidden) |
| `twwp_backlog_progress_v1` | Backlog checkbox states |
| `twwp_spec_adrs_v1` | User-added ADRs |
| `twwp_spec_growth_v1` | User-added growth log entries |
| `twwp_orgs_v1` | User-added organisations |
| `twwp_ledger_opening_v1` | Opening balance for accounting ledger |

### sessionStorage

| Key | What it stores |
|-----|---------------|
| `twwp_sess_v1` | Login session `{ok: true, user: '...'}` — cleared on tab close |

---

## Key data shapes

### `twwp_integrations_v1`
```javascript
{
  gdrive:           '',  // Drive folder URL
  'gdrive-key':     '',  // API key (read-only, Phase 1)
  'gdrive-folder':  '',  // Folder ID (last segment of folder URL)
  'gdrive-client-id': '', // OAuth Client ID (Phase 2, currently disabled)
  dropbox:          '',
  onedrive:         '',
  slack:            '',  // Webhook URL
  zapier:           '',  // Webhook URL
  webhook:          '',  // Custom webhook URL
  gcal:             '',  // Google Calendar ID
  'ha-url':         '',  // Home Assistant base URL
  'ha-token':       ''   // HA long-lived token
}
```

### `inventory`
```javascript
{
  id, catalogue_item_id, catalogue_item_name,
  qty, unit,                    // units | metres | litres | kg | other
  status,                       // in_stock | deployed | sold | disposed | lost
  location_type, location_id,
  purchase_order_id, received_date,
  acquisition_type,             // purchased | donated | loaned | found | other
  acquired_by, acquired_by_role, // from import wizard
  estimated_value, donor,        // for donated items
  notes, created, updated
}
```

### `docs`
```javascript
{
  id, title, desc,
  type,           // dynamic string — any value creates a new filter pill
  status,         // active | draft | archived | superseded
  version, date, owner, entity,
  url,            // external link (Google Drive, etc.)
  tags,           // comma-separated
  filename, drive_id, folder_path,
  notes, created, updated
}
```

### `workflow_flags`
```javascript
{
  id, page,       // deployments | trustees | maintenance | calendar
  label,          // human-readable description shown in flag card
  dep_id,         // deployment that triggered it
  created,
  dismissed       // boolean — false = visible in badge count
}
```

### `deps` (updated)
Now includes `owner_entity` (TWWP PMA / Mana Fuente / GSD Collective / Pet Shop / Other). When status becomes Active, `triggerDeploymentWorkflows()` fires silently.

### `services`
```javascript
{
  id, name,
  cat,    // cloud | legal | insurance | travel | connectivity | marketing | equipment | other
  freq,   // monthly | quarterly | annually | one_off
  amount, provider, due,  // next due date 'YYYY-MM-DD'
  status, // active | one_off | inactive
  notes, created
}
```

### `ppsr`
```javascript
{
  id, secured_party, sp_contact,
  grantor_name, grantor_type, grantor_id, grantor_address,
  collateral_type, collateral_desc, asset_id, serial,
  duration,        // '3 years' | '5 years' | '7 years' | '25 years' | 'No expiry'
  status,          // draft | registered | discharged
  ref_number, registered_date,
  notes, created, updated
}
```

---

## Google Drive integration

### Phase 1 — Read-only (API key, currently active)

Folder must be shared as "Anyone with the link can view."

```
Cloud Console → APIs & Services → Library → Enable Google Drive API
Cloud Console → Credentials → API Key → restrict to Drive API
Paste into app: AI & Integrations → Drive API Key + Folder ID
```

Used by: Sync Drive (import metadata), Classify Folder (AI classifies + proposes structure), Test Connection.

### Phase 2 — Read + Write (OAuth PKCE, planned)

User signs in with their Google account. No private keys in browser ever.

```
Cloud Console → Credentials → OAuth Client ID → Web Application
Add Authorised JavaScript Origin: https://yourusername.github.io
Add Authorised Redirect URI: https://yourusername.github.io/twwp-ops-app
Paste Client ID into app: AI & Integrations → Phase 2 OAuth Client ID
```

Will enable: upload files to Drive, execute folder structure from Classify Folder, auto-save reports/receipts/backups to Drive, multi-device sync via backup JSON in Drive.

**Do NOT use Service Account JSON in the browser** — the private key is visible in DevTools. Service accounts belong on the Rails backend only.

### Multi-device sync (planned, Phase 2)

On login: check Drive for a backup JSON newer than local data → prompt "Newer data found in Drive — sync?" On logout/backup: auto-save backup JSON to `TWWP Ops/Backups/ops-backup-YYYY-MM-DD.json`. This gives phone ↔ laptop continuity without a server database.

---

## Backup and restore

**Backup:** Sidebar → Backup JSON. Exports all `S`-managed stores.  
**Restore:** Sidebar → Restore Backup. Merges — existing records with matching IDs preserved.

**Not included in backup** (UI/dev state):
`twwp_orgs_v1`, `twwp_spec_*`, `twwp_backlog_progress_v1`, `twwp_integrations_v1`, `twwp_ledger_opening_v1`, `twwp_sb_stage`
