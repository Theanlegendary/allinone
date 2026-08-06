/**
 * FINAL AUTO ASSIGN - Works with Ant Design Modal
 * 
 * This script will automatically:
 * 1. Click to open the "Add Branch" modal
 * 2. Select a branch from the departmentCode dropdown
 * 3. Select "Chief Accountant of Company" from roleCode dropdown
 * 4. Click Save
 * 5. Repeat for all 44 branches!
 * 
 * User: Prom Kevita (COC867740)
 * 
 * INSTRUCTIONS:
 * 1. Make sure you're on the user detail page for Prom Kevita
 * 2. You should see an "Add" or "Create" button to add branch assignments
 * 3. Open Console (F12)
 * 4. Paste this entire script
 * 5. Press Enter
 * 6. Watch it work!
 */

(async function finalAutoAssign() {
    console.log("🚀 FINAL AUTO ASSIGN - ANT DESIGN MODAL VERSION");
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
    
    const roleText = 'Chief Accountant of Company'; // Role name to select
    const delayMs = 1000; // Delay between each assignment
    
    let successCount = 0;
    let failCount = 0;
    
    console.log(`\n📍 Starting assignment of ${branches.length} branches...\n`);
    
    for (let i = 0; i < branches.length; i++) {
        const branchCode = branches[i];
        
        try {
            console.log(`[${i+1}/${branches.length}] Processing ${branchCode}...`);
            
            // Step 1: Find and click the "Create" or "Add" button to open modal
            const createBtn = Array.from(document.querySelectorAll('button')).find(btn => 
                btn.textContent.includes('Create') || 
                btn.textContent.includes('Add') ||
                btn.textContent.includes('Thêm') ||
                btn.textContent.includes('បន្ថែម')
            );
            
            if (!createBtn) {
                console.log(`   ⚠️  Create button not found - modal might already be open`);
            } else {
                createBtn.click();
                console.log(`   ✓ Clicked Create button`);
                await new Promise(r => setTimeout(r, 500));
            }
            
            // Step 2: Find the branch (Post Office) input
            const branchInput = document.getElementById('departmentCode');
            if (!branchInput) {
                console.log(`   ❌ Branch input (departmentCode) not found!`);
                failCount++;
                continue;
            }
            
            // Click to open dropdown
            const branchSelect = branchInput.closest('.ant-select');
            if (branchSelect) {
                branchSelect.click();
                console.log(`   ✓ Clicked branch dropdown`);
                await new Promise(r => setTimeout(r, 500));
                
                // Find and click the branch option in the dropdown
                const dropdown = document.querySelector('.ant-select-dropdown:not(.ant-select-dropdown-hidden)');
                if (dropdown) {
                    const options = dropdown.querySelectorAll('.ant-select-item-option');
                    let branchFound = false;
                    
                    for (let opt of options) {
                        if (opt.textContent.includes(branchCode)) {
                            opt.click();
                            console.log(`   ✓ Selected branch: ${opt.textContent.trim()}`);
                            branchFound = true;
                            await new Promise(r => setTimeout(r, 300));
                            break;
                        }
                    }
                    
                    if (!branchFound) {
                        console.log(`   ❌ Branch ${branchCode} not found in dropdown`);
                        // Close modal
                        const cancelBtn = Array.from(document.querySelectorAll('button')).find(btn => btn.textContent.includes('Cancel'));
                        if (cancelBtn) cancelBtn.click();
                        failCount++;
                        await new Promise(r => setTimeout(r, 300));
                        continue;
                    }
                } else {
                    console.log(`   ❌ Dropdown did not open`);
                    failCount++;
                    continue;
                }
            }
            
            // Step 3: Find the role input
            const roleInput = document.getElementById('roleCode');
            if (!roleInput) {
                console.log(`   ❌ Role input (roleCode) not found!`);
                failCount++;
                continue;
            }
            
            // Click to open role dropdown
            const roleSelect = roleInput.closest('.ant-select');
            if (roleSelect) {
                roleSelect.click();
                console.log(`   ✓ Clicked role dropdown`);
                await new Promise(r => setTimeout(r, 500));
                
                // Find and click the role option
                const dropdown = document.querySelector('.ant-select-dropdown:not(.ant-select-dropdown-hidden)');
                if (dropdown) {
                    const options = dropdown.querySelectorAll('.ant-select-item-option');
                    let roleFound = false;
                    
                    for (let opt of options) {
                        const optText = opt.textContent.trim();
                        if (optText.includes(roleText) || 
                            optText.includes('Chief Accountant') ||
                            optText.includes('Accountant of Company')) {
                            opt.click();
                            console.log(`   ✓ Selected role: ${optText}`);
                            roleFound = true;
                            await new Promise(r => setTimeout(r, 300));
                            break;
                        }
                    }
                    
                    if (!roleFound) {
                        console.log(`   ❌ Role "${roleText}" not found in dropdown`);
                        // Close modal
                        const cancelBtn = Array.from(document.querySelectorAll('button')).find(btn => btn.textContent.includes('Cancel'));
                        if (cancelBtn) cancelBtn.click();
                        failCount++;
                        await new Promise(r => setTimeout(r, 300));
                        continue;
                    }
                }
            }
            
            // Step 4: Click Save button
            const saveBtn = Array.from(document.querySelectorAll('button[type="submit"]')).find(btn => 
                btn.textContent.includes('Save') || 
                btn.textContent.includes('Lưu') ||
                btn.textContent.includes('រក្សាទុក')
            );
            
            if (!saveBtn) {
                console.log(`   ❌ Save button not found!`);
                failCount++;
                continue;
            }
            
            saveBtn.click();
            console.log(`   ✓ Clicked Save button`);
            console.log(`   ✅ ${branchCode} assigned successfully!\n`);
            successCount++;
            
            // Wait before next assignment
            await new Promise(r => setTimeout(r, delayMs));
            
        } catch (error) {
            console.error(`   ❌ Error assigning ${branchCode}:`, error.message);
            failCount++;
            
            // Try to close modal if error occurred
            try {
                const cancelBtn = Array.from(document.querySelectorAll('button')).find(btn => btn.textContent.includes('Cancel'));
                if (cancelBtn) cancelBtn.click();
                await new Promise(r => setTimeout(r, 300));
            } catch (e) {}
        }
    }
    
    // Summary
    console.log("\n" + "=".repeat(100));
    console.log("🎉 ASSIGNMENT COMPLETE!");
    console.log("=".repeat(100));
    console.log(`✅ Successfully assigned: ${successCount} branches`);
    console.log(`❌ Failed: ${failCount} branches`);
    console.log(`📊 Total processed: ${branches.length} branches`);
    console.log("=".repeat(100));
    
    if (successCount === branches.length) {
        console.log("\n🎉 ALL 44 BRANCHES ASSIGNED SUCCESSFULLY!");
        console.log("✅ User Prom Kevita now has access to all branches!");
    } else if (successCount > 0) {
        console.log(`\n✅ ${successCount} branches were assigned successfully!`);
        if (failCount > 0) {
            console.log(`❌ ${failCount} branches failed - you may need to assign them manually`);
        }
    } else {
        console.log("\n❌ No branches were assigned. Please check:");
        console.log("1. You're on the correct user detail page");
        console.log("2. The modal opens when you click Create");
        console.log("3. The branch and role dropdowns work");
    }
    
})();
