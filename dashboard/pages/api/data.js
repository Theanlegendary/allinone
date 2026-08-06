// Data API — serves the enriched dashboard data
// Protected by token validation
// Supports two modes:
// 1. Local: reads from filesystem (when bot and dashboard run on same machine)
// 2. Remote: proxies from bot's HTTP server (when deployed to Vercel)

import fs from 'fs'
import path from 'path'

const TOKENS_PATH = path.join(process.cwd(), '..', 'dashboard_tokens.json')
const DATA_PATH = path.join(process.cwd(), '..', 'cache', 'dashboard_data.json')
const BOT_URL = process.env.BOT_DATA_URL // e.g. "http://your-bot-ip:8080/dashboard-data"

function loadTokens() {
  // Try local file first
  try {
    if (fs.existsSync(TOKENS_PATH)) {
      return JSON.parse(fs.readFileSync(TOKENS_PATH, 'utf-8'))
    }
  } catch (e) {}
  return null
}

function isTokenValid(token) {
  // Check from local file
  const data = loadTokens()
  if (!data) {
    // If no local token file, validate via env-based static tokens
    const staticToken = process.env.DASHBOARD_TOKEN
    return staticToken && token === staticToken
  }

  const now = new Date()
  for (const t of data.tokens || []) {
    if (t.token === token) {
      const expires = new Date(t.expires)
      if (now < expires) return true
    }
  }
  return false
}

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const token = req.headers.authorization?.replace('Bearer ', '')
  if (!token || !isTokenValid(token)) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  // Try local file first
  try {
    if (fs.existsSync(DATA_PATH)) {
      const raw = fs.readFileSync(DATA_PATH, 'utf-8')
      const data = JSON.parse(raw)
      res.setHeader('Cache-Control', 'no-cache')
      return res.status(200).json(data)
    }
  } catch (e) {}

  // Try remote bot URL
  if (BOT_URL) {
    try {
      const response = await fetch(BOT_URL, {
        headers: { 'Authorization': `Bearer ${token}` }
      })
      if (response.ok) {
        const data = await response.json()
        res.setHeader('Cache-Control', 'no-cache')
        return res.status(200).json(data)
      }
    } catch (e) {
      console.error('Failed to fetch from bot:', e)
    }
  }

  return res.status(200).json({ branches: {}, summary: {}, updated: null })
}
