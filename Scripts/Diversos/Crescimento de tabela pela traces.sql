SELECT UD.nm_database
,UT.nm_table
,[nm_drive]
,[nr_total_size] AS TOTAL
,dt_log
INTO #q1
FROM [Traces].[dbo].[table_size_history] TSH
JOIN traces..user_table UT ON TSH.id_table = UT.id_table
JOIN traces..user_database UD ON UD.id_database = TSH.id_database
WHERE TSH.id_database = 11
AND TSH.dt_log >= Getdate() - 60
AND [nr_total_size] > 0
ORDER BY total DESC

SELECT nm_database
,nm_table
,dt_log AS Data_Atual
,total AS Tamanho_Atual
,(
SELECT TOP 1 dt_log
FROM #q1 temp2
WHERE temp1.nm_table = temp2.nm_table
ORDER BY dt_log ASC
) AS DT_Antes
,(
SELECT TOP 1 total
FROM #q1 temp2
WHERE temp1.nm_table = temp2.nm_table
ORDER BY dt_log ASC
) AS Tamanho_Antes
,total - (
SELECT TOP 1 total
FROM #q1 temp2
WHERE temp1.nm_table = temp2.nm_table
ORDER BY dt_log ASC
) AS Diferença_TOTAL
FROM #q1 temp1
WHERE dt_log = '2021-02-10'
ORDER BY diferença_total DESC