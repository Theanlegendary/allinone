"""
generate_tracking_logs_report.py
Generates a complete tracking milestone logs report for ALL-TIME bills.
- Formatted as: BILL ID | 1ST UNIT | LOG1 | TIME | 2ND UNIT | LOG2 | TIME ...
- LOG columns (LOG1, LOG2, LOG3, ...) explicitly contain the status codes (110, 200, 210, 306, 401, 410, etc.)
- Downloads ALL-TIME dataset (no 14-day or 40-day limit)
- Excludes test bills (from test_bills.txt)
- Excludes trainer accounts/post offices (TRAINER, TEST, DEMO)
- Excludes global offices (GLOBAL, EXTERNAL)
"""

import os
import json
import glob
import re
import requests
import pandas as pd
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Border, Side, Alignment
from openpyxl.utils import get_column_letter

HERE = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(HERE, "config.json")
TEST_BILLS_PATH = os.path.join(HERE, "test_bills.txt")

EXCLUDE_KEYWORDS = {"TRAINER", "GLOBAL", "TEST", "DEMO", "EXTERNAL"}

def load_test_ids():
    test_ids = set()
    if os.path.exists(TEST_BILLS_PATH):
        with open(TEST_BILLS_PATH, "r", encoding="utf-8") as f:
            test_ids = set(line.strip() for line in f if line.strip() and not line.strip().startswith("/"))
    return test_ids

