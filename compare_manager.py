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

PREFIX_ZONE_MAP = {
    "PNP": "Phnom Penh",
    "BAN": "Banteay Meanchey",
    "BAT": "Battambang",
    "KMP": "Kandal",
    "TAK": "Takeo",
    "KPC": "Kampong Cham",
    "KPT": "Kampot",
    "SRP": "Siem Reap",
    "KPS": "Preah Sihanouk",
    "KPE": "Kampong Speu",
    "KTH": "Kampong Thom",
    "SVR": "Svay Rieng",
    "PVG": "Prey Veng",
    "PUR": "Pursat",
    "KRT": "Kratie",
    "STU": "Stung Treng",
    "RAT": "Ratanakiri",
    "MON": "Mondulkiri",
    "PRE": "Preah Vihear",
    "ODD": "Oddar Meanchey",
    "PVI": "Pailin",
    "TKG": "Tbong Khmum",
    "KEP": "Kep",
    "KOH": "Koh Kong"
}

def resolve_branch_zone(branch_code, df_detail=None):
    b_code = str(branch_code).strip().upper()

    if df_detail is not None:
        df = df_detail.copy()
        df.columns = [str(c).strip().upper() for c in df.columns]
        h_col = "POST OFFICE HANDLE" if "POST OFFICE HANDLE" in df.columns else ("CURRENT POST OFFICE" if "CURRENT POST OFFICE" in df.columns else None)
        z_col = "ZONE" if "ZONE" in df.columns else ("RECEIVE PROVINCE" if "RECEIVE PROVINCE" in df.columns else None)
        if h_col and z_col:
            m = df[df[h_col].astype(str).str.strip().str.upper() == b_code]
            if not m.empty:
                zv = str(m.iloc[0][z_col]).strip()
                if zv and zv.lower() != "nan":
                    return zv

    if os.path.exists("post_office_lookup.csv"):
        try:
            df_po = pd.read_csv("post_office_lookup.csv", encoding="utf-8-sig")
            df_po.columns = [str(c).strip().lower() for c in df_po.columns]
            if "post_office_handle" in df_po.columns and "zone" in df_po.columns:
                m = df_po[df_po["post_office_handle"].astype(str).str.strip().str.upper() == b_code]
                if not m.empty:
                    zv = str(m.iloc[0]["zone"]).strip()
                    if zv and zv.lower() != "nan":
                        return zv
        except Exception:
            pass

    prefix3 = b_code[:3]
    if prefix3 in PREFIX_ZONE_MAP:
        return PREFIX_ZONE_MAP[prefix3]

    return "Other Zone"

def load_test_bills():
    test_bills = set()
    if os.path.exists("test_bills.txt"):
        with open("test_bills.txt", "r", encoding="utf-8") as f:
            for line in f:
                b = line.strip()
                if b and not b.startswith("#"):
                    test_bills.add(b)
    return test_bills

def get_all_known_branches(df_detail=None):
    branches = set()
    if os.path.exists("post_office_lookup.csv"):
        try:
            df_po = pd.read_csv("post_office_lookup.csv", encoding="utf-8-sig")
            if "post_office_handle" in df_po.columns:
                for h in df_po["post_office_handle"].dropna().unique():
                    h_str = str(h).strip().upper()
                    if h_str and h_str != "NAN" and not any(kw in h_str for kw in EXCLUDE_KEYWORDS):
                        branches.add(h_str)
        except Exception:
            pass

    if df_detail is not None:
        df = df_detail.copy()
        df.columns = [str(c).strip().upper() for c in df.columns]
        handle_col = "POST OFFICE HANDLE" if "POST OFFICE HANDLE" in df.columns else ("CURRENT POST OFFICE" if "CURRENT POST OFFICE" in df.columns else None)
        if handle_col:
            for h in df[handle_col].dropna().unique():
                h_str = str(h).strip().upper()
                if h_str and h_str != "NAN" and not any(kw in h_str for kw in EXCLUDE_KEYWORDS):
                    branches.add(h_str)

    return sorted(list(branches))

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

        # Clean handle string (no extra suffixes or spaces)
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

    shift_bills = {}
    for oid, bdata in bills_map.items():
        if bdata["is_urgent"]:
            shift_bills[oid] = {
                "branch": bdata["branch"],
                "category": bdata["category"],
                "status": bdata["status"],
                "scan_time": bdata["scan_time"]
            }

    snapshots[date_str][shift_name] = {
        "captured_at": now_str,
        "bills": shift_bills
    }

    baseline = snapshots[date_str].get("9AM", {}).get("bills", {})
    if shift_name != "9AM" and baseline:
        shift_transitions = {}
        for oid, base_info in baseline.items():
            curr_info = bills_map.get(oid)
            if not curr_info:
                shift_transitions[oid] = {
                    "branch": base_info["branch"],
                    "category": base_info["category"],
                    "status_9am": base_info["status"],
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
                    "status_9am": base_info["status"],
                    "new_status": curr_sc,
                    "is_resolved": is_res,
                    "resolved_at": curr_info["scan_time"] if is_res else ""
                }
        snapshots[date_str][f"{shift_name}_transitions"] = shift_transitions

    save_snapshots(snapshots)
    return snapshots

