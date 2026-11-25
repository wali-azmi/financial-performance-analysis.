-- 1. Verify row count and preview sample data
SELECT COUNT(*) AS total_rows
FROM corporate_income_statement_clean;

SELECT
    symbol,
    fiscal_year,
    totalRevenue,
    grossProfit,
    operatingIncome,
    gross_margin_pct,
    operating_margin_pct
FROM corporate_income_statement_clean
LIMIT 10;

-- 2. Financial summary by fiscal year
SELECT
    fiscal_year,
    COUNT(*) AS record_count,
    COUNT(DISTINCT symbol) AS company_count,
    ROUND(SUM(totalRevenue), 2) AS total_revenue,
    ROUND(SUM(grossProfit), 2) AS total_gross_profit,
    ROUND(SUM(operatingIncome), 2) AS total_operating_income,
    ROUND(AVG(gross_margin_pct), 2) AS avg_gross_margin_pct,
    ROUND(AVG(operating_margin_pct), 2) AS avg_operating_margin_pct
FROM corporate_income_statement_clean
GROUP BY fiscal_year
ORDER BY fiscal_year DESC;

-- 3. Top 10 companies by total revenue
SELECT
    symbol,
    COUNT(*) AS periods_reported,
    ROUND(SUM(totalRevenue), 2) AS total_revenue,
    ROUND(SUM(operatingIncome), 2) AS total_operating_income,
    ROUND(AVG(operating_margin_pct), 2) AS avg_operating_margin_pct
FROM corporate_income_statement_clean
GROUP BY symbol
ORDER BY total_revenue DESC
LIMIT 10;

PRAGMA table_info(corporate_income_statement_clean);

-- 4. Top 10 companies by average operating margin (min. 4 reported periods)
SELECT
    symbol,
    COUNT(*) AS periods_reported,
    ROUND(AVG(gross_margin_pct), 2) AS avg_gross_margin_pct,
    ROUND(AVG(operating_margin_pct), 2) AS avg_operating_margin_pct,
    ROUND(AVG(opex_ratio_pct), 2) AS avg_opex_ratio_pct
FROM corporate_income_statement_clean
WHERE operating_margin_pct IS NOT NULL
GROUP BY symbol
HAVING COUNT(*) >= 4
ORDER BY avg_operating_margin_pct DESC
LIMIT 10;

-- 5. Year-over-Year (YoY) total revenue growth
WITH yearly_summary AS (
    SELECT
        fiscal_year,
        COUNT(DISTINCT symbol) AS company_count,
        SUM(totalRevenue) AS total_revenue,
        SUM(operatingIncome) AS total_operating_income
    FROM corporate_income_statement_clean
    WHERE fiscal_year IS NOT NULL
    GROUP BY fiscal_year
)
SELECT
    fiscal_year,
    company_count,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(LAG(total_revenue) OVER (ORDER BY fiscal_year), 2) AS prev_year_revenue,
    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY fiscal_year))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY fiscal_year), 0)) * 100,
        2
    ) AS yoy_revenue_growth_pct,
    ROUND(total_operating_income, 2) AS total_operating_income
FROM yearly_summary
ORDER BY fiscal_year DESC;

-- 6. Company performance comparison in latest full fiscal year (2024)
SELECT
    symbol,
    COUNT(*) AS quarters_reported,
    ROUND(SUM(totalRevenue), 2) AS revenue_2024,
    ROUND(SUM(grossProfit), 2) AS gross_profit_2024,
    ROUND(SUM(operatingIncome), 2) AS operating_income_2024,
    ROUND(AVG(gross_margin_pct), 2) AS avg_gross_margin_pct,
    ROUND(AVG(operating_margin_pct), 2) AS avg_operating_margin_pct
FROM corporate_income_statement_clean
WHERE fiscal_year = 2024
GROUP BY symbol
ORDER BY revenue_2024 DESC;