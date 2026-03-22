# TWWP Ops App

Internal operations platform for [The Wholey Water Project](https://thewholeywaterproject.com) — a community reverse osmosis water network in New Zealand.

**Live app:** https://kenny-mineral.github.io/TWWP-opps-app/

---

## What it does

A single-file browser app that manages waterhouse operations, guardian reimbursements, maintenance, members, financials, inventory, and governance.

---

## Stack

- Single HTML file (~9,300 lines) deployed via GitHub Pages
- Cloudflare Worker — OAuth proxy and scraper
- Rails 8 API on Fly.io — Google OAuth and multi-device sync
- PostgreSQL (Fly.io managed)
- Google Drive API for document storage

---

> Full documentation, credentials, and setup details are in private internal docs — not in this repository.
