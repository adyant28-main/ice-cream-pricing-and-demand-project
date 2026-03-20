# 🍨 Ice Cream Pricing & Demand Analysis
### Excel · VBA · MySQL · Power BI

> End-to-end ice cream sales analysis — Excel, VBA, MySQL &amp; Power BI | Pricing strategy, demand analysis and forecasting for a Delhi vendor (2022–2023)

---

## The Business Problem

A street ice cream vendor operating across 3 Delhi locations had 2 years of sales data sitting in a spreadsheet — unclean, unanalysed, and underused. Prices hadn't been reviewed against the market. There was no visibility into which flavours were actually profitable, which seasons drove demand, or whether the pricing strategy made sense.

This project answers four questions a business owner would actually ask:

- **What sold, where, and when?**
- **Are we making enough margin on each flavour?**
- **How do our prices compare to the market — and what should we charge?**
- **What happens to profit if we adjust prices or volume?**

---

## Dataset

| Property | Detail |
|---|---|
| Period | April 2022 — December 2023 |
| Records | 148 transactions |
| Flavours | Mango, Chocolate, Vanilla, Strawberry, Kesar Pista |
| Locations | Connaught Place, Lajpat Nagar, Karol Bagh |
| Seasons | Summer, Monsoon, Winter |
| Fields | Date, Flavour, Location, Season, Day Type, Units Sold, Selling Price, Cost/Unit, Weather, Festival Day |

Two versions of the raw data exist intentionally — one for Excel cleaning (.xlsm) and one as a deliberately messy .csv for the SQL cleaning pipeline. Both trace back to the same source; the messiness in the CSV (case inconsistencies, nulls, whitespace, one negative units row) was introduced to demonstrate SQL data wrangling.

---

## Project Workflow
```
Raw Data → Data Cleaning → Pivot Analysis → Cost & P&L Modelling
→ Dynamic Pricing → Demand Forecasting → What-If Analysis
→ Scenario Manager → Solver Optimisation → VBA Automation
→ SQL Pipeline → Power BI Dashboard
```

---

## Tools & Files

| Tool | File | What It Does |
|---|---|---|
| **Excel + VBA** | `IceCreamSeller_pricingprojectFinal.xlsm` | Full analysis workbook — cleaning, pivots, P&L, pricing, forecasting, scenarios, solver, VBA, dashboard |
| **MySQL** | `ice_cream_project_analysis.sql` | 8-step SQL pipeline — raw import to final pricing decision |
| **Power BI** | `IceCream_Dashboard.pbix` | Interactive dashboard — DAX measures, Power Query, slicers |
| **Data** | `raw_icecream_messy.csv` | Raw input for SQL pipeline |
| **Data** | `competitor_benchmark.csv` | Competitor pricing table for SQL JOIN analysis |

---

## Excel Workbook — Sheet by Sheet

The workbook follows a deliberate analyst workflow. Each sheet builds on the last.

**`Raw_Data`** — Original untouched data as imported. Preserved for audit trail.

**`Cleaning_Log`** — Documents every error found and fix applied: wrong case (PROPER function), null costs (AVERAGEIF imputation), duplicate rows, formatting inconsistencies. Kept as a reference — because in a real job, you explain what you changed and why.

**`Cleaned_Data`** — Standardised table with computed columns: Revenue (`Units × Price`), Total Cost (`Units × Cost`), Profit (`Revenue − Cost`), Year. Used as the single source of truth for all downstream analysis.

**`1) Pivot_DemandAnalysis`** — Five pivot tables covering demand by flavour, location, season, day type, and a full flavour-season interaction matrix. Answers: what sells most, and in which conditions.

**`2) Cost Structure`** — Flavour-level cost breakdown: average selling price, average cost per unit, gross margin, and margin %. Kesar Pista leads at 61.2% margin; Vanilla is weakest at 52.7%.

