# Complete Bulk Branch + Role Assignment Guide

**User:** Prom Kevita  
**Staff Code:** COC867740  
**Email:** kevitap@METFONE.COM.KH  
**Role:** Chief Accountant of Company  
**Branches:** ALL 44 branches (5 zones)

---

## 🎯 Goal

Assign **all 44 branches** with role **"Chief Accountant of Company"** to user Prom Kevita automatically instead of doing it manually 44 times.

---

## 🚀 Method: Auto-Select Branch + Role + Save (Complete Automation)

### ⏱️ Time Comparison:
- **Manual:** ~10-15 minutes (44 branches × ~20 seconds each)
- **Automated:** ~30 seconds total! ⚡

---

## 📋 Step-by-Step Instructions

### Step 1: Navigate to User Management
1. Open browser and go to:
   ```
   https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung
   ```

2. Find user **"Prom Kevita"** in the list
   - Search by name: `Prom Kevita`
   - Or search by staff code: `COC867740`

3. **Click on the user** to open their profile

---

### Step 2: Open Branch Assignment Form

The page should have a section for "Branch Assignments" or "Assign Branches". You should see:

- A **dropdown to select branch** (shows branch codes like PNPP001, KANP001, etc.)
- A **dropdown to select role** (shows roles like "Chief Accountant of Company")
- An **Add/Save button** to save the assignment

**Important:** Make sure this form is **VISIBLE** before running the script!

---

### Step 3: Open Browser Console

1. Press `F12` on your keyboard
2. Click on the **"Console"** tab at the top
3. You should see a blank console where you can type commands

---

### Step 4: Run the Auto-Assignment Script

1. Open the file: **`AUTO_ASSIGN_BRANCH_AND_ROLE.js`**
2. **Select ALL** the content (Ctrl+A)
3. **Copy** it (Ctrl+C)
4. **Paste** into the Browser Console (Ctrl+V)
5. Press **Enter**

---

### Step 5: Watch the Magic! ✨

The script will now automatically:

```
[1/44] Processing KANP001...
   ✓ Selected branch: KANP001
   ✓ Selected role: Chief Accountant of Company
   ✓ Clicked Add/Save button
   ✅ KANP001 assigned successfully!

[2/44] Processing PNPP001...
   ✓ Selected branch: PNPP001
   ✓ Selected role: Chief Accountant of Company
   ✓ Clicked Add/Save button
   ✅ PNPP001 assigned successfully!

... (continues for all 44 branches)

[44/44] Processing MONP001...
   ✓ Selected branch: MONP001
   ✓ Selected role: Chief Accountant of Company
   ✓ Clicked Add/Save button
   ✅ MONP001 assigned successfully!

============================================================
🎉 ASSIGNMENT COMPLETE!
============================================================
✅ Successful: 44 branches
❌ Failed: 0 branches
📊 Total: 44 branches
============================================================

🎉 ALL 44 BRANCHES ASSIGNED SUCCESSFULLY!
```

---

### Step 6: Verify

After the script completes:
1. Scroll down to see all assigned branches
2. Verify that each branch has role "Chief Accountant of Company"
3. Done! 🎉

---

## 🔧 Troubleshooting

### Problem 1: "Branch dropdown not found"

**Cause:** The form is not visible or the HTML structure is different.

**Solution:**
1. Make sure the branch assignment form is open
2. Run the debugging helper:
   ```javascript
   findFormElements();
   ```
3. This will show you all dropdowns and buttons on the page
4. Update the script's selectors if needed

---

### Problem 2: "Role not found in dropdown"

**Cause:** The role name might be different.

**Solution:**
1. Check the exact role name in the dropdown
2. It might be:
   - "Chief Accountant of Company"
   - "Chief Accountant"
   - "Accountant of Company"
   - Or in Khmer: "អ្នកគណនេយ្យក្រុមហ៊ុន"
3. Update line 69 in the script with the exact role name:
   ```javascript
   const roleName = 'YOUR EXACT ROLE NAME HERE';
   ```

---

### Problem 3: Script runs but branches aren't saved

**Cause:** The Save button might not be triggering correctly.

**Solution:**
1. The script might be running too fast
2. Increase the delay on line 62:
   ```javascript
   const delayMs = 1000; // Increase from 500 to 1000ms
   ```
3. Run the script again

---

### Problem 4: Need to find correct selectors

**Solution:**
Run the debugging helper first:

```javascript
function findFormElements() {
    console.log("🔍 DEBUGGING: Finding form elements...\n");
    
    const selects = document.querySelectorAll('select');
    console.log(`Found ${selects.length} select dropdowns:`);
    selects.forEach((sel, i) => {
        console.log(`  ${i+1}. ID: ${sel.id}, Name: ${sel.name}, Class: ${sel.className}`);
    });
    
    const buttons = document.querySelectorAll('button');
    console.log(`\nFound ${buttons.length} buttons:`);
    buttons.forEach((btn, i) => {
        console.log(`  ${i+1}. Text: "${btn.textContent.trim()}"}`);
    });
}

findFormElements();
```

This will show you:
- All dropdown menus (select elements)
- All buttons on the page
- Their IDs, names, and classes

Use this info to update the selectors in the main script.

---

## 📊 All 44 Branches to be Assigned

### Zone 1 (17 branches):
KANP001, PNPP001, PNPP002, PNPP003, PNPP004, PNPP005, PNPP006, PNPP007, PNPP008, PNPP009, PNPP010, PNPP011, PNPP012, PNPP013, PNPP014, PREP001, SVAP001

### Zone 2 (5 branches):
KAMP001, KOHP001, SIHP001, SPEP001, TAKP001

### Zone 3 (4 branches):
BANP001, BATP001, CHHP001, PURP001

### Zone 4 (4 branches):
ODDP001, PRHP001, SIEP001, THOP001

### Zone 5 (9 branches):
CHAP001, KRAP001, TBKP001, ROTS001, MONS001, STUS001, STUP001, ROTP001, MONP001

---

## 💡 Tips

1. **Test with one branch first:** Before running the full script, you can modify it to assign just 1-2 branches as a test.

2. **Check the console:** Keep the console open to see real-time progress and any errors.

3. **Take screenshots:** If something doesn't work, take screenshots of the page and console to help debug.

4. **Internet speed:** The script adds a 500ms delay between each assignment. If your internet is slow, increase this delay.

5. **Manual fallback:** If a few branches fail, you can always assign them manually afterward.

---

## ✅ Success Checklist

After running the script:
- [ ] Console shows "ALL 44 BRANCHES ASSIGNED SUCCESSFULLY"
- [ ] No red error messages in console
- [ ] User profile shows all 44 branch assignments
- [ ] Each branch has role "Chief Accountant of Company"
- [ ] You can click on each branch to verify the assignment

---

## 🎉 Expected Result

After successful execution:

**User:** Prom Kevita (COC867740)  
**Total Branch Assignments:** 44  
**Role for all branches:** Chief Accountant of Company

The user will now have access to view and manage data from all 44 branches across all 5 zones!

---

## 📞 Need Help?

If the script doesn't work:
1. Run `findFormElements()` in the console
2. Take a screenshot of the output
3. Take a screenshot of the page showing the form
4. Check the exact role name in the dropdown
5. Adjust the script selectors based on the findings

---

**Estimated Time:** 30-60 seconds  
**Difficulty:** Easy (just copy & paste!)  
**Risk:** Very low (assignments can be removed if needed)

🚀 **Good luck with the bulk assignment!**
