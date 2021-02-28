
DECLARE @dir_backup varchar(max) = '\\brbawbkp1004\SQL_DATABASE_BACKUP$\MSSQL$BRSPSQL06\USUÁRIO\'

SET NOCOUNT ON;


IF OBJECT_ID('tempdb..#temp') is not null
	DROP TABLE #temp

CREATE TABLE #temp (
	database_name varchar(max)	
)


insert into #temp 
select name from sys.databases where name not in(

SELECT	database_name /*, name,backup_start_date, datediff(mi, backup_start_date, backup_finish_date) [tempo (min)],
		position, server_name, recovery_model, isnull(logical_device_name, ' ') logical_device_name, device_type, 
		type, cast(backup_size/1024/1024 as numeric(15,2)) [Tamanho (MB)]*/
FROM msdb.dbo.backupset B
	  INNER JOIN msdb.dbo.backupmediafamily BF ON B.media_set_id = BF.media_set_id
where 1=1
AND	backup_start_date >=  dateadd(hh, -1 ,getdate()  )
  and type in ('D')
  )



SELECT * FROM #temp

DECLARE @base varchar(max)

WHILE (SELECT COUNT(1) FROM #temp) > 0
BEGIN
	SELECT TOP 1 @base = database_name FROM #temp order by database_name
	
	PRINT 'BACKUP DATABASE ['+@base+']'
	PRINT 'TO DISK = '''+@dir_backup+@base+'\'+@base+'_20210228.bak'''
	PRINT 'WITH COMPRESSION, CHECKSUM, STATS = 1'
	PRINT ''


	DELETE FROM #temp WHERE database_name = @base

END
