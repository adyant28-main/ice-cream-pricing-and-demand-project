
-- STEP 1 --
-- == DATA BASE AND TABLE CREATION == --

-- Creating database and tables
CREATE DATABASE ice_cream_project;

#creating table to import raw data
Use ice_cream_project;

DROP TABLE IF EXISTS raw_sales;
CREATE TABLE raw_sales (
    Date VARCHAR(50),
    Flavour VARCHAR(50),
    Location VARCHAR(50),
    Season VARCHAR(50),
    Day_Type VARCHAR(50),
    Units_Sold INT,
    Selling_Price DECIMAL(10, 2),
    Cost_Per_Unit DECIMAL(10, 2),
    Weather VARCHAR(50),
    Festive_Day VARCHAR(10)
);

#creating another table for competitor data
CREATE TABLE competitor_benchmark (
    Flavour VARCHAR(50),
    Competitor_Avg_Price DECIMAL(10, 2),
    Market_Segment VARCHAR(50)
);
-- Table is imported through table import wizard --

#verifying imports:

--  Row Counts
SELECT 'Raw Sales' as Table_Name, COUNT(*) as Row_Count FROM raw_sales
UNION ALL
SELECT 'Competitors', COUNT(*) FROM competitor_benchmark;

-- Peek at the Messy Data 
SELECT Date, Flavour, Location, Units_Sold 
FROM raw_sales 
LIMIT 10;

-- Checking Competitor Data
SELECT * FROM competitor_benchmark;

-- STEP 2 --
-- == DATA DISCOVERY == --

-- Data quality overview
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Flavour) AS unique_flavours,
    COUNT(DISTINCT Location) AS unique_locations,

    SUM(CASE WHEN Units_Sold IS NULL THEN 1 ELSE 0 END) AS null_units,
    SUM(CASE WHEN Selling_Price IS NULL THEN 1 ELSE 0 END) AS null_prices,
    SUM(CASE WHEN Cost_Per_Unit IS NULL THEN 1 ELSE 0 END) AS null_costs,

    SUM(CASE WHEN Units_Sold < 0 THEN 1 ELSE 0 END) AS negative_units,
    SUM(CASE WHEN Selling_Price <= 0 THEN 1 ELSE 0 END) AS invalid_prices

FROM raw_sales;

-- Distinct values check for inconsistent categories
SELECT DISTINCT Flavour FROM raw_sales;
SELECT DISTINCT Location FROM raw_sales;
SELECT DISTINCT Season FROM raw_sales;

-- STEP 3 --
-- == DATA CLEANING == --

-- Clean and standardize data

DROP TABLE IF EXISTS cleaned_sales;


CREATE TABLE cleaned_sales AS
WITH flavour_averages AS (
    -- Calculate average cost PER FLAVOUR (not global average)
    SELECT 
         UPPER(TRIM(Flavour)) AS Flavour,
        AVG(NULLIF(Cost_Per_Unit, 0)) AS avg_cost,
        AVG(NULLIF(Selling_Price, 0)) AS avg_price
    FROM raw_sales
    GROUP BY UPPER(TRIM(Flavour)) 
),
cleaned_base AS (
    SELECT 
        STR_TO_DATE(r.Date, '%d-%b-%y') AS sale_date,
        
        -- Fix Typos (e.g., VANILA -> VANILLA)
        CASE 
            WHEN UPPER(TRIM(r.Flavour)) = 'VANILA' THEN 'VANILLA'
            ELSE UPPER(TRIM(r.Flavour))
        END AS flavour,
        
        UPPER(TRIM(r.Location)) AS location,
        UPPER(TRIM(r.Season)) AS season,
        UPPER(TRIM(r.Day_Type)) AS day_type,
        UPPER(TRIM(r.Weather)) AS weather,
        UPPER(TRIM(r.Festive_Day)) AS festive_day,
        
      -- Handling Units
        COALESCE(r.Units_Sold, 0) AS units_sold,
        
        -- Handling Price
        COALESCE(NULLIF(r.Selling_Price, 0), fa.avg_price) AS selling_price,
        
        -- HandLing cost
        COALESCE(NULLIF(r.Cost_Per_Unit, 0), fa.avg_cost) AS cost_per_unit,
        
        YEAR(STR_TO_DATE(r.Date, '%d-%b-%y')) AS year,
        MONTH(STR_TO_DATE(r.Date, '%d-%b-%y')) AS month
        
    FROM raw_sales r
    LEFT JOIN flavour_averages fa ON UPPER(TRIM(r.Flavour)) = fa.Flavour
    WHERE STR_TO_DATE(r.Date, '%d-%b-%y') IS NOT NULL
)
SELECT 
    *,
    -- Revenue & Profit with Cleaned Data
    units_sold * selling_price AS revenue,
    units_sold * (selling_price - cost_per_unit) AS profit
