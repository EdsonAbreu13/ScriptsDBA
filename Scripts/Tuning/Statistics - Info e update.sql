DBCC FREEPROCCACHE;

OPTION(RECOMPILE, QUERYTRACEON 9481)

SELECT SCHEMA_NAME(schema_id) AS SchemaName,
       OBJECT_NAME(o.object_id) AS ObjectName,
       type AS ObjectType,
       s.name AS StatsName,
       STATS_DATE(o.object_id, stats_id) AS StatsDate
FROM sys.stats s
    INNER JOIN sys.objects o
        ON o.object_id = s.object_id
WHERE OBJECTPROPERTY(o.object_id, N'ISMSShipped') = 0
      AND LEFT(s.name, 4) != '_WA_'
ORDER BY ObjectType,
         SchemaName,
         ObjectName,
         StatsName;



--DESABILITAR AUTO STATISTICS NA TABELA
[18:00, 16/10/2020] +55 14 99818-0312: e pra quem te procurando a reposta... pra desligar o auto update na tabela, só chamar a sp_autostats...
[18:01, 16/10/2020] +55 14 99818-0312: ou direto na estatística... usar o no_recompute



-- SCRIPT PARA PEGAR AS STATISTICAS
 SELECT DISTINCT st.[NAME], STP.ROWS, STP.ROWS_SAMPLED ,' UPDATE STATISTICS ' +'['+ss.name+']'+'.['+OBJECT_NAME(st.object_id) +']'+' '+'['+st.name +']'+ ' WITH FULLSCAN'
 FROM SYS.STATS AS ST
 CROSS APPLY SYS.DM_DB_STATS_PROPERTIES (ST.OBJECT_ID, ST.STATS_ID) AS STP
 JOIN SYS.TABLES STA ON st.[object_id] = sta.object_id
 JOIN sys.schemas ss on ss.schema_id = STA.schema_id
 WHERE [ROWS] <> ROWS_SAMPLED
 AND STA.name = 'DIM_FORNECEDOR'
 ORDER BY [ROWS] DESC


SELECT stats.name AS StatisticsName,
OBJECT_SCHEMA_NAME(stats.object_id) AS SchemaName,
OBJECT_NAME(stats.object_id) AS TableName,
last_updated AS LastUpdated, [rows] AS [Rows],
rows_sampled, steps, modification_counter AS ModCounter,
persisted_sample_percent PersistedSamplePercent,
(rows_sampled * 100)/rows AS SamplePercent
FROM sys.stats
INNER JOIN sys.stats_columns sc
ON stats.stats_id = sc.stats_id AND stats.object_id = sc.object_id
INNER JOIN sys.all_columns ac
ON ac.column_id = sc.column_id AND ac.object_id = sc.object_id
CROSS APPLY sys.dm_db_stats_properties(stats.object_id, stats.stats_id) shr
WHERE OBJECT_NAME(stats.object_id) =''