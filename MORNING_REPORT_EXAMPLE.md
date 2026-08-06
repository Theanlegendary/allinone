# `/morning zone1` Excel Example - BATP001

## Command
```
/morning zone1
```

## Excel Output: "Morning_Zone1_03.08_08H30.xlsx"

---

### Sheet Structure
The Excel has **4 tables** on one sheet (same structure as `/total`):
1. **Delivery** (Under delivery orders)
2. **Not Assign** (At branch, not assigned to driver yet)
3. **Pickup** (Waiting for pickup from customer)
4. **Send Mega** (In transit to mega hub)

---

## Example Data for BATP001

### Table 1: Delivery (Under Delivery)

```
┌──────┬─────────────┬──────────────┬───────────┬──────────┬────────────┬──────────────┬────────┬─────────┬──────────┬─────────┐
│ ZONE │ POST OFFICE │   CURRENT    │  ORDER ID │ RECEIVER │STATUS_CODE │  NEXT_STEP   │  FEE   │   COD   │   Age    │ 10H KPI │
│      │   HANDLE    │ POST OFFICE  │           │          │            │              │ (USD)  │  (USD)  │          │         │
├──────┼─────────────┼──────────────┼───────────┼──────────┼────────────┼──────────────┼────────┼─────────┼──────────┼─────────┤
│Zone 1│  BATP001    │   BATP001    │ TB5001234 │ Sokha    │    401     │ ដឹកជញ្ជូន   │  2.50  │  45.00  │🟢 2h 15m │  10h    │
│Zone 1│  BATP001    │   BATP001    │ TB5001235 │ Dara     │    402     │ ដឹកជូនឡើងវិញ │  3.00  │  0.00   │🟢 5h 30m │  10h    │
│Zone 1│  BATP001    │   BATP001    │ TB5001236 │ Sophea   │    401     │ ដឹកជញ្ជូន   │  2.50  │  25.00  │🔴 11h 45m│  10h    │
└──────┴─────────────┴──────────────┴───────────┴──────────┴────────────┴──────────────┴────────┴─────────┴──────────┴─────────┘
```

**Explanation**:
- **TB5001234**: Real age 14h 15m → Adjusted **2h 15m** (14:15 - 12:00) → 🟢 Green
- **TB5001235**: Real age 17h 30m → Adjusted **5h 30m** (17:30 - 12:00) → 🟢 Green  
- **TB5001236**: Real age 23h 45m → Adjusted **11h 45m** (23:45 - 12:00) → 🔴 Red (>10h)

---

### Table 2: Not Assign (At Branch, Not Assigned)

```
┌──────┬─────────────┬──────────────┬───────────┬──────────┬────────────┬──────────────┬────────┬─────────┬──────────┬─────────┐
│ ZONE │ POST OFFICE │   CURRENT    │  ORDER ID │ RECEIVER │STATUS_CODE │  NEXT_STEP   │  FEE   │   COD   │   Age    │ 10H KPI │
│      │   HANDLE    │ POST OFFICE  │           │          │            │              │ (USD)  │  (USD)  │          │         │
├──────┼─────────────┼──────────────┼───────────┼──────────┼────────────┼──────────────┼────────┼─────────┼──────────┼─────────┤
│Zone 1│  BATP001    │   BATP001    │ TB5001240 │ Mony     │    306     │ចាត់អ្នកដឹក   │  2.50  │  30.00  │🟢 3h 20m │  10h    │
│Zone 1│  BATP001    │   BATP001    │ TB5001241 │ Ratana   │    306     │ចាត់អ្នកដឹក   │  3.00  │  50.00  │🟢 6h 10m │  10h    │
│Zone 1│  BATP001    │   BATP001    │ TB5001242 │ Veasna   │    400     │ចាត់អ្នកដឹក   │  2.50  │  15.00  │🔴 13h 40m│  10h    │
│Zone 1│  BATP001    │   BATP001    │ TB5001243 │ Sreymom  │    420     │ចាកចេញពីស្ថានីយ៍│  3.50  │  0.00   │🟢 8h 00m │  10h    │
└──────┴─────────────┴──────────────┴───────────┴──────────┴────────────┴──────────────┴────────┴─────────┴──────────┴─────────┘
```

**Explanation**:
- **TB5001240**: Real age 15h 20m → Adjusted **3h 20m** → 🟢 Green
- **TB5001241**: Real age 18h 10m → Adjusted **6h 10m** → 🟢 Green
- **TB5001242**: Real age 25h 40m → Adjusted **13h 40m** → 🔴 Red (urgent!)
- **TB5001243**: Status **420** (waiting by design) → **Always 🟢 Green** (special status)

---

### Table 3: Pickup (Waiting for Customer Pickup)

