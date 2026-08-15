import pandas as pd

df = pd.read_excel('Metfone_Order_Status_Discrepancies_IT_Report.xlsx', sheet_name='IT Error List (Discrepancies)')
with open('scratch/discrepancies_clean.txt', 'w', encoding='utf-8') as f:
    cols = ['Order ID', 'Zone', 'Handle Post Office', 'Report Tab (/total)', 'Issue / Error Type', 'Web Live Status Code', 'Web Live Status Name', 'Web Latest Update Time', 'Web Shipper / Staff']
    f.write(df[cols].to_string())

print("Saved to scratch/discrepancies_clean.txt")
