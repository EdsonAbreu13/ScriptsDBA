--select * from [dbo].[Table_Size_History] order by Dt_Log desc

DROP TABLE #TEMP

select 
		ts.Id_Size_History
		,ud.Nm_Database
		,tb.Nm_Table
		,ts.Nm_Drive
		,ts.Nr_Total_Size
		,ts.Nr_Data_Size
		,ts.Nr_Index_Size
		,ts.Qt_Rows
		,ts.Dt_Log
		,ROW_NUMBER() OVER(PARTITION BY Nm_Database,Nm_Table,Nm_Drive ORDER BY Dt_Log DESC) RNK
	INTO #TEMP
	from
		[Traces].[dbo].[Table_Size_History] ts
	JOIN 
		[Traces].[dbo].[User_Database] ud ON ud.Id_Database = ts.Id_Database
	JOIN 
		[Traces].[dbo].[User_Table] tb ON tb.Id_Table = ts.Id_Table
	WHERE Dt_Log >= '20210207'
	AND Nm_Drive = 'D'
	ORDER BY Nm_Database,Nm_Table,Nm_Drive DESC


DROP TABLE #TEMP2

SELECT 
		Nm_Database
		,Nm_Table
		,Nm_Drive
		,ISNULL((SELECT Nr_Total_Size FROM #TEMP t2 WHERE t2.Nm_Database = t.Nm_Database AND t2.Nm_Table = t.Nm_Table AND t2.Dt_Log = DATEADD(DAY,-2,t.Dt_Log)),0) AS [Total_Size 02/07]
		,ISNULL((SELECT Nr_Total_Size FROM #TEMP t2 WHERE t2.Nm_Database = t.Nm_Database AND t2.Nm_Table = t.Nm_Table AND t2.Dt_Log = DATEADD(DAY,-1,t.Dt_Log)),0) AS [Total_Size 02/08]
		,ISNULL(Nr_Total_Size,0) AS [Total_Size 02/09]
		,Nr_Data_Size
		,Nr_Index_Size
		,Qt_Rows
		,Dt_Log
		,RNK 
	INTO #TEMP2
	FROM 
		#TEMP t
	WHERE 
		RNK = 1
		--AND Nr_Total_Size > 0

SELECT 
		Nm_Database
		,Nm_Table
		,Nm_Drive
		--,[Total_Size 02/07]
		,[Total_Size 02/08]
		,[Total_Size 02/09]
		,[Total_Size 02/09]-[Total_Size 02/08] AS [Growth_MB]
		,Nr_Data_Size
		,Nr_Index_Size
		,Qt_Rows
		,Dt_Log
	FROM 
		#TEMP2 t
	WHERE 
		[Total_Size 02/09]-[Total_Size 02/08] <> 0
	ORDER BY 
		[Growth_MB] DESC

--SELECT
--s.[name] AS [schema],
--t.[name] AS [table_name],
--p.[rows] AS [row_count],
--CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [size_mb],
--CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [used_mb],
--CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [unused_mb]
--FROM
--sys.tables t
--JOIN sys.indexes i ON t.[object_id] = i.[object_id]
--JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
--JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
--LEFT JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
--WHERE
--t.is_ms_shipped = 0
--AND i.[object_id] > 255
--AND t.name like '%BKP202102%'
--GROUP BY
--t.[name],
--s.[name],
--p.[rows]
--ORDER BY
--[size_mb] DESC



select 
		SUM(ts.Nr_Total_Size)/1024. as [02/08]
	from
		[Traces].[dbo].[Table_Size_History] ts	
	WHERE Dt_Log = '20210208'
	AND Nm_Drive = 'D'
	
select 
		SUM(ts.Nr_Total_Size)/1024. as [02/09]
	from
		[Traces].[dbo].[Table_Size_History] ts	
	WHERE Dt_Log = '20210209'
	AND Nm_Drive = 'D'



	