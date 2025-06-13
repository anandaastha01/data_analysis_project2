-- CLEANING & PRE-PROCESSING

create database banking_cs;
show databases;
use banking_cs;
show tables;
select * from customer;
ALTER TABLE customer CHANGE `ï»¿Client ID` `Client_ID` VARCHAR(255);
select * from customer;
--------------------------------------

-- Backup original table
CREATE TABLE customer_backup AS
SELECT * FROM customer;
-- Create deduplicated version
CREATE TABLE customer_dedup AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Client_ID ORDER BY Client_ID) AS rn
    FROM customer
) t
WHERE t.rn = 1;
-- Drop original table
DROP TABLE customer;
-- Rename deduplicated table back to original name
ALTER TABLE customer_dedup RENAME TO customer;
-- Confirm deduplication
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT Client_ID) AS distinct_ids
FROM customer;
--------------------------------------
-- query sql dataset
-- Customer Profiling,Financial Metrics,Risk Analysis,Service Segmentation,Time-Based Trends                 


-- 1.Total Unique Customers 
SELECT COUNT(DISTINCT Client_ID) AS total_customers FROM customer;
--------------------------------------
-- 2.Average Credit Card Balance
SELECT AVG(`Credit Card Balance`) AS avg_cc_balance FROM customer;
SELECT AVG(CAST(REPLACE(`Credit Card Balance`, ',', '') AS DECIMAL(10,2))) AS avg_cc_balance
FROM customer
WHERE `Credit Card Balance` IS NOT NULL AND `Credit Card Balance` != '';
--------------------------------------
-- 3.Most Common Fee Structure 
SELECT `Fee Structure`, COUNT(*) AS frequency
FROM customer
GROUP BY `Fee Structure`
ORDER BY frequency DESC;
--------------------------------------
-- 4.Total Bussiness Lending Disbursed
SELECT SUM(`Business Lending`) AS total_business_lending FROM customer;
--------------------------------------
-- 5.Customers Owning More Than One Property
SELECT COUNT(*) AS multi_property_owners
FROM customer
WHERE `Properties Owned` > 1;
--------------------------------------
-- 6.Average Bank Deposits By Loyalty Classification
SELECT `Loyalty Classification`, AVG(`Bank Deposits`) AS avg_deposit
FROM customer
GROUP BY `Loyalty Classification`
ORDER BY avg_deposit DESC;
--------------------------------------
-- 7.Loan TO Deposite Ratio Per Customer 
SELECT `Client_ID`,
       ROUND(`Bank Loans` / NULLIF(`Bank Deposits`, 0), 2) AS loan_to_deposit_ratio
FROM customer;
--------------------------------------
-- 8.Occupation With High Risk 
SELECT `Occupation`, COUNT(*) AS high_risk_count
FROM customer
WHERE `Risk Weighting` >= 4
GROUP BY `Occupation`
ORDER BY high_risk_count DESC;
--------------------------------------
-- 9.Average Estimated Income By Nationality 
SELECT `Nationality`, AVG(`Estimated Income`) AS avg_income
FROM customer
GROUP BY `Nationality`
ORDER BY avg_income DESC;
---------------------------------------
-- 10.Customers Who Joined Before 2010
SELECT COUNT(*) AS joined_before_2010
FROM customer
WHERE STR_TO_DATE(`Joined Bank`, '%d-%m-%Y') < '2010-01-01';
----------------------------------------
-- 11.Top 5 High Net Worth Clients
SELECT `Client_ID`, `Estimated Income`
FROM customer
ORDER BY `Estimated Income` DESC
LIMIT 5;
----------------------------------------
-- 12.Total Credit Exposure by Occupation
SELECT `Occupation`, SUM(`Bank Loans` + `Credit Card Balance`) AS total_credit_exposure
FROM customer
GROUP BY `Occupation`
ORDER BY total_credit_exposure DESC;
------------------------------------------
-- 13.Loan Risk Index
SELECT `Client_ID`, `Risk Weighting` * `Bank Loans` AS loan_risk_index
FROM customer
ORDER BY loan_risk_index DESC
LIMIT 10;

------------------------------------------------------ xxx -----------------------------------------------------
