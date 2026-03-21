# TWWP Ops API — Developer Handoff Document
**Date:** 2026-03-21  
**Prepared by:** Kenny (with Claude)  
**Status:** Rails API deployed and healthy. Google OAuth partially working — login succeeds with email scope only, but `drive.file` scope still causes "Something went wrong" on Google's side.

---

## 1. What We're Trying to Build

The **TWWP Ops App** is a single-file HTML/JS operations platform for The Wholey Water Project — a sports warehouse and community organisation. It lives at:

```
https://kenny-mineral.github.io/TWWP-opps-app/
```

The app needs a backend Rails API to handle:
- **Google OAuth login** — so users can sign in with their Google account
- **Google Drive integration** — to store and retrieve operational documents (backups, uploads) in a specific Drive folder
- **Cloud sync** — so app state (data, settings) is saved server-side and can be restored across devices
- **JWT session management** — issuing tokens to the frontend after successful login

This backend is the **TWWP Ops API**, deployed on Fly.io at:
```
https://twwp-ops-api.fly.dev
```

---

## 2. What Has Been Built and Deployed

### Rails API (Live on Fly.io)
- **Rails 8.0.1** on **Ruby 3.3.0**
- **PostgreSQL** database (Fly.io managed Postgres, app: `twwp-ops-api-db`)
- **Puma** web server running on port 8080 (Thruster bypassed — see known issues)
- Deployed to **Sydney region (syd)**

### Endpoints
| Method | Path | Purpose |
|--------|------|---------|
| GET | /health | Health check — returns `{"status":"ok"}` |
| GET | /auth/google | Starts Google OAuth flow |
| GET | /auth/google/callback | Google redirects here after login |
| DELETE | /auth/session | Logout |
| GET | /api/drive/files | List files in Drive folder |
| POST | /api/drive/upload | Upload file to Drive |
| GET | /api/sync | Get saved app state |
| PUT | /api/sync | Save app state |
| GET | /api/sync/status | Check if sync data exists |

### Database Tables
- **ops_sessions** — one row per user. Stores Google access/refresh tokens, JWT state, Drive folder ID
- **ops_syncs** — one row per user. Stores full app state as JSON blob
- **oauth_states** — temporary OAuth state records (replaces PKCE/cookie approach)

### CORS Allowed Origins
- `https://kenny-mineral.github.io`
- `https://endearing-empanada-68c8c7.netlify.app`
- `http://localhost`

---

## 3. Infrastructure Details

| Resource | Value |
|----------|-------|
| Fly.io app | `twwp-ops-api` |
| Fly.io Postgres | `twwp-ops-api-db` |
| App URL | https://twwp-ops-api.fly.dev |
| Region | syd (Sydney) |
| VM | shared-cpu-1x, 1GB RAM |
| Local project path | `~/twwp-ops-api` |
| Dev notes folder | `~/Desktop/Opps App dev folder laptop/new2/` |

### Credentials
- **Production key** (decrypt credentials): `3c1cda80ab038529d03d3fceb4075dca`
  - Stored at `config/credentials/production.key` (git-ignored)
  - Also set as `RAILS_MASTER_KEY` Fly secret
- **DATABASE_URL** — set as Fly secret automatically, no manual management needed
- **Google OAuth Client ID:** `1096306613884-39mavd5fmtl0s688dcfa26gdq64sjvkd.apps.googleusercontent.com`
  - ⚠️ This is the **second** OAuth client — the first one (`...nljl`) was replaced because it was broken
- **Google OAuth Client Secret:** in Kenny's phone notes (starts with GOCSPX-)

---

## 4. Google Cloud Console Configuration

**Project:** "Opps App TWWP - Kenny"  
**Owner account:** thewholeywaterproject@gmail.com

### OAuth Consent Screen
- **Status:** External / Testing
- **App name:** Opps App
- **User support email:** thewholeywater project@gmail.com
- **Developer contact:** Kennymtbeach@gmail.com
- **Homepage/Privacy/ToS:** https://kenny-mineral.github.io/TWWP-opps-app/
- **Authorised domains:** `kenny-mineral.github.io`, `twwp-ops-api.fly.dev`
- **Test users:** thewholeywaterproject@gmail.com

