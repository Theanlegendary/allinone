"""
Export fresh PNPP003 report directly (standalone script)
"""
import sys, os, json
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')
os.chdir(r'c:\Users\DELL\Desktop\daily_push')

from datetime import datetime
import generate_report
import downloader

print("=" * 100)
print("EXPORTING FRESH PNPP003 REPORT")
print("=" * 100)

# Load config
with open('config.json', 'r', encoding='utf-8') as f:
    cfg = json.load(f)

branch_code = 'PNPP003'
today_str = datetime.now().strftime('%d_%m_%Y')
output_dir = 'bo'
ref_path = 'post_office_lookup.csv'

print(f"\n📦 Branch: {branch_code}")
print(f"📅 Date: {today_str}")
print(f"🔄 Step 1: Downloading fresh data from API...\n")

# Download fresh data
src_file = 'cache/latest_detail.xlsx'
try:
    downloader.download_detail(cfg["api"], src_file, force_refresh=True)
    print(f"✅ Fresh data downloaded to: {src_file}\n")
except Exception as e:
    print(f"⚠️  Download failed: {e}, using existing cache\n")

print(f"🔄 Step 2: Generating report for {branch_code}...\n")

try:
    # Generate the report for specific branch
    result = generate_report.generate_reports_from_data(
        export_path=src_file,
        ref_path=ref_path,
        output_dir=output_dir,
        return_metadata=True,
        mode='wide',
        target_handles=[branch_code]  # Only generate for PNPP003
    )
    
    if result and 'handle_results' in result:
        handle_results = result['handle_results']
        
        # Find PNPP003 result
        pnpp003_result = None
        for hr in handle_results:
            if hr.get('handle') == branch_code:
                pnpp003_result = hr
                break
        
        if pnpp003_result:
            excel_file = pnpp003_result.get('excel_path', 'N/A')
            image_files = pnpp003_result.get('image_paths', [])
            
            print("\n" + "=" * 100)
            print("✅ EXPORT COMPLETED SUCCESSFULLY")
            print("=" * 100)
            print(f"📄 Excel file: {excel_file}")
            print(f"🖼️  Image files ({len(image_files)}):")
            for img in image_files:
                print(f"   - {img}")
            print("=" * 100)
        else:
            print(f"\n❌ No results found for {branch_code}")
            print(f"Available handles: {[hr.get('handle') for hr in handle_results]}")
    else:
        print("\n❌ Export failed - No result returned")
        print(f"Result keys: {result.keys() if result else 'None'}")
        
except Exception as e:
    print(f"\n❌ ERROR during export: {e}")
    import traceback
    traceback.print_exc()
