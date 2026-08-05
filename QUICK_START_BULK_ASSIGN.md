# 🚀 QUICK START - Bulk Assign All 44 Branches

## What You Need

**User to assign branches to:**
- Name: Prom Kevita
- Code: COC867740
- Email: kevitap@METFONE.COM.KH
- Role: Chief Accountant of Company

**Script to use:** `AUTO_ASSIGN_FIXED.js` ⭐

---

## 3 Simple Steps

### 1️⃣ Open User Page
Go to: https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung

Find and click on **Prom Kevita (COC867740)**

### 2️⃣ Open Console
Press **F12** → Click **Console** tab

### 3️⃣ Run Script
1. Open file: `AUTO_ASSIGN_FIXED.js`
2. Copy all (Ctrl+A, Ctrl+C)
3. Paste in Console (Ctrl+V)
4. Press **Enter**
5. Wait ~35 seconds
6. Done! ✅

---

## What the Script Does

```
For each of 44 branches:
  1. Select branch from dropdown
  2. Select "Chief Accountant of Company" role
  3. Click Add button
  4. Wait 800ms
  5. Repeat for next branch
```

---

## Expected Result

**Console will show:**
```
[1/44] Processing KANP001...
   ✓ Selected branch: KANP001 - Kandal
   ✓ Selected role: Chief Accountant of Company
   ✓ Clicked Add button
   ✅ KANP001 assigned successfully!

... (continues for all 44)

🎉 ALL 44 BRANCHES ASSIGNED SUCCESSFULLY!
✅ Successfully assigned: 44 branches
```

**On the page:**
- Scroll down to see all 44 branches listed
- Each shows "Chief Accountant of Company" role

---

## If It Doesn't Work

Run this debug script first:
1. Open `DEBUG_FIND_FORM.js`
2. Copy and paste in Console
3. Check if it finds:
   - Branch dropdown (ID: branchDropdown)
   - Role dropdown (ID: roleDropdown)
   - Add button (ID: btnAddBranch)

If IDs are different, update `AUTO_ASSIGN_FIXED.js` or let me know.

---

## All 44 Branches That Will Be Assigned

**Zone 1 (17):** KANP001, PNPP001-PNPP014, PREP001, SVAP001  
**Zone 2 (5):** KAMP001, KOHP001, SIHP001, SPEP001, TAKP001  
**Zone 3 (4):** BANP001, BATP001, CHHP001, PURP001  
**Zone 4 (4):** ODDP001, PRHP001, SIEP001, THOP001  
**Zone 5 (9):** CHAP001, KRAP001, TBKP001, ROTS001, MONS001, STUS001, STUP001, ROTP001, MONP001

---

**Time:** 35 seconds  
**Effort:** Copy + Paste  
**Result:** All 44 branches assigned! 🎉
