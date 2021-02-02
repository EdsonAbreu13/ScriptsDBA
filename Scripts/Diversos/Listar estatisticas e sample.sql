
SELECT DISTINCT '['+ss.name+']'+'.['+OBJECT_NAME(st.object_id) +']' Tabela, st.[NAME], STP.ROWS, STP.ROWS_SAMPLED ,STP.ROWS - STP.ROWS_SAMPLED DIFF,' UPDATE STATISTICS ' +'['+ss.name+']'+'.['+OBJECT_NAME(st.object_id) +']'+' '+'['+st.name +']'+ ' WITH FULLSCAN'
FROM SYS.STATS AS ST
CROSS APPLY SYS.DM_DB_STATS_PROPERTIES (ST.OBJECT_ID, ST.STATS_ID) AS STP
JOIN SYS.TABLES STA ON st.[object_id] = sta.object_id
JOIN sys.schemas ss on ss.schema_id = STA.schema_id
WHERE [ROWS] <> ROWS_SAMPLED
ORDER BY DIFF DESC
go
