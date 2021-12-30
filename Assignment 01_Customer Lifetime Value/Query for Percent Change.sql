SELECT May.SHOP_MONTH, May.ProdCode, (Spend_May-Spend_Apr)/Spend_Apr AS "%Diff_Spend", (Quantity_May-Quantity_Apr)/Quantity_Apr AS "%Diff_Quantity"
FROM (
	SELECT TO_CHAR(SHOP_DATE,'YYYYMM') AS SHOP_MONTH, ProdCode, SUM(Spend) AS Spend_Apr, SUM(Quantity) AS Quantity_Apr
	FROM SupermarketData
	WHERE TO_CHAR(SHOP_DATE,'YYYYMM') = '201804'
	GROUP BY 1,2
) Apr LEFT JOIN (
	SELECT TO_CHAR(SHOP_DATE,'YYYYMM') AS SHOP_MONTH, ProdCode, SUM(Spend) AS Spend_May, SUM(Quantity) AS Quantity_May
	FROM SupermarketData
	WHERE TO_CHAR(SHOP_DATE,'YYYYMM') = '201805'
	GROUP BY 1,2
) May ON Apr.ProdCode = May.ProdCode
GROUP BY 1,2
UNION ALL
SELECT Jun.SHOP_MONTH, Jun.ProdCode, (Spend_Jun-Spend_May)/Spend_May AS "%Diff_Spend", (Quantity_Jun-Quantity_May)/Quantity_May AS "%Diff_Quantity"
FROM (
	SELECT TO_CHAR(SHOP_DATE,'YYYYMM') AS SHOP_MONTH, ProdCode, SUM(Spend) AS Spend_May, SUM(Quantity) AS Quantity_May
	FROM SupermarketData
	WHERE TO_CHAR(SHOP_DATE,'YYYYMM') = '201805'
	GROUP BY 1,2
) May LEFT JOIN (
	SELECT TO_CHAR(SHOP_DATE,'YYYYMM') AS SHOP_MONTH, ProdCode, SUM(Spend) AS Spend_Jun, SUM(Quantity) AS Quantity_Jun
	FROM SupermarketData
	WHERE TO_CHAR(SHOP_DATE,'YYYYMM') = '201806'
	GROUP BY 1,2
) Jun ON May.ProdCode = Jun.ProdCode
GROUP BY 1,2;