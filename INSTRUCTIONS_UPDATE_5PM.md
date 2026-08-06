# How to Update 5PM Values with Auto-Calculating Results

## ✅ What Changed
The compare Excel now has **formulas** instead of hardcoded values for:
- **URGENT CHANGE** column (F) = `5PM - 9AM`
- **CLEAR %** column (G) = `(9AM - 5PM) / 9AM * 100%`
- **TOTAL row** = `SUM()` formulas for all columns

## 📝 How to Update

### Option 1: Manually Edit in Excel
1. Open: `compare\Urgent_Clearance_Compare_20260803_v5.xlsx`
2. Edit any cell in the **URGENT (9AM)**, **URGENT (2PM)**, or **URGENT (5PM)** columns
3. The **URGENT CHANGE** and **CLEAR %** columns will **auto-update** instantly!
4. The **TOTAL** row also auto-updates based on the sum of all branches

### Option 2: Capture Fresh 5PM Snapshot from Current Data
If you have fresh data in a file, run:

```bash
python update_fresh_5pm.py
python regenerate_v6.py
```

This will capture current data and regenerate the Excel with formulas.

### Option 3: Input from Your Screenshot
Based on your screenshot showing:
- KANP001: Branch = 37 (urgent)
- (other branches...)

You can either:
1. Manually type these values into the Excel (column E)
2. Or tell me more branch values and I'll create an import script

## 🎯 Benefits
- **Flexible**: Change any number and results update automatically
- **Accurate**: No need to regenerate the entire Excel when you customize values
- **Fast**: Just type new numbers and formulas handle the rest

## 📊 Example
If KANP001 shows:
- 9AM: 46
- 5PM: 37

Formula automatically calculates:
- CHANGE: -9 (37 - 46)
- CLEAR %: 19.6% ((46 - 37) / 46 * 100)

Change 5PM to 20:
- CHANGE: -26 (20 - 46)
- CLEAR %: 56.5% ((46 - 20) / 46 * 100)