### Data Access Scopes (as of handoff)
| Scope | Type |
|-------|------|
| `https://www.googleapis.com/auth/userinfo.email` | Non-sensitive ✅ |
| `https://www.googleapis.com/auth/drive.file` | Non-sensitive ✅ |

### OAuth 2.0 Client
- **Type:** Web application
- **Authorised JavaScript origins:** `https://kenny-mineral.github.io`, `https://twwp-ops-api.fly.dev`
- **Authorised redirect URIs:** `https://twwp-ops-api.fly.dev/auth/google/callback`, `https://kenny-mineral.github.io/TWWP-opps-app/`

---

## 5. Hard-Won Lessons — Problems Solved During This Build

These problems were discovered and fixed the hard way. Do not deviate from these solutions:

| Problem | Fix |
|---------|-----|
| Rails 8.1.2 incompatible with Ruby 3.3 | Use Rails 8.0.1 |
| `pg` gem segfaults in Fly.io container | `gem "pg", "~> 1.1", force_ruby_platform: true` in Gemfile |
| `release_command` in fly.toml causes segfault | Remove it entirely — run migrations manually via SSH |
| SQLite segfaults in Fly.io containers | Use Postgres instead |
| `secret_key_base` missing from credentials | Must be explicitly added to production credentials YAML |
| Sessions middleware disabled in API mode | Manually add `ActionDispatch::Session::CookieStore` in `config/application.rb` |
| Thruster tries to bind port 80 (fails as non-root) | Override in fly.toml: `[processes] app = './bin/rails server -b 0.0.0.0 -p 8080'` |
| OAuth state lost between request and callback | Replaced PKCE + cookie session with `OauthState` DB records |

---

## 6. The Outstanding Problem — Google OAuth with drive.file Scope

### Symptom
When the user clicks "Connect via Rails API" in the Ops App and selects their Google account, Google shows:
> **"Something went wrong — accounts.google.com/info/unknownerror"**

This happens **after** the account chooser and the "Google hasn't verified this app" warning screen.

### What We Know
- ✅ Health check works perfectly
- ✅ Rails is building and sending the correct OAuth URL to Google
- ✅ Correct Client ID, redirect URI, and scopes in the URL
- ✅ OAuth works with `userinfo.email` scope only (confirmed working)
- ✅ `drive.file` and `userinfo.email` are both correctly added to the consent screen Data Access
- ✅ Branding fields filled in, authorised domains added
- ✅ Test user `thewholeywaterproject@gmail.com` added to Audience
- ❌ Adding `drive.file` scope causes "Something went wrong" after account selection
- ❌ Zero OAuth traffic in Google Cloud Console metrics — Google is rejecting before issuing tokens

### Current State of the Rails App
```ruby
# app/controllers/auth_controller.rb
SCOPES = 'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/userinfo.email'
```
This is the current deployed state — `drive.file` is in the code but failing.

### What Has Been Tried
1. Fixed wrong scope on consent screen (`auth/docs` → `drive.file`)
2. Created brand new OAuth client ID (replaced the original broken one)
3. Added `drive.file` to Data Access scopes on consent screen
4. Added branding info (homepage, privacy policy, ToS)
5. Added `twwp-ops-api.fly.dev` to authorised domains
6. Tested in incognito browser
7. Temporarily stripped back to email-only scope (worked — confirmed Rails OAuth flow is functional)
8. Re-added `drive.file` to Rails and redeployed (failing again)

