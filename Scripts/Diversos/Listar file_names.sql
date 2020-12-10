DROP TABLE #temp

CREATE TABLE #temp (
	database_name varchar(max),
	file_id tinyint,
	name varchar(max),
	type bit
)

DECLARE @command varchar(1000) 
SELECT @command = ' USE [?]
insert into #temp 
select DB_NAME(),file_id, name, type from sys.database_files '
EXEC sp_MSforeachdb @command 


SELECT * FROM #temp