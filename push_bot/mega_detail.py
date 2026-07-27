"""mega_detail.py - Detail Excel for MEGA1 and DVMEGA hub orders (Khmer).

Filters orders that passed through the MEGA1 or DVCMEGA1 origin hub
(col 35 = ACTION POST OFFICE after STATUS 306 AT ORIGIN HUB).

Layout:
  Section 1 — Urgent (age > 1 day) — light red background
  Section 2 — Normal               — white background

Columns:
  1. ស្ថានភាព   (Status KM)
  2. អតិថិជន   (Customer / Receiver name)
  3. ប.ស.ចេញ   (Origin PO  = RECEIVE POST OFFICE)
  4. ប.ស.ទៅ    (Dest PO    = DELIVERY POST OFFICE)
  5. លេខបញ្ជា  (ORDER ID)
  6. កាលបរិច្ឆេទ (Created Date)
  7. ថ្ងៃ       (Age days)
"""

import openpyxl
from openpyxl.styles import Font, PatternFill, Border, Side, Alignment
from openpyxl.utils import get_column_letter

STATUS_KM = {
    "110": "មិនទាន់បញ្ជូន",
    "120": "កំពុងប្រមូល",
    "200": "បានទទួល",
    "210": "កំពុងដឹកជញ្ជូន",
    "300": "កំពុងដឹកជញ្ជូន",
    "302": "បែងចែកជូន",
    "306": "ដល់មណ្ឌល",
    "309": "ស្កែនបញ្ជូន",
    "310": "បានទទួលអ្នកទទួល",
    "311": "បែងចែកដឹកបន្ត",
    "400": "រង់ចាំប្រគល់",
    "401": "កំពុងដឹកជូន",
    "402": "កំពុងដឹកជូន",
    "420": "រង់ចាំយកនៅហាង",
    "430": "ដឹកម្ដងទៀត",
    "460": "ដឹកម្ដងទៀត",
    "472": "រក្សាទុក",
    "480": "កែអាសយដ្ឋាន",
    "500": "ផ្ញើត្រឡប់",
    "520": "បានត្រឡប់",
    "540": "ត្រឡប់បរាជ័យ",
}

# Column indices in source Excel (0-based)
CI_CREATED    = 1   # CREATED DATE
CI_ORDER      = 2   # ORDER ID
CI_SENDER     = 3   # SENDER
CI_RECEIVER   = 4   # RECEIVER
CI_RECV_PO    = 11  # RECEIVE POST OFFICE  (origin)
CI_DELIV_PO   = 13  # DELIVERY POST OFFICE (destination)
CI_CURRENT_PO = 15  # CURRENT POST OFFICE
CI_STATUS     = 23  # CURRENT STATUS
CI_HUB_CODE   = 35  # ACTION POST OFFICE at ORIGIN HUB (MEGA1 / DVCMEGA1)

# Hub code -> display label
MEGA_HUB_LABELS = {
    "MEGA1":    "MEGA1",
    "DVCMEGA1": "DVMEGA",
}


def _sc(val):
    if val is None:
        return ""
    s = str(val).strip()
    if " - " in s:
        s = s.split(" - ", 1)[0]
    return s.split()[0].strip() if s else ""


def _clean_person(val):
    """Strip phone prefix: '0712345678 - Kim Heang' -> 'Kim Heang'."""
    if val is None:
        return ""
    s = str(val).strip()
    if " - " in s:
        return s.split(" - ", 1)[1].strip()
    return s


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


