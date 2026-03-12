use fusion;
set session sql_mode='';
drop table financial_loan;


-- Take a back up of main table 
create table bank_loan as
select * from financial_loan_project;
-- data cleaning-->setting appropriate data types
-- convert issue_date to date type



update financial_loan_project
set issue_date = 
case 
	when issue_date like '%/%' then str_to_date(issue_date,'%d/%m/%Y')
	when issue_date like '%-%' then str_to_date(issue_date,'%d-%m-%Y')
else null
end;

update financial_loan_project
set last_credit_pull_date =
case 
	when last_credit_pull_date  like '%/%' then str_to_date(last_credit_pull_date,'%d/%m/%Y')
	when last_credit_pull_date like '%-%' then str_to_date(last_credit_pull_date,'%d-%m-%Y')
else null
end;

update financial_loan_project
set last_payment_date = 
case 
	when last_payment_date like '%/%' then str_to_date(last_payment_date,'%d/%m/%Y')
	when last_payment_date like '%-%' then str_to_date(last_payment_date,'%d-%m-%Y')
else null
end;


update financial_loan_project
set next_payment_date = 
case 
	when next_payment_date like '%/%' then str_to_date(next_payment_date,'%d/%m/%Y')
	when next_payment_date like '%-%' then str_to_date(next_payment_date,'%d-%m-%Y')
else null
end;

-- now change column datatype to date
alter table financial_loan_project
modify issue_date date,
modify last_credit_pull_date date,
modify last_payment_date date,
modify next_payment_date date;

-- Total Loan Applications 
SELECT COUNT(id) AS Total_Applications FROM financial_loan_project;

-- MTD Loan Applications 
SELECT COUNT(id) AS Total_Applications FROM financial_loan_project
WHERE MONTH(issue_date) = 12 

SELECT COUNT(id) AS Total_Applications FROM financial_loan_project
WHERE MONTH(issue_date) = 11

-- Total Funded Amount 
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM financial_loan_project

-- MTD Total Funded Amount 
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM financial_loan_project
WHERE MONTH(issue_date) = 12

-- PMTD Total Funded Amount 
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM financial_loan_project
WHERE MONTH(issue_date) = 11

-- Total Amount Received 
SELECT SUM(total_payment) AS Total_Amount_Collected FROM financial_loan_project

-- MTD Total Amount Received 
SELECT SUM(total_payment) AS Total_Amount_Collected FROM financial_loan_project
WHERE MONTH(issue_date) = 12

-- PMTD Total Amount Received 
SELECT SUM(total_payment) AS Total_Amount_Collected FROM  financial_loan_project
WHERE MONTH(issue_date) = 11 

-- Average Interest Rate 
SELECT AVG(int_rate)*100 AS Avg_Int_Rate FROM financial_loan_project

-- MTD Average Interest 
SELECT AVG(int_rate)*100 AS MTD_Avg_Int_Rate FROM financial_loan_project
WHERE MONTH(issue_date) = 12
 
-- PMTD Average Interest 
SELECT AVG(int_rate)*100 AS PMTD_Avg_Int_Rate FROM financial_loan_project 
WHERE MONTH(issue_date) = 11


-- Avg DTI 
SELECT AVG(dti)*100 AS Avg_DTI FROM  financial_loan_project
 
-- MTD Avg DTI 
SELECT AVG(dti)*100 AS MTD_Avg_DTI FROM financial_loan_project 
WHERE MONTH(issue_date) = 12 

-- PMTD Avg DTI 
SELECT AVG(dti)*100 AS PMTD_Avg_DTI FROM financial_loan_project 
WHERE MONTH(issue_date) = 11 

-- GOOD LOAN ISSUED
 
-- Good Loan Percentage 
SELECT 
(COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id 
END) * 100.0) /  
COUNT(id) AS Good_Loan_Percentage 
FROM financial_loan_project 
 
