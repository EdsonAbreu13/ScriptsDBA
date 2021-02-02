
DECLARE @opc bit = 1	--	0 - Todos Desabilitados
						--	1 - Gerar script com status atual

SET NOCOUNT ON;


IF OBJECT_ID('tempdb..#temp') is not null
	DROP TABLE #temp

CREATE TABLE #temp (
	id int identity,
	name varchar(max),
	status char(1)
)

INSERT INTO #temp
SELECT name, enabled FROM msdb..sysjobs WHERE name <> 'syspolicy_purge_history' ORDER BY name

SELECT * FROM #temp

DECLARE @id int,
		@name varchar(max),
		@status char(1)

PRINT 'USE [msdb]'  
PRINT 'GO'
PRINT ''

WHILE (SELECT COUNT(1) FROM #temp) > 0
BEGIN
	SELECT TOP 1 @name = name, @status = status FROM #temp order by name

	IF @opc = 0 PRINT 'EXEC dbo.sp_update_job @job_name = N'''+@name+''', @enabled = 0;'
	IF @opc = 1 PRINT 'EXEC dbo.sp_update_job @job_name = N'''+@name+''', @enabled = '+@status+';'
	PRINT 'GO'
	PRINT ''

	DELETE FROM #temp WHERE name = @name

END

	



