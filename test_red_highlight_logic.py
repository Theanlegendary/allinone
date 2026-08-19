"""
Test the new red highlighting logic based on CREATED DATE (calendar days)
"""
from datetime import datetime, timedelta

def calc_overdue_test(created_date_str):
    """
    Test function to check if a bill should be red highlighted
    """
    from datetime import datetime
    import pandas as pd
    
    today = datetime.now().date()
    
    parsed_dt = pd.to_datetime(created_date_str, dayfirst=True, format='mixed', errors='coerce')
    if pd.notna(parsed_dt):
        created_date = parsed_dt.date()
        days_old = (today - created_date).days
        
        # Red if 3+ days old
        is_overdue = days_old >= 3
        is_overdue_7days = days_old >= 7
        
        return (is_overdue, is_overdue_7days, days_old)
    
    return (False, False, None)

# Test cases
today = datetime.now()
print("🧪 Testing Red Highlighting Logic (Based on CREATED DATE)")
print("=" * 80)
print(f"Today: {today.strftime('%B %d, %Y (%A)')}")
print("=" * 80)
print(f"{'Created Date':<25} {'Days Old':<12} {'Red Row?':<12} {'Expected'}")
print("=" * 80)

test_cases = [
    (today.strftime('%Y-%m-%d'), "Today", False),
    ((today - timedelta(days=1)).strftime('%Y-%m-%d'), "Yesterday", False),
    ((today - timedelta(days=2)).strftime('%Y-%m-%d'), "2 days ago", False),
    ((today - timedelta(days=3)).strftime('%Y-%m-%d'), "3 days ago", True),
    ((today - timedelta(days=4)).strftime('%Y-%m-%d'), "4 days ago", True),
    ((today - timedelta(days=7)).strftime('%Y-%m-%d'), "7 days ago", True),
    ((today - timedelta(days=10)).strftime('%Y-%m-%d'), "10 days ago", True),
]

for date_str, description, expected_red in test_cases:
    is_red, is_7days, days_old = calc_overdue_test(date_str)
    
    result_icon = "🔴 RED" if is_red else "⚪ Normal"
    expected_icon = "🔴 RED" if expected_red else "⚪ Normal"
    status = "✅" if is_red == expected_red else "❌"
    
    print(f"{date_str:<25} {days_old:<12} {result_icon:<12} {expected_icon:<12} {status}")

print("=" * 80)
print("\n📋 Summary:")
print("  - Bills created TODAY (Aug 5) = No red ⚪")
print("  - Bills created YESTERDAY (Aug 4) = No red ⚪")
print("  - Bills created 2 DAYS AGO (Aug 3) = No red ⚪")
print("  - Bills created 3+ DAYS AGO (Aug 2 or earlier) = RED 🔴")
print("\n✅ Age column (for KPI) is separate - uses 10h threshold for green/red text")
