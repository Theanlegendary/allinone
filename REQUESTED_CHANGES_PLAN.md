# Requested Changes Plan

## Summary of Requested Changes

### 1. Add VIP Column to Push Zone Reports
**Current:** Push zone reports have no VIP column
**Needed:** Add VIP column after RECEIVER in Delivery and Not Assign tabs

**Files to modify:**
- `generate_summary.py` - Add 'VIP' to REPORT_COLS
- Ensure VIP data flows through zone filtering

### 2. Add VIP Count Per Branch + Grand Total
**Current:** No VIP counting in summary
**Needed:** Show VIP count for each branch with Grand Total

**Implementation:**
- Count VIPs per branch in summary image
- Add to remark section
- Calculate Grand Total across all branches

### 3. Change Remark Format (Remove Icons)
**Current:** Remarks use icons: "🌟 5 VIP", "⚠️ 3 URGENT"
**Needed:** Simple text format: "VIP: 5", "URGENT: 3"

**Files to modify:**
- Bot remark building functions
- Summary image remark text

### 4. Change Table Titles in /total and Push Zone
**Current:** Different titles from regular push
**Needed:** Match regular push format exactly

**Need to check:**
- What is the current title format in regular push?
- What is the current title format in /total?
- Make them consistent

### 5. Rename and Add Urgent Columns
**Current:** Single "URGENT" column
**Needed:**
- Rename "URGENT" → "> 1 Day"  
- Add new column "> 3 Days"

**Implementation:**
- "> 1 Day" = Bills created yesterday or earlier (1+ days old)
- "> 3 Days" = Bills created 3+ days ago (3+ days old)
- Both columns show counts per branch

---

## Questions Before Implementation

1. **VIP Column Position:** After RECEIVER column in Delivery/Not Assign tabs - correct?

2. **VIP Count Location:** In summary image remark section or separate line?

3. **Table Titles:** What should the title format be? Example:
   - Current /total: "DELIVERY BILL CHECK — All — 05/08/2026 17:30"
   - Current push: "DELIVERY BILL CHECK — PNPP003 — 05/08/2026 17:30"
   - Should they both use same format?

4. **Urgent Column Data:** 
   - "> 1 Day" counts bills with CREATED DATE >= 1 day old?
   - "> 3 Days" counts bills with CREATED DATE >= 3 days old?
   - Show in summary image or just in Excel?

5. **Test File:** Where should I generate a test report for you to verify?

---

## Implementation Order

1. ✅ Add VIP column to generate_summary.py REPORT_COLS
2. ✅ Update remark format (remove icons)
3. ✅ Add VIP counting per branch
4. ✅ Rename URGENT → "> 1 Day"
5. ✅ Add new "> 3 Days" column
6. ✅ Fix table titles consistency
7. ✅ Generate test report

---

Please confirm these details so I can implement correctly!
