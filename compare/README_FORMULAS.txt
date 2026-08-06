╔═══════════════════════════════════════════════════════════════════════════╗
║                  URGENT CLEARANCE COMPARE - FORMULA MODE                  ║
╚═══════════════════════════════════════════════════════════════════════════╝

✅ WHAT'S NEW:
The compare Excel now uses FORMULAS instead of hardcoded values!

📊 FORMULA COLUMNS:
  • Column F (URGENT CHANGE): =E-C (5PM - 9AM)
  • Column G (CLEAR %): =IF(C=0,"N/A",ROUND((C-E)/C*100,1)&"%")
  • TOTAL row: All columns use SUM() formulas

🎯 BENEFITS:
  ✓ Edit any 9AM/2PM/5PM value → Results auto-update
  ✓ No need to regenerate Excel when customizing numbers
  ✓ TOTAL row auto-calculates from all branches
  ✓ Clearance % handles division by zero (shows "N/A")

📝 HOW TO USE:

1. MANUAL EDIT (Recommended):
   - Open: Urgent_Clearance_Compare_20260803_EDITABLE.xlsx
   - Edit column E (URGENT 5PM) with your actual report values
   - CHANGE and CLEAR% update instantly!

2. REGENERATE FROM DATA:
   - If you have fresh data file:
     python update_fresh_5pm.py
     python regenerate_v6.py

3. AUTOMATED CAPTURE:
   - The bot's compare system will use formulas automatically
   - Just run: python compare_manager.py capture

💡 EXAMPLE:
   If you edit KANP001:
   - 9AM: 46 (fixed)
   - 5PM: Change 0 → 37
   
   Results auto-calculate:
   - CHANGE: -9 (formula: =E3-C3)
   - CLEAR %: 19.6% (formula calculates clearance rate)

🔧 TECHNICAL DETAILS:
   - Formulas work in both data rows and TOTAL row
   - Per-branch formulas: =E{row}-C{row}
   - Total formulas: =SUM(C3:C{last})
   - Clear% formula: =IF(C=0,"N/A",ROUND((C-E)/C*100,1)&"%")

📂 FILES:
   • Urgent_Clearance_Compare_20260803_EDITABLE.xlsx - Ready to edit!
   • generate_editable_compare.py - Regenerate template
   • compare_manager.py - Updated with formula support
