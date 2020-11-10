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


