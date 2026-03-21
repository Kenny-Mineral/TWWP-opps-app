# TWWP / GSD Ops Platform — Distilled Reference
**Source:** ops-platform-spec-v32.md (Kenny, v0.4-structured, 2026-03-16/17)
**Purpose:** Clean, traceable extraction of every valid decision, feature, scope item, data model, and page spec from the brain dump. Organised for use in Claude build sessions.
**Method:** Every item is sourced. Contradictions are flagged. Aspirational items without decisions are placed in the Future section. Nothing invented.

---

## HOW TO USE THIS DOCUMENT

- **CONFIRMED DECISIONS** — Use these directly. They were explicitly chosen in Answer Sets 1–4.
- **V1 SCOPE** — What must exist in the first real build.
- **MODULE DEFINITIONS** — Named systems, what they do, what domain they belong to.
- **DATA MODELS** — Fields and structures defined in the spec.
- **PAGE / UI SPECS** — Concrete HTML structure or layout decisions.
- **OPEN QUESTIONS** — Items explicitly flagged as still undecided.
- **FUTURE / DEFERRED** — Valid ideas not yet decided, not invented here.

---

# PART 1 — CONFIRMED DECISIONS

These were explicitly finalised in Answer Sets 1, 2, 3, and 4. Treat them as binding.

---

## 1.1 Platform Identity Model
**Source:** Answer Set 2, Q1 — Decision B

The platform uses a three-layer identity model:

```
Account       = login credentials (email + password)
Profile       = person record (one per human)
Membership    = entity-specific participation record
```

One person may have:
- One platform account
- One core profile
- Multiple memberships, roles, or relationships across different entities

**Example:**
```
Person
→ Platform Account
→ Core Profile
  → TWWP PMA Membership
  → Trustee Role in Trust
  → Volunteer Role in Campaign
```

This resolves the earlier ambiguity between "identity" and "membership." TWWP PMA membership is not the same as platform identity.

---

## 1.2 Two-Zone Architecture
**Source:** Answer Sets 1 and 2 — confirmed in both

The platform is two interacting architectural zones, not one flat system.

### Zone A — Real-Time Device / Control Stack
- ESP32 devices
- MQTT messaging
- Home Assistant
- Live sensor telemetry
- Valve and tap controls
- Grouped Waterhouse dashboards
- Device diagnostics

### Zone B — Ecosystem / Business / Governance Stack
- Entity registry
- Ledgers and financial records
- Governance and legal documents
- Campaigns
- Procurement and catalogues
- Uploads and imports
- Community systems
- Marketing systems

**The Ops App is the coordination layer across both zones.** It does not replace either zone — it surfaces and connects them.

---

## 1.3 Home Assistant Integration Model
**Source:** Answer Sets 2 and 3, Q2/A3 — Decision C (mixed)

The Ops App and Home Assistant interact through a mixed model:

- **Quick controls live inside Ops App** for routine operational actions
- **Deeper configuration and automation remains in Home Assistant**
- **Sign-in / jump link** into HA must exist from within Ops App
- **Grouped display** of sensor dashboards and controls per Waterhouse

Controls to expose through Ops App:
- Valve on / off
- Flow / volume limit settings
- Light on / off
- Alert settings
- Grouped switch controls
- Waterhouse-level dashboard shortcuts

HA remains the deeper automation / configuration environment. Ops App is the operational surface for day-to-day actions.

**Note still open:** Whether Ops App embeds HA panels natively or uses a proxy/link model was decided as "mixed embedded + native controls" (Answer Set 4, B6) — implement native controls first, embed panels where useful.

---

## 1.4 Waterhouse Control Grouping
**Source:** Answer Set 3, A4 — Decision C

Controls should be organised **by Waterhouse**, with grouped tabs or cards inside each Waterhouse context.

Sub-groups within a Waterhouse:
- Sensors
- Switches
- Valves
- Alert settings
- Diagnostics
- Historical data panels

---

## 1.5 Financial / Ledger Model
**Source:** Answer Set 2, Q3 — Decision B and C

Financial control must support two models simultaneously:

1. **Entity-controlled funds** — the entity owns and manages its own money
2. **Managed funds** — the Operations Company holds money on behalf of an entity under a management agreement

**Multi-entity ledger requirements:**
- Entity-owned funds
- Held-on-behalf-of funds
- Cross-entity management agreements
- Tagged transaction purpose (e.g. "tagged for TWWP PMA, held by Ops Co")

**Example flow:**
```
Donation received into Operations Company account
→ tagged for TWWP PMA
→ tracked in PMA ledger view
→ recorded as managed under contract / agreement
```

---

## 1.6 Ledger Source of Truth
**Source:** Answer Set 3, A1 — Decision C

The Ops App ledger module should become the **long-term source of truth** for financial records.

Ingestion may begin from:
- CSV imports
- Email parsing tools
- Receipt photos or screenshots
- AI-assisted extraction workflows

**Linking requirements for imported cost items:**
- Suppliers
- Catalogue items
- Assets
- Campaigns
- Entities
- Ledgers

---

## 1.7 Approval Queue Model
**Source:** Answer Set 4, B1 — Decision D

A **global review queue** with strong filtering. Not siloed inside individual modules.

Primary filter dimensions:
- Entity
- Module
- Priority
- Date
- Reviewer
- Status

---

## 1.8 AI Categorisation Behaviour
**Source:** Answer Set 4, B2 — Decision D

```
High confidence   → auto-classify → create record (may still be reviewable)
Low confidence    → create Draft → require manager approval
```

Imported items support a **draft state** and remain editable before approval. Manager review is always available as a safety gate.

**AI never overrides human approval.**

Record lifecycle for all imported or AI-assisted records:
```
Draft → Needs Review → Approved → Rejected → Revised
```

---

