# THIS IS THE FIXED VERSION — apply this to ~/twwp-ops-api/app/controllers/auth_controller.rb
# Fix: stores PKCE state in database (oauth_states table) instead of Rails session
# This survives Fly.io machine auto-stops which wipe session data mid-OAuth-flow
#
# ALSO NEED TO RUN:
# rails generate migration CreateOauthStates state:string pkce_verifier:string ops_app_origin:string expires_at:datetime
# cat > app/models/oauth_state.rb with: class OauthState < ApplicationRecord; validates :state, presence: true, uniqueness: true; end
# rails db:migrate && fly deploy && fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"

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
    # Store in DB instead of session - survives machine restarts
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
    Rails.logger.error "OAuth error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
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