def build_mega_detail(source_path, out_path, cfg):
    """Build detail Excel for orders at MEGA1 / DVMEGA hubs.
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
        if not row or len(row) <= CI_HUB_CODE:
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

        # Only orders that passed through MEGA1 or DVCMEGA1 hub
        hub_code = str(row[CI_HUB_CODE] or "").strip().upper()
        hub_label = MEGA_HUB_LABELS.get(hub_code)
        if hub_label is None:
            continue

        created_date = _parse_created(row[CI_CREATED], _dt)
        age = (today - created_date).days if created_date else 0
        is_urgent = age > 1

        record = {
            "hub":       hub_label,
            "status":    sc,
            "status_km": STATUS_KM.get(sc, sc),
            "customer":  _clean_person(row[CI_RECEIVER]) or _clean_person(row[CI_SENDER]),
            "origin":    str(row[CI_RECV_PO]  or "").strip(),
            "dest":      str(row[CI_DELIV_PO] or "").strip(),
            "order_id":  str(row[CI_ORDER]    or "").strip(),
            "created":   str(row[CI_CREATED]  or "").strip(),
            "age":       age,
        }

        if is_urgent:
            urgent_rows.append(record)
        else:
            normal_rows.append(record)

    # Sort each section: by hub (MEGA1 first, DVMEGA second), then age desc
    _hub_order = {"MEGA1": 0, "DVMEGA": 1}
    urgent_rows.sort(key=lambda r: (_hub_order.get(r["hub"], 9), -r["age"], r["order_id"]))
    normal_rows.sort(key=lambda r: (_hub_order.get(r["hub"], 9), -r["age"], r["order_id"]))

    # ── Build Excel ──────────────────────────────────────────────────────────
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "MEGA Detail"

    # Styles
    thin        = Side(style="thin", color="BFBFBF")
    bdr         = Border(left=thin, right=thin, top=thin, bottom=thin)
    ctr         = Alignment(horizontal="center", vertical="center", wrap_text=False)
    left_align  = Alignment(horizontal="left",   vertical="center", wrap_text=False)

    hdr_fill    = PatternFill("solid", fgColor="1F4E78")    # dark blue
    urgent_sec  = PatternFill("solid", fgColor="C00000")    # dark red (section title)
    normal_sec  = PatternFill("solid", fgColor="375623")    # dark green (section title)
    urgent_row  = PatternFill("solid", fgColor="FFEBEB")    # light red
    normal_bg   = PatternFill("solid", fgColor="FFFFFF")    # white

    hdr_font    = Font(name="Segoe UI", size=10, bold=True, color="FFFFFF")
    sec_font    = Font(name="Segoe UI", size=10, bold=True, color="FFFFFF")
    data_font   = Font(name="Segoe UI", size=10, color="1F1F1F")
    id_font     = Font(name="Segoe UI", size=10, color="1F3864", bold=True)
    red_font    = Font(name="Segoe UI", size=10, color="C00000", bold=True)
    gray_font   = Font(name="Segoe UI", size=10, color="595959")

    # Column headers (Khmer)
    HDR = [
        "ផ្ទះ",             # 1 — Hub (MEGA1 / DVMEGA)
        "ស្ថានភាព",         # 2 — Status KM
        "អតិថិជន",          # 3 — Customer
        "ប.ស.ចេញ",          # 4 — Origin PO
        "ប.ស.ទៅ",           # 5 — Dest PO
        "លេខបញ្ជា",         # 6 — Order ID
        "កាលបរិច្ឆេទ",      # 7 — Created Date
        "ថ្ងៃ",             # 8 — Age Days
    ]
    COL_WIDTHS = [10, 26, 24, 14, 14, 16, 18, 7]
    NCOLS = len(HDR)

    def _write_section_header(row_num, label, fill):
        ws.merge_cells(start_row=row_num, start_column=1,
                       end_row=row_num, end_column=NCOLS)
        c = ws.cell(row_num, 1, label)
        c.fill      = fill
        c.font      = sec_font
        c.alignment = left_align
        c.border    = bdr
        ws.row_dimensions[row_num].height = 18

    def _write_header_row(row_num):
        ws.row_dimensions[row_num].height = 22
        for ci, h in enumerate(HDR, 1):
            c = ws.cell(row_num, ci, h)
            c.fill      = hdr_fill
            c.font      = hdr_font
            c.alignment = ctr
            c.border    = bdr

    def _write_data_row(row_num, rec, bg_fill):
        ws.row_dimensions[row_num].height = 18
        vals = [
            rec["hub"],
            rec["status_km"],
            rec["customer"],
            rec["origin"],
            rec["dest"],
            rec["order_id"],
            rec["created"],
            rec["age"],
        ]
        for ci, v in enumerate(vals, 1):
            c = ws.cell(row_num, ci, v)
            c.fill   = bg_fill
            c.border = bdr
            if ci == 6:   # Order ID → bold blue
                c.font      = id_font
                c.alignment = ctr
            elif ci == 8:  # Age → red if urgent
                c.alignment = ctr
                c.font = red_font if rec["age"] > 1 else data_font
            elif ci in (1, 4, 5, 7):  # Hub, POs, Date → centered gray
                c.font      = gray_font
                c.alignment = ctr
            else:
                c.font      = data_font
                c.alignment = left_align

    r = 1

    # ── Section 1: URGENT ───────────────────────────────────────────────────
    _write_section_header(r, f"⚠ ប្រញាប់ (Urgent) — {len(urgent_rows)} records", urgent_sec)
    r += 1
    _write_header_row(r)
    r += 1
    for rec in urgent_rows:
        _write_data_row(r, rec, urgent_row)
        r += 1

    # Gap row
    ws.row_dimensions[r].height = 8
    r += 1

    # ── Section 2: NORMAL ───────────────────────────────────────────────────
    _write_section_header(r, f"✓ ធម្មតា (Normal) — {len(normal_rows)} records", normal_sec)
    r += 1
    _write_header_row(r)
    r += 1
    for rec in normal_rows:
        _write_data_row(r, rec, normal_bg)
        r += 1

    # Column widths
    for ci, w in enumerate(COL_WIDTHS, 1):
        ws.column_dimensions[get_column_letter(ci)].width = w

    # Freeze below section 1 header + column header
    ws.freeze_panes = "A3"

    wb.save(out_path)
    total = len(urgent_rows) + len(normal_rows)
    return total, len(urgent_rows)
