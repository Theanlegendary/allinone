import json
import pandas as pd
from datetime import datetime

with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

# Load excel directly
df = pd.read_excel('cache/latest_detail.xlsx')
print(f"Total raw rows in export: {len(df)}")

total_zones = cfg.get('total_zones', {})
all_configured_handles = {}
for zk, hlist in total_zones.items():
    for h in hlist:
        all_configured_handles[h.upper()] = zk.upper()

# Check what handles exist in df
po_col = 'POST OFFICE HANDLE' if 'POST OFFICE HANDLE' in df.columns else 'CURRENT POST OFFICE'
print(f"Using PO column: {po_col}")

# Normalize handles
df['_handle'] = df[po_col].astype(str).str.strip().str.upper()

# Filter out showrooms A and agents S
df['_is_main'] = df['_handle'].apply(lambda h: not (len(h) >= 4 and h[3] in ('A', 'S')))
df_main = df[df['_is_main']].copy()

print(f"Total main post office rows: {len(df_main)}")

# Breakdown by Zone
df_main['_zone'] = df_main['_handle'].map(all_configured_handles).fillna('UNASSIGNED')

zone_summary = df_main.groupby('_zone').size()
print("\n=== RAW ROWS BY ZONE IN EXPORT ===")
print(zone_summary)

unassigned = df_main[df_main['_zone'] == 'UNASSIGNED']
if not unassigned.empty:
    print("\n=== UNASSIGNED HANDLES FOUND IN DATA ===")
    print(unassigned['_handle'].value_counts())
else:
    print("\nAll main post office handles in data are 100% assigned to a Zone!")
