import json
import os
import sys
from datetime import datetime

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import generate_report

with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

output_dir = 'scratch/fresh_run_fast'
os.makedirs(output_dir, exist_ok=True)
fresh_src = 'scratch/fresh_run_test/fresh_export.xlsx'

print("Calculating live 5-zone report...")
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

print("==================================================================================")
print(f"LIVE METFONE DATA - 5 ZONES AUDIT ({datetime.now().strftime('%d/%m/%Y %H:%M')})")
print("==================================================================================")
print(f"ALL Report: Delivery: {all_overall.get('Delivery',0)} | Not Assign: {all_overall.get('Branch',0)} | Pickup: {all_overall.get('Pickup',0)} | Send Mega: {all_overall.get('Transit',0)} | Grand Total: {all_grand}")
print("----------------------------------------------------------------------------------")

zone_accum = {'Pickup': 0, 'Delivery': 0, 'Transit': 0, 'Branch': 0}
urgent_counts = res.get('urgent_counts', {})
day_date_counts = res.get('day_date_counts', {})

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
    
    # Audit each handle in this zone
    issues = []
    for hr in z_hr:
        h = hr['handle']
        h_tot = sum(hr['handle_counts'].values())
        h_u1 = urgent_counts.get(h, {}).get('1day', 0)
        h_u3 = urgent_counts.get(h, {}).get('3days', 0)
        h_dates = sum(day_date_counts.get(h, {}).values())
        if h_u1 > h_tot:
            issues.append(f"{h}: >1Day ({h_u1}) > Total ({h_tot})")
        if h_u3 > h_u1:
            issues.append(f"{h}: >3Days ({h_u3}) > >1Day ({h_u1})")
        if h_dates > 0 and h_dates != h_tot:
            issues.append(f"{h}: Dates ({h_dates}) != Total ({h_tot})")

    audit_status = "100% CLEAN (0 Errors)" if not issues else f"ERRORS: {issues}"
    print(f"{zk.upper():<7} | Deliv: {z_counts['Delivery']:<4} | NotAssign: {z_counts['Branch']:<4} | Pickup: {z_counts['Pickup']:<2} | Mega: {z_counts['Transit']:<4} | Total: {z_grand:<4} | >1Day: {z_u1d:<4} | >3Days: {z_u3d:<4} | {audit_status}")

print("----------------------------------------------------------------------------------")
print(f"5-ZONE TOTAL : Deliv: {zone_accum['Delivery']:<4} | NotAssign: {zone_accum['Branch']:<4} | Pickup: {zone_accum['Pickup']:<2} | Mega: {zone_accum['Transit']:<4} | Total: {sum(zone_accum.values()):<4}")
print(f"ALL REPORT   : Deliv: {all_overall.get('Delivery',0):<4} | NotAssign: {all_overall.get('Branch',0):<4} | Pickup: {all_overall.get('Pickup',0):<2} | Mega: {all_overall.get('Transit',0):<4} | Total: {all_grand:<4}")
print("==================================================================================")
