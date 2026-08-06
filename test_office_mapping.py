"""
Test the new map_to_post_office function
"""
import json

# Load config
with open('config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

zone_mapping = config.get('zone_mapping', {})

def map_to_post_office(current_office, zone_mapping):
    """
    Map a current office code (like CHAA025, PREA036) to its responsible post office (like CHAP001, PREP001).
    """
    current_office = str(current_office).strip().upper()
    
    # If it's already a known post office, return it
    if current_office in zone_mapping.get('by_post_office', {}):
        return current_office
    
    # Extract prefix (first 3 letters)
    if len(current_office) >= 3:
        prefix = current_office[:3]
        
        # Look for matching post office with that prefix
        for po in zone_mapping.get('by_post_office', {}).keys():
            if po.startswith(prefix):
                return po
    
    # Fallback: return current office as-is
    return current_office

# Test cases from user's screenshot
test_cases = [
    'PREA036',
    'PREA034',
    'PREA033',
    'PREA030',
    'PREA028',
    'KANA046',
    'SVAA027',
    'SIHA009',
    'TAKA023',
    'BATA042',
    'CHHA023',
    'THOA017',
    'SIEA008',
    'CHAA025',
    'CHAA001',
    'ROTA015',
    'ROTA016',
    'STUA001',
    'ROTA005',
    'TBKA003',
    'PNPP003',  # Already a post office
    'KANP001',  # Already a post office
]

print("🧪 Testing Office Mapping Function")
print("=" * 80)
print(f"{'CURRENT OFFICE':<20} → {'HANDLE OFFICE (Expected)':<20}")
print("=" * 80)

for office in test_cases:
    result = map_to_post_office(office, zone_mapping)
    print(f"{office:<20} → {result:<20}")

print("=" * 80)
print("\n✅ Expected results:")
print("  - PREA036 → PREP001")
print("  - CHAA025 → CHAP001")
print("  - KANA046 → KANP001")
print("  - SIEA008 → SIEP001")
print("  - ROTA015 → ROTP001")
print("  - PNPP003 → PNPP003 (already a post office)")
