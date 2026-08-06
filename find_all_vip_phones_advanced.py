"""
Advanced VIP Phone Finder with Fresh Data and Fuzzy Matching
Fetches fresh data from API and uses smart matching to find VIP customers
"""
import sys, os, json
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')
os.chdir(r'c:\Users\DELL\Desktop\daily_push')

import pandas as pd
import downloader
from datetime import datetime, timedelta

print("=" * 100)
print("ADVANCED VIP PHONE NUMBER FINDER")
print("=" * 100)

# Load config
with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

# VIP list from user
vip_data = """Zone 1	PNP	TPG SHOP	PNP
Zone 1	PNP	Juuhouy	PNP
Zone 1	PNP	Prak Khley	PNP
Zone 1	KAN	Khem ma	KAN
Zone 1	KAN	Srey Roth	KAN
Zone 1	KAN	Chan Lida	KAN
Zone 1	SVA	ធី ធា	SVA
Zone 1	PNP	J DM	PNP
Zone 1	PNP	Hotpot house	PNP
Zone 1	PNP	Babe clean	PNP
Zone 1	PNP	Soap Laor	PNP
Zone 1	PNP	Jusmine wholesale	PNP
Zone 1	PNP	ស៊ីណា	PNP
Zone 1	KAN	Phann phumara	KAN
Zone 1	KAN	Mi Kh	KAN
Zone 1	KAN	Kem sokunthea	KAN
Zone 1	PNP	សត្តនា សំ	PNP
Zone 1	PNP	សាន់ លីណា	PNP
Zone 2	TAK	Ou Leakena	TAK
Zone 2	TAK	Por sokha	TAK
Zone 2	TAK	Sok ounoly	TAK
Zone 2	KOH	Hong Dany	KOH
Zone 2	KOH	KuySocheata	KOH
Zone 2	SIH	Pisey Shop	SIH
Zone 2	SIH	Ratana	SIH
Zone 2	SPE	Leakhena	SPE
Zone 2	SPE	Pho Pich	SPE
Zone 2	SPE	Meach Kunthea	SPE
Zone 2	SPE	lengkhimsan	SPE
Zone 2	KAM	je sros	KAM
Zone 2	KAM	Dun Srey Mom	KAM
Zone 2	SIH	Chheng hout printer	SIH
Zone 3	BAT	PU IT	BAT
Zone 3	BAT	ឡាងឌី លក់អង្ករ	BAT
Zone 3	BAT	យឹម សុខវណ្ណៈ លក់អង្ករ	BAT
Zone 3	BAT	Va Siekhy លក់អង្ករ	BAT
Zone 3	BAT	CPT	BAT
Zone 3	BAT	MLH សិប្បកម្មណាំវ៉ា	BAT
Zone 3	BAT	Vyda 316	BAT
Zone 3	BAN	Heng Soseksa	BAN
Zone 3	BAN	Chheat Lies	BAN
Zone 3	BAN	Dalin	BAN
Zone 3	PUR	SENGHENG51	PUR
Zone 3	PUR	Neat Shop	PUR
Zone 3	CHH	គីម សារុន	CHH
Zone 3	CHH	Hory Bunny	CHH
Zone 3	CHH	Touch Rada	CHH
Zone 3	CHH	Ah Vy (លក់ត្រីងៀត)	CHH
Zone 3	CHH	ម៉ីហោស ត្រីធម្មជាតិ	CHH
Zone 3	CHH	ចែម៉ី លក់ត្រីស្រស់ធម្មជាតិ	CHH
Zone 3	CHH	Sina Heng	CHH
Zone 3	CHH	ជាងសាន (លក់ធុងបាស)	CHH
Zone 3	CHH	Savanna	CHH
Zone 3	CHH	Tola	CHH
Zone 3	CHH	Chan Mony	CHH
Zone 4	SIE	PEANH SETHA	SIE
Zone 4	SIE	Yen vannay	SIE
Zone 4	SIE	Kim Heang	SIE
Zone 4	SIE	Samdy	SIE
Zone 4	SIE	Sophat	SIE
Zone 4	THO	Nat Rothna	THO
Zone 4	PRH	Vichra	PRH
Zone 5	CHA	- Bouy Bouy Store	CHA
Zone 5	CHA	Bouy Bouy Store	CHA
Zone 5	CHA	- Bouy Bouy Store	CHA
Zone 5	CHA	Bouy Bouy Store	CHA
Zone 5	CHA	Bouy Bouy Store	CHA
Zone 5	CHA	- Bouy Bouy Store	CHA
Zone 5	CHA	ថន​ ថារី	CHA
Zone 5	CHA	ថន​ ថារី	CHA
Zone 5	CHA	ថន​ ថារី	CHA
Zone 5	CHA	ថន​ ថារី	CHA
Zone 5	CHA	NUN VUTHA	CHA
Zone 5	CHA	Sima	CHA
Zone 5	CHA	Leakana	CHA
Zone 5	CHA	Rady	CHA
Zone 5	CHA	Rithy	CHA
Zone 5	CHA	Da Ne	CHA
Zone 5	CHA	Da Ry	CHA
Zone 5	CHA	Phuoysang Stort	CHA
Zone 5	CHA	Khome Somphors	CHA
Zone 5	CHA	Hoeun Rotha	CHA
Zone 5	CHA	Srey Yi	CHA
Zone5	TBK	ពេញនិយម	TBK
Zone5	TBK	The Venuz Gold	TBK
Zone5	TBK	Chea Pich	TBK
Zone5	TBK	Thai sokthida	TBK
Zone5	TBK	Ngan Farita	TBK
Zone5	TBK	Thy sotheany (N.Y Clothes & Jewelry)	TBK"""

