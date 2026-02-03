/* =========================================================
   TELECOM CUSTOMER CHURN – EXPLORATORY DATA ANALYSIS
   Author: [Pawan Rankhamb]
   Purpose: EDA and data quality checks for telecom churn dataset
   Table: telecom_churn
   ========================================================= */


/* =========================================================
   SECTION 0: DATA STRUCTURE & CLEANING
   ========================================================= */

-- 0.1: Check table structure (columns and data types)
DESCRIBE telecom_churn;

-- 0.2: Change the data type of date_of_registration column text to date
SET SQL_SAFE_UPDATES = 0;
  ALTER TABLE telecom_churn
MODIFY date_of_registration DATE;


-- 0.3: Check total records
SELECT COUNT(*) AS total_records
FROM telecom_churn;

-- 0.4: Check for duplicate customer_id
SELECT customer_id, COUNT(*) AS duplicate_count
FROM telecom_churn
GROUP BY customer_id
HAVING duplicate_count > 1;

-- 0.5: Check missing values for key columns
SELECT 
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN date_of_registration IS NULL THEN 1 ELSE 0 END) AS missing_registration,
    SUM(CASE WHEN num_dependents IS NULL THEN 1 ELSE 0 END) AS missing_dependents,
    SUM(CASE WHEN estimated_salary IS NULL THEN 1 ELSE 0 END) AS missing_estimated_salary,
    SUM(CASE WHEN calls_made IS NULL THEN 1 ELSE 0 END) AS missing_calls_made,
    SUM(CASE WHEN sms_sent IS NULL THEN 1 ELSE 0 END) AS missing_sms_sent,
    SUM(CASE WHEN data_used IS NULL THEN 1 ELSE 0 END) AS missing_data_used,
    SUM(CASE WHEN churn IS NULL THEN 1 ELSE 0 END) AS missing_churn
FROM telecom_churn;


/* =========================================================
   SECTION 1: BASIC DATA OVERVIEW
   ========================================================= */

-- Total customers
SELECT COUNT(*) AS total_customers
FROM telecom_churn;

-- Sample records
SELECT *
FROM telecom_churn
LIMIT 10;


/* =========================================================
   SECTION 2: OVERALL CHURN METRICS
   ========================================================= */

-- Churned vs retained customers
SELECT
    churn,
    COUNT(*) AS customer_count
FROM telecom_churn
GROUP BY churn;

-- Overall churn rate
SELECT
    ROUND(
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM telecom_churn;


/* =========================================================
   SECTION 3: CHURN BY GENDER
   ========================================================= */

SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM telecom_churn
GROUP BY gender;


/* =========================================================
   SECTION 4: CHURN BY AGE GROUP
   ========================================================= */

SELECT
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25–34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM telecom_churn
GROUP BY age_group
ORDER BY churn_rate_percentage DESC;


/* =========================================================
   SECTION 5: CHURN BY TELECOM PARTNER
   ========================================================= */

SELECT
    telecom_partner,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM telecom_churn
GROUP BY telecom_partner
ORDER BY churn_rate_percentage DESC;


/* =========================================================
   SECTION 6: USAGE BEHAVIOUR VS CHURN
   ========================================================= */

SELECT
    churn,
    ROUND(AVG(calls_made), 2) AS avg_calls_made,
    ROUND(AVG(sms_sent), 2) AS avg_sms_sent,
    ROUND(AVG(data_used), 2) AS avg_data_used
FROM telecom_churn
GROUP BY churn;


/* =========================================================
   SECTION 7: TENURE ANALYSIS (USING REGISTRATION DATE)
   ========================================================= */

SELECT
    churn,
    ROUND(
        AVG(TIMESTAMPDIFF(DAY, date_of_registration, CURRENT_DATE)/30.44),
        2
    ) AS avg_tenure_months
FROM telecom_churn
GROUP BY churn;


/* =========================================================
   SECTION 8: FINANCIAL PROXY ANALYSIS (ESTIMATED SALARY)
   ========================================================= */

SELECT
    churn,
    ROUND(AVG(estimated_salary), 2) AS avg_estimated_salary
FROM telecom_churn
GROUP BY churn;


/* =========================================================
   SECTION 9: DEPENDENTS VS CHURN
   ========================================================= */

SELECT
    num_dependents,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM telecom_churn
GROUP BY num_dependents
ORDER BY churn_rate_percentage DESC;


/* =========================================================
   SECTION 10: FINAL DATASET FOR POWER BI
   ========================================================= */

SELECT
    customer_id,
    telecom_partner,                
    gender,
    age,
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25–34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        ELSE '55+'
    END AS age_group,
    date_of_registration,
    ROUND(TIMESTAMPDIFF(DAY, date_of_registration, CURRENT_DATE)/30.44, 2) AS tenure_months,
    num_dependents,
    estimated_salary,
    calls_made,
    sms_sent,
    data_used,
    churn
FROM telecom_churn;


/* =========================================================
   SECTION 11: CTE EXAMPLE
   ========================================================= */

WITH churn_summary AS (
    SELECT
        telecom_partner,
        COUNT(*) AS total_customers,
        SUM(churn) AS churned_customers,
        ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
    FROM telecom_churn
    GROUP BY telecom_partner
)
SELECT *
FROM churn_summary
ORDER BY churn_rate_percentage DESC;


/* =========================================================
   SECTION 12: VIEW EXAMPLE
   ========================================================= */

CREATE OR REPLACE VIEW vw_telecom_churn_summary AS
SELECT
    telecom_partner,
    gender,
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25–34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM telecom_churn
GROUP BY telecom_partner, gender, age_group;
