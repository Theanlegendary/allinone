import json
import os
import requests
import pandas as pd

with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

token = cfg["api"]["bearer_token"]
headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/json, text/plain, */*",
    "User-Agent": "Mozilla/5.0"
}

# Test sample order from fresh_export.xlsx
df = pd.read_excel('scratch/fresh_run_test/fresh_export.xlsx')
sample_oids = df['ORDER ID'].dropna().astype(str).str.strip().head(5).tolist()

print(f"Testing API for sample orders: {sample_oids}")
for oid in sample_oids:
    url_track = "https://gw-express.metfone.com.kh/tms-tracking/api/v1/order-tracking"
    r = requests.get(url_track, params={"order_id": oid}, headers=headers, timeout=10)
    print(f"\nOID: {oid}, Status: {r.status_code}")
    if r.status_code == 200:
        data = r.json()
        print("Keys:", list(data.keys()))
        print("Status code/name:", data.get('status'), data.get('statusName'))
        trips = data.get('trackingTrips', [])
        if trips:
            print("Latest Trip:", trips[0].get('status'), trips[0].get('statusName'), trips[0].get('updatedAt'), trips[0].get('desc'))
