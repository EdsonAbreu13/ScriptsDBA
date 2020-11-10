SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 


SELECT *  FROM sys.dm_io_pending_io_requests



SELECT 
	
	DB_NAME(database_id) AS [Database],
	[file_id], 
	[io_stall_read_ms],
	[io_stall_write_ms],2
	[io_stall] 
FROM 
	sys.dm_io_virtual_file_stats(NULL,NULL) 
ORDER BY 
	[io_stall_read_ms] DESC 
	

SELECT TOP 10
creation_time
, last_execution_time
, total_logical_reads AS [LogicalReads] , total_logical_writes AS [LogicalWrites] , execution_count
, total_logical_reads+total_logical_writes AS [AggIO] , (total_logical_reads+total_logical_writes)/(execution_count+0.0) AS [AvgIO] , st.TEXT
, DB_NAME(st.dbid) AS database_name
, st.objectid AS OBJECT_ID
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
WHERE total_logical_reads+total_logical_writes > 0
AND sql_handle IS NOT NULL
ORDER BY [AggIO] DESC



use Traces

--filtre a base 
select top 1000 * from Log_IO_Pending where Nm_Database= 'tempdb'  order by  Dt_Log desc

 
select * from (
	select Id_Log_IO_Pending, Nm_Database, Physical_Name, IO_Pending, IO_Pending_ms,IO_Type, Number_Reads,Number_Writes,Dt_Log, 
		ROW_NUMBER () OVER(PARTITION BY Dt_Log,Nm_Database,Physical_Name ORDER BY IO_Pending_ms DESC) ord
		from Log_IO_Pending where Nm_Database= 'tempdb' and Dt_Log >= '20201021 17:00')x
where ord=1
order by  Dt_Log desc

