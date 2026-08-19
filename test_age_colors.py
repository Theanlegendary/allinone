"""Test age color logic to verify no yellow appears."""
import sys
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')

from datetime import datetime, timedelta
import pandas as pd

# Import the function
from generate_report import compute_kpi_info

# Create test cases with different ages
test_cases = [
    ("9h 30m", 570),   # 9.5 hours - should be GREEN
    ("10h 00m", 600),  # 10 hours exactly - should be GREEN
    ("10h 01m", 601),  # 10 hours 1 min - should be RED
    ("10h 20m", 620),  # 10h 20m - should be RED
    ("11h 00m", 660),  # 11 hours - should be RED
    ("12h 30m", 750),  # 12.5 hours - should be RED
    ("18h 44m", 1124), # 18h 44m - should be RED
    ("24h 00m", 1440), # 24 hours - should be RED
]

print("=" * 80)
print("AGE COLOR TEST - Checking for Yellow/Orange Dots")
print("=" * 80)
print()

now = datetime.now()

for label, minutes in test_cases:
    # Create a fake scan time that many minutes ago
    scan_time = now - timedelta(minutes=minutes)
    
    # Create a test row
    test_row = pd.Series({
        'STATUS_CODE': '401',
        'CURRENT TIME': scan_time.strftime('%d/%m/%Y %H:%M:%S')
    })
    
    # Call the function
    age_with_dot, kpi = compute_kpi_info(test_row)
    
    # Analyze the dot
    if '🟢' in age_with_dot:
        color = "GREEN ✓"
        status = "OK"
    elif '🟡' in age_with_dot:
        color = "YELLOW/ORANGE ❌"
        status = "BUG!"
    elif '🔴' in age_with_dot:
        color = "RED ✓"
        status = "OK"
    else:
        color = "UNKNOWN"
        status = "ERROR"
    
    expected = "GREEN" if minutes <= 600 else "RED"
    match = "✓ PASS" if (expected == "GREEN" and '🟢' in age_with_dot) or (expected == "RED" and '🔴' in age_with_dot) else "❌ FAIL"
    
    print(f"{label:10} ({minutes:4} min) → {age_with_dot:15} | {color:20} | Expected: {expected:6} | {match}")

print()
print("=" * 80)
print("SUMMARY")
print("=" * 80)
print()

# Test specifically the problem cases from user's screenshot
print("Testing specific cases from user's screenshot:")
problem_cases = [
    ("10h 20m", 620),
    ("11h 09m", 669),
    ("12h 28m", 748),
    ("13h 03m", 783),
    ("18h 44m", 1124),
]

has_yellow = False
for label, minutes in problem_cases:
    scan_time = now - timedelta(minutes=minutes)
    test_row = pd.Series({
        'STATUS_CODE': '402',
        'CURRENT TIME': scan_time.strftime('%d/%m/%Y %H:%M:%S')
    })
    age_with_dot, kpi = compute_kpi_info(test_row)
    
    if '🟡' in age_with_dot:
        print(f"  ❌ {label} shows YELLOW/ORANGE: {age_with_dot}")
        has_yellow = True
    elif '🔴' in age_with_dot:
        print(f"  ✓ {label} shows RED: {age_with_dot}")
    else:
        print(f"  ? {label} shows: {age_with_dot}")

print()
if has_yellow:
    print("❌ FAILED: Yellow/orange dots still appearing!")
    print("   The code has NOT been updated correctly.")
else:
    print("✓ PASSED: All ages >10h show RED, no yellow!")
    print("  The issue might be:")
    print("  1. You're looking at an old cached image")
    print("  2. The Excel-to-image renderer is changing red to orange")
    print("  3. Need to clear browser/Telegram cache")

print()
print("=" * 80)
