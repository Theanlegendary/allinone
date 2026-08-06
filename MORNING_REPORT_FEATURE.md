# Morning Report Feature - Age Adjustment

## ✅ Changes Implemented

### 1. Age Color Simplification
**Before**: 3 colors - 🟢 Green (0-10h), 🟡 Yellow (10-24h), 🔴 Red (>24h)
**After**: 2 colors - 🟢 Green (0-10h), 🔴 Red (>10h)

**Why**: Simpler and clearer - anything over 10h is urgent (RED), no middle ground.

**Files Modified**:
- `generate_summary.py` - Line 904
- `push_bot/generate_summary.py` - Line 904

---

### 2. Morning Age Adjustment System
**Problem**: Morning reports show misleading ages. Example:
- Report time: 8 AM
- Package shows: "15 hours old"
- Reality: 12 of those hours were overnight (no one could act on it)
- **Actual actionable age**: Only 3 hours

**Solution**: New `/morning` command subtracts 12 hours from all ages to show **actionable age** only.

---

## 🎯 New Bot Command: `/morning`

### Usage
```
/morning          - All zones with age -12h
/morning zone5    - Zone 5 only with age -12h
/morning zone1    - Zone 1 only with age -12h
```

### What It Does
1. Fetches current data (like `/total`)
2. Subtracts 12 hours from all package ages
3. Recalculates colors based on adjusted age:
   - Adjusted age ≤ 10h → 🟢 Green
   - Adjusted age > 10h → 🔴 Red
4. Generates Excel with adjusted ages and summary image

### Example

**Normal `/total` report at 8 AM**:
```
Order A: 15h 30m 🔴 (shows red, held since 4:30 PM yesterday)
Order B: 8h 20m 🟢  (shows green, held since 11:40 PM)
Order C: 11h 10m 🔴 (shows red, held since 8:50 PM)
```

**Morning `/morning` report at 8 AM** (age -12h):
```
Order A: 3h 30m 🟢  (actionable 3.5h, was on hold overnight)
Order B: 0h 0m 🟢   (just arrived, negative capped at 0)
Order C: 0h 0m 🟢   (negative capped at 0, fresh)
```

---

## 📝 Technical Details

### Modified Functions

**1. `compute_kpi_info(row, age_adjust_hours=0)`**
- Added `age_adjust_hours` parameter (default 0 = no adjustment)
- Subtracts adjustment from calculated minutes
- Caps minimum at 0 (no negative ages)
- Uses adjusted age for color determination

**Location**: 
- `generate_summary.py` - Line 551
- `push_bot/generate_summary.py` - Line 551

**2. `build_total_excel(result, out_path, lang='kh', age_adjust_hours=0)`**
- Added `age_adjust_hours` parameter
- Passes it to `compute_kpi_info` via lambda
- All age calculations use adjusted values

**Location**:
- `generate_summary.py` - Line 604
- `push_bot/generate_summary.py` - Line 604

**3. New Command: `cmd_morning()`**
- Similar to `cmd_total()` but calls `build_total_excel(..., age_adjust_hours=12)`
- Added to bot handlers
- Documented in `/help`

**Location**: `bot.py` - Line ~2042

---

## 🚀 How to Use

### For Regular Reports (No Adjustment)
```
/total          - Normal ages
/total zone5    - Normal ages for zone5
```

### For Morning Reports (12h Adjustment)
```
/morning        - Age -12h for overnight exclusion
/morning zone5  - Age -12h for zone5
```

### When to Use Each

**Use `/total`**:
- Afternoon/evening reports (2 PM, 5 PM)
- When you want real elapsed time since scan
- For historical comparison

**Use `/morning`**:
- Morning reports (6 AM - 12 PM)
- When packages were held overnight
- To see only actionable work time
- To avoid penalizing for overnight delays

---

## 💡 Benefits

1. **Accurate Urgency**: Morning reports show real actionable age
2. **Fair Metrics**: Managers aren't penalized for overnight hold time
3. **Better Prioritization**: Focus on truly urgent items (red = >10h actionable time)
4. **Flexible**: Choose regular or adjusted based on time of day
5. **Simple Colors**: Green = OK, Red = Urgent (no yellow confusion)

---

## 📊 Color Legend (Updated)

- 🟢 **Green**: 0-10 hours (on track, no action needed)
- 🔴 **Red**: >10 hours (urgent, needs immediate action)
- 🟢 **Special Green**: Status 420/472 (waiting by design, always green unless >7 days old)

---

## 🔧 Configuration

No configuration needed - the adjustment is hardcoded to 12 hours.

To change the adjustment amount, modify the bot command:
```python
# In bot.py, cmd_morning function
generate_summary.build_total_excel(result, total_xlsx, age_adjust_hours=12)
                                                                      ^^
                                                            Change this number
```

---

## 📁 Files Modified

1. ✅ `generate_summary.py` - Age coloring + adjustment logic
2. ✅ `push_bot/generate_summary.py` - Age coloring + adjustment logic (duplicate)
3. ✅ `bot.py` - New `/morning` command + handler registration
4. ✅ `bot.py` - Updated `/help` text

---

## ✨ Example Use Cases

**Morning Manager Review (8 AM)**:
```
Manager: /morning zone5
Bot: Shows only packages with >10h ACTIONABLE time (red)
     Packages that arrived at 10 PM show as 0h (green)
Result: Manager focuses on truly overdue items
```

**Afternoon Status Check (3 PM)**:
```
Manager: /total zone5
Bot: Shows full elapsed time since scan
     Package from 10 PM yesterday shows 17h (red)
Result: Complete time tracking for metrics
```

---

## 🎉 Ready to Use!

The feature is fully implemented. Just restart the bot and use:
- `/morning` for adjusted morning reports
- `/total` for standard reports anytime

Both commands support zone filtering: `/morning zone5`, `/total zone1`, etc.
