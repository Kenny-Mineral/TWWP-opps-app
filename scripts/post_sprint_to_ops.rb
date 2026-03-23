#!/usr/bin/env ruby
# scripts/post_sprint_to_ops.rb
# Posts sprint completion data back into the Ops App via the Rails API.
# Usage: ruby scripts/post_sprint_to_ops.rb
#
# JWT resolution order:
#   1. scripts/.ops_token file
#   2. OPS_JWT environment variable
#   3. Interactive prompt
#
# If the Rails API is unreachable or JWT is invalid, the full payload
# is written to docs/pending_sync.json as a fallback.

require 'net/http'
require 'uri'
require 'json'
require 'time'

RAILS_API = 'https://twwp-ops-api.fly.dev'.freeze
TODAY      = Time.now.strftime('%Y-%m-%d').freeze
NOW_ISO    = Time.now.utc.iso8601.freeze
TOKEN_FILE = File.join(__dir__, '.ops_token')

# ── JWT Resolution ────────────────────────────────────────────────────────────
def load_jwt
  if File.exist?(TOKEN_FILE)
    token = File.read(TOKEN_FILE).strip
    return token unless token.empty?
  end
  if ENV['OPS_JWT'] && !ENV['OPS_JWT'].empty?
    return ENV['OPS_JWT']
  end
  print 'Enter your Ops API JWT token: '
  gets.chomp
end

# ── HTTP Helpers ──────────────────────────────────────────────────────────────
def api_get(path, jwt)
  uri = URI("#{RAILS_API}#{path}")
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{jwt}"
  req['Content-Type']  = 'application/json'
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
end

def api_put(path, jwt, body)
  uri = URI("#{RAILS_API}#{path}")
  req = Net::HTTP::Put.new(uri)
  req['Authorization'] = "Bearer #{jwt}"
  req['Content-Type']  = 'application/json'
  req.body = body.to_json
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
end

# ── Sprint B task completion data ─────────────────────────────────────────────
SPRINT_B_TASKS = [
  {
    title: 'Ops API: read-only Tap-Map connection',
    note:  'TapMapRecord base class + 3 read-only models connecting to Neon DB via TAP_MAP_DATABASE_URL'
  },
  {
    title: 'Ops API: Tap-Map read endpoints',
    note:  'GET /api/tap_map/members|taps|readings — all deployed to Fly.io'
  },
  {
    title: 'Ops App: Pull from Tap-Map buttons',
    note:  '↓ buttons in Contacts, Locations, WH Monitor — deduplicating sync with source badges'
  },
  {
    title: 'WH Monitor: live sensor gauges',
    note:  'TDS, EC, pH, ORP gauges with sparklines and colour-coded thresholds from real Tap-Map readings'
  },
  {
    title: 'Project Management: rename and restructure',
    note:  '4-tab structure: Overview/Board/Timeline/Integrations'
  },
  {
    title: 'PM Board view + Trello integration',
    note:  'Kanban board + Trello API key/token auth + card sync'
  }
].freeze

SPRINT_B_SUMMARY = 'Sprint B: Tap-Map read-only DB connection (Neon), 3 read endpoints, Pull buttons in Contacts/Locations/WH Monitor, live sensor gauges with real data, Project Management restructure with Board/Timeline/Integrations tabs, Trello integration via API key+token'.freeze

def uid
  require 'securerandom'
  SecureRandom.hex(8)
end

