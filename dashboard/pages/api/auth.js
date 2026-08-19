// Token validation API
// The bot generates a daily rotating key via /adminthean command
// Supports local file-based tokens AND env-based static token for Vercel

import fs from 'fs'
import path from 'path'

const TOKENS_PATH = path.join(process.cwd(), '..', 'dashboard_tokens.json')

function isTokenValid(token) {
  // Check env-based static token first (for Vercel deployment)
  const staticToken = process.env.DASHBOARD_TOKEN
  if (staticToken && token === staticToken) {
    return true
  }

  // Check local file tokens
  try {
    if (fs.existsSync(TOKENS_PATH)) {
      const data = JSON.parse(fs.readFileSync(TOKENS_PATH, 'utf-8'))
      const now = new Date()
      for (const t of data.tokens || []) {
        if (t.token === token) {
          const expires = new Date(t.expires)
          if (now < expires) return true
        }
      }
    }
  } catch (e) {
    console.error('Failed to load tokens:', e)
  }
  return false
}

export default function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const { token } = req.body
  if (!token) {
    return res.status(400).json({ error: 'Token required' })
  }

  if (isTokenValid(token)) {
    return res.status(200).json({ success: true })
  }

  return res.status(401).json({ error: 'Invalid or expired token' })
}
