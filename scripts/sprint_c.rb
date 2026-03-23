#!/usr/bin/env ruby
# scripts/sprint_c.rb
# Sprint C completion poster — run after Sprint C code is committed.
#
# Generate a fresh JWT first:
#   fly ssh console --app twwp-ops-api -C \
#     "bin/rails runner \"puts JWT.encode({user_id: User.find_by(email: 'thewholeywaterproject@gmail.com').id, email: 'thewholeywaterproject@gmail.com', role: 'admin', exp: 30.days.from_now.to_i}, Rails.application.credentials.dig(:ops_api, :secret_key) || 'dev_secret_key', 'HS256')\""
#
# Save the output to scripts/.ops_token (single line, no trailing newline),
# or set OPS_JWT env var, or you'll be prompted.
#
# Then run:  ruby scripts/sprint_c.rb

require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'securerandom'

RAILS_API  = 'https://twwp-ops-api.fly.dev'.freeze
TODAY      = Time.now.strftime('%Y-%m-%d').freeze
NOW_ISO    = Time.now.utc.iso8601.freeze
TOKEN_FILE = File.join(__dir__, '.ops_token')

SPRINT_ID = 'C'

SPRINT_TASKS = [
  { title: 'Calendar fix',                          note: 'C1: Calendar dots on month view, week view day detail panel, chip ••• menu, sprint_complete auto-event wired.' },
  { title: 'Dev Tasks progress button',             note: 'C2: Progress modal with per-group progress bars and overall stats.' },
  { title: 'WH Monitor manual readings',            note: 'C3: + Reading modal, source badge on gauge cards, readings history table.' },
  { title: 'Onboarding wizard',                     note: 'C4: 7-step setup wizard fully wired (org, branding, location, AI, integrations, team, done).' },
  { title: 'Setup status + contextual interrupts',  note: 'C5: requiresSetup() wired to Tap-Map sync, ESP32 data, email inbox, AI helper, Calendar, Drive.' },
  { title: 'Multi-org foundation',                  note: 'C6: getTerm() on page titles + Guardian labels, module toggles hide sidebar items, logo + org_name in sidebar.' },
  { title: 'Contacts pipeline + Jira',              note: 'C7: Contacts pipeline kanban (5 columns). Jira Save & Connect, Pull Issues, Push to Jira wired.' },
].freeze

SPRINT_SUMMARY = 'Sprint C: Calendar enhancements, Dev Tasks progress, WH Monitor readings, onboarding wizard, setup interrupts, multi-org branding, Contacts pipeline + Jira'.freeze

CAL_EVENT_TITLE = 'Sprint C Complete — Onboarding + Multi-Org + Calendar'.freeze
CAL_EVENT_NOTES = 'Calendar dots/panel/chip-menu, Dev Progress, WH Monitor manual readings, Onboarding wizard, requiresSetup interrupts, getTerm/modules/branding, Contacts pipeline, Jira connect.'.freeze

def uid = SecureRandom.hex(8)

def load_jwt
  return File.read(TOKEN_FILE).strip if File.exist?(TOKEN_FILE) && !File.read(TOKEN_FILE).strip.empty?
  return ENV['OPS_JWT'] if ENV['OPS_JWT'] && !ENV['OPS_JWT'].empty?
  print 'JWT token: '; gets.chomp
end

def api_get(path, jwt)
  uri = URI("#{RAILS_API}#{path}")
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{jwt}"
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

def merge_sprint_data(state)
  devtasks = state['devtasks'] || []
  SPRINT_TASKS.each do |task|
    existing = devtasks.find { |t| t['title'].to_s.downcase.include?(task[:title].to_s.downcase) }
    if existing
      existing.merge!('status' => 'done', 'completion_date' => TODAY, 'completion_note' => task[:note])
    else
      devtasks << { 'id' => uid, 'title' => task[:title], 'status' => 'done',
                    'completion_date' => TODAY, 'completion_note' => task[:note], 'created' => NOW_ISO }
    end
  end
  state['devtasks'] = devtasks

  (state['spec_growth_user'] ||= []).unshift(
    { 'id' => uid, 'date' => TODAY, 'by' => 'Claude Code / Kenny', 'summary' => SPRINT_SUMMARY }
  )

  (state['calEvents'] ||= []) << {
    'id' => uid, 'title' => CAL_EVENT_TITLE, 'date' => TODAY,
    'type' => 'sprint_complete', 'source' => 'auto', 'color' => '#b06aff',
    'notes' => CAL_EVENT_NOTES
  }

  (state['eventLedger'] ||= []).unshift({
    'id' => uid, 'ts' => NOW_ISO, 'date' => TODAY,
    'category' => 'developer', 'action' => 'sprint_complete',
    'detail' => "Sprint C complete — #{SPRINT_TASKS.length} tasks shipped",
    'meta' => { 'page' => 'developer', 'summary' => 'sprint_c' }
  })

  state
end

jwt = load_jwt

begin
  puts "GET #{RAILS_API}/api/sync ..."
  res = api_get('/api/sync', jwt)
  raise "GET failed: #{res.code} #{res.body[0..200]}" unless res.is_a?(Net::HTTPSuccess)
  body  = JSON.parse(res.body)
  state = (body['exists'] && body['data']) ? body['data'] : {}

  puts 'Merging Sprint C data...'
  merged = merge_sprint_data(state)

  puts "PUT #{RAILS_API}/api/sync ..."
  put = api_put('/api/sync', jwt, { data: merged })
  raise "PUT failed: #{put.code} #{put.body[0..200]}" unless put.is_a?(Net::HTTPSuccess)

  puts "✅ Sprint C posted successfully."
rescue => e
  warn "❌ #{e.message}"
  pending = File.join(__dir__, '..', 'docs', 'pending_sync.json')
  warn "Writing fallback to #{pending}"
  pending_data = {
    error: e.message,
    sprint: SPRINT_ID,
    ts: NOW_ISO,
    payload: {
      devtasks_complete: SPRINT_TASKS.map { |t| t[:title] },
      growth_summary: SPRINT_SUMMARY,
      cal_event: CAL_EVENT_TITLE,
      ledger_action: 'sprint_complete'
    }
  }
  File.write(pending, JSON.pretty_generate(pending_data))
  warn "Fallback written. Re-run when Rails API is reachable."
  exit 1
end
