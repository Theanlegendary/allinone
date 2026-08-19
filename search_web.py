"""
search_web.py — Order Search Portal (No external framework needed)
Runs a lightweight HTTP web server on port 5055.
- 5-minute cache of 14-day API data stored in cache/ folder
- Background refresh thread keeps cache warm every 5 minutes
- Keyword search across ALL columns (phone, name, order ID, note, etc.)
- Category filters: Delayed (>1 day), Missing (>7 days), Issue statuses
- Download filtered results as Excel (.xlsx)
Run: python search_web.py
"""

import json
import os
import io
import sys
import time
import threading
import tempfile
import gzip
from datetime import datetime, timedelta
from urllib.parse import urlparse, parse_qs, unquote
from http.server import HTTPServer, BaseHTTPRequestHandler

import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import downloader

# Fix Windows console encoding
if sys.stdout.encoding and sys.stdout.encoding.lower() not in ('utf-8', 'utf_8'):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# ── Config ─────────────────────────────────────────────────────────────────────
CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")
CACHE_DIR   = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cache")
CACHE_FILE  = os.path.join(CACHE_DIR, "search_14days_cache.xlsx")
CACHE_TTL   = 300          # 5 minutes
PORT        = 5055

with open(CONFIG_PATH, encoding="utf-8") as _f:
    _cfg = json.load(_f)

# ── In-memory cache (loaded once, refreshed in background) ────────────────────
_df_cache: pd.DataFrame = pd.DataFrame()
_cache_mtime: float = 0.0
_cache_lock = threading.Lock()

STATUS_LABELS = {
    "110": "Pickup Pending",   "120": "Pickup Failed",    "200": "At Origin Store",
    "210": "Transit",          "230": "In Transit",        "300": "At Hub",
    "302": "Received Hub",     "306": "At Branch",         "309": "At Store",
    "310": "At Agent",         "311": "Dispatched",        "400": "Delivery Assigned",
    "401": "Out for Delivery", "402": "Re-Delivery",       "420": "Notify Customer",
    "430": "Contact Receiver", "460": "Return Init",       "470": "Returning",
    "471": "Return Verify",    "472": "Return Issue",      "480": "Rerouting",
    "500": "Returning",        "510": "Return Transit",    "511": "Return Branch",
    "512": "Return Store",     "201": "Delivered ✅",      "410": "Completed ✅",
    "520": "Return Completed ✅"
}


def _do_download():
    os.makedirs(CACHE_DIR, exist_ok=True)
    today = datetime.now()
    from_date = (today - timedelta(days=14)).strftime("%Y%m%d")
    to_date   = today.strftime("%Y%m%d")
    tmp = CACHE_FILE + ".tmp"
    downloader.download_detail(_cfg["api"], tmp, from_date=from_date, to_date=to_date, force_refresh=True)
    os.replace(tmp, CACHE_FILE)


def _load_df_from_file():
    global _df_cache, _cache_mtime
    df = pd.read_excel(CACHE_FILE)

    # Compute age in days
    date_col = "CREATED DATE" if "CREATED DATE" in df.columns else "CURRENT TIME"
    if date_col in df.columns:
        parsed = pd.to_datetime(df[date_col], dayfirst=True, format="mixed", errors="coerce")
        df["_age_days"] = ((datetime.now() - parsed).dt.total_seconds() / 86400).fillna(0).clip(lower=0)
    else:
        df["_age_days"] = 0.0

    # Add status code label
    if "CURRENT STATUS" in df.columns:
        sc = df["CURRENT STATUS"].astype(str).str.extract(r"^(\d{3})")[0]
        df["STATUS_CODE"] = sc
        df["STATUS_LABEL"] = sc.map(STATUS_LABELS).fillna(sc)
    else:
        df["STATUS_CODE"] = ""
        df["STATUS_LABEL"] = ""

    with _cache_lock:
        _df_cache   = df
        _cache_mtime = os.path.getmtime(CACHE_FILE)
    print(f"[CACHE] Loaded {len(df):,} rows from {CACHE_FILE}")