```
┌──────┬─────────────┬──────────────┬───────────┬──────────┬────────┐
│ ZONE │ POST OFFICE │   CURRENT    │  ORDER ID │ Cus name │  Phone │
│      │   HANDLE    │ POST OFFICE  │           │          │        │
├──────┼─────────────┼──────────────┼───────────┼──────────┼────────┤
│Zone 1│  BATP001    │   BATP001    │ TB5001250 │ Bopha    │012345678│
│Zone 1│  BATP001    │   BATP001    │ TB5001251 │ Chan     │098765432│
└──────┴─────────────┴──────────────┴───────────┴──────────┴────────┘
```

**Note**: Pickup section doesn't show Age column (no age calculation for pickup orders).

---

### Table 4: Send Mega (In Transit)

```
┌──────┬─────────────┬──────────────┬───────────┬────────────┬──────────────┐
│ ZONE │ POST OFFICE │   CURRENT    │  ORDER ID │STATUS_CODE │  NEXT_STEP   │
│      │   HANDLE    │ POST OFFICE  │           │            │              │
├──────┼─────────────┼──────────────┼───────────┼────────────┼──────────────┤
│Zone 1│  BATP001    │   MEGA1      │ TB5001260 │    210     │បញ្ជូនទៅឃ្លាំងធំ│
│Zone 1│  BATP001    │   DVCMEGA1   │ TB5001261 │    230     │បញ្ជូនទៅឃ្លាំងធំ│
└──────┴─────────────┴──────────────┴───────────┴────────────┴──────────────┘
```

**Note**: Send Mega section doesn't show Age/KPI (focus is on tracking location).

---

## Visual Comparison: `/total` vs `/morning`

### Scenario: Report run at **8:00 AM**, Order scanned at **5:00 PM yesterday**

#### `/total zone1` (Normal Report)
```
Age: 🔴 15h 00m    (Full elapsed time since 5 PM yesterday)
Status: RED - Appears urgent
```

#### `/morning zone1` (Adjusted Report)
```
Age: 🟢 3h 00m     (15h - 12h overnight = 3h actionable time)
Status: GREEN - Actually OK, most time was overnight
```

---

## File Name Format

```
Morning_Zone1_03.08_08H30.xlsx
└─────┬──────┘ └───┬────┘ └──┬──┘
   Command      Date      Time
   identifier   (DD.MM)   (HHHmm)
```

---

## Summary Image (Sent Before Excel)

The bot also sends a summary image showing:

```
┌────────────────────────────────────────────┐
│  ☀️ ZONE 1 MORNING Report (Age -12h)      │
│  03/08/2026 08:30                          │
├────────────────────────────────────────────┤
│  POST OFFICE │ Pickup │ Delivery │ Branch │
├──────────────┼────────┼──────────┼────────┤
│  BATP001     │   3    │    11    │   36   │
│  BANP001     │   5    │    28    │   44   │
│  ... (other Zone 1 branches)              │
├────────────────────────────────────────────┤
│  TOTAL       │   25   │   180    │   250  │
└────────────────────────────────────────────┘

📝 Age adjusted: -12 hours (excludes overnight hold)
```

---

## Color Legend in Excel

- 🟢 **Green (0-10h)**: Package age ≤ 10h after adjustment → On track
- 🔴 **Red (>10h)**: Package age > 10h after adjustment → Urgent action needed
- 🟢 **Special Green**: Status 420/472 (by design) → Always green unless >7 days old

---

## When Colors Change

**Example with adjustment**:

| Real Age | Adjusted Age (-12h) | Color |
|----------|---------------------|-------|
| 9h 30m   | 0h 0m (capped)      | 🟢    |
| 14h 20m  | 2h 20m              | 🟢    |
| 21h 45m  | 9h 45m              | 🟢    |
| 22h 15m  | 10h 15m             | 🔴    |
| 25h 00m  | 13h 00m             | 🔴    |

**Without adjustment** (regular `/total`):

| Real Age | Color |
|----------|-------|
| 9h 30m   | 🟢    |
| 14h 20m  | 🔴    |
| 21h 45m  | 🔴    |
| 22h 15m  | 🔴    |
| 25h 00m  | 🔴    |

---

## Caption Text (Sent with Excel)

```
☀️ ZONE 1 MORNING Report (Age -12h)  03/08/2026 08:30
Delivery: 180 (U:25)  |  Not Assign: 250 (U:45)  |  Pickup: 25 (U:3)  |  Send Mega: 60 (U:8)
Grand Total: 515  |  Total Urgent: 81
📝 Age adjusted: -12 hours (excludes overnight hold)
```

---

## Practical Use Case

**Manager at 8 AM**:
1. Runs `/morning zone1`
2. Sees BATP001 has 11 orders in Delivery
3. Only **1 order is RED** (11h 45m adjusted age) → Focus on this one!
4. Other 10 orders are GREEN (most age was overnight) → Can wait

**Without `/morning`** (using regular `/total`):
- Would see **8 RED orders** (including overnight time)
- Might panic and waste time on packages that just need a few more hours
- False urgency from overnight hold time

---

This is exactly what the Excel will look like! The key difference is the **Age column** shows reduced hours, making morning prioritization much more accurate. 🎯
