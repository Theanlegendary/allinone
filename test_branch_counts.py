import generate_report
import os

os.makedirs("compare/tmp_test2", exist_ok=True)

print("Running generate_reports_from_data on cached Excel...")
res = generate_report.generate_reports_from_data(
    "cache/latest_detail.xlsx",
    "post_office_lookup.csv",
    "compare/tmp_test2",
    return_metadata=True,
    mode="wide"
)

hrs = res.get("handle_results", [])
print(f"Total handles: {len(hrs)}")
print()

targets = ["PNPP009", "PNPP004", "KANP001", "BANP001", "SIHP001", "SIEP001"]
for h in hrs:
    hnd = h["handle"]
    if hnd in targets:
        hc = h.get("handle_counts", {})
        total = sum(hc.values())
        print(f"{hnd} | Branch={hc.get('Branch',0)} | Delivery={hc.get('Delivery',0)} | Pickup={hc.get('Pickup',0)} | Transit={hc.get('Transit',0)} | TOTAL={total}")

print()
print("v4 reference for comparison:")
print("PNPP009: 9AM=156, 2PM=116 (clear 25.6%)")
print("PNPP004: 9AM=89, 2PM=54 (clear 39.3%)")
print("KANP001: 9AM=46, 2PM=40 (clear 13.0%)")
print("BANP001: 9AM=68, 2PM=60 (clear 11.8%)")
print("SIHP001: 9AM=25, 2PM=18 (clear 28.0%)")
print("SIEP001: 9AM=55, 2PM=42 (clear 23.6%)")
