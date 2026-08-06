"""Fetch fresh data and find ALL VIP phone numbers."""
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
print("FETCHING FRESH DATA FROM API...")
print("=" * 100)

# Download fresh data
tmpdir = tempfile.mkdtemp(prefix="vip_search_")
fresh_file = os.path.join(tmpdir, "fresh_data.xlsx")

try:
    downloader.download_detail(cfg["api"], fresh_file, force_refresh=True)
    print(f"✓ Fresh data downloaded to: {fresh_file}")
except Exception as e:
    print(f"❌ Error downloading data: {e}")
    print("Falling back to cached data...")
    fresh_file = 'cache/latest_detail.xlsx'

print("\nLoading data...")
df = pd.read_excel(fresh_file)
print(f"✓ Loaded {len(df)} orders")

print("\n" + "=" * 100)
print("SEARCHING FOR VIP PHONE NUMBERS")
print("=" * 100)
print(f"{'Customer Name':<45} | {'Phone':<15} | {'Zone':<8} | {'Branch':<10} | {'Order ID':<15}")
print("-" * 100)

results = []
found_count = 0
found_with_phone = 0

for vip in vips:
    # Search in RECEIVER column
    matches = df[df['RECEIVER'].astype(str).str.contains(vip, case=False, na=False, regex=False)]
    
    if not matches.empty:
        # Get the most recent order
        first_match = matches.iloc[0]
        
        # Try different phone column names
        phone = 'N/A'
        for col in ['PHONE', 'Phone', 'phone', 'RECEIVER PHONE', 'CONTACT']:
            if col in first_match.index and pd.notna(first_match.get(col)):
                phone = str(first_match.get(col))
                if phone and phone != 'nan' and phone != 'N/A':
                    break
        
        zone = str(first_match.get('ZONE', 'N/A'))
        po_handle = str(first_match.get('POST OFFICE HANDLE', 'N/A'))
        order_id = str(first_match.get('ORDER ID', 'N/A'))
        
        print(f"{vip:<45} | {phone:<15} | {zone:<8} | {po_handle:<10} | {order_id:<15}")
        results.append({
            'VIP Name': vip,
            'Phone Number': phone,
            'Zone': zone,
            'Branch': po_handle,
            'Order ID': order_id,
            'Receiver (Full)': str(first_match.get('RECEIVER', ''))
        })
        found_count += 1
        if phone != 'N/A' and phone != 'nan':
            found_with_phone += 1
    else:
        print(f"{vip:<45} | {'NOT FOUND':<15} | {'':<8} | {'':<10} | {'':<15}")
        results.append({
            'VIP Name': vip,
            'Phone Number': 'NOT FOUND',
            'Zone': '',
            'Branch': '',
            'Order ID': '',
            'Receiver (Full)': ''
        })

print("=" * 100)
print(f"\n📊 SUMMARY")
print(f"  Total VIPs searched: {len(vips)}")
print(f"  ✓ Found in orders: {found_count}")
print(f"  ✓ With phone numbers: {found_with_phone}")
print(f"  ❌ Not found: {len(vips) - found_count}")
print(f"  ⚠️  Found but no phone: {found_count - found_with_phone}")

# Save to Excel
output_df = pd.DataFrame(results)
output_file = 'VIP_Phone_Numbers_COMPLETE.xlsx'
output_df.to_excel(output_file, index=False)

print(f"\n✅ COMPLETE RESULTS SAVED TO: {output_file}")
print(f"\nYou can open the Excel file to see:")
print(f"  - VIP Name")
print(f"  - Phone Number") 
print(f"  - Zone")
print(f"  - Branch (POST OFFICE HANDLE)")
print(f"  - Sample Order ID")
print(f"  - Full Receiver Name")
print("=" * 100)
