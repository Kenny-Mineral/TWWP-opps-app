# Sprint D Handoff — 2026-03-24

## Summary
Sprint D (2026-03-24) completed all 9 tasks: Onboarding Wizard enhancements, User Management, Email Service infrastructure, Email Providers page, Stripe page, VIP member tagging, Waitlist page, Blog Management, and AI News Scraper pipeline.

## Tasks Completed (D1–D9)

### D1 — Onboarding Wizard (7 steps)
- Step 1: org_type dropdown (Water Network / Community Trust / Tool Library / Cooperative / Other)
- Step 2: Live branding preview with color/logo picker
- Step 3: Guardian email field + location type label
- Step 4: AI provider selector (Gemini/Anthropic/OpenAI/OpenRouter) with key test
- Step 5: Status cards (Rails API, Google, Email, Tap-Map) with Configure buttons
- Step 6: Invite users via POST /api/users/invite
- Step 7: Sets org_config.setup_complete=true, org_id='twwp'
- Resume on reopen via org_config.wizard_step persistence
- "Redo Setup Wizard" button clears state and resets

### D2 — User Management
- Rails endpoints: GET /api/users, POST /api/users/invite, PATCH /api/users/:id, DELETE /api/users/:id, POST reset_password
- Migration adds: name, last_seen_at, invited_by, temp_password columns
- UsersController admin-gated with require_admin! check
- Frontend page-usermgmt with stats, search, filters, user table, invite modal
- Current user highlighted, cannot deactivate self

### D3 — Email Service Infrastructure
- EmailService.send_email() routes to Resend / SendGrid / Brevo / Mailtrap
- Provider selection via EmailConfig.last.provider || ENV['EMAIL_PROVIDER']
- Test mode routes to Mailtrap
- POST /api/email/test endpoint
- EmailConfig migration with provider, from_address, test_mode fields

### D4 — Email Providers Page
- New Communications sidebar section with "Email Providers" item
- 6 provider cards (Resend/SendGrid/Brevo/Mailtrap)
- Provider-specific config fields:
  - Resend: API key + verified domains list
  - SendGrid: API key + from email/name
  - Brevo: API key + sender name/email/SMS key
  - Mailtrap: host/port/username/password (also used for test mode)
- From-address manager with default selection
- Test/Live mode toggle
- Sending stats with 14-day bar chart

### D5 — Stripe Page
- 4 Rails endpoints in TapMapController:
  - GET /api/tap_map/stripe_overview (MRR, total revenue, subscriber counts)
  - GET /api/tap_map/stripe_customers (top customers by total_paid)
  - GET /api/tap_map/stripe_charges (paginated, 20/page)
  - GET /api/tap_map/stripe_subscriptions (with status filter, plan breakdown)
- Overview tab: MRR, revenue, active/total subscribers, 12-week revenue chart
- VIP Members tab: leaderboard with 💎 badges, "Sync to Contacts" button
- Charges tab: paginated table with receipt links, CSV export
- Subscriptions tab: status filter pills, plan breakdown, churn tracking

### D6 — VIP Member Tagging
- Contact model extended:
  - is_vip (boolean)
  - vip_since (date)
  - total_contributed_nzd (decimal)
  - subscription_status (enum)
  - stripe_customer_id (string)
- pullTapMapContacts() cross-references GET /api/tap_map/stripe_customers
- 💎 VIP badge on contact card when is_vip=true
- Gold border highlight on VIP contact cards
- 💎 VIP filter pill in contacts list

### D7 — Waitlist Page
- GET /api/tap_map/waitlist endpoint returns TapMapWaitListEntry records
- Frontend page-waitlist with header actions
- Stats row (Total, Get Water, Host Tap, Facilitator, Share Buy)
- Filter pills for each interest type
- Table with Name, Email, Phone, interest badges, date
- Add to Contacts and Add to Campaign actions

### D8 — Blog Management Page
- TapMapBlogPost model inheriting TapMapWriteRecord
- ContentController with blog_posts endpoints
- 3-tab page (Posts / Editor / News & Sources):
  - Posts tab: filter by status, edit/publish/archive actions
  - Editor tab: contenteditable with formatting toolbar, word count, save/publish
  - News & Sources tab: scrape + draft articles
- ActionText body stored in action_text_rich_texts table

### D9 — AI News Scraper Pipeline
- 3 default news sources (WHO Water Quality, Water New Zealand, NZ Water Journal)
- fetchAllNews() scrapes via CF Worker, extracts articles via AI
- Article selection with checkbox, Read link
- newsWeeklyDigest() generates full HTML digest post
- newsDraftOne() generates focused post from single article
- Weekly auto-publish via EmailService

## Fly Secrets Inventory

All secrets set on fly.io app (twwp-ops-api):
- RESEND_API_KEY
- SENDGRID_API_KEY
- BREVO_API_KEY
- MAILTRAP_HOST
- MAILTRAP_PORT
- MAILTRAP_USER
- MAILTRAP_PASS
- EMAIL_PROVIDER (e.g., 'resend' or 'sendgrid')
- TAP_MAP_POOLER_URL (Fly Postgres pooler for write operations)
- TAP_MAP_DATABASE_URL (read-only Neon Postgres)

## Database Architecture

### Neon (Tap-Map)
- **Read models** (TapMapRecord): users, taps, readings (read-only via TAP_MAP_DATABASE_URL)
- **Write models** (TapMapWriteRecord): blog_posts, wait_list_entries (write via TAP_MAP_POOLER_URL with PgBouncer pooling)

### Rails Postgres
- users (with role, org_id, active, name, last_seen_at, invited_by, temp_password)
- email_configs (provider, from_address, test_mode)
- action_text_attachments
- action_text_rich_texts (stores blog post bodies)

## Blog Architecture

- Blog post title, status (draft/published/archived), author
- Body stored as ActionText in action_text_rich_texts table
- ContentController: GET /api/content/blog_posts, POST create, PATCH update
- Frontend editor with contenteditable + toolbar (Bold/Italic/H2/H3/Blockquote/Link/Bullet/Numbered)
- News & Sources tab for article scraping and drafting
- Weekly digest auto-generation via EmailService

## Stripe Data Model

**Confirmed as read-only subscriptions + charges only** — no donations via Stripe integration.
- Subscriptions queried from Stripe API for VIP tagging
- Charges shown for transparency
- No write operations to Stripe from ops app

## Waitlist Table

Schema confirmed ready but empty:
- id, email, name, phone, interests, created_at
- Synced from Tap-Map via GET /api/tap_map/waitlist endpoint
- Add to Contacts action upserts contact by email
- Add to Campaign action creates campaign recipient link

## fly.toml Configuration

Fixed machine suspension issue:
```
[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = false      # ← was 'stop', now false
  auto_start_machines = true
  min_machines_running = 1        # ← ensures 1 machine always running
  processes = ['app']
```

Deployed via `fly deploy --app twwp-ops-api`. All 2 machines confirmed started.

## Next Steps

- **D10**: Confirm ops API machines running (completed: fly.toml fixed, machines started)
- **D11**: Confirm email provider keys wired in INT_KEYS (completed: added resend-api-key, sendgrid-api-key, brevo-api-key, mailtrap-host/port/user/pass, stripe-secret-key, email-provider, email-test-mode)
- **D12**: Sprint wrap + constants update + commit (in progress)
- Rails deploy: Ensure all migrations applied (`rails db:migrate` on Fly.io)
- Email provider testing: Each provider key tested via POST /api/email/test
- Blog auto-publish: Schedule weekly news digest job (Sidekiq or Fly job)
