Create database Bankingdb;
use Bankingdb;

create table Customers(
Customer_id int primary key,
Customer_name varchar(100),
Gender varchar(10),
Age int,
City varchar(50),
State varchar(50),
Account_open_date date
); 
select*from Customers;


create table Accounts(
Account_id int primary key,
Customer_id int,
Account_type varchar(20),
Branch_code int,
Balance decimal(15,2),
foreign key(Customer_id) references Customers(customer_id)
);
select* from Accounts;

CREATE TABLE Transactions (
Transaction_iD int primary key,
Account_iD int,
Transaction_date date,
Transaction_type varchar(20),
Amount decimal(15,2),
Balance_after decimal(15,2),
Description varchar(255),
Branch_code int,
foreign key (Account_iD) references Accounts(Account_iD)
);
select*from Transactions;


-- 1. Total Number of Customers
SELECT COUNT(*) AS Total_Customers
FROM Customers;

-- 2. Total Number of Accounts
SELECT COUNT(*) AS Total_Accounts
FROM Accounts;


-- 3. Total Number of Transactions
SELECT COUNT(*) AS Total_Transactions
FROM Transactions;

-- 4. Total Deposit Amount
SELECT SUM(Amount) AS Total_Deposits
FROM Transactions
WHERE Transaction_Type = 'Deposit';

-- 5. Total Withdrawal Amount
SELECT SUM(Amount) AS Total_Withdrawals
FROM Transactions
WHERE Transaction_Type = 'Withdrawal';

-- 6. Total Transfer Amount
SELECT SUM(Amount) AS Total_Transfers
FROM Transactions
WHERE Transaction_Type = 'Transfer';

-- 7. Current Balance of Each Account
SELECT a.Account_iD, c.Customer_name, t.Balance_after AS Current_balance
FROM Accounts a
JOIN Customers c ON a.Customer_id = c.Customer_id
JOIN Transactions t ON a.Account_id = t.Account_id
WHERE t.Transaction_date = (
    SELECT MAX(Transaction_date) 
    FROM Transactions 
    WHERE Account_iD = a.Account_iD
);

-- 8. Top 10 Customers by Total Transaction Amount
SELECT c.Customer_Name, SUM(t.Amount) AS Total_Transaction_Amount
FROM Transactions t
JOIN Accounts a ON t.Account_id = a.Account_id
JOIN Customers c ON a.Customer_id = c.Customer_id
GROUP BY c.Customer_id, c.Customer_name
ORDER BY Total_Transaction_amount DESC
LIMIT 10;


-- 9. Average Transaction Amount by Type
SELECT Transaction_Type, ROUND(AVG(Amount),2) AS Avg_Amount
FROM Transactions
GROUP BY Transaction_Type;

-- 10. Monthly Transaction Volume
SELECT DATE_FORMAT(Transaction_date, '%Y-%m') AS Month, COUNT(*) AS Transactions
FROM Transactions
GROUP BY Month
ORDER BY Month;

-- 11. Monthly Transaction Amount
SELECT DATE_FORMAT(Transaction_date, '%Y-%m') AS Month, SUM(Amount) AS Total_Amount
FROM Transactions
GROUP BY Month
ORDER BY Month;

-- 12. Branch-wise Total Transactions
SELECT Branch_Code, COUNT(*) AS Total_Transactions, SUM(Amount) AS Total_Amount
FROM Transactions
GROUP BY Branch_Code
ORDER BY Total_Amount DESC;

-- 13. Branch-wise Average Transaction
SELECT Branch_Code, ROUND(AVG(Amount),2) AS Avg_Transaction_Amount
FROM Transactions
GROUP BY Branch_Code;

-- 14. Number of Accounts per Branch
SELECT Branch_Code, COUNT(*) AS Num_Accounts
FROM Accounts
GROUP BY Branch_Code;



-- 15. Customers with More Than 3 Accounts
SELECT Customer_ID, COUNT(*) AS Num_Accounts
FROM Accounts
GROUP BY Customer_ID
HAVING Num_Accounts > 3;

-- 16. Highest Transaction Amount
SELECT * 
FROM Transactions
ORDER BY Amount DESC
LIMIT 1;

-- 17. Lowest Transaction Amount
SELECT * 
FROM Transactions
ORDER BY Amount ASC
LIMIT 1;


-- 18. Number of Transactions per Customer
SELECT c.Customer_Name, COUNT(t.Transaction_ID) AS Total_Transactions
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Transactions DESC;

