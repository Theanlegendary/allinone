import json
import os
import sys
from datetime import datetime

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import generate_report

with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

output_dir = 'scratch/fresh_run_test'
fresh_src = os.path.join(output_dir, 'fresh_export.xlsx')

print("Processing downloaded fresh live report data...")
res = generate_report.generate_reports_from_data(
    fresh_src,
    'post_office_lookup.csv',
    output_dir,
    return_metadata=True,
    mode='wide'
)

all_hr = res['handle_results']
all_overall = res['overall_counts']
all_grand = sum(all_overall.values())
total_zones = cfg.get('total_zones', {})

print("=======================================================")
print(f"ALL REPORT (Live TMS Data) - {datetime.now().strftime('%d/%m/%Y %H:%M')}")
print("=======================================================")
print(f"Delivery: {all_overall.get('Delivery',0)} | Not Assign: {all_overall.get('Branch',0)} | Pickup: {all_overall.get('Pickup',0)} | Send Mega: {all_overall.get('Transit',0)}")
print(f"Grand Total: {all_grand}")

print("\n=======================================================")
print("5 ZONES BREAKDOWN & INTEGRITY AUDIT")
print("=======================================================")

zone_accum = {'Pickup': 0, 'Delivery': 0, 'Transit': 0, 'Branch': 0}
zone_total_urgent_1d = 0
zone_total_urgent_3d = 0

day_date_counts = res.get('day_date_counts', {})
urgent_counts = res.get('urgent_counts', {})

for zk in sorted(total_zones.keys()):
    z_handles = [h.upper() for h in total_zones[zk]]
    z_hr = [hr for hr in all_hr if hr['handle'] in z_handles]
    
    z_counts = {'Pickup': 0, 'Delivery': 0, 'Transit': 0, 'Branch': 0}
    for hr in z_hr:
        for k in z_counts:
            z_counts[k] += hr['handle_counts'].get(k, 0)
    z_grand = sum(z_counts.values())
    for k in z_counts:
        zone_accum[k] += z_counts[k]
        
    z_u1d = sum(urgent_counts.get(h, {}).get('1day', 0) for h in z_handles)
    z_u3d = sum(urgent_counts.get(h, {}).get('3days', 0) for h in z_handles)
    zone_total_urgent_1d += z_u1d
    zone_total_urgent_3d += z_u3d
    
    # Check math validity for all handles in this zone
    valid_math = True
    for hr in z_hr:
        h = hr['handle']
        h_tot = sum(hr['handle_counts'].values())
        h_u1 = urgent_counts.get(h, {}).get('1day', 0)
        h_u3 = urgent_counts.get(h, {}).get('3days', 0)
        h_dates_sum = sum(day_date_counts.get(h, {}).values())
        if h_u1 > h_tot or h_u3 > h_u1 or (h_dates_sum > 0 and h_dates_sum != h_tot):
            valid_math = False
            print(f"  [WARN] {h}: Total={h_tot}, DatesSum={h_dates_sum}, >1Day={h_u1}, >3Days={h_u3}")

    status_str = "[MATCH 100% OK]" if valid_math else "[DISCREPANCY]"
    print(f"\n* {zk.upper()} Report:")
    print(f"   Delivery: {z_counts['Delivery']} | Not Assign: {z_counts['Branch']} | Pickup: {z_counts['Pickup']} | Send Mega: {z_counts['Transit']}")
    print(f"   Grand Total: {z_grand} | > 1 Day: {z_u1d} | > 3 Days: {z_u3d}  {status_str}")

print("\n=======================================================")
print("FINAL RECONCILIATION")
print("=======================================================")
print(f"Sum of 5 Zones Grand Total : {sum(zone_accum.values())} (Delivery:{zone_accum['Delivery']}, Not Assign:{zone_accum['Branch']}, Pickup:{zone_accum['Pickup']}, Send Mega:{zone_accum['Transit']})")
print(f"ALL Report Grand Total     : {all_grand} (Delivery:{all_overall.get('Delivery',0)}, Not Assign:{all_overall.get('Branch',0)}, Pickup:{all_overall.get('Pickup',0)}, Send Mega:{all_overall.get('Transit',0)})")
diff = all_grand - sum(zone_accum.values())
print(f"Discrepancy (ALL - Zones)  : {diff} {'(PERFECT MATCH - 0 DIFFERENCE)' if diff == 0 else ''}")
print("=======================================================")
