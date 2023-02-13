--Query 1
SELECT TOP (100) * FROM Fact.Sale;

--Query 2
IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'V_CustomerSales') 
DROP VIEW dbo.V_CustomerSales;
GO
CREATE VIEW dbo.V_CustomerSales AS (
SELECT C.[Customer]
, S.[Invoice Date Key] AS [Sale Date]
, SUM(S.[Total Including Tax]) AS [Total Daily Sales]
FROM Dimension.Customer C
INNER JOIN Fact.Sale S On S.[Customer Key] = C.[Customer Key]
GROUP BY C.[Customer]
, S.[Invoice Date Key]
);
GO


--Query 3
SELECT [Customer]
, SUM ([Total Daily Sales]) AS [Lifetime Sales]
FROM DBO.V_CustomerSales
WHERE [Customer] <> 'unknown'
GROUP BY [Customer]
HAVING SUM ([TOTAL DAILY SALES]) > 400000;

