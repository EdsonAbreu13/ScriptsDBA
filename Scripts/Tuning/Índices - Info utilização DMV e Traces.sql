;WITH dados AS
(
	SELECT 
		d.name AS Database_Name,
		objects.name AS Table_name,
		indexes.name AS Index_name,
		dm_db_index_usage_stats.user_seeks,
		dm_db_index_usage_stats.user_scans,
		dm_db_index_usage_stats.user_lookups,
		dm_db_index_usage_stats.user_updates,	 
		dm_db_index_usage_stats.last_user_seek,
		dm_db_index_usage_stats.last_user_scan,
		dm_db_index_usage_stats.last_user_lookup,
		SUM(used_page_count) * 8 / 1024  AS IndexSizeMB
	FROM
		sys.dm_db_index_usage_stats
		INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
		INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
		INNER JOIN sys.dm_db_partition_stats  s ON s.[object_id] = objects.[object_id] AND s.index_id = indexes.index_id
		INNER JOIN sys.databases d ON d.[database_id] = sys.dm_db_index_usage_stats.database_id AND d.database_id = DB_ID()
	WHERE indexes.is_primary_key = 0
		AND indexes.type_desc = 'NONCLUSTERED'   
		--AND indexes.name = 'IX_1'
		--AND d.name = 'Kurier'
		--AND  dm_db_index_usage_stats.user_lookups < 100	    
		--AND dm_db_index_usage_stats.user_seeks < 100	    
		--AND dm_db_index_usage_stats.user_scans < 100
	GROUP BY
		d.name,
		objects.name,
		indexes.name,
		dm_db_index_usage_stats.user_lookups,
		dm_db_index_usage_stats.user_seeks,
		dm_db_index_usage_stats.user_scans,
		dm_db_index_usage_stats.user_updates,
		dm_db_index_usage_stats.last_user_scan,
		dm_db_index_usage_stats.last_user_seek,
		dm_db_index_usage_stats.last_user_lookup
)
SELECT Database_Name,Table_name,Index_name,user_seeks,user_scans,user_lookups,user_updates,IndexSizeMB,
(SELECT MAX(Last_Access)
      FROM (VALUES (last_user_scan),(last_user_seek),(last_user_lookup)) AS Last_Access(Last_Access))  AS Last_Access
FROM 
	dados
ORDER BY
		IndexSizeMB DESC



-- UTILIZAÇÃO DE INDICES DMV & TRACES
;WITH dados AS
(
	SELECT 
		d.name AS Database_Name,
		objects.name AS Table_name,
		indexes.name AS Index_name,
		SUM(used_page_count) * 8 / 1024  AS IndexSizeMB
	FROM
		sys.dm_db_index_usage_stats
		INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
		INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
		INNER JOIN sys.dm_db_partition_stats  s ON s.[object_id] = objects.[object_id] AND s.index_id = indexes.index_id
		INNER JOIN sys.databases d ON d.[database_id] = sys.dm_db_index_usage_stats.database_id AND d.database_id = DB_ID()
	WHERE indexes.is_primary_key = 0
		AND indexes.type_desc = 'NONCLUSTERED'   
		--AND indexes.name = 'IX_1'
		--AND d.name = 'Kurier'
		--AND  dm_db_index_usage_stats.user_lookups < 100	    
		--AND dm_db_index_usage_stats.user_seeks < 100	    
		--AND dm_db_index_usage_stats.user_scans < 100
	GROUP BY
		d.name,
		objects.name,
		indexes.name		
)
SELECT 
		d.Database_Name
		,d.Table_name 
		,d.Index_name 
		,d.IndexSizeMB 
		,MAX(vw.Last_Access) Last_Access
		,DATEDIFF(DAY,MAX(vw.Last_Access),GETDATE() ) Last_Access
	FROM dados d
	JOIN Traces..vwIndex_Utilization_History vw ON vw.Nm_Database = d.Database_Name AND vw.Nm_Table = d.Table_name AND vw.Nm_Index = d.Index_name
	GROUP BY 
		d.Database_Name
		,d.Table_name
		,d.Index_name
		,d.IndexSizeMB
	ORDER BY
			IndexSizeMB DESC
