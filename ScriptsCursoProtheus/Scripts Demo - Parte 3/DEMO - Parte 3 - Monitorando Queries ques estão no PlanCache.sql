
--------QUERIES que mostram as informações abaixo
Fonte:
http://sqlmag.com/database-performance-tuning/identifying-high-impact-queries-and-stored-procedures-dynamic-management


------- Queries mais executadas
if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace

SELECT TOP 50  execution_count, sql_handle,last_execution_time,last_worker_time,total_worker_time
into #Temp_Trace
FROM sys.dm_exec_query_stats A
where last_elapsed_time > 20
ORDER BY A.execution_count DESC

select distinct *
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 1 DESC

-------------------------------------------------- mais executadas por minuto
if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace

sELECT TOP 30   Execution_count/case when datediff(mi,creation_time, getdate()) = 0 then 1 else datediff(mi,creation_time, getdate()) end  ExecuçõesPorMin,
	creation_time,sql_handle,execution_count,last_execution_time,last_worker_time,total_worker_time,total_physical_reads , total_logical_reads ,total_logical_writes 
into #Temp_Trace
FROM sys.dm_exec_query_stats A
order by  Execution_count/case when datediff(mi,creation_time, getdate()) = 0 then 1 else datediff(mi,creation_time, getdate()) end desc

select text,*
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 2 desc


------- Queries com mais leituras(total_physical_reads + total_logical_reads + total_logical_writes)
if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace

SELECT TOP 50  total_physical_reads + total_logical_reads + total_logical_writes IO,
 sql_handle,execution_count,last_execution_time,last_worker_time,total_worker_time
into #Temp_Trace
FROM sys.dm_exec_query_stats A
where last_elapsed_time > 20
	--and last_execution_time > dateadd(ss,-600,getdate()) --ultimos 10 min
ORDER BY A.total_physical_reads + A.total_logical_reads + A.total_logical_writes DESC

select distinct *
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 1 desc


-------- Queries com maiores consumo de CPU
if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace

sELECT TOP 50 total_worker_time ,  sql_handle,execution_count,last_execution_time,last_worker_time
into #Temp_Trace
FROM sys.dm_exec_query_stats A
where last_elapsed_time > 20
	and last_execution_time > dateadd(ss,-600,getdate()) --ultimos 5 min
order by A.total_worker_time desc

select distinct *
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 1 desc