### Theories Not Yet Ruled Out
- Google may require the app to have a **verified domain** before `drive.file` scope works even in Testing mode
- There may be a **propagation delay** after consent screen changes (Google says wait 5 minutes but sometimes longer)
- The `drive.file` scope might require the **Google Drive API** to be enabled in the project (it shows 27 requests but confirm it's the Drive API v3, not just the Data API)
- The OAuth client might need time to "settle" after being newly created

---

## 7. Suggested Next Steps

### Option A — Wait and Retry (Low effort, try first)
Google consent screen changes can take up to 30 minutes to fully propagate. Kenny has been retrying immediately after each change. Try:
1. Wait 30 minutes without touching anything
2. Try the OAuth flow again fresh in incognito

### Option B — Verify Google Drive API is Enabled (5 minutes)
Go to Google Cloud Console → APIs & Services → Enabled APIs and confirm **Google Drive API** is listed. If not, enable it. Even though it shows traffic, double-check it's the right API.

### Option C — Add drive.readonly Instead of drive.file (10 minutes)
Test with a less permissive scope to narrow down the issue:
```ruby
SCOPES = 'https://www.googleapis.com/auth/drive.readonly https://www.googleapis.com/auth/userinfo.email'
```
If this works, it narrows the issue to something specific about `drive.file`.

### Option D — Check Google Workspace Admin Settings (if applicable)
If `thewholeywaterproject@gmail.com` is a Google Workspace account (not standard Gmail), an admin may have restricted third-party OAuth apps. Check Admin Console → Security → API controls.

### Option E — Test with a Completely Fresh Google Account
Create a brand new test Gmail account, add it as a test user, and try connecting with that. If it works, the issue is specific to the `thewholeywaterproject@gmail.com` account.

### Option F — Enable the People API
Some OAuth flows require the People API to be enabled alongside Drive. Try enabling it in Google Cloud Console → APIs & Services → Enable APIs → search "People API".

---

## 8. How to Redeploy After Code Changes

```bash
cd ~/twwp-ops-api
fly deploy
```

## How to Run Migrations After Schema Changes

```bash
fly ssh console --app twwp-ops-api -C "bin/rails db:migrate"
```

## How to View Live Logs

```bash
fly logs --app twwp-ops-api
```

## How to Edit Production Credentials

```bash
cd ~/twwp-ops-api
EDITOR="nano" rails credentials:edit --environment production
```
Save: `Ctrl+O` → Enter → `Ctrl+X`  
Then redeploy: `fly deploy`

## How to Open Rails Console on Server

```bash
fly ssh console --app twwp-ops-api
# then inside:
bin/rails console
```

---

## 9. Frontend Ops App Notes

- **Location:** https://kenny-mineral.github.io/TWWP-opps-app/
- **Repo:** kenny-mineral/TWWP-opps-app on GitHub
- **Local copy:** `~/Desktop/Opps App dev folder laptop/new2/index.html`
- The app is a single `index.html` file — all CSS and JS is inline
- Push changes with standard git commands from the new2 folder
- The "Connect via Rails API" button calls `https://twwp-ops-api.fly.dev/auth/google`
- There is also a separate "Google OAuth (Browser)" flow that bypasses Rails entirely — this is marked "Partial/Coming Soon" and is a different code path

---

## 10. Development Environment

- **Machine:** Kenny's Toshiba Linux laptop
- **OS:** Ubuntu 24
- **Editor:** VS Code
- **Node:** v22.22.1
- **npm:** v10.9.4
- **Claude Code:** v2.1.80 (installed globally via `sudo npm install -g @anthropic-ai/claude-code`)
- **Fly.io CLI:** flyctl v0.4.26
- **Rails:** 8.0.1
- **Ruby:** 3.3.0

To start a Claude Code session for this project:
```bash
cd ~/twwp-ops-api && claude
```

---

## 11. File Locations Quick Reference

| File | Path |
|------|------|
| Rails app | `~/twwp-ops-api/` |
| Auth controller | `~/twwp-ops-api/app/controllers/auth_controller.rb` |
| CORS config | `~/twwp-ops-api/config/initializers/cors.rb` |
| fly.toml | `~/twwp-ops-api/fly.toml` |
| Production credentials | `~/twwp-ops-api/config/credentials/production.yml.enc` |
| Production key | `~/twwp-ops-api/config/credentials/production.key` |
| Frontend app | `~/Desktop/Opps App dev folder laptop/new2/index.html` |
| Dev notes | `~/Desktop/Opps App dev folder laptop/new2/deployment-notes.md` |
| This handoff doc | `~/Desktop/Opps App dev folder laptop/new2/TWWP-ops-api-handoff.md` |
