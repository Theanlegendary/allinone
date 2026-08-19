/**
 * DEBUGGING HELPER - Find all form elements on the page
 * 
 * Run this in the console to see what dropdowns and buttons exist
 */

function findFormElements() {
    console.log("🔍 DEBUGGING: Finding form elements...\n");
    console.log("=" .repeat(100));
    
    // Find all select elements (dropdowns)
    const selects = document.querySelectorAll('select');
    console.log(`\n📋 Found ${selects.length} SELECT dropdowns:\n`);
    selects.forEach((sel, i) => {
        console.log(`  ${i+1}. SELECT element:`);
        console.log(`     ID: "${sel.id || 'N/A'}"`);
        console.log(`     Name: "${sel.name || 'N/A'}"`);
        console.log(`     Class: "${sel.className || 'N/A'}"`);
        console.log(`     Options count: ${sel.options.length}`);
        if (sel.options.length > 0 && sel.options.length < 10) {
            console.log(`     Options: ${Array.from(sel.options).map(o => o.text).join(', ')}`);
        } else if (sel.options.length > 0) {
            console.log(`     First 3 options: ${Array.from(sel.options).slice(0, 3).map(o => o.text).join(', ')}`);
        }
        console.log('');
    });
    
    // Find all buttons
    const buttons = document.querySelectorAll('button');
    console.log(`\n🔘 Found ${buttons.length} BUTTONS:\n`);
    buttons.forEach((btn, i) => {
        const text = btn.textContent.trim();
        if (text) { // Only show buttons with text
            console.log(`  ${i+1}. BUTTON:`);
            console.log(`     Text: "${text}"`);
            console.log(`     Type: "${btn.type || 'N/A'}"`);
            console.log(`     Class: "${btn.className || 'N/A'}"`);
            console.log(`     ID: "${btn.id || 'N/A'}"`);
            console.log('');
        }
    });
    
    // Find all inputs
    const inputs = document.querySelectorAll('input[type="text"], input[type="search"]');
    console.log(`\n📝 Found ${inputs.length} TEXT INPUTS:\n`);
    inputs.forEach((inp, i) => {
        console.log(`  ${i+1}. INPUT:`);
        console.log(`     ID: "${inp.id || 'N/A'}"`);
        console.log(`     Name: "${inp.name || 'N/A'}"`);
        console.log(`     Placeholder: "${inp.placeholder || 'N/A'}"`);
        console.log(`     Class: "${inp.className || 'N/A'}"`);
        console.log('');
    });
    
    // Find all forms
    const forms = document.querySelectorAll('form');
    console.log(`\n📄 Found ${forms.length} FORMS:\n`);
    forms.forEach((form, i) => {
        console.log(`  ${i+1}. FORM:`);
        console.log(`     ID: "${form.id || 'N/A'}"`);
        console.log(`     Class: "${form.className || 'N/A'}"`);
        console.log(`     Action: "${form.action || 'N/A'}"`);
        console.log('');
    });
    
    // Find elements with "branch" in their attributes
    console.log("\n🔍 Elements containing 'branch' in attributes:\n");
    const branchElements = document.querySelectorAll('[id*="branch" i], [name*="branch" i], [class*="branch" i]');
    branchElements.forEach((el, i) => {
        console.log(`  ${i+1}. ${el.tagName}:`);
        console.log(`     ID: "${el.id || 'N/A'}"`);
        console.log(`     Name: "${el.name || 'N/A'}"`);
        console.log(`     Class: "${el.className || 'N/A'}"`);
        console.log('');
    });
    
    // Find elements with "role" in their attributes
    console.log("\n🔍 Elements containing 'role' in attributes:\n");
    const roleElements = document.querySelectorAll('[id*="role" i], [name*="role" i], [class*="role" i]');
    roleElements.forEach((el, i) => {
        console.log(`  ${i+1}. ${el.tagName}:`);
        console.log(`     ID: "${el.id || 'N/A'}"`);
        console.log(`     Name: "${el.name || 'N/A'}"`);
        console.log(`     Class: "${el.className || 'N/A'}"`);
        console.log('');
    });
    
    console.log("=" .repeat(100));
    console.log("\n✅ DONE! Use the information above to update the script selectors.");
    console.log("\nℹ️  Look for:");
    console.log("   1. A SELECT dropdown that contains branch codes (KANP001, PNPP001, etc.)");
    console.log("   2. A SELECT dropdown that contains roles (Chief Accountant, etc.)");
    console.log("   3. A BUTTON to save/add the assignment");
    console.log("=" .repeat(100));
}

// Run the debugging function
findFormElements();