**`3) Pricing_Strategy`** — Benchmarks our prices against the local competitor market (Company X). Every single flavour is priced below market. Mango has the largest gap (−₹7.39), Kesar Pista the smallest (−₹1.00).

**`4) Demand Forecasting`** — Uses historical seasonal demand patterns to project 2024 Monsoon units by flavour. Applies proportional share logic from 2022+2023 combined Monsoon data.

**`5) Profit & Loss`** — Full 2023 P&L: units, avg price, revenue, cost, gross profit, and margin % per flavour. Total 2023: ₹2,04,493 revenue, ₹1,15,209 gross profit, 56.4% blended margin.

**`Season Pricing Dynamics`** — The strategic centrepiece. Models 3 pricing scenarios for the 2024 Monsoon season using forecasted demand:
- **Baseline** (current recommended prices): ₹25,698 profit
- **Premium** (+10–15% price increase): ₹28,593 profit — best outcome
- **Volume Boost** (price cut to drive units): ₹23,132 profit — worst outcome

Conclusion: raising prices outperforms cutting them. Volume alone does not compensate for margin loss.

**`DASHBOARD`** — Single-page Excel dashboard with KPI cards, charts, and a VBA-powered Data Refresh button. Built for a non-technical business owner to use.

---

## VBA

Two macros in the workbook:

**`RefreshDashboard`** — Refreshes all pivot tables across the workbook in one click, recalculates derived fields, and resets slicer selections. Assigned to the dashboard button.

**`ExportPDFReport`** — Exports the dashboard sheet as a formatted PDF with timestamp in the filename. One-click report generation for sharing with stakeholders who don't have Excel.
```vba
Sub ExportPDFReport()
    Dim fileName As String
    fileName = "IceCream_Report_" & Format(Now(), "YYYYMMDD") & ".pdf"
    Sheets("DASHBOARD").ExportAsFixedFormat Type:=xlTypePDF, _
        Filename:=fileName, Quality:=xlQualityStandard
    MsgBox "Report saved: " & fileName
End Sub
```

---

## SQL Pipeline — 8 Steps

**Step 1 — Database & Table Creation**
Creates `ice_cream_project` database. Defines `raw_sales` and `competitor_benchmark` table schemas. Data imported via MySQL Table Import Wizard.

**Step 2 — Data Discovery**
Quality audit before touching anything: counts nulls per column, flags negative units, finds invalid prices, checks distinct values in categorical columns for inconsistencies.

**Step 3 — Data Cleaning**
Built as a single `CREATE TABLE AS` with two CTEs:
- `flavour_averages` — calculates per-flavour average cost and price (not global average — intentional, to impute nulls at flavour level)
- `cleaned_base` — standardises case (`UPPER + TRIM`), fixes the `VANILA → VANILLA` typo, imputes nulls using `COALESCE + NULLIF`, parses dates with `STR_TO_DATE`, extracts Year and Month

Duplicate removal via `ROW_NUMBER() OVER (PARTITION BY sale_date, flavour, location)`.

**Step 4 — Business Summary**
Single aggregation: total units, revenue, profit, and average price for 2023.

**Step 5 — Flavour Demand Segmentation**
`NTILE(4)` window function over a subquery to assign demand quartiles across 5 flavours. Window function runs on the aggregated result, not the raw table — correct MySQL pattern.

**Step 6 — Advanced Analytics**
Three analyses:
- Competitor pricing comparison (JOIN + CASE WHEN → PREMIUM / DISCOUNT / MATCH)
- Price band demand analysis (Low / Mid / High buckets)
- Price sensitivity index per flavour — a range-ratio proxy, not classical elasticity, labelled accordingly

**Step 7 — Month-on-Month Trend**
CTE for monthly aggregation + `LAG()` window function to calculate MoM growth % for each month in 2023.