# Parse VIP data
vip_list = []
for line in vip_data.strip().split('\n'):
    parts = line.split('\t')
    if len(parts) >= 3:
        zone = parts[0].strip()
        province = parts[1].strip()
        name = parts[2].strip()
        vip_list.append({
            'Zone': zone,
            'Province': province,
            'Name': name
        })

print(f"\n📋 Total VIP customers to search: {len(vip_list)}")

# Step 1: Fetch FRESH data from API
print("\n🔄 STEP 1: Fetching FRESH data from API...")
print("   (This will get the latest orders, not old cached data)")

# Get data from last 14 days to ensure we have recent transactions
end_date = datetime.now()
start_date = end_date - timedelta(days=14)

try:
    print(f"   Fetching from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}...")
    
    fresh_data = downloader.fetch_all_detail(
        cfg=cfg,
        start_date=start_date.strftime('%Y-%m-%d'),
        end_date=end_date.strftime('%Y-%m-%d')
    )
    
    if fresh_data and len(fresh_data) > 0:
        df = pd.DataFrame(fresh_data)
        print(f"   ✅ Fetched {len(df)} fresh orders from API")
    else:
        print("   ⚠️  API returned no data, using cached data...")
        df = pd.read_excel('cache/latest_detail.xlsx')
        print(f"   📁 Loaded {len(df)} orders from cache")
        
except Exception as e:
    print(f"   ⚠️  API fetch failed: {e}")
    print("   📁 Using cached data instead...")
    df = pd.read_excel('cache/latest_detail.xlsx')
    print(f"   Loaded {len(df)} orders from cache")

# Step 2: Search for VIP phone numbers
print("\n🔍 STEP 2: Searching for VIP phone numbers...")
print("=" * 120)
print(f"{'Zone':<8} {'Prov':<6} {'VIP Name':<35} {'Phone':<15} {'Full Name':<35} {'Found As':<10}")
print("-" * 120)

results = []
found_count = 0
not_found_count = 0

