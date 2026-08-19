/**
 * AUTO CLICK ALL BRANCHES (UI Automation)
 * 
 * This script will automatically click checkboxes or buttons
 * to assign all branches to the user.
 * 
 * INSTRUCTIONS:
 * 1. Go to https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung
 * 2. Click on user "Prom Kevita" (COC867740)
 * 3. Open the branch assignment dialog/page
 * 4. Open Browser Console (Press F12 → Console tab)
 * 5. Copy and paste this script
 * 6. Press Enter
 */

(function autoClickAllBranches() {
    console.log("🤖 AUTO-CLICKING ALL BRANCHES");
    console.log("=" .repeat(80));
    
    // Find all checkboxes for branches
    const checkboxes = document.querySelectorAll(
        'input[type="checkbox"][data-branch], ' +
        'input[type="checkbox"].branch-checkbox, ' +
        '.branch-list input[type="checkbox"], ' +
        '[class*="branch"] input[type="checkbox"]'
    );
    
    if (checkboxes.length === 0) {
        console.log("❌ No branch checkboxes found!");
        console.log("   Try these steps:");
        console.log("   1. Make sure the branch assignment dialog is open");
        console.log("   2. Look for a 'Select All' button and click it manually");
        console.log("   3. Or try the API script instead");
        return;
    }
    
    console.log(`✅ Found ${checkboxes.length} branch checkboxes`);
    console.log("\n📍 Clicking all checkboxes...\n");
    
    let clickedCount = 0;
    
    checkboxes.forEach((checkbox, index) => {
        if (!checkbox.checked) {
            checkbox.click();
            clickedCount++;
            console.log(`   [${index + 1}/${checkboxes.length}] ✅ Checked`);
        } else {
            console.log(`   [${index + 1}/${checkboxes.length}] ⚪ Already checked`);
        }
    });
    
    console.log("\n" + "=".repeat(80));
    console.log(`📊 Clicked ${clickedCount} checkboxes out of ${checkboxes.length} total`);
    console.log("=".repeat(80));
    
    // Try to find and click the "Save" or "Submit" button
    console.log("\n🔍 Looking for Save/Submit button...");
    
    const saveButtons = document.querySelectorAll(
        'button[type="submit"], ' +
        'button.btn-primary, ' +
        'button.btn-success, ' +
        'button:contains("Save"), ' +
        'button:contains("Submit"), ' +
        'button:contains("Confirm"), ' +
        'button:contains("Lưu"), ' +
        'button:contains("បញ្ជូន")'
    );
    
    if (saveButtons.length > 0) {
        console.log(`   Found ${saveButtons.length} possible save buttons`);
        console.log("   ⚠️  Please click the SAVE button manually to confirm!");
    } else {
        console.log("   ⚠️  Save button not found - please save manually");
    }
    
    console.log("\n🎉 DONE! All branches selected.");
    console.log("   👉 Don't forget to click SAVE/SUBMIT button!");
    
})();
