# Remaining Changes for URGENT Column Rename

## What's Done ✅
1. VIP column added to /total and push zone Excel reports
2. VIP emoji (🌟) removed from zone captions 
3. POST OFFICE HANDLE maps agents to main offices
4. Red row highlighting for 3+ days old bills
5. Header renamed: "URGENT" → "> 1 Day"
6. Added header: "> 3 Days"
7. Column widths defined for both columns

## What's Left ❌

### 1. Update Data Population Logic
File: `generate_summary.py` lines ~400-520

**Current code:** Fills single URGENT column
**Need:** Fill TWO columns (> 1 Day and > 3 Days)

**Logic needed:**
```python
# For each branch:
urgent_1day = urgent_counts.get(handle, {}).get("1day", 0)
urgent_3days = urgent_counts.get(handle, {}).get("3days", 0)

cells.append(str(urgent_1day) if urgent_1day else "")
cells.append(str(urgent_3days) if urgent_3days else "")
```

### 2. Update Grand Total Calculation
File: `generate_summary.py` lines ~500-535

**Need:** Sum both columns separately for Grand Total

### 3. Update Bot to Calculate Both Counts
File: `bot.py` (push zone section)

**Current:** Calculates single urgent_counts
**Need:** Calculate dict with both:
```python
zone_urgent_counts = {
    "PNPP003": {"1day": 37, "3days": 15},
    "KANP001": {"1day": 97, "3days": 40},
    ...
}
```

**Calculation logic:**
- `1day`: Bills with CREATED DATE >= 1 day old (yesterday or earlier)
- `3days`: Bills with CREATED DATE >= 3 days old

### 4. Apply Same Changes to push_bot Version
All files have duplicates in `push_bot/` folder

---

## Test Command
After implementing, run: `python test_zone1_report.py`

This will show both "> 1 Day" and "> 3 Days" columns in the summary image.
