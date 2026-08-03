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

def extract_all_bills_map(df_detail):
    """
    Map every bill in df_detail to its latest status, handle, and scan time.
    """
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

        # Parse scan time / current time
        scan_time = ""
        for tc in ["CURRENT TIME", "STATUS 306 AT STORE / AGENT (LAST TIME)", "STATUS 306 AT STORE / AGENT FROM HUB (FIRST TIME)", "SCAN TIME", "CREATED DATE"]:
            if tc in r and pd.notna(r[tc]):
                val_str = str(r[tc]).strip()
                if val_str and val_str.lower() != "nan":
                    scan_time = val_str
                    break

        # Active bills requiring action (excluding 99, 100, 201, 410, 520)
        is_urgent = (sc not in EXCLUDE_STATUSES)

        bills_map[oid] = {
            "branch": handle,
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
        # Establish 9 AM Morning Urgent Baseline
        baseline_urgent = {}
        for oid, bdata in bills_map.items():
            if bdata["is_urgent"]:
                baseline_urgent[oid] = {
                    "branch": bdata["branch"],
                    "status_9am": bdata["status"],
                    "scan_time_9am": bdata["scan_time"],
                    "captured_at": now_str
                }

        snapshots[date_str]["9AM"] = {
            "captured_at": now_str,
            "baseline_urgent": baseline_urgent
        }
        # Also initialize 2PM and 5PM if missing
        if "2PM" not in snapshots[date_str]:
            snapshots[date_str]["2PM"] = {"captured_at": "", "transitions": {}}
        if "5PM" not in snapshots[date_str]:
            snapshots[date_str]["5PM"] = {"captured_at": "", "transitions": {}}

    # Process 2PM or 5PM shift evaluation against 9AM baseline
    baseline = snapshots[date_str].get("9AM", {}).get("baseline_urgent", {})
    shift_transitions = {}

    for oid, base_info in baseline.items():
        curr_info = bills_map.get(oid)
        if not curr_info:
            # Bill missing from current export -> resolved/completed
            shift_transitions[oid] = {
                "branch": base_info["branch"],
                "status_9am": base_info["status_9am"],
                "new_status": "410", # Default assumed delivered/completed
                "is_resolved": True,
                "resolved_at": now_str
            }
        else:
            curr_sc = curr_info["status"]
            # Resolved if turned into 410, 420, 520, 201, 99, 100 or no longer urgent
            is_res = (curr_sc in RESOLVED_STATUSES or not curr_info["is_urgent"])
            shift_transitions[oid] = {
                "branch": base_info["branch"],
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

    branch_metrics = {}
    itemized_transitions = []

    for oid, base_info in baseline.items():
        br = base_info.get("branch", "UNKNOWN")
        if br not in branch_metrics:
            branch_metrics[br] = {
                "urgent_9am": 0,
                "resolved_2pm": 0,
                "resolved_5pm": 0,
                "remaining": 0
            }
        branch_metrics[br]["urgent_9am"] += 1

        # Check 2PM status
        res_2pm = t_2pm.get(oid, {}).get("is_resolved", False)
        status_2pm = t_2pm.get(oid, {}).get("new_status", "")

        # Check 5PM status
        res_5pm = t_5pm.get(oid, {}).get("is_resolved", False)
        status_5pm = t_5pm.get(oid, {}).get("new_status", "")

        # Best resolution status
        final_resolved = res_5pm or res_2pm
        final_status = status_5pm if status_5pm else (status_2pm if status_2pm else base_info["status_9am"])
        resolved_shift = "5PM" if res_5pm else ("2PM" if res_2pm else "-")

        if res_2pm:
            branch_metrics[br]["resolved_2pm"] += 1
        if res_5pm:
            branch_metrics[br]["resolved_5pm"] += 1

        if not final_resolved:
            branch_metrics[br]["remaining"] += 1

        if final_resolved:
            itemized_transitions.append({
                "BILL ID": oid,
                "BRANCH": br,
                "STATUS 9AM": base_info["status_9am"],
                "NEW STATUS": final_status,
                "RESOLVED SHIFT": resolved_shift,
                "RESOLUTION TIME": t_5pm.get(oid, {}).get("resolved_at") or t_2pm.get(oid, {}).get("resolved_at") or base_info.get("captured_at", "")
            })

    # Build final rows
    rows = []
    tot_9am = tot_2pm = tot_5pm = tot_rem = 0

    for br in sorted(branch_metrics.keys()):
        m = branch_metrics[br]
        u9 = m["urgent_9am"]
        r2 = m["resolved_2pm"]
        r5 = max(r2, m["resolved_5pm"])
        rem = u9 - r5
        pct = (r5 / u9 * 100.0) if u9 > 0 else 100.0

        tot_9am += u9
        tot_2pm += r2
        tot_5pm += r5
        tot_rem += rem

        rows.append({
            "BRANCH": br,
            "URGENT_9AM": u9,
            "RESOLVED_2PM": r2,
            "RESOLVED_5PM": r5,
            "REMAINING": rem,
            "CLEARANCE_PCT": pct
        })

    tot_pct = (tot_5pm / tot_9am * 100.0) if tot_9am > 0 else 100.0
    totals = {
        "BRANCH": "TOTAL",
        "URGENT_9AM": tot_9am,
        "RESOLVED_2PM": tot_2pm,
        "RESOLVED_5PM": tot_5pm,
        "REMAINING": tot_rem,
        "CLEARANCE_PCT": tot_pct
    }

    return rows, totals, itemized_transitions

def build_compare_excel(date_str, rows, totals, itemized_transitions, out_filepath):
    wb = openpyxl.Workbook()
    ws_sum = wb.active
    ws_sum.title = "Branch Clearance Summary"

    ws_det = wb.create_sheet(title="Itemized Transitions")

    font_family = "Segoe UI"
    f_title = Font(name=font_family, size=13, bold=True, color="FFFFFF")
    f_header = Font(name=font_family, size=10, bold=True, color="FFFFFF")
    f_data = Font(name=font_family, size=9)
    f_total = Font(name=font_family, size=10, bold=True, color="0F172A")
    f_good = Font(name=font_family, size=9, bold=True, color="065F46")

    fill_title = PatternFill(start_color="1E293B", end_color="1E293B", fill_type="solid")
    fill_hdr1 = PatternFill(start_color="334155", end_color="334155", fill_type="solid")
    fill_alt = PatternFill(start_color="F8FAFC", end_color="F8FAFC", fill_type="solid")
    fill_total = PatternFill(start_color="E2E8F0", end_color="E2E8F0", fill_type="solid")

    thin = Side(border_style="thin", color="CBD5E1")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)

    # Tab 1: Summary
    headers = ["BRANCH", "9 AM URGENT", "RESOLVED 2 PM", "RESOLVED 5 PM", "REMAINING URGENT", "CLEARANCE %"]
    ws_sum.merge_cells("A1:F1")
    t_cell = ws_sum.cell(1, 1, f"DAILY URGENT BILL CLEARANCE REPORT ({date_str})")
    t_cell.font = f_title
    t_cell.fill = fill_title
    t_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws_sum.row_dimensions[1].height = 30

    ws_sum.row_dimensions[3].height = 24
    for c_idx, h_text in enumerate(headers, 1):
        cell = ws_sum.cell(3, c_idx, h_text)
        cell.font = f_header
        cell.fill = fill_hdr1
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    r_idx = 4
    for r in rows:
        row_fill = fill_alt if r_idx % 2 == 0 else None
        ws_sum.row_dimensions[r_idx].height = 19

        vals = [r["BRANCH"], r["URGENT_9AM"], r["RESOLVED_2PM"], r["RESOLVED_5PM"], r["REMAINING"], f"{r['CLEARANCE_PCT']:.1f}%"]
        for c_idx, val in enumerate(vals, 1):
            cell = ws_sum.cell(r_idx, c_idx, val)
            cell.font = f_data
            cell.border = border
            if row_fill: cell.fill = row_fill
            cell.alignment = Alignment(horizontal="center" if c_idx > 1 else "left", vertical="center")
        r_idx += 1

    # Totals Row
    ws_sum.row_dimensions[r_idx].height = 22
    tot_vals = [totals["BRANCH"], totals["URGENT_9AM"], totals["RESOLVED_2PM"], totals["RESOLVED_5PM"], totals["REMAINING"], f"{totals['CLEARANCE_PCT']:.1f}%"]
    for c_idx, val in enumerate(tot_vals, 1):
        cell = ws_sum.cell(r_idx, c_idx, val)
        cell.font = f_total
        cell.fill = fill_total
        cell.border = border
        cell.alignment = Alignment(horizontal="center" if c_idx > 1 else "left", vertical="center")

    for col in ws_sum.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws_sum.column_dimensions[col_letter].width = max(max_len + 4, 14)

    # Tab 2: Itemized Transitions
    det_headers = ["BILL ID", "BRANCH", "STATUS 9AM", "NEW STATUS", "RESOLVED SHIFT", "RESOLUTION TIME"]
    ws_det.merge_cells("A1:F1")
    d_cell = ws_det.cell(1, 1, f"ITEMIZED RESOLVED URGENT BILL TRANSITIONS ({date_str})")
    d_cell.font = f_title
    d_cell.fill = fill_title
    d_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws_det.row_dimensions[1].height = 30

    ws_det.row_dimensions[3].height = 24
    for c_idx, h_text in enumerate(det_headers, 1):
        cell = ws_det.cell(3, c_idx, h_text)
        cell.font = f_header
        cell.fill = fill_hdr1
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    dr_idx = 4
    for item in itemized_transitions:
        row_fill = fill_alt if dr_idx % 2 == 0 else None
        ws_det.row_dimensions[dr_idx].height = 19
        vals = [item["BILL ID"], item["BRANCH"], item["STATUS 9AM"], item["NEW STATUS"], item["RESOLVED SHIFT"], item["RESOLUTION TIME"]]
        for c_idx, val in enumerate(vals, 1):
            cell = ws_det.cell(dr_idx, c_idx, val)
            cell.font = f_good if c_idx == 4 else f_data
            cell.border = border
            if row_fill: cell.fill = row_fill
            cell.alignment = Alignment(horizontal="center" if c_idx not in (1, 2) else "left", vertical="center")
        dr_idx += 1

    for col in ws_det.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws_det.column_dimensions[col_letter].width = max(max_len + 4, 14)

    wb.save(out_filepath)
    return out_filepath
