"""
Restore 9AM and 2PM snapshots from Urgent_Clearance_Compare_20260803_v4.xlsx
into compare_snapshots.json, then regenerate the full 3-shift compare Excel.
"""
import os, sys, json
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')
os.chdir(r'c:\Users\DELL\Desktop\daily_push')

import pandas as pd
from compare_manager import (
    load_snapshots, save_snapshots, build_comparison_summary,
    build_compare_excel
)

V4_PATH = r'c:\Users\DELL\Desktop\daily_push\compare\Urgent_Clearance_Compare_20260803_v4.xlsx'
DATE_STR = "03/08/2026"

# ── 1. Read v4 Excel ──────────────────────────────────────────────────────────
df = pd.read_excel(V4_PATH, header=1)  # row 0 = title, row 1 = headers
df.columns = [str(c).strip() for c in df.columns]

# Drop total row (last row)
df = df[df['POST OFFICE HANDLE'].notna()].copy()
df = df[df['POST OFFICE HANDLE'].astype(str).str.strip() != 'TOTAL'].copy()
df = df[df['POST OFFICE HANDLE'].astype(str).str.strip() != ''].copy()

print(f"Loaded {len(df)} branches from v4")

# ── 2. Load existing snapshots ─────────────────────────────────────────────────
snapshots = load_snapshots()
if DATE_STR not in snapshots:
    snapshots[DATE_STR] = {}

# ── 3. Build 9AM and 2PM handle maps from v4 data ────────────────────────────
handles_9am = {}
handles_2pm = {}

for _, row in df.iterrows():
    branch = str(row.get('POST OFFICE HANDLE', '')).strip().upper()
    if not branch or branch == 'NAN':
        continue

    u9 = int(row.get('URGENT (9AM)', 0) or 0)
    u2 = int(row.get('URGENT (2PM)', 0) or 0)

    handles_9am[branch] = {
        "urgent": u9,
        "pickup": 0,
        "delivery": 0,
        "transit": 0,
        "branch": u9
    }
    handles_2pm[branch] = {
        "urgent": u2,
        "pickup": 0,
        "delivery": 0,
        "transit": 0,
        "branch": u2
    }

total_9am = sum(v['urgent'] for v in handles_9am.values())
total_2pm = sum(v['urgent'] for v in handles_2pm.values())
print(f"9AM total urgent (from v4): {total_9am}")
print(f"2PM total urgent (from v4): {total_2pm}")

# ── 4. Restore into snapshots (don't overwrite existing 5PM) ─────────────────
snapshots[DATE_STR]['9AM'] = {
    "captured_at": f"{DATE_STR} 09:00:00 (restored from v4)",
    "handles": handles_9am
}
snapshots[DATE_STR]['2PM'] = {
    "captured_at": f"{DATE_STR} 14:00:00 (restored from v4)",
    "handles": handles_2pm
}

save_snapshots(snapshots)
print("Snapshots saved with 9AM and 2PM restored.")

# ── 5. Regenerate compare Excel with all 3 shifts ─────────────────────────────
rows, totals, _ = build_comparison_summary(DATE_STR)

out_path = os.path.join(
    r'c:\Users\DELL\Desktop\daily_push\compare',
    'Urgent_Clearance_Compare_20260803_v5.xlsx'
)
build_compare_excel(DATE_STR, rows, totals, out_filepath=out_path)
print(f"\nGenerated: {out_path}")

# ── 6. Print summary ──────────────────────────────────────────────────────────
from compare_manager import load_snapshots as _ls
s = _ls()
day = s.get(DATE_STR, {})
print(f"\n=== Snapshot summary for {DATE_STR} ===")
for shift in ['9AM', '2PM', '5PM']:
    if shift in day:
        h = day[shift].get('handles', {})
        total = sum(v.get('urgent', 0) for v in h.values())
        print(f"  {shift}: {len(h)} handles, total urgent={total}")
    else:
        print(f"  {shift}: not available")

print(f"\nTotal row: 9AM={totals['URGENT_9AM']}, 2PM={totals['URGENT_2PM']}, 5PM={totals['URGENT_5PM']}")
print(f"Change: {totals['URGENT_CHANGE']}, Clear%: {totals['CLEARANCE_PCT']:.1f}%")
