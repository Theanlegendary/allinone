"""
Fix today's bad snapshots:
1. Clear the bad 9AM and 2PM data (wrong all-section totals)
2. Record correct 5PM snapshot using Branch count only
"""
import json
import os

# Step 1: Clear today's bad snapshots
snapshot_file = "compare/compare_snapshots.json"
with open(snapshot_file) as f:
    data = json.load(f)

today_key = "03/08/2026"
print(f"Before: Shifts for {today_key}: {list(data.get(today_key, {}).keys())}")

# Clear only 9AM and 2PM (they were taken at 4:25 PM with wrong data)
# Keep 5PM so we can re-record it correctly
if today_key in data:
    data[today_key].pop("9AM", None)
    data[today_key].pop("2PM", None)
    data[today_key].pop("5PM", None)  # Also clear 5PM (it had wrong data too)

with open(snapshot_file, "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"After clear: Shifts for {today_key}: {list(data.get(today_key, {}).keys())}")

# Step 2: Record correct 5PM snapshot using updated compare_manager
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib
import compare_manager
importlib.reload(compare_manager)

print("\nRecording correct 5PM snapshot from cached Excel...")
result = compare_manager.record_total_snapshot(today_key, "cache/latest_detail.xlsx")

# Verify
with open(snapshot_file) as f:
    new_data = json.load(f)

today_new = new_data.get(today_key, {})
print(f"\nNew shifts: {list(today_new.keys())}")
for shift, sdata in today_new.items():
    captured = sdata.get("captured_at", "?")
    handles = sdata.get("handles", {})
    print(f"\n  {shift} (captured: {captured})")
    for key in ["PNPP009", "KANP001", "BANP001", "SIHP001", "PNPP004", "SIEP001"]:
        if key in handles:
            print(f"    {key}: urgent(branch)={handles[key].get('urgent', 0)}")

print("\n--- v4 reference (9AM values) ---")
print("PNPP009=156, KANP001=46, BANP001=68, SIHP001=25, PNPP004=89, SIEP001=55")
print("\nNote: 5PM values should be lower than 9AM (after deliveries)")