def format_delta_val(val_shift, val_9am):
    if val_shift is None or val_9am is None:
        return f"{val_shift or 0}"
    diff = val_shift - val_9am
    if diff == 0:
        return f"{val_shift}"
    elif diff > 0:
        return f"{val_shift} (+{diff})"
    else:
        return f"{val_shift} ({diff})"

def build_comparison_summary(date_str, df_detail=None):
    if df_detail is not None:
        shift_name = determine_shift()
        record_shift_snapshot(date_str, shift_name, df_detail)

    snapshots = load_snapshots()
    day_data = snapshots.get(date_str, {})

    s_9am = day_data.get("9AM", {}).get("bills", {})
    s_2pm = day_data.get("2PM", {}).get("bills", {})
    s_5pm = day_data.get("5PM", {}).get("bills", {})

    t_2pm = day_data.get("2PM_transitions", {})
    t_5pm = day_data.get("5PM_transitions", {})

    all_known_branches = get_all_known_branches(df_detail)
    active_branches = set(b.get("branch", "") for b in list(s_9am.values()) + list(s_2pm.values()) + list(s_5pm.values()) if b.get("branch"))
    all_branches = sorted(list(set(all_known_branches).union(active_branches)))

    branch_matrix = {br: {c: {"9AM": 0, "2PM": 0, "5PM": 0} for c in CATEGORIES} for br in all_branches}

    for oid, bdata in s_9am.items():
        br = bdata.get("branch", "UNKNOWN")
        cat = bdata.get("category", "Not Assign")
        if cat not in CATEGORIES: cat = "Not Assign"
        if br in branch_matrix:
            branch_matrix[br][cat]["9AM"] += 1

    for oid, bdata in s_2pm.items():
        br = bdata.get("branch", "UNKNOWN")
        cat = bdata.get("category", "Not Assign")
        if cat not in CATEGORIES: cat = "Not Assign"
        if br in branch_matrix:
            branch_matrix[br][cat]["2PM"] += 1

    for oid, bdata in s_5pm.items():
        br = bdata.get("branch", "UNKNOWN")
        cat = bdata.get("category", "Not Assign")
        if cat not in CATEGORIES: cat = "Not Assign"
        if br in branch_matrix:
            branch_matrix[br][cat]["5PM"] += 1

    itemized_transitions = []
    for oid, base_info in s_9am.items():
        br = base_info.get("branch", "UNKNOWN")
        cat = base_info.get("category", "Not Assign")

        res_2pm = t_2pm.get(oid, {}).get("is_resolved", False)
        status_2pm = t_2pm.get(oid, {}).get("new_status", "")

        res_5pm = t_5pm.get(oid, {}).get("is_resolved", False)
        status_5pm = t_5pm.get(oid, {}).get("new_status", "")

        final_resolved = res_5pm or res_2pm
        final_status = status_5pm if status_5pm else (status_2pm if status_2pm else base_info.get("status", ""))
        resolved_shift = "5PM" if res_5pm else ("2PM" if res_2pm else "-")

        if final_resolved:
            itemized_transitions.append({
                "BILL ID": oid,
                "ZONE": resolve_branch_zone(br, df_detail),
                "POST OFFICE HANDLE": br,
                "CATEGORY": cat,
                "STATUS 9AM": base_info.get("status", ""),
                "NEW STATUS": final_status,
                "RESOLVED SHIFT": resolved_shift,
                "RESOLUTION TIME": t_5pm.get(oid, {}).get("resolved_at") or t_2pm.get(oid, {}).get("resolved_at") or day_data.get("9AM", {}).get("captured_at", "")
            })

    rows = []
    tot_cols = {c: {"9AM": 0, "2PM": 0, "5PM": 0} for c in CATEGORIES}

    sorted_branch_tuples = []
    for br in branch_matrix.keys():
        z = resolve_branch_zone(br, df_detail)
        sorted_branch_tuples.append((z, br))

    sorted_branch_tuples.sort(key=lambda x: (x[0], x[1]))

    for z, br in sorted_branch_tuples:
        row = {"ZONE": z, "POST OFFICE HANDLE": br, "BRANCH": br}
        tot_9am = tot_2pm = tot_5pm = 0

        for cat in CATEGORIES:
            v9 = branch_matrix[br][cat]["9AM"]
            v2 = branch_matrix[br][cat]["2PM"]
            v5 = branch_matrix[br][cat]["5PM"]

            row[f"{cat}_9AM"] = v9
            row[f"{cat}_2PM"] = v2
            row[f"{cat}_5PM"] = v5
            row[f"{cat}_2PM_STR"] = format_delta_val(v2, v9)
            row[f"{cat}_5PM_STR"] = format_delta_val(v5, v9)

            tot_cols[cat]["9AM"] += v9
            tot_cols[cat]["2PM"] += v2
            tot_cols[cat]["5PM"] += v5

            tot_9am += v9
            tot_2pm += v2
            tot_5pm += v5

        # Exclude empty 0-volume branches to keep report clean & readable
        if tot_9am == 0 and tot_2pm == 0 and tot_5pm == 0:
            continue

        row["TOTAL_9AM"] = tot_9am
        row["TOTAL_2PM"] = tot_2pm
        row["TOTAL_5PM"] = tot_5pm
        row["TOTAL_2PM_STR"] = format_delta_val(tot_2pm, tot_9am)
        row["TOTAL_5PM_STR"] = format_delta_val(tot_5pm, tot_9am)

        resolved_count = tot_9am - tot_5pm
        row["CLEARANCE_PCT"] = (resolved_count / tot_9am * 100.0) if tot_9am > 0 else 100.0

        rows.append(row)

    grand_9am = sum(tot_cols[c]["9AM"] for c in CATEGORIES)
    grand_2pm = sum(tot_cols[c]["2PM"] for c in CATEGORIES)
    grand_5pm = sum(tot_cols[c]["5PM"] for c in CATEGORIES)
    grand_res = grand_9am - grand_5pm
    grand_pct = (grand_res / grand_9am * 100.0) if grand_9am > 0 else 100.0

    totals = {"ZONE": "ALL", "POST OFFICE HANDLE": "TOTAL", "BRANCH": "TOTAL"}
    for cat in CATEGORIES:
        totals[f"{cat}_9AM"] = tot_cols[cat]["9AM"]
        totals[f"{cat}_2PM"] = tot_cols[cat]["2PM"]
        totals[f"{cat}_5PM"] = tot_cols[cat]["5PM"]
        totals[f"{cat}_2PM_STR"] = format_delta_val(tot_cols[cat]["2PM"], tot_cols[cat]["9AM"])
        totals[f"{cat}_5PM_STR"] = format_delta_val(tot_cols[cat]["5PM"], tot_cols[cat]["9AM"])

    totals["TOTAL_9AM"] = grand_9am
    totals["TOTAL_2PM"] = grand_2pm
    totals["TOTAL_5PM"] = grand_5pm
    totals["TOTAL_2PM_STR"] = format_delta_val(grand_2pm, grand_9am)
    totals["TOTAL_5PM_STR"] = format_delta_val(grand_5pm, grand_9am)
    totals["CLEARANCE_PCT"] = grand_pct

    return rows, totals, itemized_transitions

