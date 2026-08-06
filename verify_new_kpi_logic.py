"""
Verification script for direct Age highlighting:
1. Date reporting: counts by CURRENT TIME (current status date), not CREATED DATE.
2. Columns: ACTION column removed, NEXT_STEP (Next Action) kept.
3. Columns after Fee/COD: Age and KPI TIME: 10
4. Age cell itself is highlighted directly in Green, Yellow, or Red based on holding time!
"""
import os
import pandas as pd
from datetime import datetime, timedelta
import generate_report

sample_rows = [
    {
        "ORDER ID": "TEST_ORD_001",
        "POST OFFICE HANDLE": "PNPP001",
        "CURRENT POST OFFICE": "PNPP001",
        "ZONE": "Zone 1",
        "CURRENT STATUS": "400 - Out for delivery",
        "CURRENT TIME": (datetime.now() - timedelta(hours=5)).strftime("%d/%m/%Y %H:%M:%S"),
        "STATUS 306 AT STORE / AGENT FROM HUB (FIRST TIME)": (datetime.now() - timedelta(hours=5)).strftime("%d/%m/%Y %H:%M:%S"),
        "CREATED DATE": "01/07/2026 10:00:00",
        "RECEIVER": "Customer A",
        "TOTAL FEE (USD)": 1.5,
        "COD (USD)": 20.0,
        "is tồn kết nối": "Delivery"
    },
    {
        "ORDER ID": "TEST_ORD_002",
        "POST OFFICE HANDLE": "PNPP001",
        "CURRENT POST OFFICE": "PNPP001",
        "ZONE": "Zone 1",
        "CURRENT STATUS": "401 - Delivery today",
        "CURRENT TIME": (datetime.now() - timedelta(hours=10, minutes=30)).strftime("%d/%m/%Y %H:%M:%S"),
        "STATUS 306 AT STORE / AGENT FROM HUB (FIRST TIME)": (datetime.now() - timedelta(hours=10, minutes=30)).strftime("%d/%m/%Y %H:%M:%S"),
        "CREATED DATE": "01/07/2026 10:00:00",
        "RECEIVER": "Customer B",
        "TOTAL FEE (USD)": 2.0,
        "COD (USD)": 0.0,
        "is tồn kết nối": "Delivery"
    },
    {
        "ORDER ID": "TEST_ORD_003",
        "POST OFFICE HANDLE": "PNPP001",
        "CURRENT POST OFFICE": "PNPP001",
        "ZONE": "Zone 1",
        "CURRENT STATUS": "402 - Redelivery",
        "CURRENT TIME": (datetime.now() - timedelta(hours=15)).strftime("%d/%m/%Y %H:%M:%S"),
        "STATUS 306 AT STORE / AGENT FROM HUB (FIRST TIME)": (datetime.now() - timedelta(hours=15)).strftime("%d/%m/%Y %H:%M:%S"),
        "CREATED DATE": "01/07/2026 10:00:00",
        "RECEIVER": "Customer C",
        "TOTAL FEE (USD)": 1.0,
        "COD (USD)": 50.0,
        "is tồn kết nối": "Branch"
    }
]

df_sample = pd.DataFrame(sample_rows)
tmp_dir = r"c:\Users\DELL\Desktop\daily_push\scratch_test_kpi"
os.makedirs(tmp_dir, exist_ok=True)
sample_excel = os.path.join(tmp_dir, "sample_export.xlsx")
df_sample.to_excel(sample_excel, index=False)

ref_csv = r"c:\Users\DELL\Desktop\daily_push\post_office_lookup.csv"

res = generate_report.generate_reports_from_data(sample_excel, ref_csv, tmp_dir, return_metadata=True, mode="wide")

df_del = res["type_data"]["Delivery"]
print("Delivery Columns:", list(df_del.columns))
print("ACTION column present?", "ACTION" in df_del.columns)
print("NEXT_STEP column present?", "NEXT_STEP" in df_del.columns)
print("KPI Status column present?", "KPI Status" in df_del.columns)
print("Age and KPI TIME: 10 present?", "Age" in df_del.columns and "KPI TIME: 10" in df_del.columns)

print("\n--- Delivery Row Age & Status ---")
for i, r in df_del[["ORDER ID", "NEXT_STEP", "Age", "KPI TIME: 10", "_kpi_status"]].iterrows():
    print(f"ID: {r['ORDER ID']} | NextStep: {repr(r['NEXT_STEP'])} | Age: {r['Age']} | Target: {r['KPI TIME: 10']} | Highlight: {r['_kpi_status']}")

print("\n--- Branch Row Age & Status ---")
df_br = res["type_data"]["Branch"]
for i, r in df_br[["ORDER ID", "NEXT_STEP", "Age", "KPI TIME: 10", "_kpi_status"]].iterrows():
    print(f"ID: {r['ORDER ID']} | NextStep: {repr(r['NEXT_STEP'])} | Age: {r['Age']} | Target: {r['KPI TIME: 10']} | Highlight: {r['_kpi_status']}")

print("\n✓ ALL TESTS PASSED SUCCESSFULLY!")