## 1.9 Catalogue / Index System Scope
**Source:** Answer Set 3 (A7) and Answer Set 4 (B3) — Decision D

The catalogue system is a **hybrid catalogue + knowledge index**, not a narrow product list.

It must support structured records for:
- Products
- Suppliers
- Components
- Assets
- Documents
- People
- Linked notes
- Compatibility references

---

## 1.10 Task / Project Management Style
**Source:** Answer Set 4, B4 — Decision D

Full **project workspace style** task system. Tasks are first-class platform objects, not a minor utility.

Minimum capabilities:
- Tasks
- Subtasks
- Notes
- Attachments
- Due dates
- Priorities
- Owners
- Module linkage
- Status tracking
- Page / module context

---

## 1.11 Waterhouse Page as Digital Twin
**Source:** Answer Set 4, B5 — Decision D

The Waterhouse page is a **full digital twin**, not a registry entry.

Minimum sections:
- Summary
- Sensors (grouped)
- Controls (grouped)
- Maintenance
- Notes
- Alerts
- Linked tasks
- Linked documents
- Linked assets
- Linked history

---

## 1.12 Entity Onboarding / Templates
**Source:** Answer Set 3 (A8) and Answer Set 4 (B8) — Decision D

New entity creation should start from a **fuller starter template** including:
- Entity record
- Roles
- Ledger
- Calendar
- Default modules (toggle-enabled)
- Starter documents
- Permissions
- Tasks
- Dashboards

This implies **entity blueprints** or entity templates as a system feature.

---

## 1.13 Calendar as Operational Surface
**Source:** Answer Sets 3 (A9) and 4 (B9) — Decision C and D

Calendar is **not a passive schedule viewer**. It is an active planning and coordination surface.

Calendar must support:
- Events
- Reminders
- Approvals
- Task due dates
- AI-generated planning events (via the capture widget / AI helper)

Approval-required items must appear in calendar as:
- Review tasks
- Approval deadlines
- Flagged events

Long-term direction: **command-centre style view** with AI suggestions.

---

## 1.14 Tap Control Authority Hierarchy
**Source:** Answer Set 2, Q5 — Decision D

```
Platform
→ Entity
→ Host
→ Tap
```

- Global defaults may be defined centrally
- Entities may apply scoped policy layers
- Hosts may influence local settings within allowed bounds
- Taps may have final local overrides where supported

---

## 1.15 V1 Scope Definition
**Source:** Answer Sets 2 (Q4) and 3 (A12) — Decision B then D

V1 is a **builder-oriented operational shell with thin real functionality across key domains**. It is not just a UI prototype.

### V1 Must Include

**Shell and navigation:**
- UI shell and module navigation
- Page-level pop-out dev / context tabs on every page
- Suggestion / change capture widget
- Markdown-linked module note flow
- Future task backlog linkage

**Real thin functionality:**
- Task / project system (full, Decision D from B4)
- Thin ledger / import / catalogue workflows
- Thin HA dashboard / control integration
- Thin Waterhouse / maintenance registry
- Calendar with tasks and approval / review visibility

**Import and approval:**
- CSV / email / image receipt ingestion
- Approval workflows for imported financial items
- Manager review queues linked to calendar / task views

**Entity:**
- Entity creation with roles, ledger, and module toggles
- Sign-in / jump access to Home Assistant

### V1 Must Not Include (deferred)
- Education / course system
- Deep ML analytics
- Public API
- Full commerce / ecommerce
- Membership billing / subscriptions
- Regional chapter management

---

## 1.16 Spreadsheet Transition Model
**Source:** Answer Set 1 (confirmed in Set 3)

Spreadsheets remain the current source of truth for many business / governance records. The Ops App ingestion layer must support CSV imports and bulk uploads as the **transition path**.

Spreadsheets are not being replaced overnight — they are being ingested and gradually superseded module by module.

---

## 1.17 Tap-Map Sync Direction
**Source:** Answer Set 3, A2 — Decision C

Tap-Map and Ops App should support **two-way sync** in a future phase.

Future requirements implied:
- External system field mapping
- Sync conflict rules
- Field ownership rules
- Admin-level sync control toggles

TWWP PMA membership (in the live Tap-Map system) is separate from Ops Platform identity but will eventually connect.

---

## 1.18 Page-Level Dev / Context Panel
**Source:** Answer Sets 2 (Q4) and 3 (A5)

Every page or module must include a **pop-out development / context tab** containing:
- Build intent notes
- Task list
- Known issues
- Change requests
- Suggestion text box
- Markdown export / update hooks

This is already partially built in the current index.html (the dev notes system). It should be systematised across all pages.

---

## 1.19 Expense / Cost Ingestion Sources
**Source:** Answer Set 3, A6 — Decision D plus image input

Supported input types:
- Email parsing
- CSV import
- Parser assistant workflows
- Receipt photo upload
- Screenshot upload

The import system must handle both structured (CSV) and semi-structured (images, emails) evidence.

---

## 1.20 HA Documentation Mirroring
**Source:** Answer Set 3, A10 — Decision C

Ops App should **mirror HA entity / service documentation** into the platform over time.

Phase 1: Notes and references first.
Later: Structured mirrored documentation.

---

## 1.21 Referral System Scope
**Source:** Answer Set 1 (confirmed)

The referral engine should support referrals across all main conversion types:
- New members
- New hosts
- Donors / supporters
- Course participants (future)
- Product customers (future)

---

## 1.22 Commerce Model
**Source:** Answer Set 1

Commerce must support both:
- Procurement (internal sourcing)
- Public sales (external customers)

Donations and sales should remain **legally separate** but **operationally connected** — separate ledgers, checkouts, and receipts, but a user can move between donation and sales flows in one journey.

---

# PART 2 — OPEN QUESTIONS

