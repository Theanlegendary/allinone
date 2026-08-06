import json

with open("compare/compare_snapshots.json") as f:
    d = json.load(f)

today = d.get("03/08/2026", {})
print("Shifts stored for today:", list(today.keys()))
for shift, data in today.items():
    captured = data.get("captured_at", "?")
    handles = data.get("handles", {})
    print(f"\n  {shift} (captured: {captured})")
    # Show a few key post offices
    for key in ["PNPP009", "KANP001", "BANP001", "SIHP001"]:
        if key in handles:
            print(f"    {key}: urgent={handles[key].get('urgent', 0)}, branch={handles[key].get('branch', 0)}")
