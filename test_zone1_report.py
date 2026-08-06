"""
Generate Zone 1 report for preview
"""
import json
import os
import tempfile
from datetime import datetime

# Load config
with open('config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

# Import modules
import downloader
import generate_report
import generate_summary

print("🔄 Downloading latest data...")
src = "latest_export.xlsx"
downloader.download_detail(config["api"], src, force_refresh=True)

print("📊 Generating reports...")
tmpdir = tempfile.mkdtemp(prefix="zone1_test_")
result = generate_report.generate_reports_from_data(
    src, "post_office_lookup.csv", tmpdir, return_metadata=True, mode="wide"
)

# Filter for Zone 1 branches
zone1_branches = [
    'KANP001', 'PNPP001', 'PNPP002', 'PNPP003', 'PNPP004', 'PNPP005', 
    'PNPP006', 'PNPP007', 'PNPP008', 'PNPP009', 'PNPP010', 'PNPP011', 
    'PNPP012', 'PNPP013', 'PNPP014', 'PREP001', 'SVAP001'
]

zone_results = [
    hr for hr in result["handle_results"]
    if hr["handle"] in zone1_branches
]

if not zone_results:
    print("❌ No data found for Zone 1")
    exit(1)

# Calculate zone totals
zone_overall = {"Pickup": 0, "Delivery": 0, "Transit": 0, "Branch": 0}
for hr in zone_results:
    for k in zone_overall:
        zone_overall[k] += hr["handle_counts"].get(k, 0)

print(f"\n📋 ZONE1 Totals:")
print(f"  Delivery: {zone_overall['Delivery']}")
print(f"  Not Assign: {zone_overall['Branch']}")
print(f"  Pickup: {zone_overall['Pickup']}")
print(f"  Send Mega: {zone_overall['Transit']}")
print(f"  Grand Total: {sum(zone_overall.values())}")

# Count VIPs
zone_vip_counts = {}
for hr in zone_results:
    h = hr["handle"]
    h_v = 0
    for hf in hr.get("handle_files", []):
        try:
            import pandas as pd
            df_h = pd.read_excel(hf["path"], sheet_name=0)
            if 'VIP' in df_h.columns:
                h_v += (df_h['VIP'] == 'VIP').sum()
        except:
            pass
    zone_vip_counts[h] = h_v

total_vips = sum(zone_vip_counts.values())
print(f"  VIP: {total_vips}")

# Build zone-filtered result for total Excel
zone_result = {**result, "handle_results": zone_results, "overall_counts": zone_overall}
zone_result["type_data"] = {}

import pandas as pd
for rn in ["Pickup", "Delivery", "Transit", "Branch"]:
    df = result.get("type_data", {}).get(rn)
    if df is not None and not df.empty:
        filter_col = "POST OFFICE HANDLE"
        if filter_col in df.columns:
            zone_result["type_data"][rn] = df[df[filter_col].isin(zone1_branches)].copy()
        else:
            zone_result["type_data"][rn] = df.copy()
    else:
        zone_result["type_data"][rn] = pd.DataFrame()

# Generate summary image
print("\n🖼️  Generating summary image...")
img_buf = generate_summary.build_summary_image(
    zone_results,
    zone_overall,
    zone_label="ZONE1",
    vip_counts=zone_vip_counts if any(zone_vip_counts.values()) else None,
)

# Save image
img_path = os.path.join(os.getcwd(), "ZONE1_Summary_Preview.png")
with open(img_path, "wb") as f:
    f.write(img_buf.getvalue())
print(f"✅ Summary image saved: {img_path}")

# Generate Excel
print("\n📄 Generating Excel report...")
stamp = datetime.now().strftime('%d%m%Y_%H%M')
zone_xlsx = os.path.join(os.getcwd(), f"Total_ZONE1_{stamp}.xlsx")
generate_summary.build_total_excel(zone_result, zone_xlsx, lang="en")
print(f"✅ Excel report saved: {zone_xlsx}")

print("\n✅ Done! Check the files:")
print(f"   - {img_path}")
print(f"   - {zone_xlsx}")
