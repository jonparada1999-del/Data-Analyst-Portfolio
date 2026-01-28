/* PROJECT: Annual Corporate Tax Provision Automation
AUTHOR: Jonathan P. 
DATE: January 2026
DESCRIPTION: This script automates the bridge from Net Book Income to Taxable Income, 
calculates federal/state liabilities, and flags high-risk audit entities.
*/
-- MONDAY: Data Ingestion & Standardization
-- Ensuring all profit figures are treated as numeric for calculation.
USE tax_portfolio;

CREATE OR REPLACE VIEW v_cleaned_tax_data AS
SELECT 
    Company_ID,
    CAST(Profit_Before_Tax AS SIGNED) AS book_income,
    CAST(Previous_Fines AS SIGNED) AS non_deductible_fines,
    Effective_Tax_Rate
FROM raw_tax_data;
-- TUESDAY: Book-to-Tax Adjustments
-- Adding back 100% of Government Fines per 2026 IRS guidelines.
CREATE OR REPLACE VIEW v_tax_adjustments AS
SELECT 
    *,
    (book_income + non_deductible_fines) AS taxable_income
FROM v_cleaned_tax_data;
-- WEDNESDAY: Federal & State Liability Calculation
-- Applying 21% Federal Corporate Rate and 2.5% NC State Rate.
SELECT 
    Company_ID,
    taxable_income,
    (taxable_income * 0.21) AS federal_tax_provision,
    (taxable_income * 0.025) AS state_tax_provision,
    -- Flagging companies with an ETR variance higher than 5%
    CASE 
        WHEN Effective_Tax_Rate > 26 THEN 'HIGH RISK: OVERPAYMENT'
        WHEN Effective_Tax_Rate < 18 THEN 'HIGH RISK: UNDERPAYMENT'
        ELSE 'LOW RISK'
    END AS audit_risk_status
FROM v_tax_adjustments;
/* Thursday: Variance Analysis
The Goal: Explain the "Why." You need to compare the Effective Tax Rate (ETR) in your data to the 21% legal rate to see if the company is overpaying.

The Task: Calculate the "Tax Gap."

Portfolio Narrative: "Identified variances between Book and Tax income, noting that high previous fines increased the Effective Tax Rate by an average of 3% across the portfolio".

Friday: Reporting (The Deadline Dashboard)
The Goal: Make sure the business doesn't get hit with more fines for being late.

The 2026 Deadlines: For a calendar-year corporation, the estimated payments are due on:

Q1: April 15, 2026

Q2: June 15, 2026

Q3: September 15, 2026

Q4: December 15, 2026*/
