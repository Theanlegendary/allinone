import os
import re

files_to_update = [
    r'c:\Users\DELL\Desktop\daily_push\index.html',
    r'c:\Users\DELL\Desktop\daily_push\push_bot\index.html',
    r'C:\Users\DELL\Downloads\genroute (3)\train.html',
    r'C:\Users\DELL\Downloads\genroute (3)\public\training.html',
    r'C:\Users\DELL\Downloads\genroute (3)\public\training-slides-v2.html'
]

# Wording replacements for Slide 3
old_mega_desc = 'ពិនិត្យ <b>តារាង ដាក់ទៅ MEGA (302/306/311)</b> ដើម្បីប្រាកដថាទំនិញបានឡើងឡាន។'
new_mega_desc = 'ពិនិត្យ <b>តារាងអីវាន់ ដាក់ នឹងកំពុងដាក់ទៅ MEGA (302/306/311)</b> ដើម្បីប្រាកដថាទំនិញកំពុងមានប្រតិបត្តិការជាមួយឡាន។'

old_rule_slide3 = '<b>ច្បាប់ប្រតិបត្តិការ៖</b> សម្រាប់អីវ៉ាន់ត្រូវយក (Pickup) ត្រូវពិនិត្យទំព័រ Pickup ក្នុង App ដើម្បីមើលការ assign ពីអតិថិជន និងរៀបចំផ្ញើបន្តតាម MEGA។'
new_rule_slide3 = 'អំពីលំហូរការងាររ៖ សម្រាប់អីវ៉ាន់បានបង្កេីតដោយភ្ញៀវ (Pickup) នឹងលោតទៅ  Pickup ស្វ័យប្រវត្តិក្នុង App ទៅតាមទិសដៅតំបន់នៅជិតទំនិញបានបង្កេីត បុគ្គលិកត្រូវឆែកមេីលជាប្រចាំដេីម្បីប្រាកដថាបានឃេីញ នឹងទទួលទំនិញ'

for path in files_to_update:
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace Wording
        content = content.replace(old_mega_desc, new_mega_desc)
        content = content.replace('ពិនិត្យ តារាង ដាក់ទៅ MEGA (302/306/311) ដើម្បីប្រាកដថាទំនិញបានឡើងឡាន។', 'ពិនិត្យ តារាងអីវាន់ ដាក់ នឹងកំពុងដាក់ទៅ MEGA (302/306/311) ដើម្បីប្រាកដថាទំនិញកំពុងមានប្រតិបត្តិការជាមួយឡាន។')
        content = content.replace(old_rule_slide3, new_rule_slide3)
        content = content.replace('សម្រាប់អីវ៉ាន់ត្រូវយក (Pickup) ត្រូវពិនិត្យទំព័រ Pickup ក្នុង App ដើម្បីមើលការ assign ពីអតិថិជន និងរៀបចំផ្ញើបន្តតាម MEGA។', new_rule_slide3)
        
        # Adjust CSS for enlarged right exhibit frame & tab buttons
        content = content.replace('grid-template-columns: 1.25fr 1fr;', 'grid-template-columns: 1.05fr 1.25fr;')
        content = content.replace('max-height: 560px;', 'max-height: 640px;')
        content = content.replace('font-size: 0.88rem;\n            font-weight: 900;\n            color: var(--text-dark);\n            padding: 8px 6px;', 'font-size: 1.05rem;\n            font-weight: 900;\n            color: var(--text-dark);\n            padding: 12px 10px;')
        content = content.replace('font-size: 0.85rem;\n            font-weight: 900;\n            color: var(--text-dark);\n            padding: 8px 6px;', 'font-size: 1.05rem;\n            font-weight: 900;\n            color: var(--text-dark);\n            padding: 12px 10px;')
        content = content.replace('padding: 8px 14px;\n            border-radius: 8px;\n            font-size: 0.88rem;', 'padding: 12px 18px;\n            border-radius: 10px;\n            font-size: 0.95rem;')
        
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Successfully updated wording & enlarged exhibit layout in {path}')
