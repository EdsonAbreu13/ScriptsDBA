

/*

-- Se alguém me pergunta um script para fazer isso, indico esse site
-- https://ola.hallengren.com/

*/

USE Curso_Protheus



if object_id('_Update_Statistics') is not null
	drop table _Update_Statistics
GO
create table _Update_Statistics(
Id_Statistics int identity,
Ds_Comando varchar(max),Nr_Linha int)
GO

GO
if object_id('stpUpdate_Statistics') is not null
	drop procedure stpUpdate_Statistics
GO



CREATE procedure [dbo].[stpUpdate_Statistics]
AS
	-- TRATAMENTO DE LOCK
	SET LOCK_TIMEOUT 300000		-- Se ficar bloqueado por mais de 5 minutos, aborta.

	-- PARA CLIENTES GRANDES
	--IF( (SELECT DATEPART(WEEKDAY, GETDATE())) <> 1 )
	--BEGIN		-- SEG A SAB
	--	SET LOCK_TIMEOUT 300000		-- Se ficar bloqueado por mais de 5 minutos, aborta.
	--END
	--ELSE		
	--BEGIN		-- DOMINGO
	--	SET LOCK_TIMEOUT 3600000	-- Se ficar bloqueado por mais de 60 minutos, aborta.
	--END

	DECLARE @SQL VARCHAR(max)  
	DECLARE @DB sysname  

	truncate table _Update_Statistics

	DECLARE curDB CURSOR FORWARD_ONLY STATIC FOR  
	SELECT A.[name]  
	FROM master.sys.databases A
--	LEFT JOIN [dbo].[Ignore_Databases] B ON A.[name] = B.[Nm_Database]
	WHERE 
		A.[name] NOT IN ('tempdb','ReportServerTempDB','model','master','msdb') 
		and A.state_desc = 'ONLINE'
	--	and B.[Nm_Database] IS NULL		-- DESCONSIDERAR DATABASES
	ORDER BY A.[name]
	         
	OPEN curDB  
	FETCH NEXT FROM curDB INTO @DB  
	WHILE @@FETCH_STATUS = 0  
	   BEGIN  
		   SELECT @SQL = 'USE [' + @DB +']' + CHAR(13) + 
			 '
			
			;WITH Tamanho_Tabelas AS (
					SELECT obj.Name, prt.rows
					FROM sys.objects obj
						JOIN sys.indexes idx on obj.object_id = idx.object_id
						JOIN sys.partitions prt on obj.object_id = prt.object_id
						JOIN sys.allocation_units alloc on alloc.container_id = prt.partition_id
					WHERE obj.type = ''U'' AND idx.type not in (5,6) AND idx.index_id IN (0, 1) and prt.rows > 1000
					GROUP BY obj.Name, prt.rows )		
			    
					

			insert into Curso_Protheus.._Update_Statistics(Ds_Comando,Nr_Linha)	
			SELECT  ''if exists(select null	FROM [' + @DB + '].sys.stats WHERE name = '''''' 
					+ REPLACE(A.Name,'''''''','''''''''''') + '''''')
					UPDATE STATISTICS [' + @DB + '].['' + schema_Name(E.schema_id) + ''].['' +B.Name + ''] '' +  ''['' + A.Name +'']''+ '' WITH FULLSCAN'', D.rows
			FROM sys.stats A
				join sys.sysobjects B with(nolock) on A.object_id = B.id
				join sys.sysindexes C with(nolock) on C.id = B.id and A.Name = C.Name
				JOIN Tamanho_Tabelas D on  B.Name = D.Name 
				join sys.tables E on E.object_id = A.object_id
			WHERE  C.rowmodctr > D.rows*.010 and C.rowmodctr > 100
				and substring( B.Name,1,3) not in (''sys'',''dtp'')
				and substring(  B.Name , 1,1) <> ''_'' -- elimina tabelas tepor�rias		
			ORDER BY D.rows
				
		 '            
		   exec (@SQL )
	   --   select @SQL
			set @SQL = ''
	   
		   FETCH NEXT FROM curDB INTO @DB  
	   END  
	   
	CLOSE curDB  
	DEALLOCATE curDB

	--select top 10 * from _Update_Statistics
	
 	declare @Loop int, @Comando nvarchar(4000)
	set @Loop = 1

	while exists(select top 1 null from _Update_Statistics)
	begin
		-- Se passar de 6 da manha deve terminar a execução automaticamente
		IF( ( (SELECT DATEPART(HOUR, GETDATE())) >= 6 ) AND ( (SELECT DATEPART(HOUR, GETDATE())) < 22 ) )
		BEGIN		
			RETURN
		END

		-- PARA CLIENTES GRANDES
		-- Se passar de 6 da manha deve terminar a execução automaticamente
		--IF( ( (SELECT DATEPART(WEEKDAY, GETDATE())) <> 1 ) AND  (SELECT DATEPART(HOUR, GETDATE())) >= 6 )
		--BEGIN		-- SEG A SAB - ATE AS 06 HORAS
		--	RETURN
		--END
		--ELSE IF( ( (SELECT DATEPART(WEEKDAY, GETDATE())) = 1 ) AND  (SELECT DATEPART(HOUR, GETDATE())) >= 21 )
		--BEGIN		-- DOMINGO - ATE AS 21 HORAS
		--	RETURN
		--END
			
		select top 1 @Comando = Ds_Comando,@Loop = Id_Statistics
		from _Update_Statistics		
		
		EXECUTE sp_executesql @Comando

		delete from _Update_Statistics
		where Id_Statistics = @Loop

		set @Loop = @Loop + 1 
		
	end



GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Update Statistics')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Update Statistics', @delete_unused_schedule=1
GO



GO
USE [msdb]
GO

/****** Object:  Job [DBA - Update Statistics]    Script Date: 9/9/2019 3:26:32 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 9/9/2019 3:26:32 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Update Statistics', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Operator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA - Update Statistics]    Script Date: 9/9/2019 3:26:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - Update Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpUpdate_Statistics', 
		@database_name=N'Curso_Protheus', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'STATS', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140426, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'92217348-d765-4c81-b817-7a2fbc913716'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
