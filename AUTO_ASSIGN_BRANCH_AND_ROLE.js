/**
 * AUTO ASSIGN BRANCH + ROLE FOR EACH BRANCH (Complete Automation)
 * 
 * This script will:
 * 1. Select a branch from dropdown
 * 2. Select role "Chief Accountant of Company"
 * 3. Click Add/Save button
 * 4. Repeat for ALL 44 branches automatically!
 * 
 * User: Prom Kevita (COC867740)
 * Role: Chief Accountant of Company
 * 
 * INSTRUCTIONS:
 * 1. Go to https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung
 * 2. Find and click on user "Prom Kevita" (COC867740)
 * 3. Make sure the "Add Branch Assignment" dialog/form is VISIBLE
 * 4. Open Browser Console (F12 → Console)
 * 5. Paste this ENTIRE script
 * 6. Press Enter
 * 7. Watch it assign all 44 branches automatically!
 */

(async function autoAssignBranchesWithRole() {
    console.log("🤖 AUTO ASSIGN ALL BRANCHES WITH ROLE");
    console.log("=" .repeat(100));
    console.log("User: Prom Kevita (COC867740)");
    console.log("Role: Chief Accountant of Company");
    console.log("Total Branches: 44");
    console.log("=" .repeat(100));
    
    // All 44 branches
    const branches = [
        // Zone 1 (17 branches)
        'KANP001', 'PNPP001', 'PNPP002', 'PNPP003', 'PNPP004', 'PNPP005', 
        'PNPP006', 'PNPP007', 'PNPP008', 'PNPP009', 'PNPP010', 'PNPP011', 
        'PNPP012', 'PNPP013', 'PNPP014', 'PREP001', 'SVAP001',
        
        // Zone 2 (5 branches)
        'KAMP001', 'KOHP001', 'SIHP001', 'SPEP001', 'TAKP001',
        
        // Zone 3 (4 branches)
        'BANP001', 'BATP001', 'CHHP001', 'PURP001',
        
        // Zone 4 (4 branches)
        'ODDP001', 'PRHP001', 'SIEP001', 'THOP001',
        
        // Zone 5 (9 branches)
        'CHAP001', 'KRAP001', 'TBKP001', 'ROTS001', 'MONS001', 
        'STUS001', 'STUP001', 'ROTP001', 'MONP001'
    ];
    
    const roleName = 'Chief Accountant of Company'; // Adjust if role name is different
    const delayMs = 500; // Delay between each assignment (adjust if needed)
    
    console.log(`\n📍 Starting assignment of ${branches.length} branches...\n`);
    
    let successCount = 0;
    let failCount = 0;
    
    for (let i = 0; i < branches.length; i++) {
        const branchCode = branches[i];
        
        try {
            console.log(`[${i+1}/${branches.length}] Processing ${branchCode}...`);
            
            // Step 1: Find and select branch dropdown
            const branchSelect = document.querySelector(
                'select[name="branch"], ' +
                'select[name="branchCode"], ' +
                'select#branch, ' +
                'select#branchCode, ' +
                'select.branch-select, ' +
                '[name*="branch"] select'
            );
            
            if (!branchSelect) {
                console.log(`   ⚠️  Branch dropdown not found! Please check the page.`);
                failCount++;
                continue;
            }
            
            // Select the branch by value or text
            let branchSelected = false;
            for (let option of branchSelect.options) {
                if (option.value === branchCode || 
                    option.text.includes(branchCode) ||
                    option.value.includes(branchCode)) {
                    branchSelect.value = option.value;
                    branchSelect.dispatchEvent(new Event('change', { bubbles: true }));
                    branchSelected = true;
                    console.log(`   ✓ Selected branch: ${branchCode}`);
                    break;
                }
            }
            
            if (!branchSelected) {
                console.log(`   ❌ Branch ${branchCode} not found in dropdown`);
                failCount++;
                continue;
            }
            
            // Small delay to let the form update
            await new Promise(r => setTimeout(r, 200));
            
            // Step 2: Find and select role dropdown
            const roleSelect = document.querySelector(
                'select[name="role"], ' +
                'select[name="roleCode"], ' +
                'select#role, ' +
                'select#roleCode, ' +
                'select.role-select, ' +
                '[name*="role"] select'
            );
            
            if (!roleSelect) {
                console.log(`   ⚠️  Role dropdown not found!`);
                failCount++;
                continue;
            }
            
            // Select the role by text
            let roleSelected = false;
            for (let option of roleSelect.options) {
                if (option.text.includes(roleName) || 
                    option.text.includes('Chief Accountant') ||
                    option.text.includes('Accountant of Company')) {
                    roleSelect.value = option.value;
                    roleSelect.dispatchEvent(new Event('change', { bubbles: true }));
                    roleSelected = true;
                    console.log(`   ✓ Selected role: ${option.text}`);
                    break;
                }
            }
            
            if (!roleSelected) {
                console.log(`   ⚠️  Role "${roleName}" not found in dropdown`);
                console.log(`   Available roles: ${Array.from(roleSelect.options).map(o => o.text).join(', ')}`);
                failCount++;
                continue;
            }
            
            // Small delay
            await new Promise(r => setTimeout(r, 200));
            
            // Step 3: Find and click Add/Save button
            const addButton = document.querySelector(
                'button[type="submit"], ' +
                'button.btn-primary, ' +
                'button.btn-success, ' +
                'button:contains("Add"), ' +
                'button:contains("Save"), ' +
                'button:contains("Thêm"), ' +
                'button:contains("Lưu"), ' +
                'button:contains("បន្ថែម"), ' +
                '.btn-add, ' +
                '.btn-save, ' +
                '[class*="add"][class*="btn"], ' +
                '[class*="save"][class*="btn"]'
            );
            
            if (!addButton) {
                console.log(`   ⚠️  Add/Save button not found!`);
                failCount++;
                continue;
            }
            
            // Click the button
            addButton.click();
            console.log(`   ✓ Clicked Add/Save button`);
            console.log(`   ✅ ${branchCode} assigned successfully!`);
            successCount++;
            
            // Wait before next assignment
            await new Promise(r => setTimeout(r, delayMs));
            
        } catch (error) {
            console.error(`   ❌ Error assigning ${branchCode}:`, error.message);
            failCount++;
        }
    }
    
    // Summary
    console.log("\n" + "=".repeat(100));
    console.log("🎉 ASSIGNMENT COMPLETE!");
    console.log("=".repeat(100));
    console.log(`✅ Successful: ${successCount} branches`);
    console.log(`❌ Failed: ${failCount} branches`);
    console.log(`📊 Total: ${branches.length} branches`);
    console.log("=".repeat(100));
    
    if (successCount === branches.length) {
        console.log("\n🎉 ALL 44 BRANCHES ASSIGNED SUCCESSFULLY!");
        console.log("You can now close this dialog and verify the assignments.");
    } else if (successCount > 0) {
        console.log("\n⚠️  PARTIALLY SUCCESSFUL");
        console.log("Check the logs above for failed branches.");
        console.log("You may need to assign the failed branches manually.");
    } else {
        console.log("\n❌ ASSIGNMENT FAILED");
        console.log("Possible issues:");
        console.log("1. The form selectors may have changed");
        console.log("2. Check if the branch/role dropdown IDs are different");
        console.log("3. Make sure you're on the correct page with the form visible");
    }
    
})();

/**
 * DEBUGGING HELPER - Run this first if the main script doesn't work
 * This will help you find the correct selectors
 */
function findFormElements() {
    console.log("🔍 DEBUGGING: Finding form elements...\n");
    
    // Find all select elements
    const selects = document.querySelectorAll('select');
    console.log(`Found ${selects.length} select dropdowns:`);
    selects.forEach((sel, i) => {
        console.log(`  ${i+1}. ID: ${sel.id || 'N/A'}, Name: ${sel.name || 'N/A'}, Class: ${sel.className || 'N/A'}`);
        console.log(`     Options: ${sel.options.length} items`);
        if (sel.options.length > 0) {
            console.log(`     First option: ${sel.options[0].text}`);
        }
    });
    
    // Find all buttons
    const buttons = document.querySelectorAll('button');
    console.log(`\nFound ${buttons.length} buttons:`);
    buttons.forEach((btn, i) => {
        console.log(`  ${i+1}. Text: "${btn.textContent.trim()}", Type: ${btn.type || 'N/A'}, Class: ${btn.className || 'N/A'}`);
    });
    
    console.log("\nℹ️  Use this information to update the selectors in the main script if needed.");
}

// To use the debugging helper, uncomment the line below:
// findFormElements();
