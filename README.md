# 🍨 Ice Cream Pricing & Demand Analytics

### Excel · VBA · MySQL · Power BI

> **End-to-end analytics project:** From messy raw data to strategic pricing recommendations. Complete workflow across Excel (with VBA), SQL (8-step pipeline), and Power BI (interactive dashboard).

---

## 📌 The Business Problem

A street ice cream vendor operating across 3 Delhi locations had **2 years of sales data** sitting in a spreadsheet — unclean, unanalysed, and underused. Prices hadn't been reviewed against the market. There was no visibility into:
- Which flavours were actually profitable
- Which seasons drove demand
- Whether the pricing strategy made sense

**This project answers four questions a business owner would actually ask:**

1. **What sold, where, and when?** — Demand patterns by flavour, season, location, day type
2. **Are we making enough margin?** — Cost structure and profitability per flavour
3. **How do our prices compare to the market?** — Competitor benchmarking and pricing strategy
4. **What happens to profit if we adjust prices?** — Scenario modelling and what-if analysis

---

## 📊 Dataset

| Property | Detail |
|----------|--------|
| **Period** | April 2022 — December 2023 |
| **Records** | 148 transactions |
| **Flavours** | Mango, Chocolate, Vanilla, Strawberry, Kesar Pista |
| **Locations** | Connaught Place, Lajpat Nagar, Karol Bagh |
| **Seasons** | Summer, Monsoon, Winter |
| **Fields** | Date, Flavour, Location, Season, Day Type, Units Sold, Selling Price, Cost/Unit, Weather, Festival Day |

> **Note:** Two versions of raw data exist intentionally — one for Excel cleaning (within the workbook) and one as a deliberately messy `.csv` for the SQL cleaning pipeline. Both trace back to the same source; the messiness in the CSV (case inconsistencies, nulls, whitespace, negative units) was introduced to demonstrate SQL data wrangling skills.

---

## 🔄 Project Workflow
Excel:
Raw Data >Data Cleaning → Pivot Demand Analysis → Cost & P&L Modelling
→ Dynamic Pricing → Demand Forecasting → 
→ Scenario Manager →  VBA Automation
 SQL Pipeline:
 (Data Cleaning)> Exploratory Analysis > Advanced Analysis > Recommendation > Summary
 Power BI: 
 Loading Data > Power Query > DAX > Measures and Columns > Charts and Analysis > Dashboard

 
---

## 📁 Repository Structure
ice-cream-pricing-and-demand-project/
│
├── README.md # This file
│
├── excel/
│ └── IceCreamSeller_pricingprojectFinal.xlsm # Main Excel workbook with VBA
│
├── sql/
│ └── ice_cream_project_analysis.sql # Complete 8-step SQL pipeline
│
├── powerbi/
│ └── IceCream_Dashboard.pbix # Interactive Power BI dashboard
│
├── data/
│ ├── raw_icecream_messy.csv # Messy data for SQL pipeline
│ └── competitor_benchmark.csv # Competitor pricing data
│
└── output/
└── pricing_recommendations.csv # Export of final decisions


---

## 📊 Excel Workbook — Sheet by Sheet

The workbook follows a deliberate analyst workflow. Each sheet builds on the last.

| Sheet | Purpose |
|-------|---------|
| **`Raw_Data`** | Original untouched data as imported. Preserved for audit trail. |
| **`Cleaning_Log`** | Documents every error found and fix applied: wrong case (PROPER function), null costs (AVERAGEIF imputation), duplicate rows, formatting inconsistencies. |
| **`Cleaned_Data`** | Standardised table with computed columns: Revenue (`Units × Price`), Total Cost (`Units × Cost`), Profit (`Revenue − Cost`), Year. Single source of truth. |
| **`1) Pivot_DemandAnalysis`** | Five pivot tables covering demand by flavour, location, season, day type, and full flavour-season interaction matrix. |
| **`2) Cost Structure`** | Flavour-level cost breakdown: average selling price, average cost per unit, gross margin, and margin %. |
| **`3) Pricing_Strategy`** | Benchmarks our prices against local market. Every flavour priced below market. |
| **`4) Demand Forecasting`** | Projects 2024 demand by flavour using historical seasonal patterns. |
| **`5) Profit & Loss`** | Full 2023 P&L with units, revenue, cost, gross profit, and margin % per flavour. |
| **`Season Pricing Dynamics`** | **Strategic centrepiece.** Models 3 pricing scenarios for 2024 Monsoon using forecasted demand. |
| **`DASHBOARD`** | Single-page Excel dashboard with KPI cards, charts, and VBA-powered refresh button. |

---

## 🔧 VBA Macros

Two macros in the workbook, assigned to dashboard buttons:

### 1. `RefreshDashboard`
Refreshes all pivot tables across the workbook in one click, recalculates derived fields.

