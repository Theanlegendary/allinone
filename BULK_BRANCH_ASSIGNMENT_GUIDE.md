# Bulk Branch Assignment Guide

**User:** Prom Kevita  
**Staff Code:** COC867740  
**Email:** kevitap@METFONE.COM.KH  
**Role to Assign:** Chief Accountant of Company  
**Website:** https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung

---

## 🎯 Goal

Assign **ALL 44 branches** to user Prom Kevita with role "Chief Accountant of Company" automatically instead of clicking 44 times manually.

---

## ✅ RECOMMENDED: Use AUTO_ASSIGN_FIXED.js

Based on the actual HTML structure of your page:
- Branch dropdown: `<select id="branchDropdown" name="branchCode">`
- Role dropdown: `<select id="roleDropdown" name="roleId">`
- Add button: `<button id="btnAddBranch">Add</button>`

This script will:
1. Loop through all 44 branches
2. For each branch:
   - Set branch dropdown value
   - Set role dropdown to "Chief Accountant of Company"
   - Click Add button
   - Wait for save to complete
3. Show success summary

### Steps:

1. **Go to the user management page:**
   ```
   https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung
   ```

2. **Find and open Prom Kevita's user detail page**
   - Click on user "Prom Kevita (COC867740)"
   - You should see the branch assignment section with dropdowns

3. **Open Browser Console:**
   - Press `F12` on keyboard
   - Click on "Console" tab at the top

4. **Copy and paste the script:**
   - Open file: **`AUTO_ASSIGN_FIXED.js`** ⭐ **USE THIS ONE**
   - Copy ALL the content (Ctrl+A, Ctrl+C)
   - Paste into the Browser Console (Ctrl+V)
   - Press `Enter`

5. **Watch it work!**
   - The script will automatically assign all 44 branches
   - Takes about 35-40 seconds (800ms delay between each)
   - You'll see logs showing progress:
     ```
     [1/44] Processing KANP001...
        ✓ Selected branch: KANP001 - Kandal
        ✓ Selected role: Chief Accountant of Company
        ✓ Clicked Add button
        ✅ KANP001 assigned successfully!
     ```

6. **Done! 🎉**
   - Script will show final summary
   - All 44 branches assigned with "Chief Accountant of Company" role

---

## 🔍 Alternative: Debug First (If Script Fails)

If `AUTO_ASSIGN_FIXED.js` doesn't work, run this first to check what's on the page:

### Steps:

1. **Open Browser Console (F12 → Console tab)**

2. **Copy and paste DEBUG_FIND_FORM.js:**
   - Open file: `DEBUG_FIND_FORM.js`
   - Copy all content
   - Paste in Console and press Enter

3. **Check the output:**
   - Look for "SELECT dropdowns" section
   - Look for "BUTTONS" section
   - Verify you see:
     - Branch dropdown with ID `branchDropdown` containing 44 branches
     - Role dropdown with ID `roleDropdown` containing "Chief Accountant of Company"
     - Add button with ID `btnAddBranch`

4. **If elements are different:**
   - Take note of the actual IDs/names shown
   - Update `AUTO_ASSIGN_FIXED.js` with the correct selectors
   - Or let me know what you see

---

## 📋 All 44 Branches (What Will Be Assigned)

### Zone 1 (17 branches):
- KANP001, PNPP001, PNPP002, PNPP003, PNPP004, PNPP005, PNPP006
- PNPP007, PNPP008, PNPP009, PNPP010, PNPP011, PNPP012, PNPP013
- PNPP014, PREP001, SVAP001

### Zone 2 (5 branches):
- KAMP001, KOHP001, SIHP001, SPEP001, TAKP001

### Zone 3 (4 branches):
- BANP001, BATP001, CHHP001, PURP001

### Zone 4 (4 branches):
- ODDP001, PRHP001, SIEP001, THOP001

