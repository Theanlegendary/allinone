"""mega_detail.py - Detail Excel for orders currently at MEGA/DVC/HUB post offices.

Filter: CURRENT POST OFFICE contains 'MEGA', 'DVC', or 'HUB'
  (parcels physically stuck at MEGA hub right now)

Layout:
  Section 1 — Urgent (age > 1 day) — light red background
  Section 2 — Normal               — white background

Columns:
  1. ស្ថានភាព     (Status KM)
  2. បុគ្គលិក       (Action User - staff who handled parcel)
  3. ប.ស.ចេញ    (Origin PO  = RECEIVE POST OFFICE)
  4. ប.ស.ទៅ     (Dest PO    = DELIVERY POST OFFICE)
  5. លេខបញ្ជា    (ORDER ID)
  6. ថ្លៃ (USD)   (Total Fee USD)
  7. COD (USD)   (COD USD)
  8. កាលបរិច្ឆេទ   (Created Date)
  9. ថ្ងៃ        (Age days)
"""

import openpyxl
from openpyxl.styles import Font, PatternFill, Border, Side, Alignment
from openpyxl.utils import get_column_letter

STATUS_KM = {
    "110": "មិនទាន់បញ្ជូន",
    "120": "កំពុងប្រមូល",
    "200": "បានទទួល",
    "210": "កំពុងដឹក",
    "300": "កំពុងដឹក",
    "302": "បែងចែក",
    "306": "ដល់មណ្ឌល",
    "309": "ស្កែន",
    "310": "បានទទួល",
    "311": "បន្តដឹក",
    "400": "រង់ចាំ",
    "401": "ដឹកជូន",
    "402": "ដឹកជូន",
    "420": "រង់នៅហាង",
    "430": "ដឹកឡើងវិញ",
    "460": "ដឹកឡើងវិញ",
    "472": "រក្សាទុក",
    "480": "កែអាសយដ្ឋាន",
    "500": "ត្រឡប់",
    "520": "បានត្រឡប់",
    "540": "ត្រឡប់បរាជ័យ",
}

# Column indices in source Excel (0-based)
CI_CREATED     = 1   # CREATED DATE
CI_ORDER       = 2   # ORDER ID
CI_SENDER      = 3   # SENDER
CI_RECEIVER    = 4   # RECEIVER
CI_RECV_PO     = 11  # RECEIVE POST OFFICE  (origin)
CI_DELIV_PO    = 13  # DELIVERY POST OFFICE (destination)
CI_CURRENT_PO  = 15  # CURRENT POST OFFICE
CI_TOTAL_FEE   = 19  # TOTAL FEE (USD)
CI_COD         = 20  # COD (USD)
CI_STATUS      = 23  # CURRENT STATUS
CI_ACTION_USER = 25  # ACTION USER (Staff ID & Name)


def _sc(val):
    if val is None:
        return ""
    s = str(val).strip()
    if " - " in s:
        s = s.split(" - ", 1)[0]
    return s.split()[0].strip() if s else ""


def _parse_created(val, dt_cls):
    if val is None:
        return None
    if isinstance(val, dt_cls):
        return val.date()
    s = str(val).strip().split(" ")[0]
    for fmt in ("%d/%m/%Y", "%Y-%m-%d", "%m/%d/%Y", "%d-%m-%Y"):
        try:
            return dt_cls.strptime(s, fmt).date()
        except ValueError:
            continue
    return None


def _fmt_money(val):
    """Return float or '' for display."""
    try:
        f = float(val)
        return round(f, 2) if f != 0 else ""
    except Exception:
        return ""


