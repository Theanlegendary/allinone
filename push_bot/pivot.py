"""
pivot.py
Doc file Excel chi tiet don (export-detail) va dung bang pivot
"PENDING BILL CHECK" giong mau:
  - Loc: CURRENT STATUS thuoc danh sach pending_status_codes
         (+ loai test neu exclude_test)
  - Hang (rows): ZONE > CURRENT POST OFFICE > ORDER ID
  - Cot (columns): MONTH / DAY theo CREATED DATE
  - Gia tri: Count of ORDER ID
  - Co dong/cot Grand Total
"""

from datetime import datetime
from collections import defaultdict, OrderedDict

import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter


# ---- vi tri cot trong file nguon (0-based) ----
COL_CREATED_DATE    = 1   # CREATED DATE  (dd/mm/yyyy HH:MM:SS)
COL_ORDER_ID        = 2   # ORDER ID
COL_DELIVERY_PROV   = 12  # DELIVERY PROVINCE (e.g. MON, BAT, PNP, SIE)
COL_CURRENT_PO      = 15  # CURRENT POST OFFICE
COL_CURRENT_STATUS  = 23  # CURRENT STATUS  ("110 - Chua tiep nhan")
COL_SENDER          = 3
COL_RECEIVER        = 4
COL_ACTION_PO_HUB   = 35  # ACTION POST OFFICE at ORIGIN HUB (col 35)
COL_TOTAL_FEE       = 19  # TOTAL FEE (USD)
COL_COD             = 20  # COD (USD)

MEGA_HUB_LABELS = {
    "MEGA1":    "MEGA1",
    "DVCMEGA1": "DVCMEGA1",
}


def _status_code(value):
    """Lay ma so dau chuoi trang thai: '110 - Chua tiep nhan' -> '110'."""
    if value is None:
        return ""
    s = str(value).strip()
    if " - " in s:
        s = s.split(" - ", 1)[0]
    return s.split()[0].strip() if s else ""


def _parse_day(value):
    """Tra ve (month, day) tu CREATED DATE. Ho tro dd/mm/yyyy ..."""
    if value is None:
        return None, None
    if isinstance(value, datetime):
        return value.month, value.day
    s = str(value).strip()
    date_part = s.split(" ")[0]
    for fmt in ("%d/%m/%Y", "%Y-%m-%d", "%m/%d/%Y", "%d-%m-%Y"):
        try:
            dt = datetime.strptime(date_part, fmt)
            return dt.month, dt.day
        except ValueError:
            continue
    return None, None


def _zone_for(po_code, zone_cfg):
    if not po_code:
        return zone_cfg.get("default_zone", "Khac")
    po = str(po_code).strip()
    by_po = zone_cfg.get("by_post_office", {})
    if po in by_po:
        return by_po[po]
    by_prefix = zone_cfg.get("by_prefix", {})
    for prefix, zone in by_prefix.items():
        if po.upper().startswith(prefix.upper()):
            return zone
    return zone_cfg.get("default_zone", "Khac")


def _is_test_row(row, test_keywords):
    blob = " ".join(str(row[c] or "") for c in (COL_SENDER, COL_RECEIVER)).lower()
    return any(k.lower() in blob for k in test_keywords)


def read_source(path):
    """Doc file Excel nguon -> list rows (tuple), bo qua header."""
    wb = openpyxl.load_workbook(path, data_only=True)
    ws = wb.active
    rows = []
    for r in ws.iter_rows(values_only=True):
        rows.append(r)
    return rows[1:] if rows else []


