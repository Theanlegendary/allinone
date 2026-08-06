import { useState } from 'react'
import { useRouter } from 'next/router'
import Head from 'next/head'

export default function Login() {
  const [token, setToken] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  async function handleSubmit(e) {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      const res = await fetch('/api/auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token: token.trim() })
      })

      if (res.ok) {
        localStorage.setItem('dashboard_token', token.trim())
        router.push('/')
      } else {
        setError('Invalid or expired access key')
      }
    } catch (e) {
      setError('Connection error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <Head>
        <title>Login — Push Bot Dashboard</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <div style={styles.container}>
        <div style={styles.card}>
          <div style={styles.logo}>⚡</div>
          <h1 style={styles.title}>Push Bot Dashboard</h1>
          <p style={styles.subtitle}>Enter your daily access key</p>

          <form onSubmit={handleSubmit} style={styles.form}>
            <input
              type="text"
              value={token}
              onChange={e => setToken(e.target.value)}
              placeholder="Access key from /adminthean"
              style={styles.input}
              autoFocus
            />
            {error && <p style={styles.error}>{error}</p>}
            <button
              type="submit"
              disabled={loading || !token.trim()}
              style={{
                ...styles.button,
                opacity: loading || !token.trim() ? 0.6 : 1
              }}
            >
              {loading ? 'Checking...' : 'Login'}
            </button>
          </form>

          <p style={styles.hint}>
            Use /adminthean in the bot to generate a key
          </p>
        </div>
      </div>
    </>
  )
}

const styles = {
  container: {
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '20px',
  },
  card: {
    background: 'var(--surface)',
    borderRadius: '16px',
    padding: '40px 32px',
    width: '100%',
    maxWidth: '380px',
    textAlign: 'center',
    border: '1px solid var(--border)',
    boxShadow: '0 25px 50px -12px rgba(0,0,0,0.5)',
  },
  logo: {
    fontSize: '3rem',
    marginBottom: '12px',
  },
  title: {
    fontSize: '1.4rem',
    fontWeight: 700,
    marginBottom: '4px',
  },
  subtitle: {
    color: 'var(--text-muted)',
    fontSize: '0.9rem',
    marginBottom: '24px',
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },
  input: {
    width: '100%',
    padding: '14px 16px',
    borderRadius: 'var(--radius)',
    border: '1px solid var(--border)',
    background: 'var(--bg)',
    color: 'var(--text)',
    fontSize: '1rem',
    textAlign: 'center',
    letterSpacing: '2px',
  },
  button: {
    width: '100%',
    padding: '14px',
    borderRadius: 'var(--radius)',
    background: 'var(--primary)',
    color: '#fff',
    fontSize: '1rem',
    fontWeight: 600,
    transition: 'all 0.2s',
  },
  error: {
    color: 'var(--danger)',
    fontSize: '0.85rem',
    margin: 0,
  },
  hint: {
    color: 'var(--text-muted)',
    fontSize: '0.75rem',
    marginTop: '20px',
  },
}
