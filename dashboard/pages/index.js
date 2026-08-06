import { useState, useEffect } from 'react'
import { useRouter } from 'next/router'
import Head from 'next/head'

const CATEGORY_FILTERS = [
  { key: 'active', label: 'Active', icon: '📍', color: 'var(--primary)' },
  { key: 'shipped', label: 'Shipped', icon: '✅', color: 'var(--success)' },
  { key: 'cancelled', label: 'Cancelled', icon: '❌', color: 'var(--danger)' },
  { key: 'return', label: 'Return', icon: '↩️', color: 'var(--warning)' },
]

// Tabs = stage-based views
const TABS = [
  { key: 'all', label: 'All', icon: '📊', color: 'var(--primary)', desc: 'All statuses at this PO' },
  { key: 'pickup', label: 'Pickup', icon: '📦', color: 'var(--purple)', desc: 'Waiting to pick up (110/120/200)' },
  { key: 'delivery', label: 'Under Delivery', icon: '🚚', color: 'var(--warning)', desc: 'Assigned/delivering (401/420/472...)' },
  { key: 'completed', label: 'Completed', icon: '✅', color: 'var(--success)', desc: 'Done today (410/520/201)' },
  { key: 'incoming', label: 'Incoming', icon: '📥', color: 'var(--text-muted)', desc: 'From other PO heading here' },
]

