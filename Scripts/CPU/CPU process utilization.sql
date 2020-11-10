SELECT TOP(5)
		record_id,
		[SQLProcessUtilization],
		100 - SystemIdle - SQLProcessUtilization as OtherProcessUtilization,
		[SystemIdle],
		100 - SystemIdle AS CPU_Utilization
	FROM	( 

				SELECT	record.value('(./Record/@id)[1]', 'int')													AS [record_id], 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')			AS [SystemIdle],
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')	AS [SQLProcessUtilization], 
						[timestamp] 
				FROM ( 
						SELECT [timestamp], CONVERT(XML, [record]) AS [record] 
						FROM [sys].[dm_os_ring_buffers] 
						WHERE	[ring_buffer_type] = N'RING_BUFFER_SCHEDULER_MONITOR' 
								AND [record] LIKE '%<SystemHealth>%'
					) AS X					   
			) AS Y
	ORDER BY record_id DESC