def build_pivot(rows, pivot_cfg, zone_cfg):
    """
    Builds a standard pivot tree:
      zone -> po -> {order_id: (month, day)}
    """
    pending = set(str(c).strip() for c in pivot_cfg.get("pending_status_codes", []))
    exclude_test = pivot_cfg.get("exclude_test", False)
    test_keywords = pivot_cfg.get("test_keywords", ["test"])

    tree = defaultdict(lambda: defaultdict(dict))  # zone -> po -> {order_id: (month, day)}
    today = datetime.now().date()
    day_keys_seen = {(today.month, today.day)}

    for row in rows:
        if not row or row[COL_ORDER_ID] in (None, ""):
            continue
        if pending and _status_code(row[COL_CURRENT_STATUS]) not in pending:
            continue
        if exclude_test and _is_test_row(row, test_keywords):
            continue

        month, day = _parse_day(row[COL_CREATED_DATE])
        if day is None:
            continue
        po = str(row[COL_CURRENT_PO] or "").strip() or "(trong)"
        zone = _zone_for(po, zone_cfg)
        order_id = str(row[COL_ORDER_ID]).strip()

        key = (month, day)
        tree[zone][po][order_id] = key
        day_keys_seen.add(key)

    day_keys = sorted(day_keys_seen)
    month_val = day_keys[0][0] if day_keys else None
    return tree, day_keys, month_val


# ---- styling ----
_HDR_FILL  = PatternFill("solid", fgColor="1E293B")   # dark slate for headers
_ZONE_FILL = PatternFill("solid", fgColor="EAEAEA")
_THIN   = Side(style="thin", color="BFBFBF")
_BORDER = Border(left=_THIN, right=_THIN, top=_THIN, bottom=_THIN)
_CENTER = Alignment(horizontal="center", vertical="center")
_LEFT   = Alignment(horizontal="left", vertical="center")


def export_pivot(tree, day_keys, month_val, pivot_cfg, out_path):
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = pivot_cfg.get("is_label", "Pivot Report")

    fn = "Segoe UI"
    hdr_font = Font(name=fn, size=10, bold=True, color="FFFFFF")
    zone_font = Font(name=fn, size=10, bold=True, color="0F172A")
    data_font = Font(name=fn, size=10, color="0F172A")
    tot_font = Font(name=fn, size=10, bold=True, color="EF4444")
    tot_fill = PatternFill("solid", fgColor="F1F5F9")

    # Header Row 1
    ws.cell(1, 1, "Zone / Post Office").font = hdr_font
    ws.cell(1, 1).fill = _HDR_FILL
    ws.cell(1, 1).border = _BORDER
    ws.cell(1, 1).alignment = _LEFT

    col_idx_map = {}
    for idx, dk in enumerate(day_keys):
        col_num = 2 + idx
        col_idx_map[dk] = col_num
        cell = ws.cell(1, col_num, f"{dk[1]:02d}")
        cell.font = hdr_font
        cell.fill = _HDR_FILL
        cell.border = _BORDER
        cell.alignment = _CENTER

    tot_col = 2 + len(day_keys)
    ws.cell(1, tot_col, "Grand Total").font = hdr_font
    ws.cell(1, tot_col).fill = _HDR_FILL
    ws.cell(1, tot_col).border = _BORDER
    ws.cell(1, tot_col).alignment = _CENTER

    ws.row_dimensions[1].height = 24

    r = 2
    grand_col_totals = defaultdict(int)
    grand_overall = 0

    for zone in sorted(tree.keys()):
        # Zone Header Row
        ws.cell(r, 1, zone).font = zone_font
        ws.cell(r, 1).fill = _ZONE_FILL
        ws.cell(r, 1).border = _BORDER
        for c in range(2, tot_col + 1):
            cell = ws.cell(r, c)
            cell.fill = _ZONE_FILL
            cell.border = _BORDER
        ws.row_dimensions[r].height = 20
        r += 1

        zone_col_totals = defaultdict(int)
        zone_total = 0

        for po in sorted(tree[zone].keys()):
            ws.cell(r, 1, f"   {po}").font = data_font
            ws.cell(r, 1).border = _BORDER
            ws.cell(r, 1).alignment = _LEFT

            po_sum = 0
            for oid, dk in tree[zone][po].items():
                if dk in col_idx_map:
                    cn = col_idx_map[dk]
                    cur = ws.cell(r, cn).value or 0
                    ws.cell(r, cn, cur + 1)
                    zone_col_totals[dk] += 1
                    grand_col_totals[dk] += 1
                    po_sum += 1

            for c in range(2, tot_col + 1):
                cell = ws.cell(r, c)
                cell.border = _BORDER
                cell.alignment = _CENTER
                cell.font = data_font

            ws.cell(r, tot_col, po_sum).font = data_font
            ws.cell(r, tot_col).border = _BORDER
            ws.cell(r, tot_col).alignment = _CENTER

            zone_total += po_sum
            ws.row_dimensions[r].height = 20
            r += 1

        grand_overall += zone_total

    # Grand Total Row
    ws.cell(r, 1, "Grand Total").font = tot_font
    ws.cell(r, 1).fill = tot_fill
    ws.cell(r, 1).border = _BORDER
    ws.cell(r, 1).alignment = _LEFT

    for dk, cn in col_idx_map.items():
        v = grand_col_totals.get(dk, 0)
        c = ws.cell(r, cn, v if v > 0 else "")
        c.font = tot_font
        c.fill = tot_fill
        c.border = _BORDER
        c.alignment = _CENTER

    c_tot = ws.cell(r, tot_col, grand_overall)
    c_tot.font = tot_font
    c_tot.fill = tot_fill
    c_tot.border = _BORDER
    c_tot.alignment = _CENTER

    ws.row_dimensions[r].height = 22

    # Column widths
    ws.column_dimensions["A"].width = 28
    for c in range(2, tot_col + 1):
        ws.column_dimensions[get_column_letter(c)].width = 7

    wb.save(out_path)
    return out_path, grand_overall