-- 19. Customers with Total Deposits Greater than 1,00,000
SELECT c.Customer_Name, SUM(t.Amount) AS Total_Deposits
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
WHERE t.Transaction_Type = 'Deposit'
GROUP BY c.Customer_ID, c.Customer_Name
HAVING Total_Deposits > 100000;

-- 20. Average Balance by Account Type
SELECT Account_Type, ROUND(AVG(Balance),2) AS Avg_Balance
FROM Accounts
GROUP BY Account_Type;


-- 21. Age-wise Total Transaction Amount
SELECT CASE 
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+' END AS Age_Group,
       SUM(t.Amount) AS Total_Transaction
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY Age_Group;


-- 22. Gender-wise Total Transaction Amount
SELECT Gender, SUM(t.Amount) AS Total_Transaction
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY Gender;

-- 23. Accounts with Negative Balance
SELECT a.Account_ID, c.Customer_Name, t.Balance_After AS Current_Balance
FROM Accounts a
JOIN Customers c ON a.Customer_ID = c.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
WHERE t.Transaction_Date = (
    SELECT MAX(Transaction_Date) 
    FROM Transactions 
    WHERE Account_ID = a.Account_ID
)
AND t.Balance_After < 0;

-- 24. Frequent Withdrawal Accounts (more than 3 withdrawals)
SELECT a.Account_ID, c.Customer_Name, COUNT(*) AS Withdrawal_Count
FROM Transactions t
JOIN Accounts a ON t.Account_ID = a.Account_ID
JOIN Customers c ON a.Customer_ID = c.Customer_ID
WHERE t.Transaction_Type = 'Withdrawal'
GROUP BY a.Account_ID, c.Customer_Name
HAVING Withdrawal_Count > 3;


-- 25. Trend of Deposits Over Time
SELECT DATE(Transaction_Date) AS Transaction_Day, SUM(Amount) AS Total_Deposits
FROM Transactions
WHERE Transaction_Type = 'Deposit'
GROUP BY Transaction_Day
ORDER BY Transaction_Day;

-- 26.Top 5 Branches by Total Transaction Value
SELECT Branch_Code, SUM(Amount) AS Total_Transactions
FROM Transactions
GROUP BY Branch_code
ORDER BY Total_Transactions DESC
LIMIT 5;

-- 27.High-Risk Accounts (Withdrawals > 50% of Balance in a Single Transaction)
SELECT a.Account_ID, c.Customer_Name, t.Amount, t.Balance_After
FROM Transactions t
JOIN Accounts a ON t.Account_id = a.Account_id
JOIN Customers c ON a.Customer_id = c.Customer_id
WHERE t.Transaction_Type='Withdrawal'
AND t.Amount > (0.5 * (t.Amount + t.Balance_After));


-- 28.Customer Segmentation by Transaction Volume
WITH CustomerTotal AS (
    SELECT c.Customer_ID, c.Customer_Name, SUM(t.Amount) AS Total_Amount
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    JOIN Transactions t ON a.Account_ID = t.Account_ID
    GROUP BY c.Customer_ID, c.Customer_Name
)
SELECT Customer_Name,
       CASE 
           WHEN Total_Amount >= 500000 THEN 'Platinum'
           WHEN Total_Amount >= 200000 THEN 'Gold'
           WHEN Total_Amount >= 50000 THEN 'Silver'
           ELSE 'Bronze'
       END AS Segment
FROM CustomerTotal;


-- 29.Customers with Increasing Transaction Trend Over Last 6 Months
WITH MonthlyTransactions AS (
    SELECT a.Customer_id, DATE_FORMAT(t.Transaction_Date, '%Y-%m') AS Month, SUM(t.Amount) AS Total_Amount
    FROM Transactions t
    JOIN Accounts a ON t.Account_id = a.Account_id
    WHERE t.Transaction_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    GROUP BY a.Customer_id, Month
)
SELECT Customer_ID
FROM MonthlyTransactions
GROUP BY Customer_id
HAVING MIN(Total_Amount) < MAX(Total_Amount);

-- 30.Top 5 Customers with Highest Average Transaction Amount
SELECT c.Customer_name, ROUND(AVG(t.Amount),2) AS Avg_Transaction
FROM Customers c
JOIN Accounts a ON c.Customer_id = a.Customer_id
JOIN Transactions t ON a.Account_ID = t.Account_id
GROUP BY c.Customer_id, c.Customer_name
ORDER BY Avg_Transaction DESC
LIMIT 5;