These were explicitly flagged as still undecided in the spec. Do not treat them as decided.

| Topic | Current State | Source |
|-------|--------------|--------|
| Entity module toggles | Not finalized — what gets enabled/disabled per entity | Answer Set 4, B7 |
| Highest build priority after telemetry base | Still undecided | Answer Set 1 |
| Volunteer / contractor / trustee modeling | Still undecided | Answer Set 1 |
| Public API intent | Still unclear | Answer Set 1 |
| HA as permanent core vs sidecar | Not fully fixed | Answer Set 1 |
| Source of truth for calendar events | Decision B stated (Ops App canonical) but not fully confirmed | Answer Set 3, A9 |

---

# PART 3 — MODULE DEFINITIONS

The spec defines a canonical Systems Registry. Below are all modules with their System ID, domain, and purpose. Status is from the spec — "planned" means designed but not built, "concept" means still early.

---

## Infrastructure Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-INF-001 | Waterhouse Infrastructure Registry | Tracks installed Waterhouses and core site infrastructure | Planned |
| SYS-INF-002 | Tap Usage Authorization System | Controls public and member dispensing limits | Planned |
| SYS-INF-003 | Tap Lock Control System | Valve opening and closing logic at device level | Planned |
| SYS-INF-004 | Water Quality Monitoring System | Measures and tracks water quality conditions | Planned |
| SYS-INF-005 | Geospatial Infrastructure Layer | Maps taps, sites, and maintenance zones geographically | Concept |
| SYS-INF-006 | Lab Testing Integration | Tracks sample collection and external lab validation | Planned |

---

## Operations Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-OPS-001 | Campaign Management System | Coordinates tap installation campaigns | Planned |
| SYS-OPS-002 | Site Assessment Module | Evaluates host locations before installation | Planned |
| SYS-OPS-003 | Installation Project Management | Tracks install scheduling and commissioning | Planned |
| SYS-OPS-004 | Maintenance Scheduling Engine | Creates and manages maintenance tasks | Planned |
| SYS-OPS-005 | Issue & Incident Management | Tracks faults, vandalism, outages, complaints | Planned |
| SYS-OPS-006 | Volunteer & Workforce Coordination | Manages volunteers, technicians, educators, contractors | Planned |
| SYS-OPS-007 | Operations Dashboard Model | Main operational dashboard views | Planned |
| SYS-OPS-008 | Device Lifecycle Model | Tracks device lifecycle from stock to decommission | Planned |
| SYS-OPS-009 | Tap Campaign Lifecycle Model | Defines campaign stages end-to-end | Planned |

---

## Governance Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-GOV-001 | Governance & Legal Systems | Manages trusts, PMAs, governance structures | Planned |
| SYS-GOV-002 | Trustee & Board Management | Maintains trustee records and board activities | Planned |
| SYS-GOV-003 | Calendar & Scheduling System | Coordinates governance and operational schedules | Planned |
| SYS-GOV-004 | Legal Document Library | Stores trust deeds, agreements, policies and filings | Planned |
| SYS-GOV-005 | Contract & Agreement Templates | Manages reusable legal templates | Planned |
| SYS-GOV-006 | Compliance & Regulatory Tracking | Tracks reporting and legal obligations | Planned |
| SYS-GOV-007 | Records & Archive Management | Stores minutes, resolutions, reports and archives | Planned |
| SYS-GOV-008 | Policy & Governance Library | Knowledge base for governance rules and proposals | Concept |

---

## Knowledge Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-KNO-001 | Education & Course System | Hosts GSD University courses and learning paths | Planned (V2+) |
| SYS-KNO-002 | Research & Knowledge Library | Searchable archive of research and references | Planned (V2+) |
| SYS-KNO-003 | Certification & Training System | Issues and tracks training certifications | Planned |
| SYS-KNO-004 | Documentation Library | Stores architecture and operational docs | Planned |
| SYS-KNO-005 | Media Production Workflows | Manages media planning, review and publishing | Planned |

---

## Funding Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-FND-001 | Funding, Donations & Grants Engine | Manages donations, grants and funding flows | Planned |
| SYS-FND-002 | Campaign Funding System | Manages contributions to tap campaigns | Planned |
| SYS-FND-003 | Resource Donation Incentive Program | Tracks donated materials and labour incentives | Planned |
| SYS-FND-004 | Sponsorship Tracking | Tracks sponsor relationships and commitments | Concept |
| SYS-FND-005 | Subscription & Membership Billing | Manages paid memberships and renewals | Concept |

---

## Community Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-COM-001 | Identity & Profile System | Unified people profile across the ecosystem | Planned |
| SYS-COM-002 | Membership Management System | Stores and manages membership records | Planned |
| SYS-COM-003 | Roles System | Tracks Quencher, Host, Facilitator, Installer, Craftsman, Staker | Planned |
| SYS-COM-004 | Community Engagement System | Supports groups, participation, volunteer engagement | Planned |
| SYS-COM-005 | Affiliate & Referral Engine | Tracks referrals across members, courses, donations and sales | Planned |
| SYS-COM-006 | Reputation & Contribution Scoring | Scores contribution and trust over time | Planned |
| SYS-COM-007 | Member Activity & Credit System | Rewards actions like sampling and reporting | Planned |
| SYS-COM-008 | Tap Guardian Role System | Supports local guardians responsible for taps | Planned |
| SYS-COM-009 | Community Reputation System | Broader contribution and trust scoring | Planned |

---

## Marketing Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-MKT-001 | Marketing, Social & Growth Systems | Coordinates outreach and marketing across entities | Planned |
| SYS-MKT-002 | Social Media Management | Schedules and tracks posts across channels | Planned |
| SYS-MKT-003 | Automated Marketing Engine | Drives onboarding, outreach, campaign announcements | Planned |
| SYS-MKT-004 | Campaign Marketing System | Landing pages, links, QR flows and share assets | Planned |
| SYS-MKT-005 | Content Library | Stores reusable outreach and campaign content | Planned |
| SYS-MKT-006 | Growth Analytics | Tracks growth, reach, conversions and expansion signals | Planned |
| SYS-MKT-007 | Local Outreach Tracker | Tracks flyer campaigns, events and local promotion | Concept |