# ── Merge sprint data into fetched state ──────────────────────────────────────
def merge_sprint_data(state)
  # 1. Mark dev tasks complete
  devtasks = state['devtasks'] || []
  SPRINT_B_TASKS.each do |task|
    existing = devtasks.find { |t| t['title'] == task[:title] }
    if existing
      existing['status']           = 'done'
      existing['completion_date']  = TODAY
      existing['completion_note']  = task[:note]
    else
      devtasks << {
        'id'              => uid,
        'title'           => task[:title],
        'status'          => 'done',
        'completion_date' => TODAY,
        'completion_note' => task[:note],
        'created'         => NOW_ISO
      }
    end
  end
  state['devtasks'] = devtasks

  # 2. Add spec_growth_user entry
  spec_growth = state['spec_growth_user'] || []
  spec_growth.unshift({
    'id'      => uid,
    'date'    => TODAY,
    'by'      => 'Claude Code / Kenny',
    'summary' => SPRINT_B_SUMMARY
  })
  state['spec_growth_user'] = spec_growth

  # 3. Add calendar event
  cal_events = state['calEvents'] || []
  cal_events << {
    'id'    => uid,
    'title' => 'Sprint B Complete — Tap-Map + PM',
    'date'  => TODAY,
    'type'  => 'Reminder',
    'notes' => 'B1-B2: Tap-Map read-only DB + endpoints. B3-B4: Pull buttons + live sensor gauges. B5-B6: PM restructure + Trello.'
  }
  state['calEvents'] = cal_events

  # 4. Add event ledger entry
  ledger = state['eventLedger'] || []
  ledger.unshift({
    'id'       => uid,
    'ts'       => NOW_ISO,
    'date'     => TODAY,
    'category' => 'developer',
    'action'   => 'sprint_complete',
    'detail'   => 'Sprint B complete — 6 tasks shipped',
    'meta'     => { 'page' => 'developer', 'summary' => 'sprint_b' }
  })
  state['eventLedger'] = ledger

  state
end

# ── Main ──────────────────────────────────────────────────────────────────────
jwt = load_jwt

if jwt.nil? || jwt.empty?
  warn 'No JWT provided — writing payload to docs/pending_sync.json'
  fallback = { 'sprint' => 'B', 'tasks' => SPRINT_B_TASKS, 'summary' => SPRINT_B_SUMMARY, 'ts' => NOW_ISO }
  File.write(File.join(__dir__, '..', 'docs', 'pending_sync.json'), JSON.pretty_generate(fallback))
  exit 1
end

puts "Fetching current state from #{RAILS_API}/api/sync ..."
begin
  get_res = api_get('/api/sync', jwt)
rescue => e
  warn "Rails API unreachable: #{e.message}"
  fallback = { 'error' => e.message, 'sprint' => 'B', 'ts' => NOW_ISO }
  File.write(File.join(__dir__, '..', 'docs', 'pending_sync.json'), JSON.pretty_generate(fallback))
  exit 1
end

unless get_res.is_a?(Net::HTTPSuccess)
  warn "GET /api/sync failed: #{get_res.code} #{get_res.body}"
  fallback = { 'http_status' => get_res.code, 'body' => get_res.body, 'sprint' => 'B', 'ts' => NOW_ISO }
  File.write(File.join(__dir__, '..', 'docs', 'pending_sync.json'), JSON.pretty_generate(fallback))
  exit 1
end

body = JSON.parse(get_res.body)
state = (body['exists'] && body['data']) ? body['data'] : {}

puts "Merging Sprint B completion data..."
merged = merge_sprint_data(state)

puts "PUT #{RAILS_API}/api/sync ..."
begin
  put_res = api_put('/api/sync', jwt, { data: merged })
rescue => e
  warn "Rails API unreachable on PUT: #{e.message}"
  File.write(File.join(__dir__, '..', 'docs', 'pending_sync.json'), JSON.pretty_generate(merged))
  exit 1
end

if put_res.is_a?(Net::HTTPSuccess)
  puts "✅ Sprint B data posted to Ops App successfully."
  puts "   Dev tasks marked complete: #{SPRINT_B_TASKS.length}"
  puts "   Calendar event added: Sprint B Complete — #{TODAY}"
  puts "   Growth log entry added."
  # Clean up pending_sync if it exists
  pending = File.join(__dir__, '..', 'docs', 'pending_sync.json')
  File.delete(pending) if File.exist?(pending)
else
  warn "❌ PUT /api/sync failed: #{put_res.code}"
  warn put_res.body
  File.write(File.join(__dir__, '..', 'docs', 'pending_sync.json'), JSON.pretty_generate(merged))
  exit 1
end