FROM cleaned_base;

-- Removing Duplicates --
ALTER TABLE cleaned_sales ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
DELETE t1
FROM cleaned_sales t1
JOIN (
    SELECT id
    FROM (
        SELECT id,
               ROW_NUMBER() OVER (PARTITION BY sale_date, flavour, location) AS rn
        FROM cleaned_sales
    ) x
    WHERE rn > 1
) t2
ON t1.id = t2.id;
-- Validation --
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT flavour) AS flavours,
    SUM(CASE WHEN selling_price IS NULL THEN 1 ELSE 0 END) AS null_prices
FROM cleaned_sales;

-- STEP 4 --
-- == BUSINESS SUMMARY == --

-- Overall performance --
SELECT 
    SUM(units_sold) AS total_units,
    ROUND(SUM(revenue),2) AS total_revenue,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(AVG(selling_price),2) AS avg_price
FROM cleaned_sales
WHERE year = 2023;

-- STEP 5--
-- Exploratory Analyis (EDA) --

-- Flavour Analysis --
-- Rank and segment flavours --
SELECT 
    flavour,
    total_units,

    NTILE(4) OVER (ORDER BY total_units DESC) AS demand_quartile

FROM (
    SELECT 
        flavour,
        SUM(units_sold) AS total_units
    FROM cleaned_sales
    WHERE year = 2023
    GROUP BY flavour
) t;

-- Seasonal Analysis --
-- Demand across seasons in 2023 --
SELECT 
    season,
    SUM(units_sold) AS total_units,
    ROUND(AVG(selling_price),2) AS avg_price,
    ROUND(SUM(revenue),2) AS revenue
FROM cleaned_sales
WHERE year = 2023
GROUP BY season;

-- Flavour-season interaction (insight)
SELECT 
    flavour,
    season,
    SUM(units_sold) AS total_units
FROM cleaned_sales
WHERE year = 2023
GROUP BY flavour, season
ORDER BY season, total_units DESC;

-- STEP 6--
-- == Advanced Analytics == --

-- Competitor Analysis --
-- Clean competitor data
UPDATE competitor_benchmark
SET Flavour = UPPER(TRIM(Flavour));



-- Compare pricing vs market (competitors) --
SELECT 
    s.flavour,
    ROUND(AVG(s.selling_price),2) AS our_price,
    c.Competitor_Avg_Price,

    ROUND(AVG(s.selling_price) - c.Competitor_Avg_Price,2) AS price_gap,

    CASE 
        WHEN AVG(s.selling_price) > c.Competitor_Avg_Price THEN 'PREMIUM'
        WHEN AVG(s.selling_price) < c.Competitor_Avg_Price THEN 'DISCOUNT'
        ELSE 'MATCH'
    END AS position

FROM cleaned_sales s
JOIN competitor_benchmark c
ON s.flavour = c.Flavour

GROUP BY s.flavour, c.Competitor_Avg_Price;

-- Price Band Analysis --
-- Demand by price range:
SELECT 
    CASE 
        WHEN selling_price < 35 THEN 'LOW'
        WHEN selling_price BETWEEN 35 AND 45 THEN 'MID'
        ELSE 'HIGH'
    END AS price_band,

    SUM(units_sold) AS total_units,
    ROUND(AVG(units_sold),2) AS avg_units