---

## Commerce Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-ECO-001 | Products Module | Manages products sold or deployed | Planned |
| SYS-ECO-002 | Product Bundles | Grouped products sold together | Planned |
| SYS-ECO-003 | Composite Products | Configurable assembled products | Planned |
| SYS-ECO-004 | Ecommerce & Sales Workflows | Order and checkout processes | Planned |
| SYS-ECO-005 | Procurement System | Sourcing and purchase workflows | Planned |
| SYS-ECO-006 | Supplier Procurement Automation | Automated supplier scraping and import | Planned |
| SYS-ECO-007 | Inventory Management | Tracks stock and storage | Planned |
| SYS-ECO-008 | Store & Product Commerce | Storefront and product deployment layer | Planned |
| SYS-ECO-009 | Product Procurement Engine | Structured sourcing comparison engine | Planned |
| SYS-ECO-010 | Supply Chain Intelligence | Supplier reliability, cost history, shipping intelligence | Concept |

---

## Hardware Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-HWD-001 | Hardware Network | Overall embedded device and probe architecture | Planned |
| SYS-HWD-002 | Device Fleet Architecture | Defines device classes and firmware modules | Planned |
| SYS-HWD-003 | IoT Device Management | Manages deployed devices and attributes | Planned |
| SYS-HWD-004 | Hardware Asset Registry | Tracks physical hardware assets | Planned |
| SYS-HWD-005 | Hardware Component Library | Master registry of reusable parts | Planned |
| SYS-HWD-006 | Sensor Compatibility Registry | Maps approved sensors to devices and protocols | Planned |
| SYS-HWD-007 | Waterhouse BOM Automation | Generates BOMs for builds and installs | Planned |
| SYS-HWD-008 | Manufacturing & Assembly Tracking | Tracks builds, QA and batch assembly | Planned |
| SYS-HWD-009 | Waterhouse Infrastructure Schema | Defines installation composition and lifecycle | Planned |
| SYS-HWD-010 | RS485 Sensor Network | Communication bus model for sensors | Planned |

---

## Data Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-DAT-001 | Sensor Monitoring System | Captures telemetry from monitoring devices | Planned |
| SYS-DAT-002 | Device Telemetry Architecture | Defines device-to-platform data flow | Planned |
| SYS-DAT-003 | Water Telemetry Data Model | Time-series structure for readings | Planned |
| SYS-DAT-004 | MQTT Topic Hierarchy | Messaging namespace for telemetry and control | Planned |
| SYS-DAT-005 | RS485 Sensor Register Map | Logical mapping of sensor registers | Planned |
| SYS-DAT-006 | Telemetry Anomaly Detection | Thresholding and outlier detection | Planned |
| SYS-DAT-007 | Water Quality Analytics Models | Trend analysis and predictive quality insights | Planned |
| SYS-DAT-008 | Operations Analytics | Campaign, usage and device performance analysis | Planned |
| SYS-DAT-009 | Data Logging & Offline Sync | Handles buffering and sync after outages | Planned |
| SYS-DAT-010 | Data Pipeline / ETL Layer | Ingestion, processing and warehousing flow | Concept |
| SYS-DAT-011 | System Knowledge Graph | Graph model of entities and relationships | Planned |
| SYS-DAT-012 | Platform Capability Map | Maps ecosystem domains and subsystems | Planned |

---

## Security Domain

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-SEC-001 | Security & Authentication | User, device and API security controls | Planned |
| SYS-SEC-002 | Permissions & Roles System | Role-based module and action permissions | Planned |
| SYS-SEC-003 | Device Provisioning & Authentication | Secure onboarding for devices | Planned |
| SYS-SEC-004 | Tap Authorization Protocol | Secure validation before water dispense | Planned |
| SYS-SEC-005 | Audit & Logging Controls | Audit trail for user and system actions | Concept |
| SYS-SEC-006 | Identity & Access Control Engine | Full access-control layer across entities and modules | Concept |

---

## Platform / Integration Systems

| System ID | Name | Purpose | Status |
|-----------|------|---------|--------|
| SYS-PLT-001 | Dashboard | Overall platform overview | Planned |
| SYS-PLT-002 | Integrations Module | Tracks connected systems and APIs | Planned |
| SYS-PLT-003 | API Architecture | Defines REST and integration interfaces | Planned |
| SYS-PLT-004 | Automation Workflow Engine | Handles event-driven workflows | Planned |
| SYS-PLT-005 | System Logging & Observability | Monitors system health and events | Planned |
| SYS-PLT-006 | Architecture Tool Stack | Tracks chosen and candidate tools | Planned |
| SYS-PLT-007 | Development & Engineering Integration | Ties repositories, firmware and issue tools together | Planned |
| SYS-PLT-008 | Deployment & Environment Management | Manages dev, staging and production environments | Concept |
| SYS-PLT-009 | Public API & Developer Layer | Future public / dev access model | Concept |
| SYS-PLT-010 | Testing & Simulation Layer | Test harnesses, mocks and simulations | Concept |
| SYS-PLT-011 | Backup & Disaster Recovery | Backup, restore and continuity planning | Concept |
| SYS-PLT-012 | System Configuration Layer | Central environment and service settings | Concept |

---

# PART 4 — DATA MODELS

Concrete field definitions from the spec. These are starting points, not finalised schemas.

---