```vba
Sub RefreshDashboard()
    Dim pt As PivotTable
    For Each ws In ThisWorkbook.Worksheets
        For Each pt In ws.PivotTables
            pt.RefreshTable
        Next pt
    Next ws
    ThisWorkbook.RefreshAll
    MsgBox "Dashboard refreshed successfully!"
End Sub

## 🗄️ SQL Pipeline — 8 Steps

| Step | Description | Key Techniques |
|------|-------------|---------------|
| 1 | Database & Table Creation | DDL, schema design |
| 2 | Data Discovery | NULL checks, negative values, distinct values audit |
| 3 | Data Cleaning | CTEs, COALESCE, NULLIF, STR_TO_DATE, ROW_NUMBER() deduplication |
| 4 | Business Summary | Aggregations, 2023 performance |
| 5 | Flavour Demand Segmentation | NTILE(4) window function |
| 6 | Advanced Analytics | Competitor JOIN, price band analysis, price sensitivity proxy |
| 7 | Month-on-Month Trend | LAG() window function, MoM growth % |
| 8 | Final Pricing Decision | CTE + RANK() + multi-condition CASE WHEN with margin priority |

---

## 📈 Power BI Dashboard

**Source:** Excel `Cleaned_Data` sheet + `Competitor_Benchmark_Data` sheet

### Power Query (M) — Key Transformations
```powerquery
let
    Source = Excel.Workbook(File.Contents("excel/IceCreamSeller_pricingprojectFinal.xlsm"), null, true),
    Cleaned_Sheet = Source{[Item="Cleaned_Data",Kind="Sheet"]}[Data],
    PromotedHeaders = Table.PromoteHeaders(Cleaned_Sheet, [PromoteAllScalars=true]),
    SetTypes = Table.TransformColumnTypes(PromotedHeaders, {
        {"Date", type date}, {"Flavour", type text}, {"Location", type text},
        {"Season", type text}, {"Day_Type", type text}, {"Units_Sold", Int64.Type},
        {"Selling_Price", type number}, {"Cost_Per_Unit", type number},
        {"Weather", type text}, {"Festival_Day", type text}
    }),
    AddColumns = Table.AddColumn(SetTypes, "Month", each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddColumns, "Month_Name", each Date.ToText([Date], "MMM"), type text),
    AddMargin = Table.AddColumn(AddMonthName, "Margin_Pct", each [Profit] / [Revenue] * 100, type number)
in
    AddMargin

Key DAX Measures
Category
	
Measure
	
DAX Pattern
KPIs
	
Total Revenue
	
SUM('Sales'[Revenue])
	
Total Profit
	
SUM('Sales'[Profit])
	
Margin %
	
DIVIDE([Total Profit], [Total Revenue], 0)
YoY
	
Revenue YoY %
	
DIVIDE([Total Revenue] - [Revenue LY], [Revenue LY])
Day Type
	
Weekend Premium %
	
DIVIDE([Weekend Revenue] - [Weekday Revenue], [Weekday Revenue])
Pricing
	
Price Gap
	
AVERAGE('Sales'[Selling_Price]) - AVERAGE('Competitor'[Avg_Price])
Ranking
	
Best Flavour
	
TOPN(1, VALUES('Sales'[Flavour]), [Total Units])
Dashboard Pages
Page
	
Visuals
Executive Summary
	
4 KPI cards · Revenue by Flavour (bar) · Revenue by Season (donut) · Monthly trend (line) · Key insights table
Flavour & Season
	
Flavour-Season heatmap (matrix) · Flavour ranking table · Season comparison · MoM growth waterfall
Pricing Strategy
	
Price comparison bar · Price gap analysis table · Recommendation card · Price vs Demand scatter
Location & Day Type
	
Location performance · Weekend premium gauge · Day type comparison · Festive day impact
Slicers (Synced Across All Pages)

    📅 Year (2022, 2023)
    ☀️ Season (Summer, Monsoon, Winter)
    🍦 Flavour (Multi-select)
    📍 Location

💡 Key Findings
Demand Insights
Metric
	
2023 Value
Total Units
	
5,221
Total Revenue
	
₹2,12,044
Total Profit
	
₹1,20,558
Blended Margin
	
56.8%

    🥭 Mango is the top flavour — 1,855 units, 35% of total demand
    ☀️ Summer drives 55% of annual sales
    🗓️ Weekends generate 58% of revenue (27% higher than weekdays)
    🏙️ Connaught Place accounts for 58.6% of total revenue

Pricing Insights
Flavour
	
Our Price
	
Competitor Avg
	
Gap
	
Margin %
Mango
	
₹37.43
	
₹45.00
	
-₹7.57
	
56.1%
Chocolate
	
₹41.56
	
₹44.00
	
-₹2.44
	
55.6%
Vanilla
	
₹28.44
	
₹35.00
	
-₹6.56
	
52.7%
Strawberry
	
₹34.73
	
₹39.00
	
-₹4.27
	
55.6%
Kesar Pista
	
₹57.89
	
₹60.00
	
-₹2.11
	
61.2%

    ✅ Every flavour is priced below the local market competitor with healthy margins (52–61%), confirming room to raise prices.

Scenario Analysis (2024 Monsoon)
Scenario
	
Projected Profit
	
vs Baseline
Premium (+10–15% price)
	
₹28,593
	
+11.3%
Baseline (current prices)
	
₹25,698
	
—
Volume Boost (price cut)
	
₹23,132
	
-10.0%

    🎯 Conclusion: Raising prices outperforms cutting them. Volume alone does not compensate for margin loss.

Final SQL Decision

1

🛠️ Skills Demonstrated
Category
	
Skills
SQL
	
DDL/DML, CTEs, subqueries, window functions (RANK, NTILE, LAG, ROW_NUMBER), JOINs, CASE WHEN, NULLIF/COALESCE, STR_TO_DATE, CREATE VIEW
Excel
	
AVERAGEIF, SUMIF, VLOOKUP, PROPER, TRIM, IF nesting, Pivot Tables, Scenario Manager, Solver, conditional formatting, data validation
VBA
	
Subroutines, workbook/sheet object model, PDF export, pivot refresh loops, event-driven macros
Power BI
	
Power Query (M), relationship modelling, DAX (CALCULATE, SAMEPERIODLASTYEAR, DIVIDE, VAR, TOPN, LOOKUPVALUE, FIRSTNONBLANK), time intelligence, calculated columns, slicers
Analytics
	
Data cleaning, EDA, competitor benchmarking, price sensitivity, demand forecasting, scenario modelling, P&L construction, margin analysis
