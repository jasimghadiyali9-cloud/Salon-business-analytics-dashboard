USE florian_salon;

DROP TABLE IF EXISTS florian_sql_data;

CREATE TABLE florian_sql_data (
    Appointment_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Gender VARCHAR(10),
    Age INT,
    City VARCHAR(50),
    Branch VARCHAR(50),
    Stylist VARCHAR(50),
    Service_Type VARCHAR(100),
    Booking_Date DATE,
    Appointment_Time VARCHAR(20),
    Service_Duration_Min INT,
    Appointment_Status VARCHAR(30),
    Estimated_Service_Revenue_INR FLOAT,
    Upsell_Revenue_INR FLOAT,
    Total_Revenue_INR FLOAT,
    Customer_Rating FLOAT,
    Payment_Mode VARCHAR(30),
    Membership_Status VARCHAR(30),
    Booking_Channel VARCHAR(30),
    Repeat_Customer VARCHAR(10),
    Booking_Month VARCHAR(20),
    Weekend_Flag VARCHAR(10),
    Peak_Time VARCHAR(10),
    Revenue_Per_Minute FLOAT,
    Upsell_Success VARCHAR(10),
    High_Value_Customer VARCHAR(10),
    Is_Member VARCHAR(10)
);
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/DELL/Downloads/florian_sql_data.csv'
INTO TABLE florian_sql_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM florian_sql_data;

SELECT 
    MIN(Booking_Date) AS Start_Date,
    MAX(Booking_Date) AS End_Date
FROM florian_sql_data;
-- 1 Branch Performance
SELECT 
    Branch,
    COUNT(*) AS Total_Appointments,
    ROUND(SUM(Total_Revenue_INR), 2) AS Revenue
FROM
    florian_sql_data
GROUP BY Branch
ORDER BY Revenue DESC;
-- 2 Footfall
SELECT Peak_Time,ROUND(SUM(Total_Revenue_INR),2) AS Revenue,ROUND(AVG(Total_Revenue_INR),2) AS Avg_Bill
FROM florian_sql_data
GROUP BY Peak_Time;
-- 3 Customer type dist
SELECT 
    Repeat_Customer,
    COUNT(*) AS Appointments,
    ROUND(SUM(Total_Revenue_INR),2) AS Revenue
FROM florian_sql_data
GROUP BY Repeat_Customer;
-- 4 Tylist Revenue-Efficiency 
SELECT Stylist,ROUND(AVG(Revenue_Per_Minute),2) AS Avg_Revenue_Per_Minute
FROM florian_sql_data
GROUP BY Stylist
ORDER BY Avg_Revenue_Per_Minute DESC
LIMIT 10;
-- 5 Highest Rated Stylists
SELECT Stylist,ROUND(AVG(Customer_Rating),2) AS Avg_Rating
FROM florian_sql_data
GROUP BY Stylist
HAVING COUNT(*) > 50
ORDER BY Avg_Rating DESC;
-- 6 Payment Mode Dist
SELECT 
    Payment_Mode,
    COUNT(*) AS Transactions,
    ROUND(SUM(Total_Revenue_INR),2) AS Revenue
FROM florian_sql_data
GROUP BY Payment_Mode
ORDER BY Revenue DESC;

-- 7 Revenue Leakage
WITH benchmark AS (
    SELECT 
        AVG(Revenue_Per_Minute) AS avg_rpm
    FROM florian_sql_data
    WHERE Appointment_Status = 'Completed'
)

SELECT 
    Appointment_Status,
    COUNT(*) AS Total_Appointments,

    ROUND(
        AVG(Service_Duration_Min),2
    ) AS Avg_Service_Duration,

    ROUND(
        COUNT(*) * AVG(Service_Duration_Min) * 
        (SELECT avg_rpm FROM benchmark),2
    ) AS Potential_Revenue_Loss

FROM florian_sql_data
WHERE Appointment_Status IN ('Cancelled','No Show')

GROUP BY Appointment_Status;

-- 8 Memberhsip Retention Analysis
SELECT 
    Membership_Status,
    COUNT(*) AS Customers,
    ROUND(AVG(Total_Revenue_INR),2) AS Avg_Revenue,
    ROUND(AVG(Customer_Rating),2) AS Avg_Rating
FROM florian_sql_data
GROUP BY Membership_Status;

-- 9 Best Upselling Stylist
SELECT 
    Stylist,
    COUNT(*) AS Total_Appointments,
    ROUND(SUM(Upsell_Revenue_INR),2) AS Upsell_Revenue,
    ROUND(AVG(Upsell_Revenue_INR),2) AS Avg_Upsell
FROM florian_sql_data
GROUP BY Stylist
ORDER BY Upsell_Revenue DESC
LIMIT 10;

-- 10 Most Profitable Service Types
SELECT 
    Service_Type,
    ROUND(AVG(Total_Revenue_INR),2) AS Avg_Bill_Value,
    ROUND(AVG(Revenue_Per_Minute),2) AS Revenue_Efficiency
FROM florian_sql_data
GROUP BY Service_Type
ORDER BY Revenue_Efficiency DESC;