def _refresh_loop():
    """Background thread: refresh cache every 5 minutes."""
    while True:
        try:
            need_refresh = (
                not os.path.exists(CACHE_FILE)
                or (time.time() - os.path.getmtime(CACHE_FILE) > CACHE_TTL)
            )
            if need_refresh:
                print("[BG] Downloading fresh 14-day data…")
                _do_download()
                _load_df_from_file()
                print("[BG] Cache refreshed.")
        except Exception as e:
            print(f"[BG] Refresh error: {e}")
        time.sleep(60)      # Check every 60 s; refresh only when TTL expired


def _initial_load():
    """Startup: ensure we have data before serving the first request."""
    if os.path.exists(CACHE_FILE) and (time.time() - os.path.getmtime(CACHE_FILE) < CACHE_TTL):
        print("[INIT] Using existing cache file.")
        _load_df_from_file()
    else:
        print("[INIT] Downloading fresh data…")
        _do_download()
        _load_df_from_file()


def _get_df():
    with _cache_lock:
        return _df_cache.copy(), _cache_mtime


# ── Search / filter ───────────────────────────────────────────────────────────
def do_search(query: str, category: str) -> pd.DataFrame:
    df, _ = _get_df()
    if df.empty:
        return df

    # Exclude completed done statuses in main view (unless asking for them)
    done_codes = {"201", "410", "520"}
    if category not in ("all_incl_done", "done", "cancel_return"):
        df = df[~df["STATUS_CODE"].isin(done_codes)].copy()

    # Keyword filter
    q = query.strip()
    if q:
        mask = df.astype(str).apply(
            lambda row: row.str.contains(q, case=False, na=False).any(), axis=1
        )
        df = df[mask]

    # Category filter
    if category == "missing":
        df = df[df["_age_days"] > 7]
    elif category == "delayed":
        df = df[df["_age_days"] > 1]
    elif category == "issue":
        df = df[df["STATUS_CODE"].isin({"420", "460", "472", "480", "500"})]
    elif category == "done":
        df, _ = _get_df()
        df = df[df["STATUS_CODE"].isin(done_codes)]
        if q:
            mask = df.astype(str).apply(
                lambda row: row.str.contains(q, case=False, na=False).any(), axis=1
            )
            df = df[mask]
    elif category == "cancel_return":
        df, _ = _get_df()
        df = df[df["STATUS_CODE"].isin({"201", "500", "510", "511", "512", "520", "540"})].copy()
        if q:
            mask = df.astype(str).apply(
                lambda row: row.str.contains(q, case=False, na=False).any(), axis=1
            )
            df = df[mask]
    elif category == "pickup":
        df = df[df["STATUS_CODE"].isin({"110", "120", "200"})]
    elif category == "delivery":
        df = df[df["STATUS_CODE"].isin({"401", "402", "420", "430", "460", "400", "306", "309"})]
    elif category == "transit":
        df = df[df["STATUS_CODE"].isin({"210", "230", "300", "302", "310", "311"})]
    elif category == "branch":
        df = df[df["STATUS_CODE"].isin({"306", "309", "400", "472", "480"})]
    elif category == "po_only":
        # Show only bills where search query matches CURRENT POST OFFICE
        if q and "CURRENT POST OFFICE" in df.columns:
            df = df[df["CURRENT POST OFFICE"].astype(str).str.contains(q, case=False, na=False)]
        # If no search query, show all (same as 'all')
    elif category == "all_incl_done":
        df, _ = _get_df()
        if q:
            mask = df.astype(str).apply(
                lambda row: row.str.contains(q, case=False, na=False).any(), axis=1
            )
            df = df[mask]

    return df


def make_excel(df: pd.DataFrame) -> bytes:
    drop_cols = ["_age_days"]
    out_df = df.drop(columns=[c for c in drop_cols if c in df.columns], errors="ignore")
    buf = io.BytesIO()
    with pd.ExcelWriter(buf, engine="openpyxl") as writer:
        out_df.to_excel(writer, index=False, sheet_name="Results")
        ws = writer.sheets["Results"]
        for col in ws.columns:
            ws.column_dimensions[col[0].column_letter].width = max(
                len(str(col[0].value or "")), 10
            ) + 4
    return buf.getvalue()


