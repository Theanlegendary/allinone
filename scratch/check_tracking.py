import requests
import json
import os

config_path = r'c:\Users\DELL\Desktop\daily_push\config.json'
with open(config_path, encoding='utf-8') as f:
    cfg = json.load(f)

token = cfg.get('api', {}).get('bearer_token', '')
headers = {'Authorization': f'Bearer {token}'}

url_tr = 'https://gw-express.metfone.com.kh/tms-tracking/api/v1/order-tracking'
# Let's query order 3103935464
r = requests.get(url_tr, params={'order_id': '3103935464'}, headers=headers, timeout=10)
if r.status_code == 200:
    data = r.json()
    trips = data.get('trackingTrips', [])
    print(f"Total trips: {len(trips)}")
    for idx, t in enumerate(trips):
        print(f"Index {idx}: status={t.get('status')}, time={t.get('updatedAt')}")
else:
    print('Failed to query API:', r.status_code)
