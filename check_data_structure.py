"""Check the actual data structure to find phone numbers."""
import pandas as pd

print("Loading data...")
df = pd.read_excel('cache/latest_detail.xlsx', nrows=10)

print("\n" + "=" * 80)
print("ALL COLUMNS IN THE DATA:")
print("=" * 80)
for i, col in enumerate(df.columns):
    print(f"{i:3d}: {col}")

print("\n" + "=" * 80)
print("SAMPLE DATA (First 3 rows):")
print("=" * 80)

# Show first 3 rows for key columns
key_cols = [c for c in df.columns if any(x in c.upper() for x in ['RECEIVER', 'PHONE', 'NAME', 'CONTACT', 'CUS', 'SENDER'])]
print(f"\nKey columns found: {key_cols}")

if key_cols:
    print("\nSample data:")
    print(df[key_cols].head(3).to_string())
else:
    print("\nNo obvious phone/name columns. Showing first 10 columns:")
    print(df.iloc[:3, :10].to_string())

print("\n" + "=" * 80)
print("SEARCHING FOR PHONE-LIKE DATA:")
print("=" * 80)

# Search for columns that might contain phone numbers (numeric patterns)
for col in df.columns:
    sample = str(df[col].iloc[0])
    # Check if it looks like a phone number (starts with 0 and has 9-10 digits)
    if sample.startswith('0') and len(sample.replace(' ', '')) >= 9:
        print(f"Possible phone column: {col}")
        print(f"  Sample values: {df[col].head(3).tolist()}")
