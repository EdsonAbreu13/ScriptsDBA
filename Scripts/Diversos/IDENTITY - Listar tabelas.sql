SELECT
 o.name as OWNER,
 t.name AS TABELA,
 i.name AS COLUNA,
 dt.name AS TIPO,
 i.increment_value AS [VALOR INCREMENTO],
 i.last_value [ULTIMO VALOR],
 CAST((CAST(i.last_value AS DECIMAL) / CASE WHEN dt.name = 'int' THEN 2147483647. WHEN dt.name = 'bigint' THEN 9223372036854775807. ELSE 0 END)*100 AS DECIMAL(4,2)) [% DE UTILIZAÇÃO]
FROM sys.schemas AS o
INNER JOIN sys.tables AS t
 ON o.[schema_id] = t.[schema_id]
INNER JOIN sys.identity_columns i
ON i.[object_id] = t.[object_id]
INNER JOIN sys.types dt 
ON I.user_type_id = dt.user_type_id
WHERE t.name LIKE 'FAT_%'
order by [% DE UTILIZAÇÃO] desc;