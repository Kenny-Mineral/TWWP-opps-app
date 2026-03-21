# TWWP Ops App

Internal operations platform for [The Wholey Water Project](https://thewholeywaterproject.com) — a community reverse osmosis water network in New Zealand.

**Version:** v4.2 (session 6) | **File:** `index.html` (~9,300 lines, ~680KB)
**Live app:** https://kenny-mineral.github.io/TWWP-opps-app/
**GitHub:** https://github.com/Kenny-Mineral/TWWP-opps-app
**Owner:** Kenny / TWWP | admin@thewholeywaterproject.com | 02041333855

---

## What this is

A single-file browser app that manages waterhouse operations, guardian reimbursements, maintenance, members, financials, inventory, and governance.

---

## Quick start

- Login: `admin` / `twwp2024` (leave blank for dev mode)
- The entire app is `index.html` at repo root

---

## Deploy a change

1. Edit `index.html`
2. Commit and push to GitHub
3. Live in ~30 seconds via GitHub Pages

---

## Services

| Service | URL | Status |
|---------|-----|--------|
| Ops App | https://kenny-mineral.github.io/TWWP-opps-app/ | ✅ Live |
| Rails API | https://twwp-ops-api.fly.dev | ✅ Deployed |
| Cloudflare Worker | https://twwp-proxy.thewholeywaterproject.workers.dev | ✅ Live |
| Tap-Map (separate app) | https://app.thewholeywaterproject.com | ✅ Do not touch |

---

## Rails API

The backend lives in a separate folder: `~/twwp-ops-api/` on the dev machine.
It is **not** part of this repo. See `PROJECT_CONTEXT.md` for commands.

---

## Google Cloud Console

**Project:** Opps App TWWP - Kenny | **Account:** thewholeywaterproject@gmail.com

| Credential | Status | Notes |
|-----------|--------|-------|
| Google Drive API | ✅ Enabled | |
| API Key | ✅ Working | Read-only Drive access |
| OAuth Client ID | ✅ Active | ends in `...39mavd5fmtl0s688dcfa26gdq64sjvkd` |
| OAuth Consent Screen | ✅ Configured | Testing mode, external |
| Gemini API Key | ✅ Working | From aistudio.google.com NOT Cloud Console |

⚠️ Two Client IDs exist — use `...39mavd5` NOT `...nljl` (old, broken)
**Current Gemini model:** gemini-2.5-flash

---

## Google Drive

**Root folder:** TWWP Ops | **Folder ID:** `1CZJoNgUtAV9r6IQqdcmWF2TWyUW7yCem`
**Sharing:** Anyone with link can view

- Phase 1 (read-only) ✅ WORKING
- Phase 2 (write/sync via Rails) ⏳ PENDING — drive.file scope bug

---

## Current critical issue

Google OAuth fails with `drive.file` scope. Email-only OAuth works.
See `docs/known-issues.md` bug A1 for full debug info and next steps.

---

## Multi-device sync

Data in localStorage only — does not sync between devices.
**Workaround:** Backup JSON → transfer → Restore Backup
**Fix:** Rails API OAuth — once drive.file scope works, sync is automatic.

---

## Where to read next

| File | Purpose |
|------|---------|
| `PROJECT_CONTEXT.md` | Full project context for AI and developers |
| `CURRENT_STATE.md` | What works, what's blocked, next steps |
| `docs/architecture.md` | How the app is built |
| `docs/pages.md` | Every page documented |
| `docs/data-storage.md` | All localStorage stores and shapes |
| `docs/how-to-extend.md` | Adding pages, stores, modals |
| `docs/known-issues.md` | Current bugs |
| `docs/backlog.md` | Outstanding work with build sequence |
| `docs/handoff/` | AI session handoff documents |