-- Good Loan Applications 
SELECT COUNT(id) AS Good_Loan_Applications FROM financial_loan_project 
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current' 

-- Good Loan Funded Amount 
SELECT SUM(loan_amount) AS Good_Loan_Funded_amount FROM financial_loan_project 
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

-- Good Loan Amount Received 
SELECT SUM(total_payment) AS Good_Loan_amount_received FROM  financial_loan_project 
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current' 


-- BAD LOAN ISSUED
 
-- Bad Loan Percentage 
SELECT 
(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) /  
COUNT(id) AS Bad_Loan_Percentage 
FROM financial_loan_project 

-- Bad Loan Applications 
SELECT COUNT(id) AS Bad_Loan_Applications FROM financial_loan_project 
WHERE loan_status = 'Charged Off' 

-- Bad Loan Funded Amount 
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM financial_loan_project 
WHERE loan_status = 'Charged Off' 

-- Bad Loan Amount Received 
SELECT SUM(total_payment) AS Bad_Loan_amount_received FROM financial_loan_project 
WHERE loan_status = 'Charged Off'

-- LOAN STATUS 
SELECT 
loan_status, 
COUNT(id) AS LoanCount, 
SUM(total_payment) AS Total_Amount_Received, 
SUM(loan_amount) AS Total_Funded_Amount, 
AVG(int_rate * 100) AS Interest_Rate, 
AVG(dti * 100) AS DTI 
FROM 
financial_loan_project 
GROUP BY 
loan_status

SELECT  
loan_status,  
SUM(total_payment) AS MTD_Total_Amount_Received,  
SUM(loan_amount) AS MTD_Total_Funded_Amount  
FROM financial_loan_project 
WHERE MONTH(issue_date) = 12  
GROUP BY loan_status 

-- B. BANK LOAN REPORT | OVERVIEW 
-- MONTH 
SELECT  
MONTH(issue_date) AS Month_Munber,  
DATENAME(MONTH, issue_date) AS Month_name,  
COUNT(id) AS Total_Loan_Applications, 
SUM(loan_amount) AS Total_Funded_Amount, 
SUM(total_payment) AS Total_Amount_Received 
FROM financial_loan_project  
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date) 
ORDER BY MONTH(issue_date)

-- STATE 
SELECT  
address_state AS State,  
COUNT(id) AS Total_Loan_Applications, 
SUM(loan_amount) AS Total_Funded_Amount, 
SUM(total_payment) AS Total_Amount_Received 
FROM  financial_loan_project
GROUP BY address_state 
ORDER BY address_state 

-- TERM 
SELECT  
term AS Term,  
COUNT(id) AS Total_Loan_Applications, 
SUM(loan_amount) AS Total_Funded_Amount, 
SUM(total_payment) AS Total_Amount_Received 
FROM financial_loan_project
GROUP BY term 
ORDER BY term

-- EMPLOYEE LENGTH 
SELECT  
emp_length AS Employee_Length,  
COUNT(id) AS Total_Loan_Applications, 
SUM(loan_amount) AS Total_Funded_Amount, 
SUM(total_payment) AS Total_Amount_Received 
FROM financial_loan_project
GROUP BY emp_length 
ORDER BY emp_length 

-- PURPOSE 
SELECT  
purpose AS PURPOSE,  
COUNT(id) AS Total_Loan_Applications, 
SUM(loan_amount) AS Total_Funded_Amount, 
SUM(total_payment) AS Total_Amount_Received 
FROM  financial_loan_project
GROUP BY purpose 
ORDER BY purpose


-- HOME OWNERSHIP 
SELECT  
home_ownership AS Home_Ownership,  
COUNT(id) AS Total_Loan_Applications, 
SUM(loan_amount) AS Total_Funded_Amount, 
SUM(total_payment) AS Total_Amount_Received 
FROM  financial_loan_project
GROUP BY home_ownership 
ORDER BY home_ownership
