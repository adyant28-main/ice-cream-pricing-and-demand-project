# 🍨 Ice Cream Pricing & Demand Analytics

### Excel · VBA · MySQL · Power BI

> **End-to-end analytics project:** From messy raw data to strategic pricing recommendations. Complete workflow across Excel (with VBA), SQL (8-step pipeline), and Power BI (interactive dashboard).

---

# 🍦 Pricing Strategy & Demand Analysis  
### Data-Driven Pricing Optimization using SQL, Power BI & Excel  

---

## 📌 Executive Summary
This project analyzes transactional sales data to evaluate pricing effectiveness and demand behavior across products.  

Using SQL-driven analytics and Power BI visualization, a structured pricing framework was developed to identify inefficiencies and support better pricing decisions.

**Outcome:**  
- Identified pricing misalignment across multiple products  
- Highlighted demand-driven pricing opportunities  
- Built a rule-based pricing decision system  

---

## 🎯 Business Objectives
- Understand how pricing impacts demand across products  
- Identify high-performing and underperforming items  
- Benchmark internal pricing against competitors  
- Segment products based on demand behavior  
- Enable consistent, data-driven pricing decisions  

---

## 🛠️ Tech Stack
- **SQL (MySQL)** – Data cleaning, transformation, and analytical queries  
- **Power BI** – Dashboarding for demand, pricing, and trend analysis  
- **Excel** – Data validation, exploratory analysis, aggregation checks, and pricing scenario testing  

---

## 📊 Data Overview
- **147 transaction records**  
- **Multiple dimensions analyzed:**
  - Flavour (product-level analysis)  
  - Location-based variation  
  - Seasonal patterns  
  - Pricing and cost structure  
  - External factors (weather, festive days)  
- **Additional dataset:** Competitor pricing benchmarks  

---

## 🔄 Analytical Workflow

### 1. Data Preparation
- Cleaned inconsistent values (e.g., flavour standardization)  
- Handled missing prices and costs using **flavour-level averages**  
- Removed duplicates using **ROW_NUMBER() window function**  
- Created business metrics:
  - Revenue  
  - Profit  
  - Margin (%)  
- Extracted time features (month, year)  

---

### 2. Demand Segmentation
- Ranked products based on total units sold  
- Segmented into **4 demand tiers using NTILE()**  

**Observation:**  
- A small group of products contributes a **disproportionate share of total demand**  

---

### 3. Pricing & Demand Relationship
- Compared average price vs average demand per product  
- Built a **price sensitivity index (elasticity proxy)**  

**Key Insight:**  
- Some products maintain demand even at higher prices → **low sensitivity**  
- Others show demand drop with price increases → **high sensitivity**  

---

### 4. Price Band Performance
- Categorized prices into:
  - Low (<35)  
  - Mid (35–45)  
  - High (>45)  

**Findings:**  
- Mid-price range contributes the **largest share of total units sold**  
- High-price range generates **higher margins but lower volume**  

---

### 5. Competitive Benchmarking
- Compared internal prices with competitor averages  
- Calculated **price gaps for each product**  

**Insight:**  
- Several products are priced **above or below market benchmarks**, indicating inconsistent positioning  

---

### 6. Trend Analysis
- Used **LAG() function** to calculate month-over-month demand changes  
- Observed **clear seasonal variation in demand patterns**  

---

### 7. Pricing Decision Framework
Developed a rule-based system combining:
- Demand levels  
- Profit margins  
- Competitor pricing  

**Outputs:**
- Increase Price  
- Reduce Price  
- Maintain Price  

---

## 📈 Key Insights (Data Story)

- Demand is **not evenly distributed** — a few products drive most sales  
- Pricing is **not consistently aligned with demand strength**  
- Mid-price products dominate volume, indicating **price sensitivity zone**  
- Some high-demand products are **underpriced relative to competitors**  
- Seasonal patterns significantly influence sales performance
- Mango is the top flavour (3,382 units, 35% of total sales).
- Summer accounts for 55.6% of sales – the peak season.
- Weekend revenue is 27% higher than weekdays.
- Connaught Place generates 58.6% of total revenue, supporting premium pricing.
- Dynamic pricing (season‑adjusted) is projected to increase gross profit by 12.8% in 2024 compared to 2023.
- Competitor benchmark shows the client’s prices are consistently below market for premium flavours (e.g., Kesar  Pista), leaving room for increase.

graph LR
  A[2023 Actual] --> B[Dynamic Pricing Applied]
  B --> C[2024 Projected]
  
  subgraph Metrics
    C1[Revenue: ₹204K → ₹274K<br/>+34%]
    C2[Profit: ₹115K → ₹169K<br/>+47%]
    C3[Margin: 56.3% → 61.8%<br/>+5.46pp]
  end
  
  B --> C1 & C2 & C3

---

## 📊 Power BI Dashboard
- Product-wise demand distribution  
- Price vs demand relationship  
- Seasonal trends  
- Competitor price comparison  
- KPI overview:
  - Total Units Sold  
  - Revenue  
  - Profit  
  - Average Selling Price  

---

## 📁 Key Files
- `ice_cream_project_analysis.sql` → Full SQL pipeline  
- `final_project_queries.rtf` → Structured analytical queries  
- `raw_data_icecream.csv` → Dataset  
- `competitor_benchmark_sql.csv` → Competitor pricing  

---

## 🧠 Skills Demonstrated
- SQL (CTEs, Window Functions, Data Cleaning)  
- Demand Analysis & Product Segmentation  
- Pricing Strategy & Competitive Analysis  
- Data Transformation & Feature Engineering  
- Business Intelligence (Power BI)  
- Analytical Thinking & Data Storytelling
- 
---

## 👤 Author
- Adyant Bhriguvanshi
- adyantbhriguvanshi@gmail.com

