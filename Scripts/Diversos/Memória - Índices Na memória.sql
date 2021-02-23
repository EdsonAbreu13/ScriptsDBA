
SELECT DB_Name() AS dbName, 
       schemas.name + '.' + obj.name as objectname,
       ind.name as indexname,
       obj.index_id as indexid,
       obj.data_compression_desc,
       obj.ActualSizeMB,
       count(*) as cached_pages_count,
       (count(*) * 8) / 1024. as mb_cached,
       (SUM(CONVERT(float, free_space_in_bytes)) / 1024.) / 1024. AS Free_Space_MB,
       indexstats.avg_fragmentation_in_percent,
       indexstats.page_count
  FROM sys.dm_os_buffer_descriptors as bd
 INNER JOIN (SELECT object_id as objectid,
                    object_name(object_id) as name,
                    index_id,
                    allocation_unit_id,
                    p.data_compression_desc,
                    (au.total_pages * 8) / 1024. ActualSizeMB
               FROM sys.allocation_units as au
              INNER JOIN sys.partitions as p
                 ON au.container_id = p.hobt_id
                AND (au.type = 1 OR au.type = 3)
              UNION ALL
             SELECT object_id as objectid,
                    object_name(object_id) as name,
                    index_id,
                    allocation_unit_id,
                    p.data_compression_desc,
                    (au.total_pages * 8) / 1024. ActualSizeMB
               FROM sys.allocation_units as au
              INNER JOIN sys.partitions as p
                 ON au.container_id = p.partition_id
                AND au.type = 2) as obj
    ON bd.allocation_unit_id = obj.allocation_unit_id
  LEFT OUTER JOIN #tmp1 indexstats
    ON obj.objectid = indexstats.object_id
   AND obj.index_id = indexstats.index_id
  LEFT OUTER JOIN sys.indexes ind
    ON obj.objectid = ind.object_id
   AND obj.index_id = ind.index_id
  LEFT OUTER JOIN sys.objects
    ON objects.object_id = ind.object_id
  LEFT OUTER JOIN sys.schemas
    ON objects.schema_id = schemas.schema_id
 WHERE bd.database_id = db_id()
   AND bd.page_type in ('data_page', 'index_page')
 GROUP BY schemas.name + '.' + obj.name,
         ind.name,
         obj.index_id,
         obj.data_compression_desc,
         ActualSizeMB,
         indexstats.avg_fragmentation_in_percent,
         indexstats.page_count
 ORDER BY cached_pages_count DESC
GO