FROM cleaned_sales
WHERE year = 2023
GROUP BY price_band
ORDER BY total_units DESC;

-- Simple Price Elasticity --
-- Measuring demand sensitivity to price --
SELECT 
    flavour,

    ROUND(AVG(selling_price),2) AS avg_price,
    ROUND(AVG(units_sold),2) AS avg_demand,

    -- simple elasticity proxy
    ROUND(
        (MAX(units_sold) - MIN(units_sold)) / 
        NULLIF(MAX(selling_price) - MIN(selling_price),0)
    ,2) AS price_sensitivity_index,

    CASE 
        WHEN (MAX(units_sold) - MIN(units_sold)) / 
             NULLIF(MAX(selling_price) - MIN(selling_price),0) > 0 
        THEN 'PRICE SENSITIVE'
        ELSE 'LESS SENSITIVE'
    END AS insight

FROM cleaned_sales
WHERE year = 2023
GROUP BY flavour;

-- STEP 7 --
-- == Trend analysis using LAG (MoM growth) == --
WITH monthly_sales AS (
    SELECT 
        month,
        SUM(units_sold) AS total_units
    FROM cleaned_sales
    WHERE year = 2023
    GROUP BY month
)

SELECT 
    month,
    total_units,
    LAG(total_units) OVER (ORDER BY month) AS prev_month_units,

    ROUND(
        (total_units - LAG(total_units) OVER (ORDER BY month)) * 100.0 /
        NULLIF(LAG(total_units) OVER (ORDER BY month), 0)
    ,2) AS mom_growth_pct

FROM monthly_sales;

-- STEP 8--
-- == FINAL DECISION QUERY == -- 
-- Aggregations + Joins + CTE + Window Functions + Case When > Multi Factor Pricing Decision

-- Integrated pricing decision (demand + competition + pricing) 


WITH flavour_metrics AS (
    SELECT 
        s.flavour,
        SUM(s.units_sold) AS total_units,
        AVG(s.selling_price) AS avg_price,
        AVG(s.cost_per_unit) AS avg_cost,
        SUM(s.profit) AS total_profit,
        c.Competitor_Avg_Price
    FROM cleaned_sales s
    JOIN competitor_benchmark c
        ON s.flavour = c.Flavour
    WHERE s.year = 2023
    GROUP BY s.flavour, c.Competitor_Avg_Price
)

SELECT 
    flavour,
    total_units,
    ROUND(avg_price,2) AS avg_price,
    ROUND(avg_cost,2) AS avg_cost,
    ROUND(total_profit,2) AS total_profit,
    Competitor_Avg_Price,

    -- price gap
    ROUND(avg_price - Competitor_Avg_Price,2) AS price_gap,

    -- margin %
    ROUND((avg_price - avg_cost) / avg_price * 100,2) AS margin_pct,

    -- demand ranking
    RANK() OVER (ORDER BY total_units DESC) AS demand_rank,

    -- final pricing decision (correct priority)
    CASE 
        WHEN (avg_price - avg_cost) / avg_price < 0.25
            THEN 'INCREASE PRICE (LOW MARGIN)'

        WHEN total_units > 1000 
             AND avg_price < Competitor_Avg_Price
            THEN 'INCREASE PRICE'

        WHEN total_units BETWEEN 500 AND 1000
             AND avg_price < Competitor_Avg_Price * 0.95
            THEN 'INCREASE PRICE'

        WHEN total_units < 500 
             AND avg_price > Competitor_Avg_Price
            THEN 'REDUCE PRICE'

        ELSE 'MAINTAIN PRICE'
    END AS pricing_decision

FROM flavour_metrics
ORDER BY total_profit DESC;

-- FINAL STEP--
-- == SUMMARY == --
-- Simple summary table view--
CREATE OR REPLACE VIEW v_sales_summary AS
SELECT 
    flavour,
    SUM(units_sold) AS total_units,
    ROUND(AVG(selling_price),2) AS avg_price,
    ROUND(SUM(revenue),2) AS total_revenue
FROM cleaned_sales
WHERE year = 2023
GROUP BY flavour;