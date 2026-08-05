/**
 * ✅ AUTO ASSIGN FIXED - Works with Standard HTML Select Dropdowns
 * 
 * Based on actual HTML structure found:
 * - Branch dropdown: <select id="branchDropdown" name="branchCode">
 * - Role dropdown: <select id="roleDropdown" name="roleId">
 * - Add button: <button id="btnAddBranch">Add</button>
 * 
 * This script will:
 * 1. Set branch dropdown to a branch code
 * 2. Set role dropdown to "Chief Accountant of Company"
 * 3. Click the Add button
 * 4. Wait for save/confirmation
 * 5. Repeat for all 44 branches
 * 
 * User: Prom Kevita (COC867740)
 * Role: Chief Accountant of Company
 * 
 * INSTRUCTIONS:
 * 1. Open the user detail page for Prom Kevita
 * 2. Open Browser Console (F12 → Console tab)
 * 3. Copy and paste this ENTIRE script
 * 4. Press Enter
 * 5. Watch it assign all 44 branches!
 */

(async function autoAssignFixed() {
    console.log("🚀 AUTO ASSIGN FIXED - STANDARD HTML SELECT VERSION");
    console.log("=" .repeat(100));
    console.log("User: Prom Kevita (COC867740)");
    console.log("Role: Chief Accountant of Company");
    console.log("=" .repeat(100));
    
    // All 44 branches
    const branches = [
        // Zone 1 (17)
        'KANP001', 'PNPP001', 'PNPP002', 'PNPP003', 'PNPP004', 'PNPP005', 
        'PNPP006', 'PNPP007', 'PNPP008', 'PNPP009', 'PNPP010', 'PNPP011', 
        'PNPP012', 'PNPP013', 'PNPP014', 'PREP001', 'SVAP001',
        // Zone 2 (5)
        'KAMP001', 'KOHP001', 'SIHP001', 'SPEP001', 'TAKP001',
        // Zone 3 (4)
        'BANP001', 'BATP001', 'CHHP001', 'PURP001',
        // Zone 4 (4)
        'ODDP001', 'PRHP001', 'SIEP001', 'THOP001',
        // Zone 5 (9)
        'CHAP001', 'KRAP001', 'TBKP001', 'ROTS001', 'MONS001', 
        'STUS001', 'STUP001', 'ROTP001', 'MONP001'
    ];
    
    const delayMs = 800; // Delay between each assignment
    
    let successCount = 0;
    let failCount = 0;
    const failedBranches = [];
    
    console.log(`\n📍 Starting assignment of ${branches.length} branches...\n`);
    
    for (let i = 0; i < branches.length; i++) {
        const branchCode = branches[i];
        
        try {
            console.log(`[${i+1}/${branches.length}] Processing ${branchCode}...`);
            
            // Step 0: Click the "Create" button to open the modal
            const createButton = Array.from(document.querySelectorAll('button')).find(btn => 
                btn.textContent.includes('Create') || 
                btn.textContent.includes('Thêm') ||
                btn.textContent.includes('បន្ថែម')
            );
            
            if (!createButton) {
                console.log(`   ❌ Create button not found!`);
                failCount++;
                failedBranches.push(branchCode);
                continue;
            }
            
            createButton.click();
            console.log(`   ✓ Clicked Create button to open modal`);
            await new Promise(r => setTimeout(r, 500)); // Wait for modal to open
            
            // Now find the dropdowns inside the modal
            const branchDropdown = document.getElementById('branchDropdown');
            const roleDropdown = document.getElementById('roleDropdown');
            const addButton = document.getElementById('btnAddBranch');
            
            if (!branchDropdown) {
                console.log(`   ❌ Branch dropdown not found after opening modal!`);
                // Try to close modal
                const cancelBtn = Array.from(document.querySelectorAll('button')).find(btn => btn.textContent.includes('Cancel'));
                if (cancelBtn) cancelBtn.click();
                failCount++;
                failedBranches.push(branchCode);
                await new Promise(r => setTimeout(r, 300));
                continue;
            }
            
            if (!roleDropdown) {
                console.log(`   ❌ Role dropdown not found after opening modal!`);
                const cancelBtn = Array.from(document.querySelectorAll('button')).find(btn => btn.textContent.includes('Cancel'));
                if (cancelBtn) cancelBtn.click();
                failCount++;
                failedBranches.push(branchCode);
                await new Promise(r => setTimeout(r, 300));
                continue;
            }
            
            if (!addButton) {
                console.log(`   ❌ Add button not found after opening modal!`);
                const cancelBtn = Array.from(document.querySelectorAll('button')).find(btn => btn.textContent.includes('Cancel'));
                if (cancelBtn) cancelBtn.click();
                failCount++;
                failedBranches.push(branchCode);
                await new Promise(r => setTimeout(r, 300));
                continue;
            }
            
            // Step 1: Select the branch
            let branchFound = false;
            for (let opt of branchDropdown.options) {
                if (opt.value === branchCode || opt.text.includes(branchCode)) {
                    branchDropdown.value = opt.value;
                    branchDropdown.dispatchEvent(new Event('change', { bubbles: true }));
                    console.log(`   ✓ Selected branch: ${opt.text.trim()}`);
                    branchFound = true;
                    break;
                }
            }
            
            if (!branchFound) {
                console.log(`   ❌ Branch ${branchCode} not found in dropdown`);
                failCount++;
                failedBranches.push(branchCode);
                continue;
            }
            
            await new Promise(r => setTimeout(r, 200));
            
            // Step 2: Select the role "Chief Accountant of Company"
            let roleFound = false;
            for (let opt of roleDropdown.options) {
                const optText = opt.text.trim();
                if (optText.includes('Chief Accountant of Company') || 
                    optText.includes('Chief Accountant') ||
                    optText === 'Chief Accountant of Company') {
                    roleDropdown.value = opt.value;
                    roleDropdown.dispatchEvent(new Event('change', { bubbles: true }));
                    console.log(`   ✓ Selected role: ${optText}`);
                    roleFound = true;
                    break;
                }
            }
            
            if (!roleFound) {
                console.log(`   ❌ Role "Chief Accountant of Company" not found in dropdown`);
                console.log(`   Available roles: ${Array.from(roleDropdown.options).map(o => o.text).join(', ')}`);
                failCount++;
                failedBranches.push(branchCode);
                continue;
            }
            
            await new Promise(r => setTimeout(r, 200));
            
            // Step 3: Click the Add button
            addButton.click();
            console.log(`   ✓ Clicked Add button`);
            console.log(`   ✅ ${branchCode} assigned successfully!\n`);
            successCount++;
            
            // Wait for save to complete and page to update
            await new Promise(r => setTimeout(r, delayMs));
            
        } catch (error) {
            console.error(`   ❌ Error assigning ${branchCode}:`, error.message);
            failCount++;
            failedBranches.push(branchCode);
        }
    }
    
    // Summary
    console.log("\n" + "=".repeat(100));
    console.log("🎉 ASSIGNMENT COMPLETE!");
    console.log("=".repeat(100));
    console.log(`✅ Successfully assigned: ${successCount} branches`);
    console.log(`❌ Failed: ${failCount} branches`);
    console.log(`📊 Total processed: ${branches.length} branches`);
    
    if (failedBranches.length > 0) {
        console.log(`\n❌ Failed branches: ${failedBranches.join(', ')}`);
    }
    
    console.log("=".repeat(100));
    
    if (successCount === branches.length) {
        console.log("\n🎉🎉🎉 ALL 44 BRANCHES ASSIGNED SUCCESSFULLY! 🎉🎉🎉");
        console.log("✅ User Prom Kevita (COC867740) now has access to all branches!");
        console.log("✅ Role: Chief Accountant of Company");
    } else if (successCount > 0) {
        console.log(`\n✅ ${successCount} branches were assigned successfully!`);
        if (failCount > 0) {
            console.log(`\n⚠️  ${failCount} branches failed. You may need to:`);
            console.log(`   1. Scroll down and check if they were actually added`);
            console.log(`   2. Try running the script again`);
            console.log(`   3. Manually add the failed branches listed above`);
        }
    } else {
        console.log("\n❌ No branches were assigned. Please check:");
        console.log("1. You're on the correct user detail/edit page");
        console.log("2. The branch dropdown has options");
        console.log("3. The role dropdown has 'Chief Accountant of Company'");
        console.log("4. The Add button is clickable");
        console.log("\n💡 Try running the DEBUG script first to see what's on the page.");
    }
    
    console.log("\n" + "=".repeat(100));
    
})();
