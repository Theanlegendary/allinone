import pandas as pd
import json

df = pd.read_excel('scratch/fresh_run_test/fresh_export.xlsx')
status_counts = df['CURRENT STATUS'].value_counts(dropna=False)
with open('scratch/status_summary.txt', 'w', encoding='utf-8') as f:
    f.write("=== VALUE COUNTS OF CURRENT STATUS IN RAW EXPORT (41,863 rows) ===\n")
    for s, c in status_counts.items():
        f.write(f"{str(s)}: {c}\n")

print("Saved status summary to scratch/status_summary.txt")
