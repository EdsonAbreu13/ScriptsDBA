
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
select DB_NAME(),file_id, name, type from sys.database_files WHERE DB_NAME() NOT IN(''master'',''model'',''tempdb'',''msdb'') '
EXEC sp_MSforeachdb @command 


SELECT * FROM #temp

DECLARE @id int,
		@base varchar(max),
		@qtd_file int,
		@script varchar(max),
		@file_name varchar(max),
		@file_id int,
		@ext varchar(max)

WHILE (SELECT COUNT(1) FROM #temp) > 0
BEGIN
	SELECT TOP 1 @base = database_name, @id = id FROM #temp order by database_name, type
	SET @qtd_file = (SELECT COUNT(1) FROM #temp WHERE database_name = @base AND type = 0)	
	PRINT 'RESTORE DATABASE ['+@base+']'
	PRINT 'FROM DISK = '''+@dir_backup+@base+'.bak'''
	PRINT 'WITH NORECOVERY, REPLACE, STATS = 1,'
	PRINT ''

	DELETE FROM #temp WHERE database_name = @base
END