## Profile (Identity Layer)
```
profile_id        UUID — unique ecosystem profile identifier
person_name       string — full name
primary_email     string — main contact email
phone             string
entity_links      array — related organisations or ventures
status            enum: active / inactive / pending
profile_type      enum: member / trustee / volunteer / contractor / donor
```

## Account (Login Layer)
```
user_id           UUID
email             string
password_hash     string
role_id           UUID
created_at        timestamp
```

## Member (Entity Participation Layer)
```
member_id         UUID
user_id           UUID — links to account
membership_status enum: active / pending / suspended / expired
join_date         date
```

## Entity
```
entity_id         UUID
name              string
type              enum: charity / trust / pma / company / initiative
description       text
related_projects  array
related_products  array
```

## Campaign
```
campaign_id       string
name              string
region            string
facilitator       string
host              string
funding_status    string
installation_status string
start_date        date
completion_date   date
```

## Waterhouse
```
waterhouse_id     string
host_site_id      UUID
installation_date date
filter_configuration  text — filtration stages
monitoring_configuration  text — installed sensors
device_node_id    string — ESP32 node ID
location          text
guardian          string
installer         string
maintenance_status string
```

## Device (IoT)
```
device_id         UUID
device_type       string
firmware_version  string
installation_site UUID
last_seen         timestamp
mqtt_topic        string
connectivity_status string
sensor_configuration text
```

## Telemetry (Time-series)
```
telemetry_id      UUID
device_id         UUID
sensor_type       enum: pH / ORP / TDS / temperature / flow / chlorine
value             float
unit              string
timestamp         timestamp
```

## Maintenance Task
```
task_id           UUID
asset_id          UUID — linked Waterhouse or device
maintenance_type  string
assigned_technician string
scheduled_date    date
completion_status enum: open / in_progress / complete / cancelled
notes             text
```

## Financial Entry
```
entry_id          UUID
entity_id         UUID
type              enum: expense / donation / reimbursement / income
amount            decimal
description       text
category          string
date              date
method            string
ref               string — invoice or receipt number
contact           string — payer or payee
notes             text
linked_campaign   UUID (optional)
linked_asset      UUID (optional)
approval_status   enum: draft / needs_review / approved / rejected / revised
```

## Imported Record (Approval Queue)
```
record_id         UUID
source_type       enum: csv / email / photo / screenshot / manual
raw_content       text
parsed_data       json
confidence_score  float — AI confidence 0.0 to 1.0
status            enum: draft / needs_review / approved / rejected / revised
reviewer          UUID
reviewed_at       timestamp
linked_to         array — catalogue items, suppliers, assets, campaigns
```

## Supplier
```
supplier_id       UUID
name              string
platform          enum: AliExpress / Alibaba / CJ / DirectManufacturer / Other
contact           string
products_supplied array
shipping_time     string
reliability_score float
notes             text
```

## Product
```
product_id        UUID
name              string
type              enum: single / bundle / composite / digital / service
entity_id         UUID
cost              decimal
price             decimal
supplier_id       UUID
description       text
```

## Asset (Physical Hardware)
```
asset_id          UUID
asset_type        string
location          UUID — Waterhouse or storage
owner_entity      UUID
status            enum: in_stock / deployed / maintenance / retired
```

## Task (Platform Tasks)
```
task_id           UUID
title             string
description       text
owner             UUID — profile
due_date          date
priority          enum: low / normal / high / urgent
status            enum: open / in_progress / complete / cancelled
module_link       string — which page or module
parent_task       UUID (optional — for subtasks)
attachments       array
```

## Calendar Event
```
event_id          UUID
event_type        enum: meeting / maintenance / installation / approval / reminder / custom
title             string
start_time        datetime
end_time          datetime
participants      array — profile IDs
location          string
related_module    string
related_record    UUID
is_approval_item  boolean
```

## Trustee
```
trustee_id        UUID
name              string
role              string
appointment_date  date
term_length       string
contact_info      string
```

## Referral
```
referral_id       UUID
referrer_profile_id UUID
referral_code     string
referred_profile_id UUID
campaign_id       UUID (optional)
reward_type       enum: credit / payout / badge
conversion_status enum: pending / converted / paid
```

## Hardware Component
```
component_id      UUID
part_name         string
category          enum: electronics / sensor / plumbing / power / enclosure / other
supplier          UUID
part_number       string
compatibility_notes text
datasheet_link    URL
```

## Sensor Registry Entry
```
sensor_id         UUID
sensor_type       enum: pH / ORP / TDS / temperature / flow
protocol          enum: RS485 / analog / digital
register_map      text
calibration_method text
compatible_devices array — device class IDs
```

---

# PART 5 — ROLES AND PERMISSIONS

## Operational Roles (TWWP Network)
Defined in the spec as core ecosystem roles:
- **Quencher** — standard water collecting member
- **Host** — property owner hosting a Waterhouse
- **Facilitator** — campaign coordinator
- **Installer** — technical installation person
- **Craftsman** — builds or fabricates Waterhouses
- **Staker** — community funder of a campaign

## Platform Roles
- Admin — full system access
- Operations Manager — operations management
- Campaign Facilitator — campaign coordination
- Installer / Technician — maintenance tasks
- Host — local infrastructure access
- Data Analyst — read and reporting access
- Member — water access
- Guest — limited viewing

## Permission Scope Model
Permissions should be scoped at three levels:
```
Entity + Module + Asset/Tap/Device
```
(Source: Answer Set 1 — confirmed)

---

# PART 6 — HARDWARE AND DEVICE ARCHITECTURE

## Device Classes
```
NODE-MON    Monitoring node collecting sensor data
NODE-TAP    Tap control node
NODE-GATE   Gateway bridging networks
NODE-MESH   Mesh relay node
```

