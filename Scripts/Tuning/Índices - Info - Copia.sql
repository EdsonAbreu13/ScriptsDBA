-- EXIBIR TODOS OS INDICES (COMPOSTO E COM INCLUDE)
select SCHEMA_NAME (o.SCHEMA_ID) SchemaName
  ,o.name ObjectName,i.name IndexName
  ,i.type_desc
  ,LEFT(list, ISNULL(splitter-1,len(list)))Columns
  , SUBSTRING(list, indCol.splitter+1, 1000) includedColumns--len(name) - splitter-1) columns
  , COUNT(1)over (partition by o.object_id)
from sys.indexes i
join sys.objects o on i.object_id= o.object_id
cross apply (select NULLIF(charindex('|',indexCols.list),0) splitter , list
             from (select cast((
                          select case when sc.is_included_column = 1 and sc.ColPos= 1 then'|'else '' end +
                                 case when sc.ColPos > 1 then ', ' else ''end + name
                            from (select sc.is_included_column, index_column_id, name
                                       , ROW_NUMBER()over (partition by sc.is_included_column
                                                            order by sc.index_column_id)ColPos
                                   from sys.index_columns  sc
                                   join sys.columns        c on sc.object_id= c.object_id
                                                            and sc.column_id = c.column_id
                                  where sc.index_id= i.index_id
                                    and sc.object_id= i.object_id) sc
                   order by sc.is_included_column
                           ,ColPos
                     for xml path (''),type) as varchar(max)) list)indexCols) indCol
where indCol.splitter is not null
--and o.name = ''
order by SchemaName, ObjectName, IndexName


-- TAMANHO DOS INDICES
SELECT i.[name] AS IndexName
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
	join sysobjects o ON i.[object_id] = o .id
where o.name = 'TestesIndices'
GROUP BY i.[name]
ORDER BY 2 desc


-- Informa quantas vezes um índice foi índice foi utilizado desde a última vez que o SQL Server foi reiniciado
dm_db_index_usage_status


-- LISTAR QUANTAS VEZES OS ÍNDICES FORAM UTILIZADOS DESDE O ÚLTIMO REINICIO DO SQL SERVER
USE <BANCO DESEJADO>
GO 

select getdate(), o.Name,i.name, s.user_seeks,s.user_scans,s.user_lookups, s.user_Updates, 
	isnull(s.last_user_seek,isnull(s.last_user_scan,s.last_User_Lookup)) Ultimo_acesso,fill_factor
from sys.dm_db_index_usage_stats s
	 join sys.indexes i on i.object_id = s.object_id and i.index_id = s.index_id
	 join sys.sysobjects o on i.object_id = o.id
where s.database_id = db_id() and o.name in ('table_tennis') --and i.name = 'SK02_Telefone_Cliente'
order by s.user_seeks + s.user_scans + s.user_lookups desc


--	Query que mostra algumas sugestão de índices para que possamos analisar a criação
SELECT 
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE NONCLUSTERED INDEX [SK01_'
 + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) +']'+ 

' ON ' + dm_mid.statement+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE
'' END+ ISNULL (dm_mid.inequality_columns, '')
+ ')'+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement,dm_migs.user_seeks,dm_migs.user_scans
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
and dm_migs.last_user_seek >= getdate()-1
ORDER BY Avg_Estimated_Impact DESC



-- UTILIZAÇÃO DOS INDICES
SELECT 
	d.name AS Database_Name,
	objects.name AS Table_name,
    indexes.name AS Index_name,
    dm_db_index_usage_stats.user_lookups,
    dm_db_index_usage_stats.user_seeks,
    dm_db_index_usage_stats.user_scans,
    dm_db_index_usage_stats.user_updates,	 
	dm_db_index_usage_stats.last_user_scan,
	dm_db_index_usage_stats.last_user_seek,
	dm_db_index_usage_stats.last_user_lookup,
    SUM(used_page_count) * 8 / 1024  AS IndexSizeMB
FROM
    sys.dm_db_index_usage_stats
    INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
    INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
    INNER JOIN sys.dm_db_partition_stats  s ON s.[object_id] = objects.[object_id] AND s.index_id = indexes.index_id
	INNER JOIN sys.databases d ON d.[database_id] = sys.dm_db_index_usage_stats.database_id
WHERE indexes.is_primary_key = 0
	and indexes.type_desc = 'NONCLUSTERED'   
	and indexes.name = 'IX_1'
	--and d.name = 'Kurier'
--    dm_db_index_usage_stats.user_lookups < 100
--    AND
--    dm_db_index_usage_stats.user_seeks < 100
--    AND
--    dm_db_index_usage_stats.user_scans < 100
group by
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


--USO DE INDICE PELA VIEW DA POWER TUNING (Traces)
SELECT
     Nm_Database   
     ,Nm_Table
     ,LastRead    = MAX(Dt_History)
 FROM
     dbo.vwIndex_Utilization_History
 WHERE
     User_Seeks + User_Scans  + User_Lookups >= 0
 GROUP BY
     Nm_Database   
     ,Nm_Table
 HAVING
     MAX(Dt_History) < DATEADD(DD,-30,GETDATE())