### Zone 5 (9 branches):
- CHAP001, KRAP001, TBKP001, ROTS001, MONS001, STUS001, STUP001, ROTP001, MONP001

**Total: 44 branches**

---

## 📄 Available Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| **AUTO_ASSIGN_FIXED.js** ⭐ | Standard HTML selects | **USE THIS FIRST** - Works with branchDropdown/roleDropdown |
| FINAL_AUTO_ASSIGN.js | Ant Design modal | If page uses departmentCode/roleCode search inputs |
| DEBUG_FIND_FORM.js | Debugging helper | Run first if you're not sure which script to use |
| AUTO_ASSIGN_BRANCH_AND_ROLE.js | Legacy version | Old version, use AUTO_ASSIGN_FIXED.js instead |

---

## 🔧 Troubleshooting

### Problem: "Branch dropdown not found"
**Solution:** 
1. Make sure you're on the user detail page (not the user list)
2. Scroll to the branch assignment section
3. Run `DEBUG_FIND_FORM.js` to see what elements exist

### Problem: "Role not found in dropdown"
**Solution:** 
1. Check if role is named differently (e.g., "Accountant" vs "Chief Accountant of Company")
2. Look at the console output showing available roles
3. Manually check the role dropdown to see exact text

### Problem: "Script runs but nothing happens"
**Solution:**
1. Check console for error messages (red text)
2. Look for "✅ Successfully assigned" messages
3. Scroll down on the page to see if branches were added
4. Refresh the page and check if branches are saved

### Problem: "Some branches failed"
**Solution:**
1. Script will show "❌ Failed branches: XXXP001, YYYP001"
2. Manually assign the failed branches
3. Or run the script again (it will process all 44 again)

---

## 💡 Tips

1. **Make sure you're on Prom Kevita's user page** - Not just the user list
2. **Keep console open** - You'll see exactly what the script is doing
3. **Be patient** - Takes ~35-40 seconds to assign all 44 branches
4. **Check the page after** - Scroll down to verify branches were added
5. **Refresh if needed** - Sometimes page needs refresh to show changes

---

## ✅ Success Checklist

After running the script:
- [ ] Saw progress logs: `[1/44] Processing KANP001...`
- [ ] Saw final summary: `✅ Successfully assigned: 44 branches`
- [ ] Scrolled down to see all 44 branches listed
- [ ] Each branch shows role "Chief Accountant of Company"
- [ ] User "Prom Kevita" now has access to all 44 branches

---

## 📸 What You Should See

**Console Output (Success):**
```
🚀 AUTO ASSIGN FIXED - STANDARD HTML SELECT VERSION
====================================================================================================
User: Prom Kevita (COC867740)
Role: Chief Accountant of Company
====================================================================================================

📍 Starting assignment of 44 branches...

[1/44] Processing KANP001...
   ✓ Selected branch: KANP001 - Kandal
   ✓ Selected role: Chief Accountant of Company
   ✓ Clicked Add button
   ✅ KANP001 assigned successfully!

[2/44] Processing PNPP001...
   ✓ Selected branch: PNPP001 - Phnom Penh
   ✓ Selected role: Chief Accountant of Company
   ✓ Clicked Add button
   ✅ PNPP001 assigned successfully!

... (continues for all 44 branches)

====================================================================================================
🎉 ASSIGNMENT COMPLETE!
====================================================================================================
✅ Successfully assigned: 44 branches
❌ Failed: 0 branches
📊 Total processed: 44 branches
====================================================================================================

🎉🎉🎉 ALL 44 BRANCHES ASSIGNED SUCCESSFULLY! 🎉🎉🎉
✅ User Prom Kevita (COC867740) now has access to all branches!
✅ Role: Chief Accountant of Company
```

---

**Estimated Time:** 35-40 seconds (vs 10+ minutes manually)  
**Difficulty:** Easy (just copy and paste!)  
**Risk:** Low (assignments can be removed if needed)

🎉 **Good luck!**