## ESP32 Firmware Modules
| Module | Function |
|--------|----------|
| device_core | hardware initialisation |
| telemetry | sensor polling |
| rs485_driver | communication with sensors |
| mqtt_client | telemetry publishing |
| valve_control | tap control |
| storage | SD card logging |
| diagnostics | health monitoring |
| ota_update | firmware updates |

## MQTT Topic Structure
```
twwp/device/{device_id}/status
twwp/device/{device_id}/firmware
twwp/device/{device_id}/logs
twwp/waterhouse/{node_id}/telemetry
twwp/waterhouse/{node_id}/telemetry/ph
twwp/waterhouse/{node_id}/telemetry/orp
twwp/waterhouse/{node_id}/telemetry/tds
twwp/waterhouse/{node_id}/telemetry/temp
twwp/waterhouse/{tap_id}/usage
twwp/waterhouse/{node_id}/alerts
twwp/waterhouse/{tap_id}/command/open
twwp/waterhouse/{tap_id}/command/close
```

## Telemetry Payload (standard)
```json
{
  "ph": 7.1,
  "orp": 320,
  "tds": 8,
  "temperature": 18.4,
  "timestamp": "ISO8601"
}
```

## RS485 Register Map (Yieryi 4-in-1 probe example)
| Register | Measurement |
|----------|-------------|
| 0x0001 | pH |
| 0x0002 | ORP |
| 0x0003 | TDS |
| 0x0004 | Temperature |

## Waterhouse Filtration Sequence
```
Water Supply
→ Pre-Filters (sediment + carbon block)
→ RO Membrane
→ Deionizer / DI resin
→ Remineralisation cartridge
→ Public Tap
```

## Firmware Tooling
- **PlatformIO** — candidate, main build tool for structured ESP32 development
- **Arduino-compatible libraries** — candidate, curated and version controlled
- **ESPHome** — experimental, good for rapid prototypes and simpler HA-native devices, not production tap control

## Network Strategy
- **RS485** — internal probe / meter network inside Waterhouse units
- **WiFi** — primary uplink where available
- **LoRa / Meshtastic** — experimental, mesh relay or fallback for sparse coverage
- **Ethernet** — deferred

---

# PART 7 — ARCHITECTURE TOOL STACK

Status categories: Chosen / Candidate / Experimental / Rejected / Deferred

| Layer | Tool | Status | Notes |
|-------|------|--------|-------|
| Relational Data | Supabase / Postgres | Candidate | Strong for core records, auth, storage, business data |
| Relational Data | Self-managed Postgres | Candidate | More control if self-hosting important |
| Time-Series Telemetry | InfluxDB | Candidate | Best fit for dense telemetry, retention, downsampling |
| Time-Series Telemetry | Postgres telemetry tables | Experimental | Acceptable for early prototypes only |
| Dashboarding | Grafana | Candidate | Strong for telemetry dashboards, engineering observability |
| Dashboarding | Home Assistant dashboards | Experimental | Fast ops visibility during early stages |
| Dashboarding | Custom Ops dashboard | Candidate | Best for long-term business + operational workflows |
| Device Firmware | PlatformIO | Candidate | Structured ESP32 development |
| Device Firmware | Arduino IDE | Experimental | Quick tests only |
| Device Framework | Custom ESP32 firmware | Candidate | Advanced tap control, quotas, custom RS485 logic |
| Device Framework | ESPHome | Experimental | Rapid prototypes and HA-native simple devices |
| Messaging | MQTT broker | Candidate | Core device messaging backbone |
| Automation | Home Assistant | Candidate | Automation edge logic, device state orchestration |
| Automation | n8n | Candidate | Workflow automation across APIs and external services |
| Automation | Backend-native job runner | Candidate | Durable platform-side automations |
| Storage | Object storage | Candidate | Images, documents, logs, exports |
| Storage | SD card edge storage | Candidate | Offline telemetry buffering |
| Storage | Local file system only | Rejected | Too fragile as primary long-term store |
| Network | RS485 | Candidate | Internal probe network |
| Network | WiFi | Candidate | Main uplink |
| Network | LoRa / Meshtastic | Experimental | Fallback or sparse coverage |
| Network | Ethernet | Deferred | Where site conditions allow |
| Integration | Home Assistant | Candidate | Core integration for automation and local ops |
| Integration | Payment processors | Deferred | Needed once subscriptions formalised |
| Integration | Email provider | Candidate | Alerts, onboarding, account workflows |
| Integration | Mapping services | Candidate | Tap-Map and geographic infrastructure planning |

**Note:** No tools are listed as "Chosen" — all are still at Candidate or below. Avoid treating Supabase or InfluxDB as finalised.

---

# PART 8 — PAGE / UI SPECIFICATIONS

## 8.1 Waterhouse Digital Twin Page — Full Spec
**Source:** Sections 035 and 036

### Layout Zones
1. Sticky Header — Waterhouse identity + actions
2. Summary Strip — status + key metrics (4 cards)
3. Main Grid (2-column)
   - Left: monitoring + controls + history
   - Right: tasks + maintenance + notes/docs
4. Lower Linked-Object Sections (tab-bar)
   - Assets
   - Deployments
   - Documents
   - Notes
5. Dev Context Panel (persistent, every page)

### Header Actions
- Open in HA (external link)
- Add Task
- Log Maintenance
- Settings (future)

### Summary Strip Cards
- Flow Rate
- Total Volume Today
- Water Quality Status
- Last Sync Time

### Sensor Groups (Left, one card per group)
Each Sensor Group Card shows:
- Group name (e.g. "Filtered Output")
- HA group mapping note (e.g. `sensor.wh1.filtered.*`)
- pH, TDS, ORP, Temperature readings
- Status indicator
- Last updated time

### Control Groups (Left, one card per group)
Each Control Group Card shows:
- Group name
- HA entity mapping note
- Valve on / off buttons
- Volume limit input
- Light on / off
- Alert toggle

