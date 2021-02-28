SELECT
s.[name] AS [schema],
t.[name] AS [table_name],
p.[rows] AS [row_count],
CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [size_mb],
CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [used_mb],
CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [unused_mb]
FROM
sys.tables t
JOIN sys.indexes i ON t.[object_id] = i.[object_id]
JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
LEFT JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
WHERE
t.is_ms_shipped = 0
AND i.[object_id] > 255
GROUP BY
t.[name],
s.[name],
p.[rows]
ORDER BY
[size_mb] DESC


==============================

/*valores em KB se quiser transformar p/ MB divide por 1024 e se quiser ir de MB para GB divide por mais 1024*/

SELECT
    OBJECT_NAME(object_id) As Tabela, Rows As Linhas,
    SUM(Total_Pages * 8) As Reservado,
    SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Dados,
        SUM(Used_Pages * 8) -
        SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Indice,
    SUM((Total_Pages - Used_Pages) * 8) As NaoUtilizado
	into #tamanho1
FROM
    sys.partitions As P
    INNER JOIN sys.allocation_units As A ON P.hobt_id = A.container_id
	--where OBJECT_NAME(object_id) like 'bkp032017%'
GROUP BY OBJECT_NAME(object_id), Rows
ORDER BY LINHAS DESC




select Tabela, Linhas, Reservado/1024/1024 reservado_GB, Dados/1024/1024 dados_GB, Indice/1024/1024 indice_GB, NaoUtilizado/1024/1024 naoutilizado_GB from #tamanho1
order by Reservado desc