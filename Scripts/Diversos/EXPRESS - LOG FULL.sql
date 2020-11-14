set nocount on 
SELECT 'ALTER INDEX [' + I.name + '] ON [' + S.name + '].[' + T.NAME + '] REBUILD WITH (FILLFACTOR = 90, DATA_COMPRESSION=PAGE, PAD_INDEX = ON, SORT_IN_TEMPDB = ON)'  + char(10) + char(10) +
'PRINT '  + '''' + T.name + ' - ' + '' + I.NAME + '''' + CHAR(10) + 'GO' + CHAR(10)
from sys.indexes I
join sys.tables T on I.object_id = T.object_id
join sys.schemas S on t.schema_id = S.schema_id
where I.name is not null
order by T.NAME
GO

SELECT 
'
DBCC SHRINKFILE(1) WITH NO_INFOMSGS
GO
DBCC SHRINKFILE(2) WITH NO_INFOMSGS
GO
'

SELECT 'ALTER INDEX [' + I.name + '] ON [' + S.name + '].[' + T.NAME + '] REBUILD WITH (FILLFACTOR = 90, DATA_COMPRESSION=PAGE, PAD_INDEX = ON, SORT_IN_TEMPDB = ON)'  + char(10) + char(10) +
'PRINT '  + '''' + T.name + ' - ' + '' + I.NAME + '''' + CHAR(10) + 'GO' + CHAR(10)
from sys.indexes I
join sys.tables T on I.object_id = T.object_id
join sys.schemas S on t.schema_id = S.schema_id
where I.name is not null
order by T.NAME
GO