### Tasks Panel (Right)
- Active tasks
- Due tasks
- Overdue tasks
- Create task button
- Complete + open detail actions

### Maintenance Section (Right)
- Checklist format
- Completion status
- Notes per item
- Readings per item

### History Timeline (Left, lower)
Events visible:
- Deployments
- Maintenance
- Alerts
- Changes

### Lower Tab Sections
- **Assets** — installed components, filters, sensors, hardware (linked to Item + Assignment + Deployment)
- **Deployments** — past deployments, current configuration
- **Documents** — operational notes, attached files, manuals
- **Notes** — operational freetext

### Waterhouse UI States
- loading
- healthy
- warning
- offline
- maintenance mode
- alert active

### Dev Context Panel for Waterhouse Page
Must include:
- Mapped HA entities
- Mapped MQTT topics
- Linked service calls
- Backend notes
- Next tasks
- Known issues
- Suggestion / change capture

### V1 Implementation Order
**Implement first:**
- Static HTML structure
- localStorage Waterhouse object
- Placeholder sensor groups
- Placeholder control groups
- Linked task / doc / asset panels

**Then wire in:**
- HA sign-in link
- Grouped sensor values
- Grouped control actions
- Maintenance / task / doc integration

**Avoid in first pass:**
- Deeply nested charts
- Over-complicated tabs
- Duplicate pages for same Waterhouse data

### HTML Skeleton (from spec section 036.3)
The spec includes a full ready-to-use HTML skeleton for both the Waterhouse list page and the Waterhouse detail page. Key IDs:
- `page-waterhouses` — list page
- `page-waterhouse-detail` — detail / digital twin page
- `whSummaryStrip` — 4-card grid
- `whSensorGroups` — sensor group container
- `whControlGroups` — control group container
- `whHistoryTimeline` — history section
- `whTasksPanel` — tasks panel
- `whMaintenancePanel` — maintenance section
- `whNotesDocsPanel` — notes and docs
- `whLowerTabs` — tab bar for assets / deployments / documents / notes
- `whLower-assets`, `whLower-deployments`, `whLower-documents`, `whLower-notes` — lower tab content

---

## 8.2 Import & Approval System — Full Spec
**Source:** Section 031

### Import Sources (V1)
- CSV uploads
- Email parsing
- Receipt photos
- Screenshots
- Manual entry

### Import Sources (Future)
- API ingestion from AliExpress, Alibaba
- Automated scraping tools

### Import Processing Flow
```
1. Data uploaded or received
2. Parser extracts structured data
3. AI assists categorisation (optional)
4. Record created in Draft state
5. Record enters Approval Queue
6. Manager reviews: approve / reject
7. Record becomes active and linked
```

### Record Lifecycle
```
Draft → Needs Review → Approved → Rejected → Revised
```

### Approval Queue — required filters
- Entity
- Module
- Priority
- Date
- Reviewer
- Status

### Queue Types
- Financial approvals
- Catalogue approvals
- Document approvals
- System / config approvals

### Calendar Integration
All approval-required items must appear in calendar as:
- Review tasks
- Approval deadlines
- Flagged events

### Catalogue Linking
On import, system attempts to auto-link to:
- Existing items
- Suppliers
- Assets

If no match found: create new catalogue entry (Draft state)

### System Rules
1. No imported data becomes active without approval (if flagged)
2. All records must be linkable to core objects
3. Approval history must be stored
4. AI never overrides human approval

---

## 8.3 Operations Dashboard — Panels Required
**Source:** Stage 7

| Panel | Displays |
|-------|---------|
| Infrastructure Overview | Number of taps, active Waterhouses, device health |
| Telemetry Overview | Real-time sensor readings, alerts |
| Campaign Overview | Active campaigns, installations pending |
| Procurement Overview | Supplier orders, inventory levels |
| Maintenance Overview | Upcoming service tasks |

---

## 8.4 Entities Supported by Platform
**Source:** Stage 1, confirmed throughout

The platform explicitly supports these entities from day one:
- TWWP PMA
- GSD Collective Charity Trust
- Fuente Viva
- GSD Shop
- Kendall Samkin
- Future ventures

A separate **Operations Company** owns and manages the Ops Platform and may hold funds on behalf of other entities under management agreements.

---

# PART 9 — EVENT MAP

System events that trigger automation or data processing.

## Device Events
| Event | Description |
|-------|-------------|
| device_online | Device connects to network |
| device_offline | Device lost connectivity |
| firmware_update_available | New firmware version detected |
| telemetry_received | Sensor data received |
| device_error | Device reports error |

## Water System Events
| Event | Description |
|-------|-------------|
| tap_request | User requests water |
| tap_authorized | Authorization granted |
| tap_dispense_complete | Dispensing finished |
| water_quality_alert | Sensor anomaly detected |

## Operational Events
| Event | Description |
|-------|-------------|
| campaign_created | New campaign initiated |
| campaign_funded | Campaign funding target reached |
| installation_completed | New Waterhouse commissioned |
| maintenance_required | Maintenance task generated |

## Commerce Events
| Event | Description |
|-------|-------------|
| product_imported | Supplier product scraped |
| purchase_order_created | Procurement initiated |
| inventory_updated | Stock level changed |

## Example Automation Chain
```
Telemetry anomaly → water_quality_alert event → Maintenance task generated → Calendar approval item created
```

---

# PART 10 — CAMPAIGN LIFECYCLE MODEL

Tap installation campaigns follow a standardised lifecycle:

```
1.  Community interest detected
2.  Host site assessment
3.  Campaign launched
4.  Community funding raised
5.  Procurement of materials
6.  Waterhouse construction
7.  ESP32 node provisioning
8.  Installation
9.  Telemetry verification
10. System activation
11. Monitoring and maintenance
```

---

