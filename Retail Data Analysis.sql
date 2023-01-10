create database Retail
select * from CUSTOMER AS T1
select * from prod_cat_info as T2
select * from Transactions AS T3

/*
select T1.customer_Id,DOB,Gender, city_code, transaction_id,tran_date,T2.prod_cat,
T3.prod_cat_code,T2.prod_subcat,T3.prod_subcat_code,Qty,Rate,
Tax, total_amt,store_type
from CUSTOMER as T1
inner join Transactions as T3
on T1.customer_Id=T3.cust_id 
inner join prod_cat_info as T2
on T2.prod_sub_cat_code=T3.prod_subcat_code
*/

--DATA PREPARATION AND UNDERSTANDING
--Q1.WHAT IS THE TOTAL NUMBER OF ROWS IN EACH OF THE 3 TABLES?

		SELECT COUNT(*) AS T1 FROM CUSTOMER 
		SELECT COUNT(*) AS T2 FROM prod_cat_info
		SELECT COUNT(*) AS T3 FROM TRANSACTIONS

--Q2.WHAT IS THE TOTAL NUMBER OF TRANSACTIONS THAT HAVE A RETURN?

		SELECT COUNT(TOTAL_AMT) as Return_transactions FROM Transactions
		WHERE TOTAL_AMT LIKE '-%'

--Q3.CONVERT THE DATE VARIABLES INTO VALID DATE FORMATS

		SELECT CONVERT (VARCHAR,DOB,103) AS NEW_DOB 
		from Customer
		select CONVERT (VARCHAR,TRAN_DATE,103) AS NEW_TRAN_DATE 
		from Transactions

--Q4.WHAT IS THE TIME RANGE OF THE TRANSACTION DATA AVAILABLE FOR ANALYSIS? SHOW THE OUTPUT IN NUMBER OF DAYS,MONTHS 
--   AND YEARS SIMULTANEOUSLY IN DIFFERENT COLUMNS.

		SELECT 
		DATEDIFF(DAY, MIN(CONVERT(DATE, Tran_date, 105)), MAX(CONVERT(DATE,Tran_date, 105)))as No_Days, 
		DATEDIFF(MONTH, MIN(CONVERT(DATE, Tran_date, 105)), MAX(CONVERT(DATE,Tran_date, 105))) No_Months,  
		DATEDIFF(YEAR, MIN(CONVERT(DATE, Tran_date, 105)), MAX(CONVERT(DATE,Tran_date, 105))) No_Year 
		FROM Transactions

--Q5.WHICH PRODUCT DOES THE 'DIY' BELONG TO?

		SELECT PROD_CAT , prod_subcat
		FROM prod_cat_info
		WHERE prod_subcat LIKE 'DIY'

--DATA ANALYSIS

--Q1.WHICH CHANNEL IS MOST FREQUENTLY USED FOR TRANSACTIONS?

SELECT STORE_TYPE,
COUNT(STORE_TYPE) AS Count_
FROM Transactions
GROUP BY Store_type
ORDER BY count_ DESC 
offset 0 rows
fetch first 1 rows only

--Q2.WHAT IS THE COUNT OF MALE AND FEMALE CUSTOMERS IN TNE DATABASE?

select Gender,count(customer_Id) as New_count
from Customer
where gender in ('M', 'F')
group by Gender
 
--Q3.FROM WHICH CITY DO WE HAVE THE MAXIMUM NUMBER OF CUSTOMERS AND HOW MANY?

SELECT CITY_CODE, COUNT(CITY_CODE) AS MAX_CUSTOMERS
FROM Customer
GROUP BY city_code
ORDER BY MAX_CUSTOMERS DESC

--Q4.HOW MANY SUB-CATEGORIES ARE THERE UNDER THE BOOKS CATEGORIES?

SELECT PROD_CAT, COUNT(PROD_SUBCAT) AS SUBCAT
FROM prod_cat_info
WHERE prod_cat LIKE 'BOOKS'
GROUP BY prod_cat

--Q5.WHAT IS THE MAXIMUM QUANTITIES OF PRODUCT EVER ORDERED?

SELECT COUNT(QTY) AS MAX_QTY,T2.prod_cat
FROM Transactions AS T3
inner join prod_cat_info as T2
on T2.prod_sub_cat_code=T3.prod_subcat_code
GROUP BY T2.prod_cat
ORDER BY MAX_QTY DESC

--Q6.WHAT IS THE NET TOTAL REVENUE GENERATED IN CATEGORIES ELECTRONICS AND BOOKS?

select sum(T3.total_amt) as Total ,T3.Tax
from Transactions as T3
inner join prod_cat_info as T2
ON T2.prod_cat_code =T3.prod_cat_code 
and  T2.prod_sub_cat_code= T3.prod_subcat_code
where T2.prod_cat in ('Electronics', 'Books')

--Q7.HOW MANY CUSTOMERS HAVE >10 TRANSACTIONS WITH US,EXCLUDING RETURNS?
select count(cust_id) as no_of_customers
from  
(
		select cust_id
		from Transactions
		where Qty >= 0 AND total_amt NOT LIKE '-%'
		group by cust_id
		having COUNT(cust_id) > 10
) t1
--Q8.WHAT IS THE NET TOTAL REVENUE GENERATED IN CATEGORIES "ELECTRONICS" AND "CLOTHING" CATEGORIES FROM "FLAGSHIP" STORES?

select sum(total_amt) as Net_Revenue, T2.prod_cat, Store_type
from Transactions as T3
inner join prod_cat_info as T2
on T2.prod_cat_code= T3.prod_cat_code
and T2.prod_sub_cat_code= T3.prod_subcat_code
where Prod_cat in('Electronics', 'Clothing') and Store_type like 'Flagship Store'
group by T2.prod_cat , Store_type


