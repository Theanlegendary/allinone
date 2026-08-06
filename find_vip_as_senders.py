"""Find VIP phone numbers by searching them as SENDERS in pickup orders."""
import sys, os, json, tempfile
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')
os.chdir(r'c:\Users\DELL\Desktop\daily_push')

import pandas as pd
import downloader

# Load config
with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

vip_list = """TPG SHOP
Juuhouy
Prak Khley
Khem ma
Srey Roth
Chan Lida
ធី ធា
J DM
Hotpot house
Babe clean
Soap Laor
Jusmine wholesale
ស៊ីណា
Phann phumara
Mi Kh
Kem sokunthea
សត្តនា សំ
សាន់ លីណា
Ou Leakena
Por sokha
Sok ounoly
Hong Dany
KuySocheata
Pisey Shop
Ratana
Leakhena
Pho Pich
Meach Kunthea
lengkhimsan
je sros
Dun Srey Mom
Chheng hout printer
PU IT
ឡាងឌី លក់អង្ករ
យឹម សុខវណ្ណៈ លក់អង្ករ
Va Siekhy លក់អង្ករ
CPT
MLH សិប្បកម្មណាំវ៉ា
Vyda 316
Heng Soseksa
Chheat Lies
Dalin
SENGHENG51
Neat Shop
គីម សារុន
Hory Bunny
Touch Rada
Ah Vy (លក់ត្រីងៀត)
ម៉ីហោស ត្រីធម្មជាតិ
ចែម៉ី លក់ត្រីស្រស់ធម្មជាតិ
Sina Heng
ជាងសាន (លក់ធុងបាស)
Savanna
Tola
Chan Mony
PEANH SETHA
Yen vannay
Kim Heang
Samdy
Sophat
Nat Rothna
Vichra
Bouy Bouy Store
- Bouy Bouy Store
ថន​ ថារី
NUN VUTHA
Sima
Leakana
Rady
Rithy
Da Ne
Da Ry
Phuoysang Stort
Khome Somphors
Hoeun Rotha
Srey Yi
ពេញនិយម
The Venuz Gold
Chea Pich
Thai sokthida
Ngan Farita
Thy sotheany (N.Y Clothes & Jewelry)"""

vips = [v.strip() for v in vip_list.split('\n') if v.strip()]

print("=" * 100)
print("SEARCHING FOR VIP PHONE NUMBERS")
print("(Checking both as RECEIVERS and SENDERS)")
print("=" * 100)

# Use cached data
df = pd.read_excel('cache/latest_detail.xlsx')
print(f"✓ Loaded {len(df)} orders")
print(f"Columns: {', '.join([c for c in df.columns if 'name' in c.lower() or 'phone' in c.lower() or 'receiver' in c.lower()][:10])}")

print("\n" + "=" * 100)
print(f"{'Customer Name':<45} | {'Phone':<15} | {'Found As':<12} | {'Order ID':<15}")
print("-" * 100)

results = []
found_with_phone = 0

for vip in vips:
    phone = 'NOT FOUND'
    found_as = ''
    order_id = ''
    zone = ''
    branch = ''
    full_name = ''
    
    # Search in RECEIVER column (format: "PHONE - NAME")
    matches = df[df['RECEIVER'].astype(str).str.contains(vip, case=False, na=False, regex=False)]
    
    if not matches.empty:
        first_match = matches.iloc[0]
        receiver_field = str(first_match.get('RECEIVER', ''))
        
        # Extract phone from "PHONE - NAME" format
        if ' - ' in receiver_field:
            phone = receiver_field.split(' - ')[0].strip()
            full_name = receiver_field.split(' - ', 1)[1].strip()
        else:
            phone = 'N/A'
            full_name = receiver_field
        
        found_as = 'RECEIVER'
        order_id = str(first_match.get('ORDER ID', 'N/A'))
        zone = str(first_match.get('DELIVERY PROVINCE', first_match.get('CURRENT PROVINCE', '')))
        branch = str(first_match.get('CURRENT POST OFFICE', ''))
    
    # If not found in RECEIVER, try SENDER
    if phone == 'NOT FOUND':
        matches = df[df['SENDER'].astype(str).str.contains(vip, case=False, na=False, regex=False)]
        
        if not matches.empty:
            first_match = matches.iloc[0]
            sender_field = str(first_match.get('SENDER', ''))
            
            # Extract phone from "PHONE - NAME" format
            if ' - ' in sender_field:
                phone = sender_field.split(' - ')[0].strip()
                full_name = sender_field.split(' - ', 1)[1].strip()
            else:
                phone = 'N/A'
                full_name = sender_field
            
            found_as = 'SENDER'
            order_id = str(first_match.get('ORDER ID', 'N/A'))
            zone = str(first_match.get('RECEIVE PROVINCE', first_match.get('CURRENT PROVINCE', '')))
            branch = str(first_match.get('CURRENT POST OFFICE', ''))
    
    if phone != 'NOT FOUND':
        found_with_phone += 1
        print(f"{vip:<45} | {phone:<15} | {found_as:<12} | {order_id:<15}")
    else:
        print(f"{vip:<45} | {'NOT FOUND':<15} | {'':<12} | {'':<15}")
    
    results.append({
        'VIP Name': vip,
        'Phone Number': phone,
        'Full Name in System': full_name,
        'Found As': found_as,
        'Zone/Province': zone,
        'Branch': branch,
        'Sample Order ID': order_id
    })

print("=" * 100)
print(f"\n📊 SUMMARY")
print(f"  Total VIPs: {len(vips)}")
print(f"  ✅ Found with phone: {found_with_phone}")
print(f"  ❌ Not found: {len(vips) - found_with_phone}")

# Save
output_df = pd.DataFrame(results)
output_file = 'VIP_Phone_Numbers_FINAL.xlsx'
output_df.to_excel(output_file, index=False)

print(f"\n✅ RESULTS SAVED TO: {output_file}")
print("=" * 100)
