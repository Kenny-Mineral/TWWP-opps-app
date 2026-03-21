# TWWP Ops App — Session Handoff
## Chat session: March 20-21, 2026
## Status: Rails API deployed but Google OAuth broken — fix identified, not yet applied

---

## Project overview

Kenny Samkin runs The Wholey Water Project (TWWP) — a community reverse osmosis
water filtration network in New Zealand with neighbourhood tap installations
called "waterhouses".

The **TWWP Ops App** is a single-file HTML/CSS/JS browser app that replaces
manual Word document workflows for operational reporting, reimbursements,
maintenance tracking, and network management.

- **Live at:** https://kenny-mineral.github.io/TWWP-opps-app/
- **Single file:** index.html (~9,300 lines)
- **Deployed via:** GitHub Pages (drag and drop to GitHub repo)
- **Local working file:** /home/claude/twwp/index_v42.html (on Claude's machine)

---

## The core problem we were trying to solve this session

The Ops App needed Google Drive OAuth so that:
1. Data syncs between Kenny's phone and laptop
2. Reports and backups save automatically to Drive
3. No more manual export/import

**Why this is hard:** Google's OAuth token exchange blocks cross-origin
browser requests (CORS). A browser-only app cannot complete the token
exchange directly. Three approaches were attempted:

### Approach 1 — Cloudflare Worker proxy (FAILED)
- Worker proxies the token exchange via /token endpoint
- Problem: sessionStorage clears when Google redirects back to the page
  so the PKCE verifier is lost and Google returns invalid_request
- Status: Worker is deployed but OAuth fails every time

### Approach 2 — Browser PKCE with localStorage fallback (PARTIAL)
- Save PKCE state to both sessionStorage AND localStorage before redirect
- Problem: Still unreliable across different browsers and devices
- Status: Code written in index.html but not confirmed working

### Approach 3 — Rails API on Fly.io (DEPLOYED, ALMOST WORKING)
- Proper server-side OAuth — no CORS issues, state stored in database
- Status: App deployed at https://twwp-ops-api.fly.dev
- Problem: One remaining bug (see below)

---

## Current state — Rails API

### What works
- Health endpoint: https://twwp-ops-api.fly.dev/health returns 200 OK
- App starts and runs on Fly.io
- Database connected (Postgres)
- Routes configured
- JWT auth framework in place

### The remaining bug — CRITICAL

**Symptom:** Google OAuth returns `invalid_request` every time

**Root cause identified from logs:**
The Fly.io machine auto-stops after ~2 minutes of inactivity.
When the user clicks Connect → Google redirects them → takes ~2-5 minutes
to sign in → by the time Google redirects back to /auth/google/callback,
the Fly.io machine has restarted and the Rails session is gone.

The PKCE verifier (stored in session[:pkce_verifier]) is wiped on restart.
Google checks the verifier against the challenge and it doesn't match → invalid_request.

**The fix — identified but NOT yet applied:**
Store PKCE state in the database (a new oauth_states table) instead of
in the Rails session. Database survives machine restarts. Session does not.

### Fix to apply (exact commands)

Step 1 — Update auth controller:
```bash
cd ~/twwp-ops-api
cat > app/controllers/auth_controller.rb << 'EOF'
class AuthController < ApplicationController
  skip_before_action :authenticate_request!

  GOOGLE_AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth'
  GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token'
  SCOPES = 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/userinfo.email'

  def google_redirect
    client_id = Rails.application.credentials.dig(:google, :client_id)
    redirect_uri = "#{request.base_url}/auth/google/callback"
    ops_app_origin = params[:origin] || 'https://kenny-mineral.github.io/TWWP-opps-app/'
    verifier = SecureRandom.urlsafe_base64(32)
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    state = SecureRandom.hex(16)
    OauthState.create!(
      state: state,
      pkce_verifier: verifier,
      ops_app_origin: ops_app_origin,
      expires_at: 10.minutes.from_now
    )
    auth_url = "#{GOOGLE_AUTH_URL}?" + {
      client_id: client_id, redirect_uri: redirect_uri,
      response_type: 'code', scope: SCOPES,
      code_challenge: challenge, code_challenge_method: 'S256',
      state: state, access_type: 'offline', prompt: 'consent'
    }.to_query
    redirect_to auth_url, allow_other_host: true
  end

  def google_callback
    oauth_state = OauthState.find_by(state: params[:state])
    return redirect_to_app(error: 'state_mismatch') unless oauth_state
    return redirect_to_app(error: 'state_expired') if oauth_state.expires_at < Time.current
    return redirect_to_app(error: params[:error]) if params[:error]
    ops_app_origin = oauth_state.ops_app_origin
    verifier = oauth_state.pkce_verifier
    oauth_state.destroy
    client_id = Rails.application.credentials.dig(:google, :client_id)
    client_secret = Rails.application.credentials.dig(:google, :client_secret)
    redirect_uri = "#{request.base_url}/auth/google/callback"
    response = Faraday.post(GOOGLE_TOKEN_URL) do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = { code: params[:code], client_id: client_id, client_secret: client_secret,
        redirect_uri: redirect_uri, grant_type: 'authorization_code',
        code_verifier: verifier }.to_query
    end
    token_data = JSON.parse(response.body)
    return redirect_to_app(error: token_data['error'], origin: ops_app_origin) if token_data['error']
    userinfo = JSON.parse(Faraday.get('https://www.googleapis.com/oauth2/v2/userinfo') { |r|
      r.headers['Authorization'] = "Bearer #{token_data['access_token']}" }.body)
    email = userinfo['email']
    ops_session = OpsSession.find_or_initialize_by(email: email)
    ops_session.update!(access_token: token_data['access_token'],
      refresh_token: token_data['refresh_token'] || ops_session.refresh_token,
      token_expires_at: Time.current + (token_data['expires_in'] || 3600).seconds,
      google_client_id: client_id, active: true, last_seen_at: Time.current)
    secret = Rails.application.credentials.dig(:ops_api, :secret_key) || 'dev_secret_key'
    jwt = JWT.encode({ session_id: ops_session.id, email: email,
      exp: 30.days.from_now.to_i }, secret, 'HS256')
    redirect_to "#{ops_app_origin}?session_token=#{jwt}&email=#{CGI.escape(email)}",
      allow_other_host: true
  rescue => e
    Rails.logger.error "OAuth error: #{e.message}"
    redirect_to_app(error: 'server_error', origin: ops_app_origin)
  end

  def logout
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      begin
        secret = Rails.application.credentials.dig(:ops_api, :secret_key) || 'dev_secret_key'
        payload = JWT.decode(token, secret, true, algorithm: 'HS256').first
        OpsSession.find_by(id: payload['session_id'])&.update(active: false)
      rescue; end
    end
    render json: { status: 'logged_out' }
  end

  private

  def redirect_to_app(error: nil, origin: nil)
    base = origin || 'https://kenny-mineral.github.io/TWWP-opps-app/'
    redirect_to error ? "#{base}?auth_error=#{error}" : base, allow_other_host: true
  end
end
EOF
echo "auth controller updated"
```

Step 2 — Create migration and model:
```bash
rails generate migration CreateOauthStates state:string pkce_verifier:string ops_app_origin:string expires_at:datetime

cat > app/models/oauth_state.rb << 'EOF'
class OauthState < ApplicationRecord
  validates :state, presence: true, uniqueness: true
end
EOF
echo "model done"
```

Step 3 — Migrate and deploy:
```bash
rails db:migrate
fly deploy
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"
```

Step 4 — Test by clicking Connect via Rails API in the Ops App.
Should now complete successfully.

---

## Infrastructure summary

| Resource | Value |
|---|---|
| Ops App URL | https://kenny-mineral.github.io/TWWP-opps-app/ |
| Rails API URL | https://twwp-ops-api.fly.dev |
| Fly.io app name | twwp-ops-api |
| Fly.io Postgres | twwp-ops-api-db |
| Region | syd (Sydney) |
| VM | shared-cpu-1x, 1GB RAM |
| Ruby | 3.3.0 |
| Rails | 8.0.1 |
| Local app folder | ~/twwp-ops-api |
| Production key | config/credentials/production.key (git ignored) |

---

## Google Cloud Console setup

| Setting | Value |
|---|---|
| Project | Opps App TWWP - Kenny |
| OAuth Client | TWWP Ops App (Web application) |
| Client ID | 1096306613884-n4on7nf4bgnqjrjjsiue4i2n1pq5nljl.apps.googleusercontent.com |
| Client Secret | In Kenny's phone notes (starts with GOCSPX-) |
| JS Origins | https://kenny-mineral.github.io |
| Redirect URIs | https://kenny-mineral.github.io/TWWP-opps-app/ (browser flow) |
| | https://twwp-ops-api.fly.dev/auth/google/callback (Rails flow) |
| Test users | thewholeywaterproject@gmail.com, kennymtbeach@gmail.com, kjsamkin@gmail.com |

---

## What was built in the Ops App (index.html) this session

1. **Connection status dot** — fixed position top right of header
   - Green/amber/red based on service health
   - Auto-checks every 5 minutes
   - Tap to open status panel

2. **Status panel** — slides in from right
   - Shows: AI, Google Drive, Cloudflare Proxy, OAuth, Home Assistant, Local Storage
   - Individual Test buttons + Test All button

3. **Drive sync fix** — now recurses into subfolders
   - Better error messages showing total files found vs new
   - Fixed "All Drive files already in library" false positive

4. **Rails API connection** — new section in AI & Integrations modal
   - "Connect via Rails API" button
   - handleRailsAPICallback() on page load
   - saveToRailsAPI() on logout and every 30 minutes
   - Silent sync from server on login if server data is newer

5. **Google OAuth Phase 2 (browser-only)** — also in index.html as fallback
   - PKCE flow saving to both sessionStorage AND localStorage
   - Loading overlay during token exchange
   - Better error messages

6. **Cloudflare Worker updated** — twwp-proxy.thewholeywaterproject.workers.dev
   - Added /token endpoint (POST — proxies Google token exchange)
   - Added /refresh endpoint (POST — proxies token refresh)
   - Added /health endpoint (GET — version check)
   - Existing scraper endpoint unchanged

---

## Ops App — other fixes this session

- Drive folder sync now recurses into subfolders
- Status dot HTML placement bug fixed (was ending up inside script tag)
- Print function newline bug fixed (was causing syntax errors)
- Redirect URI trailing slash fixed (always appends trailing slash)

---

## Key technical decisions

| Decision | Reason |
|---|---|
| Rails 8.0.1 not 8.1.2 | 8.1.2 has Ruby 3.3 syntax incompatibility |
| pg gem with force_ruby_platform: true | Prevents segfault in Fly.io containers |
| Remove release_command from fly.toml | release_command causes segfault, run migrations manually |
| Fly.io auto-stop is root cause of OAuth bug | Machine restarts wipe session, PKCE state lost |
| Fix: store PKCE in database not session | Database survives restarts, session does not |
| Sydney region | Closest Fly.io region to New Zealand |

---

## Database tables (Rails API)

**ops_sessions** — one row per user
- email, access_token, refresh_token, token_expires_at
- google_client_id, drive_folder_id
- active, last_seen_at, last_backup_at

**ops_syncs** — one row per user
- email, app_data (text field storing JSON)

**oauth_states** — temporary, one row per OAuth attempt
- state, pkce_verifier, ops_app_origin, expires_at
- THIS TABLE DOES NOT EXIST YET — needs to be created (fix above)

---

## Useful commands

```bash
# View live logs
fly logs --app twwp-ops-api

# Redeploy after changes
cd ~/twwp-ops-api && fly deploy

# Run migrations on server
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"

# Rails console on server
fly ssh console --app twwp-ops-api
# then: bin/rails console

# Check app status
fly status --app twwp-ops-api
```

---

## What happens after OAuth is fixed

Once Connect via Rails API works end to end:

1. User clicks Connect → signs into Google → redirected back to Ops App
2. App receives session_token in URL params → stores in localStorage
3. All API calls use Bearer token in Authorization header
4. On logout → app POSTs all data to /api/sync → saves to Postgres
5. On login from any device → GET /api/sync/status → if server newer, sync silently
6. Drive file operations go through Rails → no CORS issues

---

## Backlog items identified this session

- Add Test button for Cloudflare Proxy URL field in AI & Integrations
- Email Registry tab (was blocked by syntax errors in earlier sessions)
- Document Creation tab (same — blocked)
- Auto-deploy via GitHub Actions (discussed but not implemented)
- ESP32 sensor module integration (ordered, waiting on firmware)
- Stripe integration in Financials tab
- Tap-Map sync (Rails API can eventually connect to existing twwp-app)

---

## Files to give to next Claude session

Just give this markdown file. All code is already:
- On GitHub (index.html): kenny-mineral.github.io/TWWP-opps-app
- On Kenny's Toshiba (~/twwp-ops-api): Rails API
- On Fly.io: deployed and running

The next session only needs to:
1. Apply the auth controller fix (commands above)
2. Test the OAuth flow
3. Continue with backlog items

---

## Contacts

Kenny Samkin
admin@thewholeywaterproject.com
02041333855