def build_compare_excel(date_str, rows, totals, itemized_transitions, out_filepath):
    wb = openpyxl.Workbook()
    ws_sum = wb.active
    ws_sum.title = "Zone Branch Shift Matrix"

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

    fill_s1 = PatternFill(start_color="DBEAFE", end_color="DBEAFE", fill_type="solid") # Blue 9AM
    font_s1 = Font(name=font_family, size=9, bold=True, color="1E40AF")
    hdr_s1  = PatternFill(start_color="1E3A8A", end_color="1E3A8A", fill_type="solid")

    fill_s2 = PatternFill(start_color="FFEDD5", end_color="FFEDD5", fill_type="solid") # Orange 2PM
    font_s2 = Font(name=font_family, size=9, bold=True, color="9A3412")
    hdr_s2  = PatternFill(start_color="C2410C", end_color="C2410C", fill_type="solid")

    fill_s3 = PatternFill(start_color="D1FAE5", end_color="D1FAE5", fill_type="solid") # Green 5PM
    font_s3 = Font(name=font_family, size=9, bold=True, color="065F46")
    hdr_s3  = PatternFill(start_color="047857", end_color="047857", fill_type="solid")

    cat_fills = [fill_cat1, fill_cat2, fill_cat3, fill_cat4]
    thin = Side(border_style="thin", color="CBD5E1")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)

    ws_sum.merge_cells("A1:R1")
    t_cell = ws_sum.cell(1, 1, f"ZONE & BRANCH URGENT SHIFT MATRIX (P1..P3, D1..D3, T1..T3, N1..N3) — {date_str}")
    t_cell.font = f_title
    t_cell.fill = fill_title
    t_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws_sum.row_dimensions[1].height = 30

    ws_sum.row_dimensions[2].height = 22
    ws_sum.merge_cells("A2:B2")
    z_cell = ws_sum.cell(2, 1, "ZONE & POST OFFICE HANDLE")
    z_cell.fill = fill_title
    z_cell.font = Font(name=font_family, size=10, bold=True, color="FFFFFF")
    z_cell.alignment = Alignment(horizontal="center", vertical="center")

    col_idx = 3
    cat_codes = [("PICKUP", "P"), ("DELIVERY", "D"), ("TRANSIT", "T"), ("NOT ASSIGN", "N")]
    for idx, (cat_name, code) in enumerate(cat_codes):
        ws_sum.merge_cells(start_row=2, start_column=col_idx, end_row=2, end_column=col_idx+2)
        c_cell = ws_sum.cell(2, col_idx, f"URGENT {cat_name} ({code}1..3)")
        c_cell.font = f_cat
        c_cell.fill = cat_fills[idx % len(cat_fills)]
        c_cell.alignment = Alignment(horizontal="center", vertical="center")
        col_idx += 3

    ws_sum.merge_cells("O2:Q2")
    tot_cell = ws_sum.cell(2, 15, "TOTAL (TOT1..3)")
    tot_cell.font = f_cat
    tot_cell.fill = fill_hdr
    tot_cell.alignment = Alignment(horizontal="center", vertical="center")

    ws_sum.cell(2, 18, "CLEARANCE").fill = fill_hdr
    ws_sum.cell(2, 18).font = f_cat
    ws_sum.cell(2, 18).alignment = Alignment(horizontal="center", vertical="center")

    sub_headers = ["ZONE", "POST OFFICE HANDLE", "P1", "P2 (Δ)", "P3 (Δ)", "D1", "D2 (Δ)", "D3 (Δ)", "T1", "T2 (Δ)", "T3 (Δ)", "N1", "N2 (Δ)", "N3 (Δ)", "TOT1", "TOT2 (Δ)", "TOT3 (Δ)", "CLEAR %"]
    ws_sum.row_dimensions[3].height = 20

    for c_i, sh_text in enumerate(sub_headers, 1):
        cell = ws_sum.cell(3, c_i, sh_text)
        cell.font = Font(name=font_family, size=9, bold=True, color="FFFFFF")

        if c_i in (3, 6, 9, 12, 15):
            cell.fill = hdr_s1 # 9 AM
        elif c_i in (4, 7, 10, 13, 16):
            cell.fill = hdr_s2 # 2 PM
        elif c_i in (5, 8, 11, 14, 17):
            cell.fill = hdr_s3 # 5 PM
        else:
            cell.fill = fill_hdr

        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    r_idx = 4
    for r in rows:
        row_fill = fill_alt if r_idx % 2 == 0 else None
        ws_sum.row_dimensions[r_idx].height = 19

        vals = [r["ZONE"], r["POST OFFICE HANDLE"]]
        for cat in CATEGORIES:
            vals.extend([r[f"{cat}_9AM"], r[f"{cat}_2PM_STR"], r[f"{cat}_5PM_STR"]])
        vals.extend([r["TOTAL_9AM"], r["TOTAL_2PM_STR"], r["TOTAL_5PM_STR"], f"{r['CLEARANCE_PCT']:.1f}%"])

        for c_i, val in enumerate(vals, 1):
            cell = ws_sum.cell(r_idx, c_i, val)
            cell.border = border

            if c_i in (3, 6, 9, 12, 15):
                cell.fill = fill_s1
                cell.font = font_s1
            elif c_i in (4, 7, 10, 13, 16):
                cell.fill = fill_s2
                cell.font = font_s2
            elif c_i in (5, 8, 11, 14, 17):
                cell.fill = fill_s3
                cell.font = font_s3
            elif c_i == 18:
                cell.font = f_good
                if row_fill: cell.fill = row_fill
            else:
                cell.font = f_data
                if row_fill: cell.fill = row_fill

            cell.alignment = Alignment(horizontal="center" if c_i > 2 else "left", vertical="center")
        r_idx += 1

    ws_sum.row_dimensions[r_idx].height = 22
    tot_vals = [totals["ZONE"], totals["POST OFFICE HANDLE"]]
    for cat in CATEGORIES:
        tot_vals.extend([totals[f"{cat}_9AM"], totals[f"{cat}_2PM_STR"], totals[f"{cat}_5PM_STR"]])
    tot_vals.extend([totals["TOTAL_9AM"], totals["TOTAL_2PM_STR"], totals["TOTAL_5PM_STR"], f"{totals['CLEARANCE_PCT']:.1f}%"])

    for c_i, val in enumerate(tot_vals, 1):
        cell = ws_sum.cell(r_idx, c_i, val)
        cell.font = f_total
        cell.fill = fill_total
        cell.border = border
        cell.alignment = Alignment(horizontal="center" if c_i > 2 else "left", vertical="center")

    for col in ws_sum.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws_sum.column_dimensions[col_letter].width = max(max_len + 3, 12)

    det_headers = ["BILL ID", "ZONE", "POST OFFICE HANDLE", "CATEGORY", "STATUS 9AM", "NEW STATUS", "RESOLVED SHIFT", "RESOLUTION TIME"]
    ws_det.merge_cells("A1:H1")
    d_cell = ws_det.cell(1, 1, f"ITEMIZED RESOLVED URGENT BILL TRANSITIONS ({date_str})")
    d_cell.font = f_title
    d_cell.fill = fill_title
    d_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws_det.row_dimensions[1].height = 30

    ws_det.row_dimensions[3].height = 24
    for c_idx, h_text in enumerate(det_headers, 1):
        cell = ws_det.cell(3, c_idx, h_text)
        cell.font = Font(name=font_family, size=9, bold=True, color="FFFFFF")
        cell.fill = fill_hdr
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border

    dr_idx = 4
    for item in itemized_transitions:
        row_fill = fill_alt if dr_idx % 2 == 0 else None
        ws_det.row_dimensions[dr_idx].height = 19
        vals = [item["BILL ID"], item["ZONE"], item["POST OFFICE HANDLE"], item["CATEGORY"], item["STATUS 9AM"], item["NEW STATUS"], item["RESOLVED SHIFT"], item["RESOLUTION TIME"]]
        for c_idx, val in enumerate(vals, 1):
            cell = ws_det.cell(dr_idx, c_idx, val)
            cell.font = f_good if c_idx == 6 else f_data
            cell.border = border
            if row_fill: cell.fill = row_fill
            cell.alignment = Alignment(horizontal="center" if c_idx not in (1, 2, 3) else "left", vertical="center")
        dr_idx += 1

    for col in ws_det.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws_det.column_dimensions[col_letter].width = max(max_len + 3, 12)

    wb.save(out_filepath)
    return out_filepath
