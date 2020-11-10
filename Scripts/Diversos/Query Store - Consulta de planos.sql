SELECT Txt.query_text_id, 
       Txt.query_sql_text, 
       Pl.plan_id, 
       Qry.* 
FROM   sys.query_store_plan AS Pl 
       INNER JOIN sys.query_store_query AS Qry 
               ON Pl.query_id = Qry.query_id 
       INNER JOIN sys.query_store_query_text AS Txt 
               ON Qry.query_text_id = Txt.query_text_id 
WHERE  1 = 1 
       AND query_sql_text LIKE '%VW_BZ_PRODUTO%' 
--and Qry.last_compile_start_time >= '20191025 10:00' and Qry.last_compile_start_time <= '20190925 10:30'



SELECT 
		Dateadd(hh, -3, CONVERT(DATETIME, RSI.start_time))start_time, 
       Dateadd(hh, -3, CONVERT(DATETIME, RSI.end_time))end_time, 
       Q.query_hash, 
       QP.plan_id, 
       QP.query_id, 
       CONVERT(XML, QP.query_plan) query_plan, 
       QP.count_compiles, 
       Q.count_compiles, 
       RS.count_executions, 
       RS.avg_cpu_time, 
       Dateadd(hh, -3, CONVERT(DATETIME, QP.initial_compile_start_time)) Compile_plan_Date, 
       Dateadd(hh, -3, CONVERT(DATETIME, QP.last_compile_start_time)) last_compile_start_time , 
       Dateadd(hh, -3, CONVERT(DATETIME, QP.last_execution_time)) last_execution_time, 
       execution_type_desc, 
       Dateadd(hh, -3, CONVERT(DATETIME, RS.first_execution_time)) First_Execution_Plan 
FROM   sys.query_store_query Q 
       INNER JOIN sys.query_store_plan QP 
               ON QP.query_id = Q.query_id 
       INNER JOIN sys.query_store_runtime_stats RS 
               ON RS.plan_id = QP.plan_id 
       INNER JOIN sys.query_store_runtime_stats_interval RSI 
               ON RSI.runtime_stats_interval_id = RS.runtime_stats_interval_id 
WHERE  1=1
AND Q.query_hash = 0xDA810CF5F85598EA 
--AND Dateadd(hh, -8, CONVERT(DATETIME, RSI.start_time)) > '20191030' 
--and QP.is_forced_plan = 1 
ORDER  BY 1, 
          QP.initial_compile_start_time 