def _merge_pivot_cfg(global_pivot, report):
    cfg = dict(global_pivot)
    if "pending_status_codes" in report:
        cfg["pending_status_codes"] = report["pending_status_codes"]
    cfg["is_label"] = report.get("is_label", report.get("title", "Pending"))
    return cfg


def run_report(rows, out_path, config, report):
    """Dung 1 report tu rows da doc san. Tra ve (out_path, total)."""
    pivot_cfg = _merge_pivot_cfg(config.get("pivot", {}), report)
    tree, days, month = build_pivot(rows, pivot_cfg, config["zone_mapping"])
    return export_pivot(tree, days, month, pivot_cfg, out_path)


def build_mega_pivot(rows, pivot_cfg, zone_cfg):
    """
    Builds a 2-level pivot tree for MEGA check matching Metfone OPS format:
      Level 1: CURRENT POST OFFICE (MEGA1 / DVCMEGA1)
      Level 2: DELIVERY PROVINCE (MON, BAT, PNP, SIE, etc.)
    """
    exclude_test     = pivot_cfg.get("exclude_test", False)
    test_keywords    = pivot_cfg.get("test_keywords", ["test"])
    exclude_statuses = {"410", "201", "520", "99", "100", "-99"}

    # tree[hub][prov][(month, day)] = count
    tree = defaultdict(lambda: defaultdict(lambda: defaultdict(int)))
    urgent_tree = defaultdict(lambda: defaultdict(int))
    day_keys_seen = set()
    today = datetime.now().date()
    day_keys_seen.add((today.month, today.day))

    for row in rows:
        if not row or len(row) <= COL_CURRENT_PO:
            continue
        if row[COL_ORDER_ID] in (None, ""):
            continue
        status_code = _status_code(row[COL_CURRENT_STATUS])
        if status_code in exclude_statuses:
            continue
        if exclude_test and _is_test_row(row, test_keywords):
            continue

        po = str(row[COL_CURRENT_PO] or "").strip().upper()
        col35 = str(row[COL_ACTION_PO_HUB] if len(row) > COL_ACTION_PO_HUB and row[COL_ACTION_PO_HUB] else "").strip().upper()

        if col35 == "MEGA1" or po == "MEGA1":
            hub_label = "MEGA1"
        elif "DVC" in col35 or "DVC" in po or "MEGA" in col35 or "MEGA" in po or "HUB" in po:
            hub_label = "DVCMEGA1"
        else:
            continue

        prov = str(row[COL_DELIVERY_PROV] if len(row) > COL_DELIVERY_PROV and row[COL_DELIVERY_PROV] else "").strip().upper() or "KHAC"

        month, day = _parse_day(row[COL_CREATED_DATE])
        if day is None:
            continue

        key = (month, day)
        tree[hub_label][prov][key] += 1
        day_keys_seen.add(key)

        created_val  = row[COL_CREATED_DATE]
        created_date = None
        if isinstance(created_val, datetime):
            created_date = created_val.date()
        elif created_val:
            s = str(created_val).strip().split(" ")[0]
            for fmt in ("%d/%m/%Y", "%Y-%m-%d", "%m/%d/%Y", "%d-%m-%Y"):
                try:
                    created_date = datetime.strptime(s, fmt).date()
                    break
                except ValueError:
                    continue
        if created_date and (today - created_date).days > 1:
            urgent_tree[hub_label][prov] += 1

    day_keys = sorted(day_keys_seen)
    return tree, day_keys, urgent_tree


