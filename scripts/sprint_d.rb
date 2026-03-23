#!/usr/bin/env ruby
# scripts/sprint_d.rb
# Sprint D completion post (Onboarding, User Mgmt, Email, Stripe, VIP, Waitlist, Blog, News)
# Run: ruby scripts/sprint_d.rb
# JWT stored in scripts/.ops_token or set OPS_JWT env var

require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'securerandom'

RAILS_API  = 'https://twwp-ops-api.fly.dev'.freeze
TODAY      = Time.now.strftime('%Y-%m-%d').freeze
NOW_ISO    = Time.now.utc.iso8601.freeze
TOKEN_FILE = File.join(__dir__, '.ops_token')

# ── Claude Code session token usage ──────────────────────────────────────────
claude_input_tokens  = ENV['CLAUDE_INPUT_TOKENS']&.to_i  || 0
claude_output_tokens = ENV['CLAUDE_OUTPUT_TOKENS']&.to_i || 0
if claude_input_tokens.zero?
  puts "\n📊 Claude Code Token Usage (Both Sessions Combined)"
  puts "Enter total INPUT tokens for Sprint D (Part 1 + Part 2, or 0 to skip):"
  claude_input_tokens = gets.chomp.to_i
  unless claude_input_tokens.zero?
    puts "Enter total OUTPUT tokens for Sprint D (Part 1 + Part 2):"
    claude_output_tokens = gets.chomp.to_i
  end
end
CLAUDE_INPUT_TOKENS  = claude_input_tokens.freeze
CLAUDE_OUTPUT_TOKENS = claude_output_tokens.freeze
# Cost at Sonnet 4.x rates: input $0.000003/tok, output $0.000015/tok
CLAUDE_COST_USD = ((CLAUDE_INPUT_TOKENS * 0.000003) + (CLAUDE_OUTPUT_TOKENS * 0.000015)).round(4).freeze
# ── END token capture ─────────────────────────────────────────────────────────

# ── SPRINT-SPECIFIC: Sprint D ──────────────────────────────────────────────
SPRINT_ID = 'D'  # Sprint D

SPRINT_TASKS = [
  { title: 'D1 — Onboarding Wizard enhancements', note: '7-step onboarding with org setup, branding, guardian email, AI provider key, integrations status, user invite, completion' },
  { title: 'D2 — User Management', note: 'Rails endpoints for users (GET/POST/PATCH/DELETE), UsersController admin-gated, frontend page-usermgmt with stats/filters/invite' },
  { title: 'D3 — Email Service Infrastructure', note: 'EmailService.send_email() routing to Resend/SendGrid/Brevo/Mailtrap, EmailConfig model, POST /api/email/test' },
  { title: 'D4 — Email Providers Page', note: 'page-emailproviders with 6 provider cards, config fields, from-address manager, test/live mode toggle, sending stats' },
  { title: 'D5 — Stripe Page (Overview/VIP/Charges/Subscriptions)', note: '4 Rails endpoints (stripe_overview, stripe_customers, stripe_charges, stripe_subscriptions), MRR/revenue stats, leaderboard' },
  { title: 'D6 — VIP Member Tagging', note: 'Contact fields (is_vip, vip_since, total_contributed, subscription_status, stripe_customer_id), 💎 badge, VIP filter pill' },
  { title: 'D7 — Waitlist Page', note: 'page-waitlist pulling TapMapWaitListEntry, stats by interest, table with Add to Contacts/Campaign actions' },
  { title: 'D8 — Blog Management Page', note: 'TapMapBlogPost model, ContentController, create/edit/publish, ActionText body, News & Sources tab' },
  { title: 'D9 — AI News Scraper Pipeline', note: '3 news sources, fetchAllNews() with CF Worker scrape + AI extract, weeklyDigest generation, news-to-blog draft' },
].freeze

SPRINT_SUMMARY = "Sprint D: Onboarding wizard (7 steps), User management page + Rails endpoints, EmailService (Resend/SendGrid/Brevo/Mailtrap), Email Providers page, Stripe page (Overview/VIP/Charges/Subscriptions), VIP member tagging (💎 badges, leaderboard), Waitlist page, Blog management page, AI news scraper pipeline.".freeze

CAL_EVENT_TITLE = "Sprint D Complete — Email + Stripe + Blog + Waitlist".freeze
CAL_EVENT_NOTES = 'D1: Onboarding (7 steps). D2: User Mgmt Rails endpoints. D3: EmailService routing. D4: Email Providers page. D5: Stripe page (4 endpoints). D6: VIP member tagging. D7: Waitlist page. D8: Blog management. D9: News scraper pipeline.'.freeze
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
    existing = devtasks.find { |t| t['title'].to_s.downcase.include?(task[:title].to_s.downcase) }
    if existing
      existing.merge!('status' => 'done', 'completion_date' => TODAY, 'completion_note' => task[:note])
    else
      devtasks << { 'id' => uid, 'title' => task[:title], 'status' => 'done',
                    'completion_date' => TODAY, 'completion_note' => task[:note], 'created' => NOW_ISO }
    end
  end
  state['devtasks'] = devtasks

  # Spec growth entry
  growth_summary = SPRINT_SUMMARY.dup
  if CLAUDE_INPUT_TOKENS > 0
    growth_summary += " [#{CLAUDE_INPUT_TOKENS}i/#{CLAUDE_OUTPUT_TOKENS}o tok, ~$#{CLAUDE_COST_USD} USD]"
  end
  (state['spec_growth_user'] ||= []).unshift(
    { 'id' => uid, 'date' => TODAY, 'by' => 'Claude Code / Kenny', 'summary' => growth_summary }
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

  # Attach Claude Code sprint token record to sync payload
  if CLAUDE_INPUT_TOKENS > 0
    sprint_tok = {
      'id'           => uid,
      'sprint_id'    => SPRINT_ID,
      'date'         => TODAY,
      'provider'     => 'anthropic',
      'source'       => 'claude_code',
      'input_tokens' => CLAUDE_INPUT_TOKENS,
      'output_tokens'=> CLAUDE_OUTPUT_TOKENS,
      'cost_usd'     => CLAUDE_COST_USD,
      'created'      => NOW_ISO
    }
    (merged['sprint_tokens'] ||= []).unshift(sprint_tok)
    puts "  Claude Code tokens: #{CLAUDE_INPUT_TOKENS}i / #{CLAUDE_OUTPUT_TOKENS}o — ~$#{CLAUDE_COST_USD} USD"
  end

  puts "PUT #{RAILS_API}/api/sync ..."
  put = api_put('/api/sync', jwt, { data: merged })
  raise "PUT failed: #{put.code} #{put.body}" unless put.is_a?(Net::HTTPSuccess)

  puts "✅ Sprint #{SPRINT_ID} posted successfully."
rescue => e
  warn "❌ #{e.message}"
  pending = File.join(__dir__, '..', 'docs', 'pending_sync.json')
  warn "Writing fallback to #{pending}"
  File.write(pending, JSON.pretty_generate({
    error: e.message, sprint: SPRINT_ID, ts: NOW_ISO,
    sprint_tokens: CLAUDE_INPUT_TOKENS > 0 ? {
      input: CLAUDE_INPUT_TOKENS, output: CLAUDE_OUTPUT_TOKENS, cost_usd: CLAUDE_COST_USD
    } : nil
  }.compact))
  exit 1
end
