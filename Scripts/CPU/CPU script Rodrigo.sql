IF OBJECT_ID('tempdb..#UsoCPUAnterior') IS NOT NULL
DROP TABLE #UsoCPUAnterior;
SELECT
R.session_id
,R.request_id
,R.start_time
,R.cpu_time
,CURRENT_TIMESTAMP as DataColeta
INTO
#UsoCPUAnterior
FROM
sys.dm_exec_requests R
WHERE 
R.session_id != @@SPID
WAITFOR DELAY '00:00:01.000'; --> Aguarda 1 segundo (intervalo de monitoramento)
SELECT
R.session_id
,R.request_id
,R.start_time
,Intervalo = ISNULL(DATEDIFF(ms,DataColeta,CURRENT_TIMESTAMP),R.total_elapsed_time)
,CPUIntervalo = ISNULL(R.cpu_time-U.cpu_time,R.cpu_time)
,[%Intervalo] = ISNULL((R.cpu_time-U.cpu_time)*100/DATEDIFF(ms,DataColeta,CURRENT_TIMESTAMP),ISNULL(R.cpu_time*100/NULLIF(R.total_elapsed_time,0),0))
,Duracao = R.total_elapsed_time 
,CPUTotal = R.cpu_time 
,[%Total] = CONVERT(int,(R.cpu_time*100./NULLIF(R.total_elapsed_time,0)))
,ObjectName = ISNULL(OBJECT_NAME(EX.objectid,EX.dbid),R.command)
,Trecho = CONVERT(xml,
REPLACE
(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
CONVERT
(
NVARCHAR(MAX),
N'<?query -- ' + NCHAR(13) + NCHAR(10) 
+ 
SUBSTRING(EX.text,R.statement_start_offset/2 + 1, ISNULL((NULLIF(R.statement_end_offset,-1) - R.statement_start_offset)/2 + 1,LEN(EX.text)) )
+ NCHAR(13) + NCHAR(10) + N'--?>' COLLATE Latin1_General_Bin2
),
NCHAR(31),N'?'),NCHAR(30),N'?'),NCHAR(29),N'?'),NCHAR(28),N'?'),NCHAR(27),N'?'),NCHAR(26),N'?'),NCHAR(25),N'?'),NCHAR(24),N'?'),NCHAR(23),N'?'),NCHAR(22),N'?'),
NCHAR(21),N'?'),NCHAR(20),N'?'),NCHAR(19),N'?'),NCHAR(18),N'?'),NCHAR(17),N'?'),NCHAR(16),N'?'),NCHAR(15),N'?'),NCHAR(14),N'?'),NCHAR(12),N'?'),
NCHAR(11),N'?'),NCHAR(8),N'?'),NCHAR(7),N'?'),NCHAR(6),N'?'),NCHAR(5),N'?'),NCHAR(4),N'?'),NCHAR(3),N'?'),NCHAR(2),N'?'),NCHAR(1),N'?'),
NCHAR(0),
N''
) 
)
,DatabaseName = db_name(R.database_id)
,s.*
,R.logical_reads
,R.reads
,r.writes
FROM
sys.dm_exec_requests R
LEFT JOIN
#UsoCPUAnterior U
ON R.session_id = U.session_id
AND R.request_id = U.request_id
AND R.start_time = U.start_time
outer apply sys.dm_exec_sql_text( R.sql_handle ) as EX
cross apply (
select S.scheduler_id as 'data()' From sys.dm_os_tasks T join sys.dm_os_schedulers S on S.scheduler_id = T.scheduler_id 
WHERE T.session_id = R.session_id AND T.request_id = R.request_id 
FOR XML PATH('')
) S(sched)
WHERE 
R.session_id != @@SPID
and
s.sched IS NOT NULL
ORDER BY
[%Intervalo] desc
