
DECLARE @dir_backup varchar(max) = 'B:\BACKUP\'

SET NOCOUNT ON;


IF OBJECT_ID('tempdb..#temp') is not null
	DROP TABLE #temp

CREATE TABLE #temp (
	id int identity,
	database_name varchar(max),
	file_id tinyint,
	name varchar(max),
	type bit
)

DECLARE @command varchar(1000) 
SELECT @command = ' USE [?]
insert into #temp 
select DB_NAME(),file_id, name, type from sys.database_files WHERE DB_NAME() NOT IN(''msdb'') '
EXEC sp_MSforeachdb @command 


SELECT * FROM #temp

DECLARE @base varchar(max)

WHILE (SELECT COUNT(1) FROM #temp) > 0
BEGIN
	SELECT TOP 1 @base = database_name FROM #temp order by database_name, type
	
	PRINT 'RESTORE DATABASE ['+@base+']'
	PRINT 'FROM DISK = '''+@dir_backup+@base+'_DIFF.bak'''
	PRINT 'WITH REPLACE, STATS = 1'
	PRINT ''

	DELETE FROM #temp WHERE database_name = @base

END
