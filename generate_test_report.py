"""Generate a test report to verify age colors."""
import sys, os, tempfile
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')
os.chdir(r'c:\Users\DELL\Desktop\daily_push')

from datetime import datetime, timedelta
import pandas as pd
import generate_report

# Create fake data with different ages
now = datetime.now()
test_data = []

ages_to_test = [
    ("9h 30m", 570),
    ("10h 00m", 600),
    ("10h 20m", 620),
    ("11h 09m", 669),
    ("12h 28m", 748),
    ("18h 44m", 1124),
]

for i, (label, minutes) in enumerate(ages_to_test, 1):
    scan_time = now - timedelta(minutes=minutes)
    test_data.append({
        'ORDER ID': f'TEST{i:03d}',
        'POST OFFICE HANDLE': 'SIEP001',
        'CURRENT POST OFFICE': 'SIEP001',
        'STATUS_CODE': '402',
        'RECEIVER': f'Test {label}',
        'CURRENT TIME': scan_time.strftime('%d/%m/%Y %H:%M:%S'),
        'CREATED DATE': (now - timedelta(days=1)).strftime('%d/%m/%Y'),
        'TOTAL FEE (USD)': 2.5,
        'COD (USD)': 0,
    })

df = pd.DataFrame(test_data)

# Save to Excel
tmpdir = tempfile.mkdtemp(prefix="age_test_")
test_file = os.path.join(tmpdir, "test_ages.xlsx")
df.to_excel(test_file, index=False)

print("=" * 80)
print("Generating test report with age colors...")
print("=" * 80)
print()

# Generate report
result = generate_report.generate_reports_from_data(
    test_file,
    "post_office_lookup.csv",
    tmpdir,
    return_metadata=True,
    mode="wide"
)

# Find the output Excel
import glob
output_files = glob.glob(os.path.join(tmpdir, "Report_SIEP001_Delivery_*.xlsx"))
if output_files:
    output_file = output_files[0]
    print(f"✓ Test report generated: {output_file}")
    print()
    
    # Read it back and check age values
    df_out = pd.read_excel(output_file, header=1)
    if 'Age' in df_out.columns:
        print("Age values in generated Excel:")
        print("-" * 80)
        for idx, row in df_out.iterrows():
            age_val = str(row['Age'])
            receiver = row.get('RECEIVER', '')
            if '🟢' in age_val:
                color = "GREEN ✓"
            elif '🟡' in age_val:
                color = "YELLOW/ORANGE ❌ BUG!"
            elif '🔴' in age_val:
                color = "RED ✓"
            else:
                color = "NO DOT"
            print(f"  {receiver:15} → {age_val:15} | {color}")
        
        print()
        print("-" * 80)
        has_yellow = any('🟡' in str(row['Age']) for _, row in df_out.iterrows())
        if has_yellow:
            print("❌ FAILED: Excel contains yellow/orange dots!")
        else:
            print("✓ PASSED: No yellow in Excel - all ages >10h are RED!")
    else:
        print("⚠ Age column not found in output")
else:
    print("❌ No output file generated")

print()
print(f"Test files location: {tmpdir}")
print("=" * 80)
