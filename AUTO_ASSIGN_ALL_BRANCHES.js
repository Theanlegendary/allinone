/**
 * AUTO ASSIGN ALL BRANCHES TO USER
 * 
 * User: Prom Kevita
 * Staff Code: COC867740
 * Email: kevitap@METFONE.COM.KH
 * Role: Chief Accountant of Company
 * 
 * INSTRUCTIONS:
 * 1. Go to https://opsexpress.metfone.com.kh/quan-ly-nguoi-dung
 * 2. Find and click on user "Prom Kevita" (COC867740)
 * 3. Open Browser Console (Press F12, then click "Console" tab)
 * 4. Copy and paste this ENTIRE script into the console
 * 5. Press Enter
 * 6. Wait 5-10 seconds for all branches to be assigned!
 */

(async function autoAssignAllBranches() {
    console.log("🚀 AUTO ASSIGN ALL BRANCHES - STARTING...");
    console.log("=" .repeat(80));
    
    // Configuration
    const config = {
        staffCode: 'COC867740',
        userName: 'Prom Kevita',
        role: 'Chief Accountant of Company', // Or the exact role name from the system
        delayBetweenRequests: 100 // milliseconds between each API call
    };
    
    console.log(`📋 User: ${config.userName}`);
    console.log(`📋 Staff Code: ${config.staffCode}`);
    console.log(`📋 Role: ${config.role}`);
    console.log("=" .repeat(80));
    
    // Step 1: Get all available branches
    console.log("\n📍 Step 1: Fetching all branches...");
    
    // This will depend on your API structure - adjust the endpoint as needed
    let branches = [];
    
    // Try to get branches from the page's existing data
    try {
        // Check if branches are already loaded in the page
        const branchElements = document.querySelectorAll('[data-branch-code], .branch-item, .office-code');
        
        if (branchElements.length > 0) {
            console.log(`   Found ${branchElements.length} branches in the DOM`);
            
            branchElements.forEach((el, idx) => {
                const code = el.getAttribute('data-branch-code') || 
                           el.getAttribute('data-code') || 
                           el.textContent.trim();
                           
                branches.push({
                    code: code,
                    name: el.textContent.trim()
                });
            });
        } else {
            // If not in DOM, we need to make an API call
            console.log("   Branches not found in DOM, fetching from API...");
            
            // Adjust this API endpoint to match your system
            const response = await fetch('/api/branches', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                branches = data.branches || data.data || data;
                console.log(`   ✅ Fetched ${branches.length} branches from API`);
            } else {
                throw new Error('Failed to fetch branches from API');
            }
        }
    } catch (error) {
        console.error("   ❌ Error fetching branches:", error);
        
        // Fallback: Use your known branch list
        console.log("   Using fallback branch list from config.json...");
        branches = [
            // Zone 1 (17 branches)
            {code: 'KANP001', name: 'Kandal HUB'},
            {code: 'PNPP001', name: 'Phnom Penh HUB 1'},
            {code: 'PNPP002', name: 'Phnom Penh Branch 2'},
            {code: 'PNPP003', name: 'Toul Kork'},
            {code: 'PNPP004', name: 'Phnom Penh Branch 4'},
            {code: 'PNPP005', name: 'Phnom Penh Branch 5'},
            {code: 'PNPP006', name: 'Phnom Penh Branch 6'},
            {code: 'PNPP007', name: 'Phnom Penh Branch 7'},
            {code: 'PNPP008', name: 'Phnom Penh Branch 8'},
            {code: 'PNPP009', name: 'Phnom Penh Branch 9'},
            {code: 'PNPP010', name: 'Phnom Penh Branch 10'},
            {code: 'PNPP011', name: 'Phnom Penh Branch 11'},
            {code: 'PNPP012', name: 'Phnom Penh Branch 12'},
            {code: 'PNPP013', name: 'Phnom Penh Branch 13'},
            {code: 'PNPP014', name: 'Phnom Penh Branch 14'},
            {code: 'PREP001', name: 'Prey Veng HUB'},
            {code: 'SVAP001', name: 'Svay Rieng HUB'},
            
            // Zone 2 (5 branches)
            {code: 'KAMP001', name: 'Kampot HUB'},
            {code: 'KOHP001', name: 'Koh Kong HUB'},
            {code: 'SIHP001', name: 'Sihanoukville HUB'},
            {code: 'SPEP001', name: 'Svay Pak HUB'},
            {code: 'TAKP001', name: 'Takeo HUB'},
            
            // Zone 3 (4 branches)
            {code: 'BANP001', name: 'Banteay Meanchey HUB'},
            {code: 'BATP001', name: 'Battambang HUB'},
            {code: 'CHHP001', name: 'Kampong Chhnang HUB'},
            {code: 'PURP001', name: 'Pursat HUB'},
            
            // Zone 4 (4 branches)
            {code: 'ODDP001', name: 'Oddar Meanchey HUB'},
            {code: 'PRHP001', name: 'Preah Vihear HUB'},
            {code: 'SIEP001', name: 'Siem Reap HUB'},
            {code: 'THOP001', name: 'Kampong Thom HUB'},
            
            // Zone 5 (9 branches)
            {code: 'CHAP001', name: 'Kampong Cham HUB'},
            {code: 'KRAP001', name: 'Kratie HUB'},
            {code: 'TBKP001', name: 'Tbong Khmum HUB'},
            {code: 'ROTS001', name: 'Ratanakiri Branch'},
            {code: 'MONS001', name: 'Mondulkiri Branch'},
            {code: 'STUS001', name: 'Stung Treng Branch'},
            {code: 'STUP001', name: 'Stung Treng HUB'},
            {code: 'ROTP001', name: 'Ratanakiri HUB'},
            {code: 'MONP001', name: 'Mondulkiri HUB'}
        ];
        console.log(`   📝 Using ${branches.length} branches from fallback list`);
    }
    
    console.log(`\n✅ Total branches to assign: ${branches.length}`);
    console.log("=" .repeat(80));
    
    // Step 2: Assign each branch
    console.log("\n📍 Step 2: Assigning branches...\n");
    
    let successCount = 0;
    let failCount = 0;
    
    for (let i = 0; i < branches.length; i++) {
        const branch = branches[i];
        
        try {
            console.log(`   [${i+1}/${branches.length}] Assigning ${branch.code} - ${branch.name}...`);
            
            // Adjust this API call to match your system's endpoint
            const response = await fetch('/api/user-branch-assignment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    // Add any auth tokens if needed
                    // 'Authorization': 'Bearer YOUR_TOKEN_HERE'
                },
                body: JSON.stringify({
                    staffCode: config.staffCode,
                    branchCode: branch.code,
                    role: config.role
                })
            });
            
            if (response.ok) {
                console.log(`   ✅ Success: ${branch.code}`);
                successCount++;
            } else {
                console.log(`   ❌ Failed: ${branch.code} (Status: ${response.status})`);
                failCount++;
            }
            
            // Small delay to avoid overwhelming the server
            await new Promise(resolve => setTimeout(resolve, config.delayBetweenRequests));
            
        } catch (error) {
            console.error(`   ❌ Error assigning ${branch.code}:`, error);
            failCount++;
        }
    }
    
    // Summary
    console.log("\n" + "=".repeat(80));
    console.log("📊 ASSIGNMENT COMPLETE!");
    console.log("=".repeat(80));
    console.log(`✅ Successful: ${successCount} branches`);
    console.log(`❌ Failed: ${failCount} branches`);
    console.log(`📊 Total: ${branches.length} branches`);
    console.log("=".repeat(80));
    
    if (successCount === branches.length) {
        console.log("🎉 ALL BRANCHES ASSIGNED SUCCESSFULLY!");
    } else if (successCount > 0) {
        console.log("⚠️  PARTIALLY SUCCESSFUL - Check failed branches above");
    } else {
        console.log("❌ ASSIGNMENT FAILED - Please check API endpoint and permissions");
    }
    
    // Refresh the page to see changes
    console.log("\n🔄 Refreshing page in 3 seconds to show changes...");
    setTimeout(() => {
        location.reload();
    }, 3000);
    
})();