def build_mega_detail(source_path, out_path, cfg):
    """Build detail Excel for orders currently at MEGA/DVC/HUB post offices.
    Returns (total_orders, urgent_count).
    """
    from datetime import datetime as _dt

    exclude_statuses = {"410", "201", "520", "99", "100", "-99"}
    excl_test = cfg.get("pivot", {}).get("exclude_test", False)
    test_kw   = cfg.get("pivot", {}).get("test_keywords", ["test"])

    wb_src = openpyxl.load_workbook(source_path, data_only=True)
    ws_src = wb_src.active
    all_rows = list(ws_src.iter_rows(values_only=True))
    if not all_rows:
        return 0, 0
    data_rows = all_rows[1:]

    today = _dt.now().date()

    urgent_rows = []
    normal_rows = []

    for row in data_rows:
        if not row or len(row) <= CI_STATUS:
            continue
        if row[CI_ORDER] is None or str(row[CI_ORDER]).strip() == "":
            continue
        sc = _sc(row[CI_STATUS])
        if sc in exclude_statuses:
            continue
        if excl_test:
            blob = " ".join(str(row[c] or "") for c in (CI_SENDER, CI_RECEIVER)).lower()
            if any(k.lower() in blob for k in test_kw):
                continue

        # Filter: only parcels CURRENTLY at a MEGA/DVC/HUB post office
        po = str(row[CI_CURRENT_PO] or "").strip().upper()
        if not ("MEGA" in po or "HUB" in po or "DVC" in po):
            continue

        created_date = _parse_created(row[CI_CREATED], _dt)
        age = (today - created_date).days if created_date else 0
        is_urgent = age > 1

        action_user = str(row[CI_ACTION_USER] or "").strip() if len(row) > CI_ACTION_USER else ""

        record = {
            "status_km":   STATUS_KM.get(sc, sc),
            "action_user": action_user,
            "origin":      str(row[CI_RECV_PO]  or "").strip(),
            "dest":        str(row[CI_DELIV_PO] or "").strip(),
            "order_id":    str(row[CI_ORDER]    or "").strip(),
            "fee":         _fmt_money(row[CI_TOTAL_FEE] if len(row) > CI_TOTAL_FEE else None),
            "cod":         _fmt_money(row[CI_COD]       if len(row) > CI_COD       else None),
            "created":     str(row[CI_CREATED]  or "").strip(),
            "age":         age,
        }

        if is_urgent:
            urgent_rows.append(record)
        else:
            normal_rows.append(record)

    # Sort: age descending, then order_id
    urgent_rows.sort(key=lambda r: (-r["age"], r["order_id"]))
    normal_rows.sort(key=lambda r: (-r["age"], r["order_id"]))

    # ── Build Excel ──────────────────────────────────────────────────────────
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "MEGA Detail"

    # Styles
    thin        = Side(style="thin", color="BFBFBF")
    bdr         = Border(left=thin, right=thin, top=thin, bottom=thin)
    ctr         = Alignment(horizontal="center", vertical="center", wrap_text=False)
    left_align  = Alignment(horizontal="left",   vertical="center", wrap_text=False)
    right_align = Alignment(horizontal="right",  vertical="center", wrap_text=False)

    hdr_fill   = PatternFill("solid", fgColor="1F4E78")
    urgent_sec = PatternFill("solid", fgColor="C00000")
    normal_sec = PatternFill("solid", fgColor="375623")
    urgent_row = PatternFill("solid", fgColor="FFEBEB")
    normal_bg  = PatternFill("solid", fgColor="FFFFFF")

    hdr_font  = Font(name="Segoe UI", size=10, bold=True, color="FFFFFF")
    sec_font  = Font(name="Segoe UI", size=10, bold=True, color="FFFFFF")
    data_font = Font(name="Segoe UI", size=10, color="1F1F1F")
    id_font   = Font(name="Segoe UI", size=10, color="1F3864", bold=True)
    red_font  = Font(name="Segoe UI", size=10, color="C00000", bold=True)
    gray_font = Font(name="Segoe UI", size=10, color="595959")
    fee_font  = Font(name="Segoe UI", size=10, color="196B24")  # green for fee/cod

    HDR = [
        "ស្ថានភាព",      # 1 — Status KM
        "បុគ្គលិក",       # 2 — Action User (Staff ID & Name)
        "ប.ស.ចេញ",       # 3 — Origin PO
        "ប.ស.ទៅ",        # 4 — Dest PO
        "លេខបញ្ជា",      # 5 — Order ID
        "ថ្លៃ (USD)",    # 6 — Fee
        "COD (USD)",     # 7 — COD
        "កាលបរិច្ឆេទ",  # 8 — Created Date
        "ថ្ងៃ",          # 9 — Age
    ]
    COL_WIDTHS = [26, 32, 12, 12, 16, 10, 10, 18, 6]
    NCOLS = len(HDR)

    def _write_section_header(row_num, label, fill):
        ws.merge_cells(start_row=row_num, start_column=1,
                       end_row=row_num, end_column=NCOLS)
        c = ws.cell(row_num, 1, label)
        c.fill = fill; c.font = sec_font
        c.alignment = left_align; c.border = bdr
        ws.row_dimensions[row_num].height = 18

    def _write_header_row(row_num):
        ws.row_dimensions[row_num].height = 22
        for ci, h in enumerate(HDR, 1):
            c = ws.cell(row_num, ci, h)
            c.fill = hdr_fill; c.font = hdr_font
            c.alignment = ctr; c.border = bdr

    def _write_data_row(row_num, rec, bg_fill):
        ws.row_dimensions[row_num].height = 18
        vals = [
            rec["status_km"],
            rec["action_user"],
            rec["origin"],
            rec["dest"],
            rec["order_id"],
            rec["fee"],
            rec["cod"],
            rec["created"],
            rec["age"],
        ]
        for ci, v in enumerate(vals, 1):
            c = ws.cell(row_num, ci, v)
            c.fill = bg_fill; c.border = bdr
            if ci == 5:          # Order ID — bold blue centered
                c.font = id_font; c.alignment = ctr
            elif ci in (6, 7):   # Fee / COD — green right-aligned
                c.font = fee_font; c.alignment = right_align
            elif ci == 9:        # Age — red if urgent
                c.font = red_font if rec["age"] > 1 else data_font
                c.alignment = ctr
            elif ci in (3, 4, 8):  # POs, Date — centered gray
                c.font = gray_font; c.alignment = ctr
            else:
                c.font = data_font; c.alignment = left_align

    r = 1

    # ── Section 1: URGENT ───────────────────────────────────────────────────
    _write_section_header(r, f"⚠ ប្រញាប់ (Urgent) — {len(urgent_rows)} records", urgent_sec)
    r += 1
    _write_header_row(r); r += 1
    for rec in urgent_rows:
        _write_data_row(r, rec, urgent_row); r += 1

    ws.row_dimensions[r].height = 6; r += 1   # gap

    # ── Section 2: NORMAL ───────────────────────────────────────────────────
    _write_section_header(r, f"✓ ធម្មតា (Normal) — {len(normal_rows)} records", normal_sec)
    r += 1
    _write_header_row(r); r += 1
    for rec in normal_rows:
        _write_data_row(r, rec, normal_bg); r += 1

    for ci, w in enumerate(COL_WIDTHS, 1):
        ws.column_dimensions[get_column_letter(ci)].width = w

    ws.freeze_panes = "A3"
    wb.save(out_path)

    total = len(urgent_rows) + len(normal_rows)
    return total, len(urgent_rows)
