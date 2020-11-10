


-- Vamos simular um Wait ASYNC NETWORK IO seguindo esse post
-- https://forrestmcdaniel.com/2019/03/11/two-easy-async_network_io-demos/

-- Thanks Forrest!!!


-- Vamos chamar objetos .Net via powershell simulando uma aplicação consumindo dados linha a linha


--Vamos criar um job para rodar um Script Power shell
$conn = New-Object -TypeName System.Data.SqlClient.SqlConnection("Server = .;Integrated Security = True")
$qry = "SELECT TOP 5000 ROW_NUMBER() OVER(ORDER BY (SELECT 'DEMO ASYNC')), REPLICATE('abcd',2000), REPLICATE('FROM',2000), REPLICATE('TSQL',2000) FROM Curso_Protheus.dbo.SA1010"
$cmd = New-Object System.Data.SqlClient.SqlCommand

$conn.Open()

$cmd.CommandText = $qry
$cmd.Connection = $conn

$reader = $cmd.ExecuteReader()

while ($reader.Read()) {$reader[0];Start-Sleep -Milliseconds 5}

$conn.Close()



-- Rodar o Job job e monitorar na whoisactive

exec sp_whoisactive --@get_task_info =2, @get_plans = 1, @delta_interval = 1, @show_sleeping_spids = 0, @get_outer_command = 1


-- Mostrar o Wait usando o SSMS e ver na whoisactive novamente
SELECT TOP 1000000 FROM SA1010


--Validar os waits

-- Para dar uma melhor visão, limpando o wait stats...
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)


;WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
       100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
 
        -- Maybe uncomment these four if you have mirroring issues
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
 
        N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
 
        -- Maybe uncomment these six if you have AG issues
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
 
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE', N'MEMORY_ALLOCATION_EXT',
        N'ONDEMAND_TASK_QUEUE',
        N'PREEMPTIVE_XE_GETTARGETSTATE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'QDS_SHUTDOWN_QUEUE', N'REDO_THREAD_PENDING_WORK',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
        N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_RECOVERY',
        N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT','TRACEWRITE','SOS_WORK_DISPATCHER')
    AND [waiting_tasks_count] > 0
    )
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S],
    CAST ('https://www.sqlskills.com/help/waits/' + MAX ([W1].[wait_type]) as XML) AS [Help/Info URL]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX( [W1].[Percentage] ) < 95; -- percentage threshold
GO



-- Teste Profile logando a string "SELECT TOP 5000"

--Rodar a query novamente e o JOB e comparar o tempo

SELECT TOP 5000 ROW_NUMBER() OVER(ORDER BY (SELECT 'DEMO ASYNC')), REPLICATE('abcd',2000), REPLICATE('FROM',2000), REPLICATE('TSQL',2000) FROM Curso_Protheus.dbo.SA1010 WHERE A1_NOME COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%a%a%a%a%a%'


/*

--Estudo complementar
-- https://www.sqlskills.com/help/waits/async_network_io/
	
	"This wait type is never indicative of a problem with SQL Server"

	There is usually nothing that you can do with your SQL Server code that will affect this wait type. There are a few causes of this on the client side, including:

		 - The client code is doing what is known as RBAR (Row-By-Agonizing-Row), where only one row at a time is pulled from the results and processed, 
		instead of caching all the results and then immediately replying to SQL Server and proceeding to process the cached rows.

		- The client code is running on a server that has performance issues, and so the client code is running slowly.
		- The client code is running on a VM on a host that is configured incorrectly or overloaded such that the VM doesn’t get to run properly (i.e. slowly or coscheduling issues).

*/