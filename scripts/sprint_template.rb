#!/usr/bin/env ruby
# scripts/sprint_template.rb
# Template for future sprint completion posts.
# Copy this file, update the constants below, and run:
#   ruby scripts/post_sprint_SPRINTID.rb
#
# Put your JWT in scripts/.ops_token (single line, no trailing newline)
# or set OPS_JWT env var, or you'll be prompted.

require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'securerandom'

RAILS_API  = 'https://twwp-ops-api.fly.dev'.freeze
TODAY      = Time.now.strftime('%Y-%m-%d').freeze
NOW_ISO    = Time.now.utc.iso8601.freeze
TOKEN_FILE = File.join(__dir__, '.ops_token')

# ── SPRINT-SPECIFIC: Update these for each new sprint ──────────────────────
SPRINT_ID = 'C'  # Change to next sprint letter/number

SPRINT_TASKS = [
  # Add one entry per task:
  # { title: 'Exact task title as it appears in devtasks store', note: 'What was built' },
  { title: 'Example Task Title', note: 'Description of what was implemented' },
].freeze

SPRINT_SUMMARY = "Sprint #{SPRINT_ID}: one-line summary of what was shipped".freeze

CAL_EVENT_TITLE = "Sprint #{SPRINT_ID} Complete — Short Label".freeze
CAL_EVENT_NOTES = 'Task summaries for the calendar event notes field.'.freeze
# ── END SPRINT-SPECIFIC ──────────────────────────────────────────────────────

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
  # Mark dev tasks complete
  devtasks = state['devtasks'] || []
  SPRINT_TASKS.each do |task|
    existing = devtasks.find { |t| t['title'] == task[:title] }
    if existing
      existing.merge!('status' => 'done', 'completion_date' => TODAY, 'completion_note' => task[:note])
    else
      devtasks << { 'id' => uid, 'title' => task[:title], 'status' => 'done',
                    'completion_date' => TODAY, 'completion_note' => task[:note], 'created' => NOW_ISO }
    end
  end
  state['devtasks'] = devtasks

  # Spec growth entry
  (state['spec_growth_user'] ||= []).unshift(
    { 'id' => uid, 'date' => TODAY, 'by' => 'Claude Code / Kenny', 'summary' => SPRINT_SUMMARY }
  )

  # Calendar event
  (state['calEvents'] ||= []) << {
    'id' => uid, 'title' => CAL_EVENT_TITLE, 'date' => TODAY,
    'type' => 'Reminder', 'notes' => CAL_EVENT_NOTES
  }

  # Ledger entry
  (state['eventLedger'] ||= []).unshift({
    'id' => uid, 'ts' => NOW_ISO, 'date' => TODAY,
    'category' => 'developer', 'action' => 'sprint_complete',
    'detail' => "Sprint #{SPRINT_ID} complete — #{SPRINT_TASKS.length} tasks shipped",
    'meta' => { 'page' => 'developer', 'summary' => "sprint_#{SPRINT_ID.downcase}" }
  })

  state
end

jwt = load_jwt

begin
  puts "GET #{RAILS_API}/api/sync ..."
  res = api_get('/api/sync', jwt)
  raise "GET failed: #{res.code}" unless res.is_a?(Net::HTTPSuccess)
  body  = JSON.parse(res.body)
  state = (body['exists'] && body['data']) ? body['data'] : {}

  puts 'Merging sprint data...'
  merged = merge_sprint_data(state)

  puts "PUT #{RAILS_API}/api/sync ..."
  put = api_put('/api/sync', jwt, { data: merged })
  raise "PUT failed: #{put.code} #{put.body}" unless put.is_a?(Net::HTTPSuccess)

  puts "✅ Sprint #{SPRINT_ID} posted successfully."
rescue => e
  warn "❌ #{e.message}"
  pending = File.join(__dir__, '..', 'docs', 'pending_sync.json')
  warn "Writing fallback to #{pending}"
  File.write(pending, JSON.pretty_generate({ error: e.message, sprint: SPRINT_ID, ts: NOW_ISO }))
  exit 1
end
