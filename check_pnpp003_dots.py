"""Check PNPP003 Excel for yellow dots"""
import pandas as pd
import glob

print("=" * 100)
print("CHECKING PNPP003 EXCEL FILES FOR YELLOW DOTS")
print("=" * 100)

# Find today's PNPP003 files
files = glob.glob('bo/Report_PNPP003*05_08_2026*.xlsx')

for file in sorted(files):
    print(f"\n📄 Checking: {file}")
    
    try:
        xl = pd.ExcelFile(file)
        
        for sheet in xl.sheet_names:
            df = xl.parse(sheet)
            
            # Check Age column if it exists
            if 'Age' in df.columns:
                age_values = df['Age'].dropna().astype(str)
                
                has_green = sum('🟢' in v for v in age_values)
                has_yellow = sum('🟡' in v for v in age_values)
                has_red = sum('🔴' in v for v in age_values)
                
                print(f"   Sheet: {sheet}")
                print(f"      🟢 Green dots: {has_green}")
                print(f"      🟡 Yellow dots: {has_yellow} {'← ❌ PROBLEM!' if has_yellow > 0 else '← ✓ Good'}")
                print(f"      🔴 Red dots: {has_red}")
                
                # Show sample yellow dots if any
                if has_yellow > 0:
                    yellow_samples = [v for v in age_values if '🟡' in v][:3]
                    print(f"      Sample yellow values: {yellow_samples}")
            
            # Check VIP column if it exists
            if 'VIP' in df.columns:
                vip_count = sum(df['VIP'] == 'VIP')
                print(f"      ✨ VIP count: {vip_count}")
                
    except Exception as e:
        print(f"   ⚠️ Error reading file: {e}")

print("\n" + "=" * 100)