for vip in vip_list:
    zone = vip['Zone']
    province = vip['Province']
    name = vip['Name']
    
    phone = ''
    full_name = ''
    found_as = ''
    order_id = ''
    match_type = ''
    
    # Clean the search name (remove leading dashes, extra spaces)
    search_name = name.strip().lstrip('-').strip()
    
    # STEP 1: Search in RECEIVER column
    receiver_matches = df[df['RECEIVER'].astype(str).str.contains(search_name, case=False, na=False, regex=False)]
    
    if not receiver_matches.empty:
        first_match = receiver_matches.iloc[0]
        receiver_field = str(first_match.get('RECEIVER', ''))
        
        if ' - ' in receiver_field:
            phone = receiver_field.split(' - ')[0].strip()
            full_name = receiver_field.split(' - ', 1)[1].strip()
        else:
            phone = receiver_field
            full_name = receiver_field
        
        found_as = 'RECEIVER'
        order_id = str(first_match.get('ORDER ID', ''))
        match_type = 'EXACT'
    
    # STEP 2: If not found, search in SENDER column
    if not phone:
        sender_matches = df[df['SENDER'].astype(str).str.contains(search_name, case=False, na=False, regex=False)]
        
        if not sender_matches.empty:
            first_match = sender_matches.iloc[0]
            sender_field = str(first_match.get('SENDER', ''))
            
            if ' - ' in sender_field:
                phone = sender_field.split(' - ')[0].strip()
                full_name = sender_field.split(' - ', 1)[1].strip()
            else:
                phone = sender_field
                full_name = sender_field
            
            found_as = 'SENDER'
            order_id = str(first_match.get('ORDER ID', ''))
            match_type = 'EXACT'
    
    # STEP 3: If still not found, try partial/fuzzy matching
    if not phone:
        # Try with first word only (for names like "Bouy Bouy Store")
        words = search_name.split()
        if len(words) > 1:
            first_word = words[0]
            
            # Try RECEIVER
            partial_matches = df[df['RECEIVER'].astype(str).str.contains(first_word, case=False, na=False, regex=False)]
            if not partial_matches.empty:
                first_match = partial_matches.iloc[0]
                receiver_field = str(first_match.get('RECEIVER', ''))
                
                if ' - ' in receiver_field:
                    phone = receiver_field.split(' - ')[0].strip()
                    full_name = receiver_field.split(' - ', 1)[1].strip()
                else:
                    phone = receiver_field
                    full_name = receiver_field
                
                found_as = 'RECEIVER'
                order_id = str(first_match.get('ORDER ID', ''))
                match_type = 'PARTIAL'
    
    # Record results
    if phone:
        found_count += 1
        status = '✅'
        print(f"{zone:<8} {province:<6} {name:<35} {phone:<15} {full_name:<35} {found_as:<10}")
    else:
        not_found_count += 1
        status = '❌'
        phone = 'NOT FOUND'
        print(f"{zone:<8} {province:<6} {name:<35} {'NOT FOUND':<15} {'':<35} {'':<10}")
    
    results.append({
        'Status': status,
        'Zone': zone,
        'Province': province,
        'VIP Name (Search)': name,
        'Phone Number': phone,
        'Full Name in System': full_name,
        'Found As': found_as,
        'Match Type': match_type,
        'Sample Order ID': order_id
    })

# Step 3: Save results
print("=" * 120)
print(f"\n📊 SUMMARY")
print(f"   Total VIPs searched: {len(vip_list)}")
print(f"   ✅ Found with phone: {found_count}")
print(f"   ❌ Not found: {not_found_count}")
print(f"   Success rate: {found_count/len(vip_list)*100:.1f}%")

# Save to Excel
output_df = pd.DataFrame(results)
output_file = f'VIP_Phone_Numbers_Complete_{datetime.now().strftime("%Y%m%d_%H%M")}.xlsx'

with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    # Sheet 1: All results
    output_df.to_excel(writer, sheet_name='All VIPs', index=False)
    
    # Sheet 2: Found only
    found_df = output_df[output_df['Phone Number'] != 'NOT FOUND']
    found_df.to_excel(writer, sheet_name='Found', index=False)
    
    # Sheet 3: Not found only
    not_found_df = output_df[output_df['Phone Number'] == 'NOT FOUND']
    not_found_df.to_excel(writer, sheet_name='Not Found', index=False)

print(f"\n✅ RESULTS SAVED TO: {output_file}")
print(f"   📄 Sheet 1: All VIPs ({len(output_df)} records)")
print(f"   📄 Sheet 2: Found ({len(found_df)} records)")
print(f"   📄 Sheet 3: Not Found ({len(not_found_df)} records)")
print("=" * 120)

# Show NOT FOUND list for manual checking
if not_found_count > 0:
    print(f"\n⚠️  VIPs NOT FOUND ({not_found_count}):")
    print("   (These may need manual search or different spelling)")
    print("-" * 80)
    for idx, row in not_found_df.iterrows():
        print(f"   - {row['Zone']:<10} {row['Province']:<6} {row['VIP Name (Search)']}")
    print("-" * 80)
