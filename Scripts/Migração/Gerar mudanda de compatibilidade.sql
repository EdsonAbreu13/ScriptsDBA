
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
IF (DB_NAME() NOT IN(''master'',''tempdb'',''model'',''msdb''))
PRINT ''ALTER DATABASE [?] SET  COMPATIBILITY_LEVEL = 130'''
EXEC sp_MSforeachdb @command 
