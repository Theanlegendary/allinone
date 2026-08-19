"""Generate images for PNPP003 Excel files"""
import os
import glob
from datetime import datetime
import excel_to_image

print("=" * 100)
print("GENERATING IMAGES FOR PNPP003 REPORTS")
print("=" * 100)

today_str = datetime.now().strftime('%d_%m_%Y')
bo_dir = 'bo'

# Find all PNPP003 Excel files from today
pattern = os.path.join(bo_dir, f'Report_PNPP003*{today_str}*.xlsx')
excel_files = glob.glob(pattern)

print(f"\n📂 Found {len(excel_files)} Excel files:")
for f in excel_files:
    print(f"   - {os.path.basename(f)}")

if not excel_files:
    print("\n❌ No PNPP003 Excel files found!")
    exit(1)

print(f"\n🖼️  Generating images...\n")

success_count = 0
failed_count = 0

for excel_file in excel_files:
    basename = os.path.basename(excel_file)
    image_file = excel_file.replace('.xlsx', '.png')
    
    try:
        print(f"   Processing: {basename}...")
        
        # excel_to_image returns BytesIO, we need to save it
        img_bytes = excel_to_image.excel_to_image(excel_file)
        
        if img_bytes:
            with open(image_file, 'wb') as f:
                f.write(img_bytes.getvalue())
            
            file_size = os.path.getsize(image_file)
            print(f"   ✅ Created: {os.path.basename(image_file)} ({file_size:,} bytes)")
            success_count += 1
        else:
            print(f"   ❌ Failed to create image")
            failed_count += 1
            
    except Exception as e:
        print(f"   ❌ Error: {e}")
        failed_count += 1

print("\n" + "=" * 100)
print("📊 SUMMARY")
print("=" * 100)
print(f"   Total files processed: {len(excel_files)}")
print(f"   ✅ Successful: {success_count}")
print(f"   ❌ Failed: {failed_count}")
print("=" * 100)

# List all PNPP003 files (Excel + Images)
print(f"\n📁 All PNPP003 files in {bo_dir}:")
all_files = glob.glob(os.path.join(bo_dir, f'Report_PNPP003*{today_str}*'))
for f in sorted(all_files):
    size = os.path.getsize(f)
    print(f"   {os.path.basename(f):<60} {size:>10,} bytes")
print("=" * 100)
