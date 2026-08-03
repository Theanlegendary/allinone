import os
import json
import re
import pandas as pd
from datetime import datetime
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

SNAPSHOT_FILE = "compare_snapshots.json"
EXCLUDE_STATUSES = {"99", "100", "201", "410", "520"}
RESOLVED_STATUSES = {"99", "100", "201", "410", "420", "520"}
EXCLUDE_KEYWORDS = ["TRAINER", "GLOBAL", "EXTERNAL", "TEST"]

CATEGORIES = ["Pickup", "Delivery", "Transit", "Not Assign"]
SHIFTS = ["9AM", "2PM", "5PM"]

def load_test_bills():
    test_bills = set()
    if os.path.exists("test_bills.txt"):
        with open("test_bills.txt", "r", encoding="utf-8") as f:
            for line in f:
                b = line.strip()
                if b and not b.startswith("#"):
                    test_bills.add(b)
    return test_bills

def determine_shift(now=None):
    if now is None:
        now = datetime.now()
    hour = now.hour
    if hour < 12:
        return "9AM"
    elif hour < 16:
        return "2PM"
    else:
        return "5PM"

def load_snapshots():
    if os.path.exists(SNAPSHOT_FILE):
        try:
            with open(SNAPSHOT_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_snapshots(data):
    with open(SNAPSHOT_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def classify_category(row_dict):
    """
    Classify a bill into Pickup, Delivery, Transit, or Not Assign.
    """
    cat_raw = str(row_dict.get("REPORT TYPE", "") or row_dict.get("TYPE", "") or row_dict.get("_REPORT_CLASS", "") or "").upper()
    if "PICKUP" in cat_raw:
        return "Pickup"
    elif "DELIVERY" in cat_raw:
        return "Delivery"
    elif "TRANSIT" in cat_raw or "MEGA" in cat_raw:
        return "Transit"
    elif "BRANCH" in cat_raw or "NOT ASSIGN" in cat_raw:
        return "Not Assign"

    sc = str(row_dict.get("STATUS_CODE", "") or row_dict.get("STATUS", "") or "").lstrip("S").strip()
    if sc in ("200", "210", "302", "310"):
        return "Pickup"
    elif sc in ("311", "401", "402", "470", "472", "480", "500"):
        return "Delivery"
    elif sc in ("306", "309"):
        return "Transit"
    else:
        return "Not Assign"

def extract_all_bills_map(df_detail):
    df = df_detail.copy()
    df.columns = [str(c).strip().upper() for c in df.columns]

    test_bills = load_test_bills()
    handle_col = "POST OFFICE HANDLE" if "POST OFFICE HANDLE" in df.columns else ("CURRENT POST OFFICE" if "CURRENT POST OFFICE" in df.columns else None)
    oid_col = "ORDER ID" if "ORDER ID" in df.columns else ("BILL ID" if "BILL ID" in df.columns else None)
    sc_col = "STATUS_CODE" if "STATUS_CODE" in df.columns else ("STATUS" if "STATUS" in df.columns else None)

    bills_map = {}
    if not handle_col or not oid_col or not sc_col:
        return bills_map

    for _, r in df.iterrows():
        oid = str(r.get(oid_col, "") or "").strip()
        if not oid or oid in test_bills:
            continue

        handle = str(r.get(handle_col, "") or "").strip().upper()
        if any(kw in handle for kw in EXCLUDE_KEYWORDS):
            continue

        sc = str(r.get(sc_col, "") or "").lstrip("S").strip()
        if sc and " " in sc:
            sc = sc.split()[0].strip()

        scan_time = ""
        for tc in ["CURRENT TIME", "STATUS 306 AT STORE / AGENT (LAST TIME)", "STATUS 306 AT STORE / AGENT FROM HUB (FIRST TIME)", "SCAN TIME", "CREATED DATE"]:
            if tc in r and pd.notna(r[tc]):
                val_str = str(r[tc]).strip()
                if val_str and val_str.lower() != "nan":
                    scan_time = val_str
                    break

        cat = classify_category(r)
        is_urgent = (sc not in EXCLUDE_STATUSES)

        bills_map[oid] = {
            "branch": handle,
            "category": cat,
            "status": sc,
            "scan_time": scan_time,
            "is_urgent": is_urgent
        }

    return bills_map

def record_shift_snapshot(date_str, shift_name, df_detail):
    snapshots = load_snapshots()
    if date_str not in snapshots:
        snapshots[date_str] = {}

    bills_map = extract_all_bills_map(df_detail)
    now_str = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

    if shift_name == "9AM" or "9AM" not in snapshots[date_str]:
        baseline_urgent = {}
        for oid, bdata in bills_map.items():
            if bdata["is_urgent"]:
                baseline_urgent[oid] = {
                    "branch": bdata["branch"],
                    "category": bdata["category"],
                    "status_9am": bdata["status"],
                    "scan_time_9am": bdata["scan_time"],
                    "captured_at": now_str
                }

        snapshots[date_str]["9AM"] = {
            "captured_at": now_str,
            "baseline_urgent": baseline_urgent
        }
        if "2PM" not in snapshots[date_str]:
            snapshots[date_str]["2PM"] = {"captured_at": "", "transitions": {}}
        if "5PM" not in snapshots[date_str]:
            snapshots[date_str]["5PM"] = {"captured_at": "", "transitions": {}}

    baseline = snapshots[date_str].get("9AM", {}).get("baseline_urgent", {})
    shift_transitions = {}

    for oid, base_info in baseline.items():
        curr_info = bills_map.get(oid)
        if not curr_info:
            shift_transitions[oid] = {
                "branch": base_info["branch"],
                "category": base_info["category"],
                "status_9am": base_info["status_9am"],
                "new_status": "410",
                "is_resolved": True,
                "resolved_at": now_str
            }
        else:
            curr_sc = curr_info["status"]
            is_res = (curr_sc in RESOLVED_STATUSES or not curr_info["is_urgent"])
            shift_transitions[oid] = {
                "branch": base_info["branch"],
                "category": base_info["category"],
                "status_9am": base_info["status_9am"],
                "new_status": curr_sc,
                "is_resolved": is_res,
                "resolved_at": curr_info["scan_time"] if is_res else ""
            }

    if shift_name != "9AM":
        snapshots[date_str][shift_name] = {
            "captured_at": now_str,
            "transitions": shift_transitions
        }

    save_snapshots(snapshots)
    return snapshots

def build_comparison_summary(date_str, df_detail=None):
    if df_detail is not None:
        shift_name = determine_shift()
        record_shift_snapshot(date_str, shift_name, df_detail)

    snapshots = load_snapshots()
    day_data = snapshots.get(date_str, {})
    baseline = day_data.get("9AM", {}).get("baseline_urgent", {})

    t_2pm = day_data.get("2PM", {}).get("transitions", {})
    t_5pm = day_data.get("5PM", {}).get("transitions", {})

    # branch -> category -> {9AM, 2PM, 5PM}
    branch_matrix = {}
    itemized_transitions = []

    for oid, base_info in baseline.items():
        br = base_info.get("branch", "UNKNOWN")
        cat = base_info.get("category", "Not Assign")
        if cat not in CATEGORIES:
            cat = "Not Assign"

        if br not in branch_matrix:
            branch_matrix[br] = {c: {"9AM": 0, "2PM": 0, "5PM": 0} for c in CATEGORIES}

        branch_matrix[br][cat]["9AM"] += 1

        res_2pm = t_2pm.get(oid, {}).get("is_resolved", False)
        status_2pm = t_2pm.get(oid, {}).get("new_status", "")

        res_5pm = t_5pm.get(oid, {}).get("is_resolved", False)
        status_5pm = t_5pm.get(oid, {}).get("new_status", "")

        if not res_2pm:
            branch_matrix[br][cat]["2PM"] += 1
        if not (res_2pm or res_5pm):
            branch_matrix[br][cat]["5PM"] += 1

        final_resolved = res_5pm or res_2pm
        final_status = status_5pm if status_5pm else (status_2pm if status_2pm else base_info["status_9am"])
        resolved_shift = "5PM" if res_5pm else ("2PM" if res_2pm else "-")

        if final_resolved:
            itemized_transitions.append({
                "BILL ID": oid,
                "BRANCH": br,
                "CATEGORY": cat,
                "STATUS 9AM": base_info["status_9am"],
                "NEW STATUS": final_status,
                "RESOLVED SHIFT": resolved_shift,
                "RESOLUTION TIME": t_5pm.get(oid, {}).get("resolved_at") or t_2pm.get(oid, {}).get("resolved_at") or base_info.get("captured_at", "")
            })

    # Build per-branch row metrics (12 columns + total + clear %)
    rows = []
    tot_cols = {c: {"9AM": 0, "2PM": 0, "5PM": 0} for c in CATEGORIES}

    for br in sorted(branch_matrix.keys()):
        row = {"BRANCH": br}
        tot_9am = tot_2pm = tot_5pm = 0

        for cat in CATEGORIES:
            v9 = branch_matrix[br][cat]["9AM"]
            v2 = branch_matrix[br][cat]["2PM"]
            v5 = branch_matrix[br][cat]["5PM"]

            row[f"{cat}_9AM"] = v9
            row[f"{cat}_2PM"] = v2
            row[f"{cat}_5PM"] = v5

            tot_cols[cat]["9AM"] += v9
            tot_cols[cat]["2PM"] += v2
            tot_cols[cat]["5PM"] += v5

            tot_9am += v9
            tot_2pm += v2
            tot_5pm += v5

        row["TOTAL_9AM"] = tot_9am
        row["TOTAL_2PM"] = tot_2pm
        row["TOTAL_5PM"] = tot_5pm

        resolved_count = tot_9am - tot_5pm
        row["CLEARANCE_PCT"] = (resolved_count / tot_9am * 100.0) if tot_9am > 0 else 100.0

        rows.append(row)

    # Totals Row
    grand_9am = sum(tot_cols[c]["9AM"] for c in CATEGORIES)
    grand_2pm = sum(tot_cols[c]["2PM"] for c in CATEGORIES)
    grand_5pm = sum(tot_cols[c]["5PM"] for c in CATEGORIES)
    grand_res = grand_9am - grand_5pm
    grand_pct = (grand_res / grand_9am * 100.0) if grand_9am > 0 else 100.0

    totals = {"BRANCH": "TOTAL"}
    for cat in CATEGORIES:
        totals[f"{cat}_9AM"] = tot_cols[cat]["9AM"]
        totals[f"{cat}_2PM"] = tot_cols[cat]["2PM"]
        totals[f"{cat}_5PM"] = tot_cols[cat]["5PM"]

    totals["TOTAL_9AM"] = grand_9am
    totals["TOTAL_2PM"] = grand_2pm
    totals["TOTAL_5PM"] = grand_5pm
    totals["CLEARANCE_PCT"] = grand_pct

    return rows, totals, itemized_transitions

def build_compare_excel(date_str, rows, totals, itemized_transitions, out_filepath):
    wb = openpyxl.Workbook()
    ws_sum = wb.active
    ws_sum.title = "12-Col Branch Shift Matrix"

    ws_det = wb.create_sheet(title="Itemized Status Transitions")

    font_family = "Segoe UI"
    f_title = Font(name=font_family, size=13, bold=True, color="FFFFFF")
    f_cat = Font(name=font_family, size=10, bold=True, color="FFFFFF")
    f_header = Font(name=font_family, size=9, bold=True, color="FFFFFF")
    f_data = Font(name=font_family, size=9)
    f_total = Font(name=font_family, size=10, bold=True, color="0F172A")
    f_good = Font(name=font_family, size=9, bold=True, color="065F46")

    fill_title = PatternFill(start_color="1E293B", end_color="1E293B", fill_type="solid")
    fill_cat1 = PatternFill(start_color="1E3A8A", end_color="1E3A8A", fill_type="solid")
    fill_cat2 = PatternFill(start_color="065F46", end_color="065F46", fill_type="solid")
    fill_cat3 = PatternFill(start_color="9A3412", end_color="9A3412", fill_type="solid")
    fill_cat4 = PatternFill(start_color="581C87", end_color="581C87", fill_type="solid")
    fill_hdr = PatternFill(start_color="334155", end_color="334155", fill_type="solid")
    fill_alt = PatternFill(start_color="F8FAFC", end_color="F8FAFC", fill_type="solid")
    fill_total = PatternFill(start_color="E2E8F0", end_color="E2E8F0", fill_type="solid")

    cat_fills = [fill_cat1, fill_cat2, fill_cat3, fill_cat4]

    thin = Side(border_style="thin", color="CBD5E1")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)

    # 17 total columns: BRANCH | Pickup 9/2/5 | Delivery 9/2/5 | Transit 9/2/5 | Not Assign 9/2/5 | TOT 9/2/5 | CLEAR %
    ws_sum.merge_cells("A1:Q1")
    t_cell = ws_sum.cell(1, 1, f"DAILY URGENT BILL SHIFT COMPARISON MATRIX (9 AM vs 2 PM vs 5 PM) — {date_str}")
    t_cell.font = f_title
    t_cell.fill = fill_title
    t_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws_sum.row_dimensions[1].height = 30

    # Row 2: Category Headers
    ws_sum.row_dimensions[2].height = 22
    ws_sum.cell(2, 1, "BRANCH").fill = fill_title
    ws_sum.cell(2, 1).font = f_header
    ws_sum.cell(2, 1).alignment = Alignment(horizontal="center", vertical="center")

    col_idx = 2
    for idx, cat in enumerate(CATEGORIES):
        ws_sum.merge_cells(start_row=2, start_column=col_idx, end_row=2, end_column=col_idx+2)
        c_cell = ws_sum.cell(2, col_idx, f"URGENT {cat.upper()}")
        c_cell.font = f_cat
        c_cell.fill = cat_fills[idx % len(cat_fills)]
        c_cell.alignment = Alignment(horizontal="center", vertical="center")
        col_idx += 3

    ws_sum.merge_cells("N2:P2")
    tot_cell = ws_sum.cell(2, 14, "OVERALL TOTALS")
    tot_cell.font = f_cat
    tot_cell.fill = fill_hdr
    tot_cell.alignment = Alignment(horizontal="center", vertical="center")

    ws_sum.cell(2, 17, "CLEARANCE").fill = fill_hdr
    ws_sum.cell(2, 17).font = f_cat
    ws_sum.cell(2, 17).alignment = Alignment(horizontal="center", vertical="center")

    # Row 3: Shift Headers
    sub_headers = ["BRANCH"]
    for _ in CATEGORIES:
        sub_headers.extend(["9 AM", "2 PM", "5 PM"])
    sub_headers.extend(["9 AM", "2 PM", "5 PM", "CLEAR %"])

    ws_sum.row_dimensions[3].height = 20
    for c_i, sh_text in enumerate(sub_headers, 1):
        cell = ws_sum.cell(3, c_i, sh_text)
        cell.font = f_header
        cell.fill = fill_hdr
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    # Data Rows
    r_idx = 4
    for r in rows:
        row_fill = fill_alt if r_idx % 2 == 0 else None
        ws_sum.row_dimensions[r_idx].height = 19

        vals = [r["BRANCH"]]
        for cat in CATEGORIES:
            vals.extend([r[f"{cat}_9AM"], r[f"{cat}_2PM"], r[f"{cat}_5PM"]])
        vals.extend([r["TOTAL_9AM"], r["TOTAL_2PM"], r["TOTAL_5PM"], f"{r['CLEARANCE_PCT']:.1f}%"])

        for c_i, val in enumerate(vals, 1):
            cell = ws_sum.cell(r_idx, c_i, val)
            cell.font = f_data
            cell.border = border
            if row_fill: cell.fill = row_fill
            cell.alignment = Alignment(horizontal="center" if c_i > 1 else "left", vertical="center")
        r_idx += 1

    # Totals Row
    ws_sum.row_dimensions[r_idx].height = 22
    tot_vals = [totals["BRANCH"]]
    for cat in CATEGORIES:
        tot_vals.extend([totals[f"{cat}_9AM"], totals[f"{cat}_2PM"], totals[f"{cat}_5PM"]])
    tot_vals.extend([totals["TOTAL_9AM"], totals["TOTAL_2PM"], totals["TOTAL_5PM"], f"{totals['CLEARANCE_PCT']:.1f}%"])

    for c_i, val in enumerate(tot_vals, 1):
        cell = ws_sum.cell(r_idx, c_i, val)
        cell.font = f_total
        cell.fill = fill_total
        cell.border = border
        cell.alignment = Alignment(horizontal="center" if c_i > 1 else "left", vertical="center")

    for col in ws_sum.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws_sum.column_dimensions[col_letter].width = max(max_len + 3, 11)

    # Tab 2: Itemized Transitions
    det_headers = ["BILL ID", "BRANCH", "CATEGORY", "STATUS 9AM", "NEW STATUS", "RESOLVED SHIFT", "RESOLUTION TIME"]
    ws_det.merge_cells("A1:G1")
    d_cell = ws_det.cell(1, 1, f"ITEMIZED RESOLVED URGENT BILL TRANSITIONS ({date_str})")
    d_cell.font = f_title
    d_cell.fill = fill_title
    d_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws_det.row_dimensions[1].height = 30

    ws_det.row_dimensions[3].height = 24
    for c_idx, h_text in enumerate(det_headers, 1):
        cell = ws_det.cell(3, c_idx, h_text)
        cell.font = f_header
        cell.fill = fill_hdr
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    dr_idx = 4
    for item in itemized_transitions:
        row_fill = fill_alt if dr_idx % 2 == 0 else None
        ws_det.row_dimensions[dr_idx].height = 19
        vals = [item["BILL ID"], item["BRANCH"], item["CATEGORY"], item["STATUS 9AM"], item["NEW STATUS"], item["RESOLVED SHIFT"], item["RESOLUTION TIME"]]
        for c_idx, val in enumerate(vals, 1):
            cell = ws_det.cell(dr_idx, c_idx, val)
            cell.font = f_good if c_idx == 5 else f_data
            cell.border = border
            if row_fill: cell.fill = row_fill
            cell.alignment = Alignment(horizontal="center" if c_idx not in (1, 2) else "left", vertical="center")
        dr_idx += 1

    for col in ws_det.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws_det.column_dimensions[col_letter].width = max(max_len + 3, 12)

    wb.save(out_filepath)
    return out_filepath