def export_mega_pivot(tree, day_keys, out_path, urgent_tree=None):
    """
    Renders 2-level pivot table matching exact OPS screenshot:
      Row 1: PENDING BILL (Title)
      Row 2: Count of ORDER ID | Action day
      Row 3: CURRENT POST OFFICE | DELIVERY PROVINCE | dd/mm Date cols | Grand Total
      Rows : MEGA1 / DVCMEGA1 groups with province sub-rows and Total rows
    """
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "PENDING BILL"

    # Styles
    hdr_fill   = PatternFill("solid", fgColor="D9E1F2")   # soft purple-blue header fill
    tot_fill   = PatternFill("solid", fgColor="F2F2F2")   # soft grey for total rows
    title_font = Font(name="Calibri", size=11, bold=True, color="C00000")   # Red PENDING BILL title
    hdr_font   = Font(name="Calibri", size=10, bold=True, color="000000")
    sub_font   = Font(name="Calibri", size=10, bold=True, color="000000")
    data_font  = Font(name="Calibri", size=10, color="000000")

    # 1. Title Row (Row 1)
    ws.cell(1, 1, "PENDING BILL").font = title_font
    ws.cell(1, 1).alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[1].height = 20

    # 2. Row 2: "Count of ORDER ID", "Action day"
    ws.cell(2, 1, "Count of ORDER ID").font = Font(name="Calibri", size=10, bold=True)
    ws.cell(2, 3, "Action day").font = Font(name="Calibri", size=10, bold=True)
    for r in (1, 2, 3):
        ws.row_dimensions[r].height = 20

    # 3. Row 3: Headers
    ws.cell(3, 1, "CURRENT POST OFFICE")
    ws.cell(3, 2, "DELIVERY PROVINCE")

    col_idx_map = {}
    for idx, dk in enumerate(day_keys):
        col_num = 3 + idx
        col_idx_map[dk] = col_num
        ws.cell(3, col_num, f"{dk[1]:02d}/{dk[0]:02d}")   # dd/mm format (e.g. 01/07, 27/07)

    total_col_num = 3 + len(day_keys)
    ws.cell(3, total_col_num, "Grand Total")

    # Merge title row across table width
    ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=total_col_num)

    # Format header row 3
    for c in range(1, total_col_num + 1):
        cell = ws.cell(3, c)
        cell.fill = hdr_fill
        cell.font = hdr_font
        cell.border = _BORDER
        if c >= 3:
            cell.alignment = _CENTER
        else:
            cell.alignment = _LEFT

    r = 4
    grand_col_totals = defaultdict(int)
    grand_overall = 0

    hub_order = ["MEGA1", "DVCMEGA1"]
    for hub in hub_order:
        prov_dict = tree.get(hub, {})
        if not prov_dict:
            continue

        # Hub Group Header Row (e.g. MEGA1)
        ws.row_dimensions[r].height = 20
        ws.cell(r, 1, hub).font = sub_font
        ws.cell(r, 1).border = _BORDER
        ws.cell(r, 1).alignment = _LEFT
        ws.cell(r, 2).border = _BORDER

        for c in range(3, total_col_num + 1):
            cell = ws.cell(r, c)
            cell.border = _BORDER

        r += 1

        hub_col_totals = defaultdict(int)
        hub_total_sum = 0

        # Province sub-rows
        for prov in sorted(prov_dict.keys()):
            ws.row_dimensions[r].height = 19
            ws.cell(r, 1).border = _BORDER
            ws.cell(r, 2, prov).font = data_font
            ws.cell(r, 2).border = _BORDER
            ws.cell(r, 2).alignment = _LEFT

            row_sum = 0
            for idx, dk in enumerate(day_keys):
                col_num = col_idx_map[dk]
                val = prov_dict[prov].get(dk, 0)
                cell = ws.cell(r, col_num)
                cell.border = _BORDER
                cell.font = data_font
                cell.alignment = _CENTER
                if val > 0:
                    cell.value = val
                    row_sum += val
                    hub_col_totals[dk] += val
                    grand_col_totals[dk] += val

            tot_cell = ws.cell(r, total_col_num, row_sum if row_sum > 0 else "")
            tot_cell.font = data_font
            tot_cell.alignment = _CENTER
            tot_cell.border = _BORDER

            hub_total_sum += row_sum
            r += 1

        # Hub Total Subtotal Row (e.g. MEGA1 Total)
        ws.row_dimensions[r].height = 20
        sub_label = f"{hub} Total"
        ws.cell(r, 1, sub_label).font = sub_font
        ws.cell(r, 1).fill = tot_fill
        ws.cell(r, 1).border = _BORDER
        ws.cell(r, 1).alignment = _LEFT

        ws.cell(r, 2).fill = tot_fill
        ws.cell(r, 2).border = _BORDER

        for idx, dk in enumerate(day_keys):
            col_num = col_idx_map[dk]
            val = hub_col_totals.get(dk, 0)
            cell = ws.cell(r, col_num)
            cell.fill = tot_fill
            cell.font = sub_font
            cell.border = _BORDER
            cell.alignment = _CENTER
            if val > 0:
                cell.value = val

        tot_hub_cell = ws.cell(r, total_col_num, hub_total_sum)
        tot_hub_cell.fill = tot_fill
        tot_hub_cell.font = sub_font
        tot_hub_cell.border = _BORDER
        tot_hub_cell.alignment = _CENTER

        grand_overall += hub_total_sum
        r += 1

    # Grand Total Row
    ws.row_dimensions[r].height = 22
    ws.cell(r, 1, "Grand Total").font = sub_font
    ws.cell(r, 1).fill = tot_fill
    ws.cell(r, 1).border = _BORDER
    ws.cell(r, 1).alignment = _LEFT

    ws.cell(r, 2).fill = tot_fill
    ws.cell(r, 2).border = _BORDER

    for idx, dk in enumerate(day_keys):
        col_num = col_idx_map[dk]
        val = grand_col_totals.get(dk, 0)
        cell = ws.cell(r, col_num)
        cell.fill = tot_fill
        cell.font = sub_font
        cell.border = _BORDER
        cell.alignment = _CENTER
        if val > 0:
            cell.value = val

    gt_cell = ws.cell(r, total_col_num, grand_overall)
    gt_cell.fill = tot_fill
    gt_cell.font = sub_font
    gt_cell.border = _BORDER
    gt_cell.alignment = _CENTER

    # Column widths
    ws.column_dimensions["A"].width = 22
    ws.column_dimensions["B"].width = 20
    for c in range(3, total_col_num + 1):
        col_letter = get_column_letter(c)
        ws.column_dimensions[col_letter].width = 7
    ws.column_dimensions[get_column_letter(total_col_num)].width = 12

    wb.save(out_path)
    return out_path, grand_overall


def run_mega(source_path, out_path, config):
    rows = read_source(source_path)
    tree, day_keys, urgent_tree = build_mega_pivot(rows, config.get("pivot", {}), config.get("zone_mapping", {}))
    return export_mega_pivot(tree, day_keys, out_path, urgent_tree=urgent_tree)


def run_mega_combined(source_path, out_path, config):
    """Build combined Excel."""
    return run_mega(source_path, out_path, config)