export default function Dashboard() {
  const router = useRouter()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [expandedBranch, setExpandedBranch] = useState(null)
  const [activeTab, setActiveTab] = useState('all')
  const [search, setSearch] = useState('')
  const [filters, setFilters] = useState({
    active: true,
    shipped: true,
    cancelled: true,
    return: true,
  })

  useEffect(() => {
    const token = localStorage.getItem('dashboard_token')
    if (!token) {
      router.push('/login')
      return
    }
    fetchData(token)
  }, [])

  async function fetchData(token) {
    try {
      const res = await fetch('/api/data', {
        headers: { Authorization: `Bearer ${token}` }
      })
      if (res.status === 401) {
        localStorage.removeItem('dashboard_token')
        router.push('/login')
        return
      }
      if (!res.ok) throw new Error('Failed to load')
      const json = await res.json()
      setData(json)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  function toggleFilter(key) {
    setFilters(prev => ({ ...prev, [key]: !prev[key] }))
  }

  function handleLogout() {
    localStorage.removeItem('dashboard_token')
    router.push('/login')
  }

  if (loading) {
    return (
      <div style={styles.center}>
        <div style={styles.spinner}>⏳</div>
        <p>Loading dashboard...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div style={styles.center}>
        <p style={{ color: 'var(--danger)' }}>{error}</p>
        <button onClick={() => location.reload()} style={styles.retryBtn}>Retry</button>
      </div>
    )
  }

  const branches = data?.branches || {}
  const updated = data?.updated || 'N/A'

  // Apply category filter
  function filterByCategory(orders) {
    return orders.filter(o => filters[o.category] !== false)
  }

  // Apply stage tab filter
  function filterByStage(orders, stage) {
    if (stage === 'all') return orders
    if (stage === 'incoming') return orders // incoming is separate list
    return orders.filter(o => o.stage === stage)
  }

  // Get orders for a branch + current tab + filters
  function getTabOrders(bd) {
    if (activeTab === 'incoming') {
      return filterByCategory(bd.incoming || [])
    }
    // For all/pickup/delivery/completed — use total_today (pending + completed)
    const all = bd.total_today || []
    const staged = filterByStage(all, activeTab)
    return filterByCategory(staged)
  }

  // Calculate summary count for a tab across all branches
  function getSummaryCount(tabKey) {
    let total = 0
    for (const bd of Object.values(branches)) {
      if (tabKey === 'incoming') {
        total += filterByCategory(bd.incoming || []).length
      } else {
        const all = bd.total_today || []
        const staged = filterByStage(all, tabKey)
        total += filterByCategory(staged).length
      }
    }
    return total
  }

  // Filter branches by search
  const branchKeys = Object.keys(branches).sort().filter(b => {
    if (!search) return true
    const q = search.toLowerCase()
    if (b.toLowerCase().includes(q)) return true
    const bd = branches[b]
    const allOrders = [...(bd.total_today || []), ...(bd.incoming || [])]
    return allOrders.some(o =>
      (o.order_id && o.order_id.toLowerCase().includes(q)) ||
      (o.receiver && o.receiver.toLowerCase().includes(q)) ||
      (o.phone && o.phone.includes(q))
    )
  })

  return (
    <>
      <Head>
        <title>Push Bot Dashboard</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <div style={styles.page}>
        {/* Header */}
        <header style={styles.header}>
          <div style={styles.headerTop}>
            <h1 style={styles.headerTitle}>⚡ Manager Report</h1>
            <button onClick={handleLogout} style={styles.logoutBtn}>Logout</button>
          </div>
          <p style={styles.updated}>Updated: {updated}</p>
        </header>

        {/* Tab Selector */}
        <div style={styles.tabGrid}>
          {TABS.map(tab => (
            <div
              key={tab.key}
              style={{
                ...styles.tabCard,
                borderTop: `3px solid ${tab.color}`,
                background: activeTab === tab.key ? 'var(--surface-hover)' : 'var(--surface)',
                opacity: activeTab === tab.key ? 1 : 0.65,
              }}
              onClick={() => setActiveTab(tab.key)}
            >
              <div style={{ fontSize: '0.9rem' }}>{tab.icon}</div>
              <div style={{ ...styles.tabValue, color: tab.color }}>
                {getSummaryCount(tab.key)}
              </div>
              <div style={styles.tabLabel}>{tab.label}</div>
            </div>
          ))}
        </div>

        {/* Category Filters */}
        <div style={styles.filterRow}>
          <span style={styles.filterTitle}>Filter:</span>
          {CATEGORY_FILTERS.map(f => (
            <label key={f.key} style={styles.filterLabel} onClick={() => toggleFilter(f.key)}>
              <span style={{
                ...styles.checkbox,
                background: filters[f.key] ? f.color : 'transparent',
                borderColor: f.color,
              }}>
                {filters[f.key] && '✓'}
              </span>
              <span style={{ opacity: filters[f.key] ? 1 : 0.5, fontSize: '0.72rem' }}>
                {f.label}
              </span>
            </label>
          ))}
        </div>

        {/* Tab Description */}
        <div style={styles.tabDesc}>
          {TABS.find(t => t.key === activeTab)?.icon}{' '}
          <strong>{TABS.find(t => t.key === activeTab)?.label}</strong>
          {' — '}
          <span style={{ color: 'var(--text-muted)' }}>
            {TABS.find(t => t.key === activeTab)?.desc}
          </span>
        </div>

        {/* Search */}
        <div style={styles.searchBox}>
          <input
            type="text"
            placeholder="Search branch, order ID, name, phone..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            style={styles.searchInput}
          />
        </div>

        {/* Branch Cards */}
        <div style={styles.branchList}>
          {branchKeys.length === 0 && (
            <p style={styles.empty}>No branches found</p>
          )}
          {branchKeys.map(branch => {
            const bd = branches[branch]
            const tabOrders = getTabOrders(bd)
            const tabCount = tabOrders.length
            if (tabCount === 0 && !search) return null
            return (
              <BranchCard
                key={branch}
                branch={branch}
                data={bd}
                activeTab={activeTab}
                tabOrders={tabOrders}
                tabCount={tabCount}
                expanded={expandedBranch === branch}
                onToggle={() => setExpandedBranch(
                  expandedBranch === branch ? null : branch
                )}
                search={search}
                filterByCategory={filterByCategory}
                filterByStage={filterByStage}
              />
            )
          })}
        </div>
      </div>
    </>
  )
}

function BranchCard({ branch, data, activeTab, tabOrders, tabCount, expanded, onToggle, search, filterByCategory, filterByStage }) {
  // Fee/COD from pending only
  let totalFee = 0
  let totalCod = 0
  const pending = filterByCategory(data.all_pending || [])
  pending.forEach(o => { totalFee += o.fee || 0; totalCod += o.cod || 0 })

  // Search filter
  let displayOrders = tabOrders
  if (search) {
    const q = search.toLowerCase()
    displayOrders = tabOrders.filter(o =>
      (o.order_id && o.order_id.toLowerCase().includes(q)) ||
      (o.receiver && o.receiver.toLowerCase().includes(q)) ||
      (o.phone && o.phone.includes(q))
    )
  }

  // Per-tab mini counts
  const allTotal = filterByCategory(data.total_today || [])
  const pickupCount = filterByCategory(filterByStage(data.total_today || [], 'pickup')).length
  const deliveryCount = filterByCategory(filterByStage(data.total_today || [], 'delivery')).length
  const completedCount = filterByCategory(filterByStage(data.total_today || [], 'completed')).length
  const incomingCount = filterByCategory(data.incoming || []).length

  return (
    <div style={styles.branchCard}>
      <div style={styles.branchHeader} onClick={onToggle}>
        <div>
          <div style={styles.branchName}>{branch}</div>
          <div style={styles.branchMeta}>
            <span style={styles.tag}>📦{pickupCount}</span>
            <span style={styles.tag}>🚚{deliveryCount}</span>
            <span style={styles.tag}>✅{completedCount}</span>
            <span style={styles.tag}>📥{incomingCount}</span>
          </div>
        </div>
        <div style={styles.branchRight}>
          <div style={styles.branchTotal}>{tabCount}</div>
          {(totalFee > 0 || totalCod > 0) && (
            <div style={styles.branchFees}>
              {totalFee > 0 && <span style={styles.feeTag}>Fee: ${totalFee.toFixed(2)}</span>}
              {totalCod > 0 && <span style={styles.codTag}>COD: ${totalCod.toFixed(2)}</span>}
            </div>
          )}
          <div style={styles.expandIcon}>{expanded ? '▲' : '▼'}</div>
        </div>
      </div>

      {expanded && (
        <div style={styles.orderList}>
          {displayOrders.length === 0 && <p style={styles.noOrders}>No orders in this view</p>}
          {displayOrders.map((order, i) => (
            <div key={i} style={styles.orderRow}>
              <div style={styles.orderTop}>
                <span style={styles.orderId}>{order.order_id}</span>
                <span style={{
                  ...styles.statusBadge,
                  background: getCategoryBg(order.category)
                }}>
                  {order.report_type} ({order.status_code})
                </span>
              </div>
              <div style={styles.orderMeta}>
                {order.receiver && <span>📦 {order.receiver}</span>}
                {order.phone && <span>📞 {order.phone}</span>}
                {order.current_po && <span>📍 At: {order.current_po}</span>}
              </div>
              <div style={styles.orderMeta}>
                {order.fee > 0 && <span style={styles.feeSmall}>Fee: ${order.fee.toFixed(2)}</span>}
                {order.cod > 0 && <span style={styles.codSmall}>COD: ${order.cod.toFixed(2)}</span>}
                {order.created_date && <span>📅 {order.created_date}</span>}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

function getCategoryBg(category) {
  switch (category) {
    case 'shipped': return 'rgba(16,185,129,0.25)'
    case 'cancelled': return 'rgba(239,68,68,0.25)'
    case 'return': return 'rgba(245,158,11,0.25)'
    default: return 'rgba(59,130,246,0.15)'
  }
}

const styles = {
  page: {
    maxWidth: '600px',
    margin: '0 auto',
    padding: '16px',
    paddingBottom: '40px',
  },
  center: {
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '12px',
  },
  spinner: { fontSize: '2rem' },
  retryBtn: {
    padding: '10px 20px',
    borderRadius: 'var(--radius)',
    background: 'var(--primary)',
    color: '#fff',
    fontWeight: 600,
  },
  header: {
    marginBottom: '16px',
  },
  headerTop: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: '1.3rem',
    fontWeight: 700,
  },
  logoutBtn: {
    padding: '8px 16px',
    borderRadius: '8px',
    background: 'var(--surface)',
    color: 'var(--text-muted)',
    fontSize: '0.8rem',
    border: '1px solid var(--border)',
  },
  updated: {
    color: 'var(--text-muted)',
    fontSize: '0.8rem',
    marginTop: '4px',
  },
  tabGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(5, 1fr)',
    gap: '6px',
    marginBottom: '10px',
  },
  tabCard: {
    background: 'var(--surface)',
    borderRadius: '10px',
    padding: '8px 4px',
    textAlign: 'center',
    cursor: 'pointer',
    transition: 'all 0.15s',
  },
  tabValue: {
    fontSize: '1.1rem',
    fontWeight: 800,
  },
  tabLabel: {
    fontSize: '0.55rem',
    color: 'var(--text-muted)',
    fontWeight: 600,
    textTransform: 'uppercase',
    marginTop: '1px',
  },
  filterRow: {
    display: 'flex',
    gap: '10px',
    alignItems: 'center',
    flexWrap: 'wrap',
    marginBottom: '10px',
    padding: '8px 12px',
    background: 'var(--surface)',
    borderRadius: 'var(--radius)',
    border: '1px solid var(--border)',
  },
  filterTitle: {
    fontSize: '0.7rem',
    fontWeight: 700,
    color: 'var(--text-muted)',
  },
  filterLabel: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    cursor: 'pointer',
    userSelect: 'none',
  },
  checkbox: {
    width: '16px',
    height: '16px',
    borderRadius: '4px',
    border: '2px solid',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '0.6rem',
    color: '#fff',
    fontWeight: 800,
    transition: 'all 0.15s',
  },
  tabDesc: {
    fontSize: '0.78rem',
    marginBottom: '10px',
    padding: '7px 12px',
    background: 'var(--surface)',
    borderRadius: '8px',
    border: '1px solid var(--border)',
  },
  searchBox: {
    marginBottom: '12px',
  },
  searchInput: {
    width: '100%',
    padding: '12px 16px',
    borderRadius: 'var(--radius)',
    border: '1px solid var(--border)',
    background: 'var(--surface)',
    color: 'var(--text)',
    fontSize: '0.9rem',
  },
  branchList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '10px',
  },
  empty: {
    textAlign: 'center',
    color: 'var(--text-muted)',
    padding: '40px',
  },
  branchCard: {
    background: 'var(--surface)',
    borderRadius: 'var(--radius)',
    border: '1px solid var(--border)',
    overflow: 'hidden',
  },
  branchHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '14px 16px',
    cursor: 'pointer',
  },
  branchName: {
    fontWeight: 700,
    fontSize: '0.95rem',
    marginBottom: '4px',
  },
  branchMeta: {
    display: 'flex',
    gap: '6px',
    flexWrap: 'wrap',
  },
  tag: {
    fontSize: '0.68rem',
    padding: '2px 5px',
    borderRadius: '4px',
    background: 'var(--bg)',
    color: 'var(--text-muted)',
    fontWeight: 700,
  },
  branchRight: {
    textAlign: 'right',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-end',
    gap: '4px',
  },
  branchTotal: {
    fontSize: '1.3rem',
    fontWeight: 800,
  },
  branchFees: {
    display: 'flex',
    gap: '6px',
    flexWrap: 'wrap',
  },
  feeTag: {
    fontSize: '0.65rem',
    color: 'var(--warning)',
    fontWeight: 600,
  },
  codTag: {
    fontSize: '0.65rem',
    color: 'var(--success)',
    fontWeight: 600,
  },
  expandIcon: {
    fontSize: '0.7rem',
    color: 'var(--text-muted)',
  },
  orderList: {
    borderTop: '1px solid var(--border)',
    padding: '8px 12px',
    maxHeight: '400px',
    overflowY: 'auto',
  },
  noOrders: {
    color: 'var(--text-muted)',
    fontSize: '0.8rem',
    textAlign: 'center',
    padding: '12px',
  },
  orderRow: {
    padding: '10px 8px',
    borderBottom: '1px solid var(--border)',
  },
  orderTop: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '4px',
  },
  orderId: {
    fontWeight: 700,
    fontSize: '0.85rem',
    fontFamily: 'monospace',
  },
  statusBadge: {
    fontSize: '0.65rem',
    padding: '2px 8px',
    borderRadius: '6px',
    fontWeight: 600,
  },
  orderMeta: {
    display: 'flex',
    gap: '10px',
    fontSize: '0.78rem',
    color: 'var(--text-muted)',
    flexWrap: 'wrap',
    marginBottom: '2px',
  },
  feeSmall: {
    color: 'var(--warning)',
    fontWeight: 600,
  },
  codSmall: {
    color: 'var(--success)',
    fontWeight: 600,
  },
}
