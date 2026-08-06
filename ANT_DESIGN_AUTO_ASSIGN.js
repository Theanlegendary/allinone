/**
 * AUTO ASSIGN FOR ANT DESIGN UI
 * 
 * This script works with Ant Design React components
 * 
 * INSTRUCTIONS:
 * 1. Go to user list page: https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung
 * 2. Click on user "Prom Kevita" (COC867740) to open their detail/edit page
 * 3. Scroll down to find the "Branch Assignment" section
 * 4. Open Console (F12)
 * 5. Paste this script
 * 6. Press Enter
 */

(async function autoAssignAntDesign() {
    console.log("🚀 AUTO ASSIGN - ANT DESIGN VERSION");
    console.log("=" .repeat(100));
    
    // First, let's find what's on the current page
    console.log("\n🔍 Analyzing current page...\n");
    
    // Check for Ant Design Select components
    const antSelects = document.querySelectorAll('.ant-select');
    console.log(`Found ${antSelects.length} Ant Design Select components`);
    
    if (antSelects.length === 0) {
        console.log("\n❌ No Ant Design select components found!");
        console.log("📋 Make sure you:");
        console.log("   1. Clicked on user 'Prom Kevita' to open their profile");
        console.log("   2. Are on the user edit/detail page (not the list page)");
        console.log("   3. The branch assignment form is visible");
        console.log("\n💡 After doing the above, run this script again.");
        return;
    }
    
    // Show what selects we found
    antSelects.forEach((sel, i) => {
        const label = sel.closest('.ant-form-item')?.querySelector('.ant-form-item-label')?.textContent || 'Unknown';
        const value = sel.querySelector('.ant-select-selection-item')?.textContent || 'Empty';
        console.log(`  ${i+1}. Select: "${label}" - Current value: "${value}"`);
    });
    
    // Find Ant Design buttons
    const antButtons = document.querySelectorAll('.ant-btn');
    console.log(`\nFound ${antButtons.length} Ant Design buttons:`);
    antButtons.forEach((btn, i) => {
        const text = btn.textContent.trim();
        if (text && text.length < 50) {
            console.log(`  ${i+1}. Button: "${text}"`);
        }
    });
    
    console.log("\n" + "=".repeat(100));
    console.log("\n📝 NEXT STEPS:");
    console.log("   1. Look at the selects and buttons listed above");
    console.log("   2. Find which select is for 'Branch' and which is for 'Role'");
    console.log("   3. Find the 'Add' or 'Save' button");
    console.log("   4. Take a screenshot and share it if you need help");
    console.log("\n💡 TIP: Ant Design uses custom dropdowns that open when clicked.");
    console.log("   We need to simulate clicks to open them and select options.");
    
    // Try to find branch and role selects
    console.log("\n🔍 Looking for Branch and Role selects...\n");
    
    let branchSelect = null;
    let roleSelect = null;
    
    antSelects.forEach(sel => {
        const formItem = sel.closest('.ant-form-item');
        if (!formItem) return;
        
        const label = formItem.querySelector('.ant-form-item-label')?.textContent?.toLowerCase() || '';
        
        if (label.includes('branch') || label.includes('chi nhánh') || label.includes('សាខា')) {
            branchSelect = sel;
            console.log(`✓ Found branch select: ${formItem.querySelector('.ant-form-item-label')?.textContent}`);
        }
        
        if (label.includes('role') || label.includes('vai trò') || label.includes('តួនាទី') || label.includes('chức vụ')) {
            roleSelect = sel;
            console.log(`✓ Found role select: ${formItem.querySelector('.ant-form-item-label')?.textContent}`);
        }
    });
    
    if (!branchSelect || !roleSelect) {
        console.log("\n❌ Could not auto-detect branch and role selects");
        console.log("📋 Please identify them manually from the list above");
        console.log("\n💡 You may need to scroll down to see the branch assignment form");
        return;
    }
    
    console.log("\n✅ Found both branch and role selects!");
    console.log("🎯 Ready to start assignment process");
    
    // All 44 branches
    const branches = [
        'KANP001', 'PNPP001', 'PNPP002', 'PNPP003', 'PNPP004', 'PNPP005', 
        'PNPP006', 'PNPP007', 'PNPP008', 'PNPP009', 'PNPP010', 'PNPP011', 
        'PNPP012', 'PNPP013', 'PNPP014', 'PREP001', 'SVAP001',
        'KAMP001', 'KOHP001', 'SIHP001', 'SPEP001', 'TAKP001',
        'BANP001', 'BATP001', 'CHHP001', 'PURP001',
        'ODDP001', 'PRHP001', 'SIEP001', 'THOP001',
        'CHAP001', 'KRAP001', 'TBKP001', 'ROTS001', 'MONS001', 
        'STUS001', 'STUP001', 'ROTP001', 'MONP001'
    ];
    
    console.log(`\n📋 Will assign ${branches.length} branches`);
    console.log("⚠️  This script found the form elements but cannot auto-click Ant Design dropdowns reliably.");
    console.log("💡 You may need to manually click and select, or use an API approach instead.");
    
    // Try to click the branch select to see what happens
    console.log("\n🧪 Testing: Clicking branch select...");
    branchSelect.click();
    
    await new Promise(r => setTimeout(r, 500));
    
    // Check if dropdown opened
    const dropdown = document.querySelector('.ant-select-dropdown:not(.ant-select-dropdown-hidden)');
    if (dropdown) {
        console.log("✓ Dropdown opened! We can see the options:");
        const options = dropdown.querySelectorAll('.ant-select-item-option');
        console.log(`  Found ${options.length} options in dropdown`);
        
        if (options.length > 0) {
            console.log("  First 5 options:");
            Array.from(options).slice(0, 5).forEach((opt, i) => {
                console.log(`    ${i+1}. ${opt.textContent}`);
            });
        }
    } else {
        console.log("❌ Dropdown did not open");
    }
    
    console.log("\n" + "=".repeat(100));
    console.log("⚠️  MANUAL APPROACH RECOMMENDED");
    console.log("=" .repeat(100));
    console.log("\nSince this uses Ant Design React components, the easiest way is:");
    console.log("1. Find if there's a 'Select All Branches' checkbox");
    console.log("2. Or contact the system admin to do a bulk SQL update");
    console.log("3. Or use the API if you have access to it");
    
})();