**Step 8 — Final Pricing Decision Query**
CTE `flavour_metrics` aggregates all flavour-level KPIs and joins competitor data. Main SELECT adds price gap, margin %, `RANK()` by demand, and a multi-condition `CASE WHEN` pricing decision (INCREASE / REDUCE / MAINTAIN) with priority order: margin check first, then demand tier, then competitor position. Final step creates a `VIEW` as a reusable reporting layer.

---

## Power BI Dashboard

**Source:** Excel `Cleaned_Data` sheet + `Competitor_Benchmark_Data` sheet

**Power Query transformations:**
- Type casting all columns, renaming for consistency
- Filtering blank Season rows
- Adding `Month`, `Month_Name`, `Quarter`, `Margin_Pct` columns
- Competitor table filtered to local budget segment only
- Auto-generated `Date_Table` with Season logic built in

**DAX Measures (17):**

| Measure | Pattern Used |
|---|---|
| Total Revenue / Profit / Units | SUM |
| Avg Selling Price | AVERAGE |
| Profit Margin % | DIVIDE with zero-division handling |
| Revenue LY / Units LY | CALCULATE + SAMEPERIODLASTYEAR |
| YoY Revenue Growth % | DIVIDE + time intelligence |
| YoY Units Growth % | DIVIDE + time intelligence |
| Weekend Revenue | CALCULATE + filter context |
| Festival Day Revenue | CALCULATE + filter context |
| Price vs Competitor Gap | VAR + AVERAGE |
| MoM Units Growth % | VAR + nested CALCULATE |
| Best Flavour / Peak Season | TOPN + FIRSTNONBLANK |

**Calculated Columns:**
- `Price_Band` — IF logic bucketing Low / Mid / High
- `Pricing_Action` — LOOKUPVALUE against competitor table → ⬆ INCREASE / ✔ MAINTAIN / ⬇ REDUCE
- `Season_Order` and `Month_Sort` — for correct axis sorting

**Visuals:** 6 KPI cards · Clustered bar (Profit by Flavour) · Line chart (Monthly trend 2022 vs 2023) · Donut (Season share) · Clustered bar (Our price vs Competitor) · Matrix (Flavour × Season) · Stacked bar (Price Band × Day Type) · 4 tile slicers

---

## Key Findings

**Demand**
- 2023: 5,221 units · ₹2,12,044 revenue · ₹1,20,558 profit · 56.8% blended margin
- Revenue grew 20% year-on-year (2022 → 2023)
- Mango is the top flavour — 1,855 units, ₹41,634 profit (35% of total demand)
- Summer drives 55% of annual demand; weekends generate 58% of revenue

**Pricing**
- Every flavour is priced below the local market competitor
- Largest gap: Mango at −₹7.39 · Smallest gap: Kesar Pista at −₹1.00
- Healthy margins (52–61%) across all flavours confirm room to raise prices

**Scenario Analysis**
- Premium pricing scenario: ₹28,593 projected Monsoon profit (+11.3% vs baseline)
- Volume Boost scenario: ₹23,132 — cutting prices to drive volume underperforms
- Recommendation: raise prices, do not chase volume

---

## Skills Demonstrated

**SQL** — DDL/DML, CTEs, subqueries, window functions (RANK, NTILE, LAG, ROW_NUMBER), JOINs, CASE WHEN, NULLIF/COALESCE, STR_TO_DATE, CREATE VIEW

**Excel** — AVERAGEIF, SUMIF, VLOOKUP, PROPER, TRIM, IF nesting, Pivot Tables, Scenario Manager, Solver, conditional formatting, data validation

**VBA** — Subroutines, workbook/sheet object model, PDF export, pivot refresh loops, event-driven macros

**Power BI** — Power Query (M), relationship modelling, DAX (CALCULATE, SAMEPERIODLASTYEAR, DIVIDE, VAR, TOPN, LOOKUPVALUE, FIRSTNONBLANK), time intelligence, calculated columns, slicers

**Analytics** — Data cleaning, EDA, competitor benchmarking, price sensitivity, demand forecasting, scenario modelling, P&L construction, margin analysis

---
