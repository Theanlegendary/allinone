"""Debug script to trace exactly what's happening in report generation."""
import sys
sys.path.insert(0, r'c:\Users\DELL\Desktop\daily_push')

# Monkey patch to debug
original_compute = None

def debug_compute_kpi_info(row):
    """Wrapped version with debug output."""
    result = original_compute(row)
    age_text, kpi = result
    
    # Check for yellow
    if '🟡' in age_text:
        print(f"⚠️  WARNING: Yellow dot found! '{age_text}'")
        import traceback
        traceback.print_stack()
    
    return result

# Patch generate_report
import generate_report
original_compute = generate_report.compute_kpi_info
generate_report.compute_kpi_info = debug_compute_kpi_info

print("=" * 80)
print("DEBUG MODE ACTIVE - Will print stack trace if yellow dot is generated")
print("=" * 80)
print()
print("Now run your bot and it will show where yellow comes from.")
print("The bot is patched and running with debug mode.")
