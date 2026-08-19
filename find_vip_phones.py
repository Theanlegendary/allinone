"""Find phone numbers for VIP customers."""
import pandas as pd
import sys
sys.path.insert(0, '.')

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
Thy sotheany"""

vips = [v.strip() for v in vip_list.split('\n') if v.strip()]

print("Loading data...")
# Try the more recent tracking log file first
try:
    df = pd.read_excel('Bill_Tracking_Status_Logs_01Jul_03Aug_20260803_0852.xlsx', header=2)
    print("Using: Bill_Tracking_Status_Logs (August 3, 2026)")
except:
    df = pd.read_excel('cache/latest_detail.xlsx')
    print("Using: cache/latest_detail.xlsx")

print("\n" + "=" * 100)
print("VIP CUSTOMER PHONE NUMBERS")
print("=" * 100)
print(f"{'Customer Name':<45} | {'Phone Number':<15} | {'Zone':<10}")
print("-" * 100)

results = []
found_count = 0

for vip in vips:
    # Search in RECEIVER column
    matches = df[df['RECEIVER'].astype(str).str.contains(vip, case=False, na=False, regex=False)]
    
    if not matches.empty:
        first_match = matches.iloc[0]
        phone = str(first_match.get('PHONE', first_match.get('Phone', 'N/A')))
        zone = str(first_match.get('ZONE', 'N/A'))
        po_handle = str(first_match.get('POST OFFICE HANDLE', 'N/A'))
        
        print(f"{vip:<45} | {phone:<15} | {zone:<10}")
        results.append((vip, phone, zone))
        found_count += 1
    else:
        print(f"{vip:<45} | {'NOT FOUND':<15} | {'':<10}")
        results.append((vip, 'NOT FOUND', ''))

print("=" * 100)
print(f"\nTotal VIPs: {len(vips)}")
print(f"Found: {found_count}")
print(f"Not Found: {len(vips) - found_count}")

# Create Excel output
output_df = pd.DataFrame(results, columns=['VIP Name', 'Phone Number', 'Zone'])
output_file = 'VIP_Phone_Numbers.xlsx'
output_df.to_excel(output_file, index=False)
print(f"\n✓ Results saved to: {output_file}")
