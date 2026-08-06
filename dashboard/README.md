# Push Bot Dashboard

Web dashboard for the push bot. Shows per-branch summary cards with order details.

## Features

- Summary cards per branch: Pickup, Delivery, Transit, Branch counts
- Total Fee/COD per branch
- Click to expand shows order details (ID, receiver, status, fee, COD, date)
- Token-based login (no username) — daily rotating key
- Bot command `/adminthean` generates new access key
- Dark mode UI

## Local Development

```bash
cd dashboard
npm install
npm run dev
```

## Deploy to Vercel

1. Push this `dashboard/` folder to a Git repo (or use Vercel CLI)

2. In Vercel project settings, set environment variables:
   - `BOT_DATA_URL` = `http://your-public-ip:8080/dashboard-data`
   - `DASHBOARD_TOKEN` = a static fallback token (optional)

3. Deploy:
   ```bash
   cd dashboard
   npx vercel
   ```

## How Token Auth Works

1. In Telegram, send `/adminthean` to the bot
2. Bot generates an 8-char key valid for 24 hours
3. Enter that key on the dashboard login page
4. Token is stored in localStorage

## Architecture

- **Bot (bot.py)**: Generates dashboard data on every `push` → saves to `cache/dashboard_data.json`
- **Bot HTTP server (port 8080)**: Serves `/dashboard-data` endpoint
- **Dashboard (Next.js)**: Reads data from bot's HTTP endpoint or local file
- **Token file**: `dashboard_tokens.json` in workspace root
