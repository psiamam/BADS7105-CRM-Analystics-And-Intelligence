SELECT  * , CASE WHEN STATUS IS NOT NULL and STATUS = "Churn" THEN -1 
        WHEN STATUS IS NOT NULL and STATUS <> "Churn" THEN 1 
        ELSE 0 END AS VALUE
FROM (
    SELECT * 
    FROM (
        SELECT  YEAR_MONTH, MIN_SHOP_DATE, FOR_CHECK, PREVIOUS_MONTH, 
                CASE WHEN MIN_SHOP_DATE = YEAR_MONTH THEN "New"
                WHEN PREVIOUS_MONTH IS NOT NULL AND FOR_CHECK ="1" THEN "Repeat" 
                WHEN PREVIOUS_MONTH IS NULL AND FOR_CHECK = "1" AND MIN_SHOP_DATE < YEAR_MONTH THEN "Reactivated" 
                WHEN PREVIOUS_MONTH IS NOT NULL AND FOR_CHECK IS NULL THEN "Churn"
                ELSE NULL END AS STATUS 
        FROM (
            SELECT YEAR_MONTH, MIN_SHOP_DATE, FOR_CHECK, LAG(FOR_CHECK) OVER (PARTITION BY CUST_CODE ORDER BY YEAR_MONTH) AS PREVIOUS_MONTH 
            FROM (
                SELECT MASTER.YEAR_MONTH, MASTER.CUST_CODE, MASTER.CUST_CODE_YEARMONTH, MASTER.MIN_SHOP_DATE, CHK_CUST.FOR_CHECK 
                FROM (
                    SELECT DETAIL.YEAR_MONTH, DETAIL.CUST_CODE, DETAIL.CUST_CODE_YEARMONTH, MIN_DATE.MIN_SHOP_DATE
                    FROM (
                        SELECT YEAR_MONTH,CUST_CODE, CONCAT(CUST_CODE,YEAR_MONTH) AS CUST_CODE_YEARMONTH
                        FROM (
                            SELECT MASTER_YR.YEAR_MONTH, MASTER_CUST.CUST_CODE
                            FROM (
                                    SELECT FORMAT_DATETIME("%Y-%m", SHOP_DATE) AS YEAR_MONTH 
                                    FROM (
                                        SELECT PARSE_DATE('%Y%m%d', CAST(SHOP_DATE AS STRING)) AS SHOP_DATE 
                                        FROM `data-rookery-331410.Supermarket_Data.Supermarket_Data_Table`  -- Change Table Name
                                        WHERE CUST_CODE IS NOT NULL
                                        ) GROUP BY 1
                                    ORDER BY 1
                                ) MASTER_YR 
                                CROSS JOIN (
                                    SELECT CUST_CODE 
                                    FROM `data-rookery-331410.Supermarket_Data.Supermarket_Data_Table`  -- Change Table Name
                                    WHERE CUST_CODE IS NOT NULL
                                    GROUP BY 1 
                                    ORDER BY 1
                                ) MASTER_CUST
                            )
                        ) DETAIL JOIN (
                            SELECT CUST_CODE, MIN(FORMAT_DATETIME("%Y-%m",SHOP_DATE)) as MIN_SHOP_DATE 
                            FROM (
                                SELECT PARSE_DATE('%Y%m%d', CAST(SHOP_DATE AS STRING)) AS SHOP_DATE, CUST_CODE 
                                FROM `data-rookery-331410.Supermarket_Data.Supermarket_Data_Table`  -- Change Table Name
                                WHERE CUST_CODE IS NOT NULL
                                ) CUST
                            GROUP BY 1
                        ) MIN_DATE ON DETAIL.CUST_CODE = MIN_DATE.CUST_CODE
                    ) MASTER LEFT JOIN (
                        SELECT CONCAT(CUST_CODE, YEAR_MONTH) AS CUST_CODE_YEARMONTH, "1" AS FOR_CHECK 
                        FROM (
                                SELECT CUST_CODE, FORMAT_DATETIME("%Y-%m", SHOP_DATE) AS YEAR_MONTH 
                                FROM (
                                    SELECT PARSE_DATE('%Y%m%d', CAST(SHOP_DATE AS STRING)) AS SHOP_DATE, CUST_CODE 
                                    FROM `data-rookery-331410.Supermarket_Data.Supermarket_Data_Table` -- Change Table Name
                                    WHERE CUST_CODE IS NOT NULL
                                    ) CUST_SHOP_DATE
                                GROUP BY 1,2
							) X
                        ) CHK_CUST ON MASTER.CUST_CODE_YEARMONTH = CHK_CUST.CUST_CODE_YEARMONTH
                        ORDER BY CHK_CUST.FOR_CHECK
                ) DETAIL_1
            ) DETAIL_2
        ) DETAIL_3
        WHERE STATUS IS NOT NULL 
        ORDER BY 1
    ) DETAIL_4