--Q9.WHAT IS THE TOTAL REVENUE GENERATED FROM "MALE" CUSTOMERS IN "ELECTRONICS" CATEGORY?
---- OUTPUT SHOULD DISPLAY TOTAL REVENUE BY PROD_SUB_CAT

		select T2.prod_cat, T2.prod_subcat, T1.Gender,sum( total_amt) as Total_Revenue 
		from CUSTOMER as T1
		inner join Transactions as T3
		on T1.customer_Id=T3.cust_id 
		inner join prod_cat_info as T2
		on T2.prod_cat_code= T3.prod_cat_code
		and T2.prod_sub_cat_code=T3.prod_subcat_code
		where T1.Gender like 'M' and T2.Prod_cat = 'Electronics' 
		group by T2.Prod_cat , Gender , T2.prod_subcat

--Q10.WHAT IS THE PERCENTAGE OF SALES AND RETURNS BY PRODUCT SUB CATEGORY; DISPLAY ONLY TOP 5 CATEGORIES IN TERMS OF SALES.
		Select Top 5 prod_cat,
		Sum(Case When Qty < 0 Then Qty Else 0 end )* 100/Sum(Case When Qty > 0 Then Qty Else 0 end ) [Return%],
		100 + Sum(Case When Qty < 0 Then Qty Else 0 end )* 100/Sum(Case When Qty > 0 Then Qty Else 0 end ) [Sales %]
		from Transactions as x
		inner join prod_cat_info as y
		on x.prod_cat_code=y.prod_cat_code
		and x.prod_subcat_code=y.prod_sub_cat_code
		group by prod_cat 
		Order By [Sales %]

--Q11.FOR ALL CUSTOMERS AGED BETWEEN 25 TO 35 YEARS , FIND WHAT IS THE TOTAL REVENUE GENERATED BY THESE CONSUMERS IN LAST
-- 30 DAYS OF TRANSACTIONS FROM MAX TRANSACTION DATE AVAILABLE IN THE DATA?

SELECT CUST_ID,SUM(TOTAL_AMT) AS TOTAL_REVENUE
FROM TRANSACTIONS
WHERE CUST_ID IN 
	(
	 SELECT CUSTOMER_ID
	 FROM CUSTOMER
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM TRANSACTIONS)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103))FROM Transactions
	 )
GROUP BY CUST_ID

--Q12.WHICH PRODUCT CATEGORY HAS SEEN THE MAX VALUE OF RETURNS IN THE LAST 3 MONTHS OF TRANSACTION?

SELECT TOP 1
PROD_CAT, SUM(TOTAL_AMT)AS MAX_RETURN
FROM TRANSACTIONS AS T3
INNER JOIN PROD_CAT_INFO AS T2 
ON T3.PROD_CAT_CODE = T2.PROD_CAT_CODE 
AND T3.PROD_SUBCAT_CODE = T2.PROD_SUB_CAT_CODE
WHERE TOTAL_AMT < 0 
AND CONVERT(date, TRAN_DATE, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)) 
AND (SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)
GROUP BY PROD_CAT
ORDER BY MAX_RETURN DESC

--Q13.WHICH STORE-TYPE SELLS THE MAXIMUM PRODUCTS; BY VALUE OF SALES AND BY QUANTITY SOLD?

		SELECT STORE_TYPE,SUM(TOTAL_AMT) AS SALES_VALUE, SUM(QTY) AS SALES_QUANTTITY
		FROM TRANSACTIONS
		GROUP BY STORE_TYPE
		HAVING SUM(TOTAL_AMT) >= ALL (SELECT SUM(TOTAL_AMT) FROM TRANSACTIONS GROUP BY STORE_TYPE)
		AND SUM(QTY) >=ALL (SELECT SUM(QTY) FROM TRANSACTIONS GROUP BY STORE_TYPE)

--Q14.WHAT ARE THE CATEGORIES FOR WHICH AVERAGE REVENUE IS ABOVE THE OVERALL AVERAGE?

		SELECT T2.PROD_CAT,AVG(TOTAL_AMT) AS OVERALL_AVG
		FROM TRANSACTIONS AS T3
		INNER JOIN PROD_CAT_INFO  AS T2
		ON T2.PROD_CAT_CODE = T3.PROD_CAT_CODE 
		AND T3.PROD_SUBCAT_CODE= T2.prod_sub_cat_code
		GROUP BY T2.prod_cat
		HAVING AVG(TOTAL_AMT) >(SELECT AVG(TOTAL_AMT) FROM TRANSACTIONS)


--Q15.FIND THE AVERAGE AND TOTAL REVENUE BY EACH SUBCATEGORY FOR THE CATEGORIES WHICH ARE AMONG TOP 5 CATEGORIES
-- IN TERMS OF QUANTITY SOLD.

		SELECT PROD_CAT, PROD_SUBCAT, AVG(TOTAL_AMT) AS AVG_REVENUE, SUM(TOTAL_AMT) AS REVENUE
		FROM Transactions AS T3
		INNER JOIN prod_cat_info AS T2
		ON T2.PROD_CAT_CODE=T3.PROD_CAT_CODE
		AND T2.PROD_SUB_CAT_CODE=T3.PROD_SUBCAT_CODE
		WHERE PROD_CAT IN
		(
		SELECT TOP 5 PROD_CAT
		FROM TRANSACTIONS 
		INNER JOIN  prod_cat_info AS T2
		ON T2.PROD_CAT_CODE=T3.PROD_CAT_CODE
		AND T2.PROD_SUB_CAT_CODE=T3.PROD_SUBCAT_CODE
		GROUP BY PROD_CAT
		ORDER BY SUM(QTY) DESC
		)
		GROUP BY PROD_CAT, PROD_SUBCAT 