def generate_tracking_logs(detail_xlsx_path, out_path, max_workers=35):
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        cfg = json.load(f)

    test_ids = load_test_ids()
    df = pd.read_excel(detail_xlsx_path)
    df.columns = [str(c).strip().upper() for c in df.columns]

    # Exclude completed/cancelled codes 99, 520, 201 if needed
    if "CURRENT STATUS" in df.columns or "STATUS_CODE" in df.columns:
        sc_col = "STATUS_CODE" if "STATUS_CODE" in df.columns else "CURRENT STATUS"
        df = df[~df[sc_col].astype(str).str.strip().isin(["99", "520", "201"])].copy()

    headers_api = {
        "Authorization": "Bearer " + cfg["api"]["bearer_token"],
        "Accept": "application/json, text/plain, */*",
        "User-Agent": "Mozilla/5.0"
    }

    def fetch_order_log(oid):
        oid_str = str(oid).strip()
        if not oid_str or oid_str.lower() == "nan" or oid_str in test_ids:
            return None

        try:
            r = requests.get(
                "https://gw-express.metfone.com.kh/tms-tracking/api/v1/order-tracking",
                params={"order_id": oid_str},
                headers=headers_api,
                timeout=10
            )
            if r.status_code != 200:
                return None
            data = r.json()
            trips = data.get("trackingTrips", [])
            if not trips:
                return None

            for t in trips:
                upd = str(t.get("updatedBy", {}).get("name", "") or "").upper()
                desc = str(t.get("desc", "") or "").upper()
                po = str(t.get("postcode", "") or t.get("postOffice", {}).get("code", "") or "").upper()
                if any(kw in upd or kw in desc or kw in po for kw in EXCLUDE_KEYWORDS):
                    return None

            trips_sorted = list(reversed(trips))
            row_dict = {"BILL ID": oid_str}

            max_step = len(trips_sorted)
            for idx, t in enumerate(trips_sorted, 1):
                st = str(t.get("status", "") or "").lstrip("S").strip()
                po = t.get("postOffice") or {}
                unit = t.get("postcode") or (po.get("code") if isinstance(po, dict) else "") or ""
                if not unit and "handoverInfo" in t:
                    unit = t.get("handoverInfo", {}).get("departmentCode", "")

                dt_raw = t.get("updatedAt", "")
                dt_str = ""
                if dt_raw:
                    try:
                        dt_obj = pd.to_datetime(dt_raw)
                        dt_str = dt_obj.strftime("%d/%m/%Y %H:%M:%S")
                    except Exception:
                        dt_str = str(dt_raw)

                row_dict[f"UNIT_{idx}"] = unit
                row_dict[f"LOG_{idx}"] = st
                row_dict[f"TIME_{idx}"] = dt_str

            row_dict["_max_step"] = max_step
            return row_dict
        except Exception:
            return None

    unique_oids = df["ORDER ID"].dropna().unique()
    results = []

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(fetch_order_log, oid) for oid in unique_oids]
        for future in as_completed(futures):
            res = future.result()
            if res:
                results.append(res)

    if not results:
        raise ValueError("No tracking logs could be extracted.")

    max_milestones = max(r.get("_max_step", 1) for r in results)

    wb = Workbook()
    ws = wb.active
    ws.title = "Tracking Logs"

    font_family = "Calibri"
    f_title = Font(name=font_family, size=14, bold=True, color="FFFFFF")
    f_header = Font(name=font_family, size=10, bold=True, color="FFFFFF")
    f_data = Font(name=font_family, size=9)

    fill_title = PatternFill(start_color="1E293B", end_color="1E293B", fill_type="solid")
    fill_hdr1 = PatternFill(start_color="334155", end_color="334155", fill_type="solid")
    fill_hdr2 = PatternFill(start_color="475569", end_color="475569", fill_type="solid")
    fill_alt = PatternFill(start_color="F8FAFC", end_color="F8FAFC", fill_type="solid")

    thin = Side(border_style="thin", color="CBD5E1")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)

    # Build Header Columns: BILL ID | 1ST UNIT | LOG1 | TIME | 2ND UNIT | LOG2 | TIME ...
    headers = ["BILL ID"]
    for i in range(1, max_milestones + 1):
        suffix = "ST" if i == 1 else "ND" if i == 2 else "RD" if i == 3 else "TH"
        headers.extend([f"{i}{suffix} UNIT", f"LOG{i}", "TIME"])

    ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=len(headers))
    t_cell = ws.cell(1, 1, "ALL-TIME BILL TRACKING MILESTONE LOGS REPORT")
    t_cell.font = f_title
    t_cell.fill = fill_title
    t_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[1].height = 30

    ws.row_dimensions[3].height = 24
    for c_idx, h_text in enumerate(headers, 1):
        cell = ws.cell(3, c_idx, h_text)
        cell.font = f_header
        cell.fill = fill_hdr1 if c_idx == 1 or ((c_idx - 1) // 3) % 2 == 0 else fill_hdr2
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    results.sort(key=lambda x: str(x.get("BILL ID", "")))

    r_idx = 4
    for r_data in results:
        row_fill = fill_alt if r_idx % 2 == 0 else None
        ws.row_dimensions[r_idx].height = 19

        c_bill = ws.cell(r_idx, 1, str(r_data.get("BILL ID", "")))
        c_bill.font = f_data
        c_bill.border = border
        c_bill.alignment = Alignment(horizontal="left", vertical="center")

        col_pos = 2
        for i in range(1, max_milestones + 1):
            unit_val = r_data.get(f"UNIT_{i}", "")
            log_val  = r_data.get(f"LOG_{i}", "")
            time_val = r_data.get(f"TIME_{i}", "")

            for val in [unit_val, log_val, time_val]:
                cell = ws.cell(r_idx, col_pos, val)
                cell.font = f_data
                cell.border = border
                if row_fill:
                    cell.fill = row_fill
                cell.alignment = Alignment(horizontal="center", vertical="center")
                col_pos += 1

        r_idx += 1

    for col in ws.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws.column_dimensions[col_letter].width = max(max_len + 3, 11)

    wb.save(out_path)
    return out_path

if __name__ == "__main__":
    import downloader
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        cfg = json.load(f)
    tmp_detail = os.path.join(HERE, "latest_all_time_detail.xlsx")
    today_str = datetime.now().strftime("%Y%m%d")
    downloader.download_detail(cfg["api"], tmp_detail, from_date="20250101", to_date=today_str, force_refresh=True)
    out_file = os.path.join(HERE, f"All_Time_Bill_Tracking_Milestone_Logs_{datetime.now().strftime('%Y%m%d_%H%M')}.xlsx")
    generate_tracking_logs(tmp_detail, out_file)
    print(f"✅ All-Time Milestone Report saved to {out_file}")