# PART 11 — DEVICE LIFECYCLE MODEL

```
1. Manufacturing
2. Inventory storage
3. Device provisioning
4. Installation
5. Operation
6. Firmware updates
7. Maintenance
8. Decommission
```

---

# PART 12 — TAP AUTHORIZATION FLOW

```
User → Tap-Map App → Authorization API → ESP32 Tap Controller
→ Valve Activation → Flow Meter Tracking → Usage Data → Ops Platform
```

**Access limits (example, not final policy):**
- Guest / public: ~400 ml sample
- Member daily: up to 20 L
- Member weekly: up to 30 L

---

# PART 13 — GOVERNANCE STRUCTURES

## Entity Types
| Type | Description |
|------|-------------|
| Charity Trust | Non-profit entity supporting infrastructure funding |
| PMA (Private Membership Association) | Member-based operational network |
| Trading Companies | Commercial entities supporting funding and operations |
| Project Initiatives | Specific initiatives such as water campaigns |

## Board and Trustee Activities Tracked
- Board meetings
- Resolutions
- Policy approvals
- Strategic planning decisions

## Legal Document Categories
- Trust Documents (trust deeds, amendments)
- Governance Documents (policies, manuals)
- Membership Agreements (PMA terms)
- Contractor Agreements (installer, facilitator)
- Sponsorship Agreements
- Liability Waivers
- Regulatory Documents

## Contract Template Types
- Host Agreement
- Installer Contract
- Facilitator Agreement
- Sponsorship Agreement
- Donation Agreement
- Vendor Agreement

---

# PART 14 — CONTRIBUTION AND REPUTATION

## Contribution Sources (for reputation scoring)
- Hosting infrastructure
- Installing Waterhouses
- Maintenance work
- Donations
- Campaign support
- Educational contributions
- Research contributions
- Community moderation
- Volunteer hours

## Reputation Metrics
| Metric | Description |
|--------|-------------|
| contribution_score | Weighted contribution total |
| reputation_level | Trust tier or recognition level |
| completed_tasks | Number of verified completed actions |
| volunteer_hours | Logged contribution time |
| verified_contributions | Approved ecosystem contributions |

---

# PART 15 — FUTURE / DEFERRED ITEMS

These are valid ideas from the spec that have not been given a confirmed decision yet. They are real features for later phases. Do not build them in V1.

- ML-based anomaly detection and predictive maintenance models
- Campaign growth forecasting (AI)
- Infrastructure expansion modelling (where to put next taps)
- Graph relationship visualisation (node-edge view of entities)
- ESPHome mesh relay network (LoRa / Meshtastic)
- GSD University course hosting and student tracking
- Research and knowledge library (public/private)
- Affiliate and referral engine (beyond basic tracking)
- Regional chapter management
- Community forums and discussion boards
- Lab testing integration (sample chain-of-custody)
- Certification and training system
- Ecommerce checkout and order fulfilment
- Subscription / membership billing
- Stripe payment links and recurring billing
- Procurement AI pipeline (supplier auto-scraping)
- OTA firmware management through Ops App
- Multi-region database replication
- Full public API and developer layer
- Audit and logging controls (deep)
- Backup and disaster recovery system
- Testing and simulation layer
- Media production workflows
- Manufacturing and assembly batch tracking

---

# PART 16 — NOTED CONTRADICTIONS FROM SOURCE DOCUMENT

These contradictions exist in the source spec. Flagged so they don't cause confusion during build.

**Contradiction 1 — Identity vs Membership**
Early sections treat membership and identity as the same. Answer Set 2 resolved this: Account / Profile / Membership are separate layers. Use Answer Set 2 as canonical.

**Contradiction 2 — Source of truth**
Spreadsheets are acknowledged as current source of truth for business records, but the spec also says Ops App ledger becomes source of truth. Resolution: Ops App is the long-term target; CSV ingestion is the transition path. Both are true for different time horizons.

**Contradiction 3 — HA as core vs sidecar**
Early stages treat HA as primary; later stages treat Ops App as primary. Resolution from Answer Sets 2 and 3: Ops App is the operational surface; HA is the automation / configuration environment. Neither replaces the other — they integrate.

**Contradiction 4 — Public tap access rules**
Some sections say open public access, others say membership required. Resolution from Answer Set 2 (Decision D): hierarchy is Platform → Entity → Host → Tap. Global defaults exist, host overrides are allowed within bounds. Exact policy hierarchy still needs a dedicated spec section.

**Contradiction 5 — MQTT topic structure repeated with variations**
MQTT topics appear three times with slightly different structures. The most complete version (from Stage 8) is in Part 6 of this document. Use that.

**Contradiction 6 — V1 scope creep**
Answer Set 2 said V1 = UI + workflows + builder shell. Answer Set 3 then expanded V1 to include "thin real functionality across all three zones." Resolution: V1 includes thin real functionality, not just UI shell. See Part 1, section 1.15 for the final V1 definition.

---

# APPENDIX — GITHUB REPO STRUCTURE
*From spec (recommended, not confirmed as final)*

```
twwp-platform/
├── firmware/        ESP32 firmware code
├── hardware/        device schematics, wiring, pinouts
├── backend/         platform backend services
├── api/             REST API definitions
├── automation/      Home Assistant automation configs
├── dashboard/       operations dashboard UI
├── tap-map/         Tap-Map web/mobile application
├── docs/            architecture documentation
├── scripts/         deployment and provisioning scripts
├── analytics/       telemetry analytics models
├── integrations/    external platform connectors
├── storage/         file conventions and storage adapters
└── tests/           validation and regression testing
```

---

*End of distilled reference. Total items: 22 confirmed decisions, 6 open questions, 75+ named modules, 20+ data models, 2 full page specs, 4 lifecycle models, 15 future items.*
*Last updated from source: 2026-03-17*
