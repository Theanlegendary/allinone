import os
import json
import tempfile
import pandas as pd
from datetime import datetime

with open("config.json", "r", encoding="utf-8") as f:
    cfg = json.load(f)

import downloader
import compare_manager

tmpdir = tempfile.mkdtemp(prefix="test_compare_")
src = os.path.join(tmpdir, "export_compare.xlsx")
today_str = datetime.now().strftime("%d/%m/%Y")

print("Step 1: Downloading live API data for /compare 3 (Full Day Total)...")
downloader.download_detail(cfg["api"], src, force_refresh=True)

print("Step 2: Processing live data with target_shift='5PM'...")
df_detail = pd.read_excel(src)
df_detail.columns = [str(c).strip().upper() for c in df_detail.columns]

rows, totals, itemized = compare_manager.build_comparison_summary(today_str, df_detail, target_shift="5PM")

out_excel = os.path.join("compare", "Urgent_Clearance_Compare_3_FullDayTotal.xlsx")
compare_manager.build_compare_excel(today_str, rows, totals, itemized, out_excel)

print("\n=== /compare 3 (FULL DAY TOTAL) PIPELINE OUTPUT SUMMARY ===")
print("Total Rows Generated:", len(rows))
for r in rows:
    print(f"  {r['ZONE']} | {r['POST OFFICE HANDLE']} | 9AM: {r['URGENT_9AM']} | 2PM: {r['URGENT_2PM']} | 5PM: {r['URGENT_5PM']} | CHANGE: {r['URGENT_CHANGE']} | CLEAR: {r['CLEARANCE_PCT']:.1f}%")

print(f"\nTOTALS: {totals['ZONE']} | {totals['POST OFFICE HANDLE']} | 9AM: {totals['URGENT_9AM']} | 2PM: {totals['URGENT_2PM']} | 5PM: {totals['URGENT_5PM']} | CHANGE: {totals['URGENT_CHANGE']} | CLEAR: {totals['CLEARANCE_PCT']:.1f}%")
print("Full Day Total Excel Report saved to:", out_excel)
