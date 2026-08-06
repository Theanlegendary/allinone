"""Generate compare Excel with formulas - ready for manual 5PM input."""
import os, sys
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')
import pandas as pd
from compare_manager import load_snapshots, save_snapshots, build_comparison_summary, build_compare_excel

V4_PATH = r'compare\Urgent_Clearance_Compare_20260803_v4.xlsx'
DATE_STR = "03/08/2026"

# Load v4 for 9AM and 2PM
df = pd.read_excel(V4_PATH, header=1)
df.columns = [str(c).strip() for c in df.columns]
df = df[df['POST OFFICE HANDLE'].notna()].copy()
df = df[df['POST OFFICE HANDLE'].astype(str).str.strip() != 'TOTAL'].copy()
df = df[df['POST OFFICE HANDLE'].astype(str).str.strip() != ''].copy()

snapshots = load_snapshots()
if DATE_STR not in snapshots:
    snapshots[DATE_STR] = {}

# Build 9AM and 2PM from v4
handles_9am = {}
handles_2pm = {}
handles_5pm = {}  # Empty - to be filled manually

for _, row in df.iterrows():
    branch = str(row.get('POST OFFICE HANDLE', '')).strip().upper()
    if not branch or branch == 'NAN':
        continue
    
    u9 = int(row.get('URGENT (9AM)', 0) or 0)
    u2 = int(row.get('URGENT (2PM)', 0) or 0)
    
    handles_9am[branch] = {"urgent": u9, "pickup": 0, "delivery": 0, "transit": 0, "branch": u9}
    handles_2pm[branch] = {"urgent": u2, "pickup": 0, "delivery": 0, "transit": 0, "branch": u2}
    handles_5pm[branch] = {"urgent": 0, "pickup": 0, "delivery": 0, "transit": 0, "branch": 0}  # Placeholder

snapshots[DATE_STR]['9AM'] = {
    "captured_at": f"{DATE_STR} 09:00:00 (from v4)",
    "handles": handles_9am
}
snapshots[DATE_STR]['2PM'] = {
    "captured_at": f"{DATE_STR} 14:00:00 (from v4)",
    "handles": handles_2pm
}
snapshots[DATE_STR]['5PM'] = {
    "captured_at": f"{DATE_STR} 17:00:00 (EDIT THIS IN EXCEL)",
    "handles": handles_5pm
}

save_snapshots(snapshots)

# Generate Excel
rows, totals, _ = build_comparison_summary(DATE_STR)
out_path = os.path.join('compare', 'Urgent_Clearance_Compare_20260803_EDITABLE.xlsx')
build_compare_excel(DATE_STR, rows, totals, out_filepath=out_path)

print(f"✓ Generated: {out_path}")
print(f"\n📊 Current state:")
print(f"  9AM: {sum(v['urgent'] for v in handles_9am.values())} urgent (from v4)")
print(f"  2PM: {sum(v['urgent'] for v in handles_2pm.values())} urgent (from v4)")
print(f"  5PM: 0 urgent (PLACEHOLDER - edit in Excel)")
print(f"\n📝 Next steps:")
print(f"  1. Open: {out_path}")
print(f"  2. Edit column E (URGENT 5PM) with your actual values from the report")
print(f"  3. CHANGE and CLEAR% will auto-calculate!")
print(f"\n💡 All CHANGE and CLEAR% columns use FORMULAS")
print(f"   - You can customize any 9AM/2PM/5PM value")
print(f"   - Results update automatically!")
