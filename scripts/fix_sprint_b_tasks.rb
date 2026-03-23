#!/usr/bin/env ruby
# scripts/fix_sprint_b_tasks.rb
# One-off: mark the two missing Sprint B devtasks as complete.
# Finds tasks containing "Project Management" or "PM Board" (case-insensitive).
#
# Generate JWT first:
#   fly ssh console --app twwp-ops-api -C \
#     "bin/rails runner \"puts JWT.encode({user_id: User.find_by(email: 'thewholeywaterproject@gmail.com').id, email: 'thewholeywaterproject@gmail.com', role: 'admin', exp: 30.days.from_now.to_i}, Rails.application.credentials.dig(:ops_api, :secret_key) || 'dev_secret_key', 'HS256')\""
#
# Save output to scripts/.ops_token, then run:  ruby scripts/fix_sprint_b_tasks.rb

require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'securerandom'

RAILS_API  = 'https://twwp-ops-api.fly.dev'.freeze
TODAY      = Time.now.strftime('%Y-%m-%d').freeze
NOW_ISO    = Time.now.utc.iso8601.freeze
TOKEN_FILE = File.join(__dir__, '.ops_token')

MISSING_B_TASKS = [
  { match: 'project management', title: 'Project Management tabs',
    note: 'Sprint B B5: Renamed Projects → Project Management. Added Overview, Board, Timeline, Integrations tabs.' },
  { match: 'pm board',           title: 'PM Board view + Trello integration',
    note: 'Sprint B B6: Kanban board with drag-and-drop, Trello API key/token auth, pull/push cards.' },
].freeze

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

jwt = load_jwt

puts "GET #{RAILS_API}/api/sync ..."
res = api_get('/api/sync', jwt)
abort "GET failed: #{res.code} #{res.body[0..200]}" unless res.is_a?(Net::HTTPSuccess)

body  = JSON.parse(res.body)
state = (body['exists'] && body['data']) ? body['data'] : {}
devtasks = state['devtasks'] || []

MISSING_B_TASKS.each do |task|
  existing = devtasks.find { |t| t['title'].to_s.downcase.include?(task[:match]) }
  if existing
    puts "  Found '#{existing['title']}' — marking complete"
    existing.merge!('status' => 'done', 'completion_date' => TODAY, 'completion_note' => task[:note])
  else
    puts "  Not found by match '#{task[:match]}' — adding new entry '#{task[:title]}'"
    devtasks << { 'id' => uid, 'title' => task[:title], 'status' => 'done',
                  'completion_date' => TODAY, 'completion_note' => task[:note], 'created' => NOW_ISO }
  end
end
state['devtasks'] = devtasks

puts "PUT #{RAILS_API}/api/sync ..."
put = api_put('/api/sync', jwt, { data: state })
abort "PUT failed: #{put.code} #{put.body[0..200]}" unless put.is_a?(Net::HTTPSuccess)

puts "✅ Sprint B missing tasks fixed."
