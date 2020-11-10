IF OBJECT_ID('tempdb..#DupIndex') IS NOT NULL
DROP TABLE #DupIndex
SELECT
*
,IndexChecksum = CHECKSUM(I.FullTableName,I.FullIndexCols)
,KeyIndexChecksum = CHECKSUM(I.FullTableName,I.KeyIndexCol)
,FullDupRn = ROW_NUMBER() OVER( PARTITION BY I.FullTableName,I.FullIndexCols ORDER BY I.IndexName )
INTO
#DupIndex
FROM
(
SELECT
ObjectId = T.object_id
,TableName = T.name
,FullTableName = S.name+'.'+T.name
,IndexName = I.name
,FullIndexCols = STUFF(
(SELECT 
','+IIF(IC.is_included_column = 1,'INC:','')+C.name as 'text()'
FROM
sys.index_columns IC
JOIN
sys.columns C
ON C.object_id = IC.object_id
AND C.column_id = IC.column_id
WHERE
IC.object_id = I.object_id
AND
IC.index_id = I.index_id
ORDER BY
IC.is_included_column
,IC.key_ordinal
,C.name
FOR XML PATH('')
),1,1,''
)
,KeyIndexCol = STUFF(
(SELECT 
','+IIF(IC.is_included_column = 1,'INC:','')+C.name as 'text()'
FROM
sys.index_columns IC
JOIN
sys.columns C
ON C.object_id = IC.object_id
AND C.column_id = IC.column_id
WHERE
IC.object_id = I.object_id
AND
IC.index_id = I.index_id
AND
IC.is_included_column = 0
ORDER BY
IC.is_included_column
,IC.key_ordinal
,C.name
FOR XML PATH('')
),1,1,''
)
FROM
sys.indexes I
JOIN
sys.tables T
ON T.object_id = I.object_id
JOIN
sys.schemas S
ON S.schema_id = T.schema_id
WHERE
I.index_id >= 1
) I
ORDER BY
I.FullTableName
,I.IndexName
-- duplicados
SELECT * FROM #DupIndex WHERE FullDupRn > 1