# ── HTML templates ────────────────────────────────────────────────────────────
HTML = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>📦 Order Search Portal</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
  *{{margin:0;padding:0;box-sizing:border-box}}
  :root{{
    --bg:#0a0f1e;--surface:#111827;--surface2:#1a2235;--border:#1e2d45;
    --accent:#3b82f6;--accent2:#06b6d4;--green:#10b981;--amber:#f59e0b;
    --red:#ef4444;--purple:#8b5cf6;--text:#e2e8f0;--muted:#64748b;
    --radius:12px;--radius-sm:8px
  }}
  body{{font-family:'Inter',sans-serif;background:var(--bg);color:var(--text);min-height:100vh}}
  a{{color:inherit;text-decoration:none}}

  /* Header */
  .header{{background:linear-gradient(135deg,#0f172a 0%,#1e1b4b 100%);
    border-bottom:1px solid var(--border);padding:20px 32px;
    display:flex;align-items:center;gap:16px;position:sticky;top:0;z-index:100;
    box-shadow:0 4px 24px rgba(0,0,0,.4)}}
  .header h1{{font-size:20px;font-weight:700;
    background:linear-gradient(135deg,#60a5fa,#a78bfa);-webkit-background-clip:text;
    -webkit-text-fill-color:transparent}}
  .header .sub{{font-size:12px;color:var(--muted);margin-top:2px}}
  .cache-badge{{margin-left:auto;font-size:11px;color:var(--muted);
    background:var(--surface2);padding:4px 10px;border-radius:20px;border:1px solid var(--border)}}
  .cache-badge.fresh{{color:var(--green)}}
  .cache-badge.stale{{color:var(--amber)}}

  /* Main layout */
  .container{{max-width:1600px;margin:0 auto;padding:24px 32px}}

  /* Stats bar */
  .stats-bar{{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin-bottom:24px}}
  .stat-card{{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);
    padding:16px 20px;cursor:pointer;transition:all .2s}}
  .stat-card:hover{{border-color:var(--accent);transform:translateY(-2px)}}
  .stat-card.active{{border-color:var(--accent);background:rgba(59,130,246,.12)}}
  .stat-card .val{{font-size:28px;font-weight:700;margin-bottom:4px}}
  .stat-card .lbl{{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px}}
  .stat-total .val{{color:var(--accent)}}
  .stat-delayed .val{{color:var(--amber)}}
  .stat-missing .val{{color:var(--red)}}
  .stat-issue .val{{color:var(--purple)}}
  .stat-done .val{{color:var(--green)}}

  /* Search bar */
  .search-row{{display:flex;gap:12px;margin-bottom:20px;align-items:center;flex-wrap:wrap}}
  .search-wrap{{flex:1;min-width:240px;position:relative}}
  .search-wrap input{{width:100%;background:var(--surface);border:1px solid var(--border);
    border-radius:var(--radius-sm);padding:12px 16px 12px 44px;font-size:14px;color:var(--text);
    outline:none;transition:border-color .2s;font-family:inherit}}
  .search-wrap input:focus{{border-color:var(--accent)}}
  .search-wrap input::placeholder{{color:var(--muted)}}
  .search-wrap .ico{{position:absolute;left:14px;top:50%;transform:translateY(-50%);
    color:var(--muted);font-size:16px}}
  .btn{{padding:11px 20px;border-radius:var(--radius-sm);border:none;cursor:pointer;
    font-size:13px;font-weight:600;font-family:inherit;transition:all .2s;white-space:nowrap}}
  .btn-primary{{background:linear-gradient(135deg,var(--accent),var(--accent2));color:#fff}}
  .btn-primary:hover{{opacity:.9;transform:translateY(-1px)}}
  .btn-excel{{background:rgba(16,185,129,.15);color:var(--green);border:1px solid rgba(16,185,129,.3)}}
  .btn-excel:hover{{background:rgba(16,185,129,.25)}}
  .btn-clear{{background:var(--surface2);color:var(--muted);border:1px solid var(--border)}}
  .btn-clear:hover{{color:var(--text)}}

  /* Result info */
  .result-info{{font-size:13px;color:var(--muted);margin-bottom:12px;display:flex;
    align-items:center;gap:8px}}
  .result-info strong{{color:var(--text)}}

  /* Table */
  .table-wrap{{overflow-x:auto;border-radius:var(--radius);border:1px solid var(--border);
    background:var(--surface)}}
  table{{width:100%;border-collapse:collapse;font-size:13px}}
  thead tr{{background:var(--surface2)}}
  th{{padding:11px 14px;text-align:left;font-weight:600;color:var(--muted);
    font-size:11px;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;
    border-bottom:1px solid var(--border);position:sticky;top:0;background:var(--surface2)}}
  td{{padding:10px 14px;border-bottom:1px solid rgba(30,45,69,.6);vertical-align:middle;
    white-space:nowrap;max-width:220px;overflow:hidden;text-overflow:ellipsis}}
  tr:last-child td{{border-bottom:none}}
  tr:hover td{{background:rgba(255,255,255,.025)}}

  /* Status badge */
  .badge{{display:inline-block;padding:2px 8px;border-radius:20px;font-size:11px;font-weight:600}}
  .badge-transit{{background:rgba(14,165,233,.15);color:#38bdf8}}
  .badge-delivery{{background:rgba(59,130,246,.15);color:#60a5fa}}
  .badge-pickup{{background:rgba(168,85,247,.15);color:#c084fc}}
  .badge-done{{background:rgba(16,185,129,.15);color:#34d399}}
  .badge-issue{{background:rgba(239,68,68,.15);color:#f87171}}
  .badge-return{{background:rgba(245,158,11,.15);color:#fbbf24}}
  .badge-default{{background:rgba(100,116,139,.15);color:var(--muted)}}

  /* Age indicator */
  .age-ok{{color:var(--green)}}
  .age-warn{{color:var(--amber)}}
  .age-danger{{color:var(--red);font-weight:600}}

  /* Empty state */
  .empty{{padding:80px 20px;text-align:center;color:var(--muted)}}
  .empty .ico{{font-size:48px;margin-bottom:16px}}
  .empty p{{font-size:15px}}

  /* Loading overlay */
  #loading{{display:none;position:fixed;inset:0;background:rgba(10,15,30,.7);
    z-index:200;align-items:center;justify-content:center;font-size:16px}}
  #loading.show{{display:flex}}
  .spinner{{width:40px;height:40px;border:3px solid var(--border);
    border-top-color:var(--accent);border-radius:50%;animation:spin .8s linear infinite;margin-right:12px}}
  @keyframes spin{{to{{transform:rotate(360deg)}}}}

  /* Pagination */
  .pager{{display:flex;gap:8px;align-items:center;margin-top:16px;flex-wrap:wrap}}
  .pager button{{background:var(--surface);border:1px solid var(--border);
    color:var(--text);padding:6px 12px;border-radius:6px;cursor:pointer;font-size:12px}}
  .pager button:hover{{border-color:var(--accent)}}
  .pager button.active{{background:var(--accent);border-color:var(--accent);color:#fff}}
  .pager-info{{font-size:12px;color:var(--muted);margin-left:8px}}

  @media(max-width:768px){{
    .container{{padding:16px}}
    .stats-bar{{grid-template-columns:repeat(2,1fr)}}
    .header{{padding:14px 16px}}
  }}
</style>
</head>
<body>

<div id="loading"><div class="spinner"></div> Searching…</div>

<header class="header">
  <div>🚚</div>
  <div>
    <h1>Order Search Portal</h1>
    <div class="sub">14-Day Bill Tracker · 5-min live cache</div>
  </div>
  <div class="cache-badge {cache_class}" id="cacheBadge">
    {cache_label}
  </div>
</header>

<div class="container">

  <!-- Stats bar -->
  <div class="stats-bar">
    <div class="stat-card stat-total {a_all}" onclick="setCategory('all')">
      <div class="val">{cnt_all:,}</div>
      <div class="lbl">📦 Active</div>
    </div>
    <div class="stat-card stat-delayed {a_po}" onclick="setCategory('po_only')">
      <div class="val">{cnt_po:,}</div>
      <div class="lbl">📍 PO Only</div>
    </div>
    <div class="stat-card stat-missing {a_delayed}" onclick="setCategory('delayed')">
      <div class="val">{cnt_delayed:,}</div>
      <div class="lbl">⏰ Delayed &gt;1D</div>
    </div>
    <div class="stat-card stat-issue {a_issue}" onclick="setCategory('issue')">
      <div class="val">{cnt_issue:,}</div>
      <div class="lbl">⚠️ Issues</div>
    </div>
    <div class="stat-card stat-done {a_done}" onclick="setCategory('done')">
      <div class="val">{cnt_done:,}</div>
      <div class="lbl">✅ Done</div>
    </div>
    <div class="stat-card {a_cancel}" onclick="setCategory('cancel_return')">
      <div class="val" style="color:var(--red)">{cnt_cancel:,}</div>
      <div class="lbl">❌ Cancel/Return</div>
    </div>
    <div class="stat-card {a_allbills}" onclick="setCategory('all_incl_done')">
      <div class="val" style="color:var(--muted)">{cnt_allbills:,}</div>
      <div class="lbl">📊 All Bills</div>
    </div>
  </div>

  <!-- Stage filters -->
  <div class="search-row" style="gap:8px;margin-bottom:12px">
    <span style="font-size:12px;color:var(--muted);font-weight:600">Stage:</span>
    <button class="btn {f_pickup}" onclick="setCategory('pickup')" style="padding:6px 12px;font-size:12px">📦 Pickup</button>
    <button class="btn {f_delivery}" onclick="setCategory('delivery')" style="padding:6px 12px;font-size:12px">🚚 Under Delivery</button>
    <button class="btn {f_transit}" onclick="setCategory('transit')" style="padding:6px 12px;font-size:12px">🔄 Transit</button>
    <button class="btn {f_branch}" onclick="setCategory('branch')" style="padding:6px 12px;font-size:12px">🏢 At Branch</button>
  </div>

  <!-- Search bar -->
  <form method="get" action="/" onsubmit="showLoading()">
    <input type="hidden" name="cat" id="catInput" value="{cat}">
    <div class="search-row">
      <div class="search-wrap">
        <span class="ico">🔍</span>
        <input type="text" name="q" id="searchInput" value="{q}"
          placeholder="Search by order ID, phone, sender, receiver, note…"
          autocomplete="off">
      </div>
      <button type="submit" class="btn btn-primary">Search</button>
      <button type="button" class="btn btn-clear" onclick="clearSearch()">Clear</button>
      <button type="button" class="btn btn-excel" onclick="downloadExcel()">⬇ Excel</button>
    </div>
  </form>

  <!-- Result info -->
  <div class="result-info">
    {result_info}
  </div>

  <!-- Table -->
  {table_html}

  <!-- Pagination -->
  <div class="pager">
    {pager_html}
  </div>

</div>

<script>
var currentCat = "{cat}";
var currentQ = "{q}";
var currentPage = {page};

function setCategory(cat) {{
  currentCat = cat;
  document.getElementById('catInput').value = cat;
  showLoading();
  window.location = '/?cat=' + cat + (currentQ ? '&q=' + encodeURIComponent(currentQ) : '');
}}

function showLoading() {{
  document.getElementById('loading').classList.add('show');
}}

function clearSearch() {{
  document.getElementById('searchInput').value = '';
  document.getElementById('catInput').value = currentCat;
  window.location = '/?cat=' + currentCat;
}}

function downloadExcel() {{
  showLoading();
  var url = '/export?cat=' + currentCat + (currentQ ? '&q=' + encodeURIComponent(currentQ) : '');
  fetch(url).then(r => r.blob()).then(blob => {{
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'orders_export.xlsx';
    a.click();
    document.getElementById('loading').classList.remove('show');
  }});
}}

// Hide loading on page load (in case back navigation)
window.addEventListener('pageshow', function() {{
  document.getElementById('loading').classList.remove('show');
}});

// Refresh cache badge every 30s
setInterval(function() {{
  fetch('/cache_status').then(r=>r.json()).then(d=>{{
    var badge = document.getElementById('cacheBadge');
    badge.textContent = d.label;
    badge.className = 'cache-badge ' + d.cls;
  }});
}}, 30000);
</script>
</body>
</html>"""

PAGE_SIZE = 200


def _badge_for(sc):
    sc = str(sc or "")
    if sc in ("201", "410", "520"):
        return "badge-done"
    if sc in ("420", "460", "472", "480", "500"):
        return "badge-issue"
    if sc in ("460", "470", "471", "472", "480", "500", "510", "511", "512"):
        return "badge-return"
    if sc in ("401", "402", "420", "430"):
        return "badge-delivery"
    if sc in ("110", "120", "200"):
        return "badge-pickup"
    if sc in ("210", "230", "300", "302", "306", "309", "310", "311"):
        return "badge-transit"
    return "badge-default"


def _build_table(df, page=1):
    if df.empty:
        return '<div class="empty"><div class="ico">🔍</div><p>No orders found matching your search.</p></div>', ""

    total = len(df)
    total_pages = max(1, (total + PAGE_SIZE - 1) // PAGE_SIZE)
    page = max(1, min(page, total_pages))
    start = (page - 1) * PAGE_SIZE
    end   = min(start + PAGE_SIZE, total)
    chunk = df.iloc[start:end]

    # Columns to display
    display_cols = ["ORDER ID", "CREATED DATE", "STATUS_LABEL", "STATUS_CODE",
                    "SENDER", "RECEIVER",
                    "RECEIVE POST OFFICE", "DELIVERY POST OFFICE", "CURRENT POST OFFICE",
                    "CURRENT TIME", "_age_days"]
    available = [c for c in display_cols if c in chunk.columns]

    rows_html = []
    for _, row in chunk.iterrows():
        age = row.get("_age_days", 0) or 0
        age_cls = "age-ok" if age <= 1 else ("age-warn" if age <= 7 else "age-danger")
        sc = str(row.get("STATUS_CODE", ""))
        label = str(row.get("STATUS_LABEL", sc))
        badge_cls = _badge_for(sc)

        tds = []
        for col in available:
            val = row.get(col, "")
            if col == "STATUS_LABEL":
                tds.append(f'<td><span class="badge {badge_cls}">{val}</span></td>')
            elif col == "_age_days":
                days = int(float(age))
                tds.append(f'<td class="{age_cls}">{days}d</td>')
            elif col == "STATUS_CODE":
                continue   # merged into STATUS_LABEL
            else:
                safe = str(val) if val is not None and str(val) != "nan" else ""
                tds.append(f'<td title="{safe}">{safe[:60]}</td>')
        rows_html.append(f"<tr>{''.join(tds)}</tr>")

    header_labels = {
        "ORDER ID": "Order ID", "CREATED DATE": "Created",
        "STATUS_LABEL": "Status", "STATUS_CODE": None,
        "SENDER": "Sender", "RECEIVER": "Receiver",
        "RECEIVE POST OFFICE": "Origin PO", "DELIVERY POST OFFICE": "Dest PO",
        "CURRENT POST OFFICE": "Current PO", "CURRENT TIME": "Last Update",
        "_age_days": "Age"
    }
    ths = "".join(
        f"<th>{header_labels.get(c, c)}</th>"
        for c in available if header_labels.get(c) is not None
    )

    table = f"""<div class="table-wrap">
<table><thead><tr>{ths}</tr></thead>
<tbody>{"".join(rows_html)}</tbody>
</table></div>"""

    # Pager
    pager = []
    if total_pages > 1:
        for p in range(1, total_pages + 1):
            cls = "active" if p == page else ""
            pager.append(f'<button class="{cls}" onclick="window.location=\'/?q=\'+(document.getElementById(\'searchInput\').value||\'\')+\'&cat={{}}&page={p}\'">{ p }</button>'.format())
    pager.append(f'<span class="pager-info">Showing {start+1}–{end} of {total:,}</span>')
    return table, " ".join(pager)


def _get_counts():
    df, mtime = _get_df()
    done_codes = {"201", "410", "520"}
    cancel_return_codes = {"201", "500", "510", "511", "512", "520", "540"}
    active = df[~df["STATUS_CODE"].isin(done_codes)]
    return {
        "all":     len(active),
        "po":      0,  # calculated per search
        "delayed": int((active["_age_days"] > 1).sum()),
        "issue":   int(active["STATUS_CODE"].isin({"420", "460", "472", "480", "500"}).sum()),
        "done":    int(df["STATUS_CODE"].isin(done_codes).sum()),
        "cancel":  int(df["STATUS_CODE"].isin(cancel_return_codes).sum()),
        "allbills": len(df),
        "mtime":   mtime,
    }


def _get_po_count(query):
    """Count pending bills at a specific PO (CURRENT POST OFFICE matches query)."""
    if not query:
        return 0
    df, _ = _get_df()
    done_codes = {"201", "410", "520"}
    active = df[~df["STATUS_CODE"].isin(done_codes)]
    if "CURRENT POST OFFICE" in active.columns:
        match = active[active["CURRENT POST OFFICE"].astype(str).str.contains(query, case=False, na=False)]
        return len(match)
    return 0


def _cache_label(mtime):
    age = int(time.time() - mtime)
    if age < 60:
        return f"🟢 Fresh ({age}s ago)", "fresh"
    if age < CACHE_TTL:
        return f"🟡 {age//60}m {age%60}s ago", "fresh"
    return f"🔴 Stale ({age//60}m ago)", "stale"


# ── HTTP Handler ──────────────────────────────────────────────────────────────
class Handler(BaseHTTPRequestHandler):

    def log_message(self, fmt, *args):
        print(f"[HTTP] {self.address_string()} — {fmt % args}")

    def _send(self, data: bytes, ct="text/html; charset=utf-8", status=200):
        self.send_response(status)
        self.send_header("Content-Type", ct)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        parsed = urlparse(self.path)
        qs     = parse_qs(parsed.query)
        q      = unquote(qs.get("q", [""])[0]).strip()
        cat    = qs.get("cat", ["all"])[0]
        page   = int(qs.get("page", ["1"])[0])

        if parsed.path == "/export":
            df = do_search(q, cat)
            xlsx = make_excel(df)
            stamp = datetime.now().strftime("%d%m%Y_%H%M")
            filename = f"orders_{cat}_{stamp}.xlsx"
            self.send_response(200)
            self.send_header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            self.send_header("Content-Disposition", f'attachment; filename="{filename}"')
            self.send_header("Content-Length", str(len(xlsx)))
            self.end_headers()
            self.wfile.write(xlsx)
            return

        if parsed.path == "/cache_status":
            _, mtime = _get_df()
            label, cls = _cache_label(mtime)
            resp = json.dumps({"label": label, "cls": cls}).encode()
            self._send(resp, "application/json")
            return

        if parsed.path != "/":
            self._send(b"Not found", status=404)
            return

        # Main page
        df = do_search(q, cat)
        counts  = _get_counts()
        counts["po"] = _get_po_count(q)
        _, mtime = _get_df()
        cl, cc  = _cache_label(mtime)

        table_html, pager_html = _build_table(df, page)
        total_found = len(df)

        if q or cat != "all":
            cat_map = {"all": "All Active", "delayed": "Delayed >1 day",
                       "issue": "Issue Status", "done": "Completed",
                       "pickup": "Pickup", "delivery": "Under Delivery",
                       "transit": "Transit", "branch": "At Branch",
                       "po_only": "PO Only", "cancel_return": "Cancel/Return",
                       "all_incl_done": "All Bills"}
            result_info = (
                f'Found <strong>{total_found:,}</strong> orders'
                + (f' matching "<strong>{q}</strong>"' if q else "")
                + f' in category <strong>{cat_map.get(cat, cat)}</strong>'
            )
        else:
            result_info = f'Showing <strong>{total_found:,}</strong> most recent active orders'

        def ac(c): return "active" if cat == c else ""
        def fc(c): return "btn-primary" if cat == c else "btn-clear"

        html = HTML.format(
            q=q, cat=cat, page=page,
            cache_label=cl, cache_class=cc,
            cnt_all=counts["all"], cnt_po=counts["po"],
            cnt_delayed=counts["delayed"],
            cnt_issue=counts["issue"],
            cnt_done=counts["done"],
            cnt_cancel=counts["cancel"],
            cnt_allbills=counts["allbills"],
            a_all=ac("all"), a_po=ac("po_only"), a_delayed=ac("delayed"),
            a_issue=ac("issue"), a_done=ac("done"),
            a_cancel=ac("cancel_return"), a_allbills=ac("all_incl_done"),
            f_pickup=fc("pickup"), f_delivery=fc("delivery"),
            f_transit=fc("transit"), f_branch=fc("branch"),
            result_info=result_info,
            table_html=table_html, pager_html=pager_html,
        )
        self._send(html.encode("utf-8"))


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("="*55)
    print("  [ORDER SEARCH PORTAL]")
    print(f"  http://localhost:{PORT}")
    print("="*55)
    print("[INIT] Loading initial data...")
    _initial_load()
    # Background refresh thread
    t = threading.Thread(target=_refresh_loop, daemon=True)
    t.start()
    print(f"[READY] Server listening on port {PORT}")
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
