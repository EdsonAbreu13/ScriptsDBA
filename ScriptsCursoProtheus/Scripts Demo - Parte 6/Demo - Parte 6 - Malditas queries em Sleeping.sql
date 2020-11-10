
USE Curso_Protheus


--Executar em uma conexão os comandos ate o textsize
BEGIN TRAN

UPDATE dbo.SA1010
SET A1_END = A1_END +' a'
WHERE R_E_C_N_O_ = 50




SET TEXTSIZE 5




-- Executar em outra conexão 
UPDATE dbo.SA1010
SET A1_END = A1_END +' b'
WHERE R_E_C_N_O_ = 50


-- Validar a Whoisactive em outra conexão

EXEC sp_whoisactive





























/*
-- https://techcommunity.microsoft.com/t5/sql-server-support/how-it-works-what-is-a-sleeping-awaiting-command-session/ba-p/315486

"The situation can be caused by many other variations but it is always a situation where the SQL Server is waiting for the next command from the client.   


Outside a physical connection problem these are always application design issues.

Bob Dorr
SQL Server Senior Escalation Engineer"

*/




-- Gerar mais conexões sleeing em outras conexoes

BEGIN TRAN

SELECT GETDATE()




/*

	Validar se quer matar um tipo específico de sleeping.

	Cuidado!!!

	Você pode matar um processo importante que pode ter sido programado para entrar em sleeping por um tempo.

	Algumas opções para usar no Where
	--  and sql_command like '%SET TEXTSIZE %'
	--	and database_name = 'ReportServer'
	--	and sql_command LIKE '%ReportServer.dbo.WriteLockSession%'	
	--  and program_name = 'Microsoft Office 2010'  


	--testar a Execução da procedure

	exec Curso_Protheus..stpKill_Sleeping_Sessions

	select * from Log_History_JOB_Kill
	order by 1 desc

*/



-- Executar em outra conexao
USE Curso_Protheus
GO

------------------------------------------------------------------------------
-- CRIA A TABELA DE HISTORICO DO KILL
------------------------------------------------------------------------------

IF OBJECT_ID('Log_History_JOB_Kill') IS NOT NULL
	DROP table Log_History_JOB_Kill

CREATE TABLE [dbo].[Log_History_JOB_Kill] (
	[Dt_Log] [datetime] NULL,
	[start_time] [datetime] NULL,
	[dd hh:mm:ss.mss] [varchar](8000) NULL,
	[database_name] [nvarchar](128) NULL,
	[session_id] [smallint] NOT NULL,
	[blocking_session_id] [smallint] NULL,
	[sql_text] [xml] NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[wait_info] [nvarchar](4000) NULL,
	[status] [varchar](30) NOT NULL,
	[percent_complete] [varchar](30) NULL,
	[host_name] [nvarchar](128) NULL,
	[sql_command] [varchar](max) NULL,
	[CPU] [varchar](100) NULL,
	[reads] [varchar](100) NULL,
	[writes] [varchar](100) NULL,
	[program_name] [nvarchar](500) NULL,
	[open_tran_count] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

USE [Curso_Protheus]

IF OBJECT_ID('stpKill_Sleeping_Sessions') IS NOT NULL
	DROP PROCEDURE stpKill_Sleeping_Sessions

GO

CREATE PROCEDURE stpKill_Sleeping_Sessions
AS

	-- Cria a Tabela Temporaria
	IF (OBJECT_ID('tempdb..#TEMP_Resultado_WhoisActive') IS NOT NULL)
		DROP TABLE #TEMP_Resultado_WhoisActive

	CREATE TABLE #TEMP_Resultado_WhoisActive (
		[Dt_Log] [datetime] NULL,
		[start_time] [datetime] NULL,
		[dd hh:mm:ss.mss] [varchar](8000) NULL,
		[database_name] [nvarchar](128) NULL,
		[session_id] [smallint] NOT NULL,
		[blocking_session_id] [smallint] NULL,
		[sql_text] [xml] NULL,
		[login_name] [nvarchar](128) NOT NULL,
		[wait_info] [nvarchar](4000) NULL,
		[status] [varchar](30) NOT NULL,
		[percent_complete] [varchar](30) NULL,
		[host_name] [nvarchar](128) NULL,
		[sql_command] [xml] NULL,
		[CPU] [varchar](100) NULL,
		[reads] [varchar](100) NULL,
		[writes] [varchar](100) NULL,
		[program_name] [nvarchar](500) NULL,
		[open_tran_count] [int] NULL	
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

	-- Retorna os dados da sp_whoisactive
	EXEC sp_WhoIsActive @get_outer_command = 1,
		@output_column_list = '[start_time][collection_time][d%][session_id][blocking_session_id][sql_text][login_name][wait_info][status][percent_complete]
		  [host_name][database_name][sql_command][CPU][reads][writes][program_name][open_tran_count]',
		@destination_table = '#TEMP_Resultado_WhoisActive'

	ALTER TABLE #TEMP_Resultado_WhoisActive
	ALTER COLUMN [sql_command] VARCHAR(MAX)
	
	UPDATE #TEMP_Resultado_WhoisActive
	SET [sql_command] = REPLACE( REPLACE( REPLACE( REPLACE( CAST([sql_command] AS VARCHAR(1000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')

	-- SELECT * FROM #TEMP_Resultado_WhoisActive

	-- Verifica se existe algum query que precisa de KILL
	IF (OBJECT_ID('tempdb..#TEMP_KILL_Query') IS NOT NULL)
		DROP TABLE #TEMP_KILL_Query

	select *
	into #TEMP_KILL_Query
	from #TEMP_Resultado_WhoisActive
	where DATEDIFF(MINUTE, Dt_Log, start_time) > 5	-- Processos com mais de 5 minutos
		and session_id > 50		-- Apenas processos de usuario
		and status = 'sleeping'	-- Apenas processos com o status "sleeping"
	
	-- and sql_command like '%SET TEXTSIZE %'

	--	and database_name = 'ReportServer'
	--	and sql_command LIKE '%ReportServer.dbo.WriteLockSession%'	
	--	and sql_command LIKE '%ReportServer.dbo.WriteLockSession%'	
	-- and program_name = 'Microsoft Office 2010'  
	

	-- select * from #TEMP_KILL_Query

	-- Mata as Conexoes
	DECLARE @SPID as VARCHAR(5)

	WHILE ( (SELECT COUNT(*) FROM #TEMP_KILL_Query) > 0 )
	BEGIN
		SET @SPID = (SELECT TOP 1 session_id FROM #TEMP_KILL_Query)
		EXEC ('KILL ' +  @SPID)

		INSERT INTO [dbo].[Log_History_JOB_Kill]
		SELECT * FROM #TEMP_KILL_Query WHERE session_id = @SPID

		DELETE FROM #TEMP_KILL_Query WHERE session_id = @SPID
	END



	
GO

USE [msdb]
GO

/****** Object:  Job [DBA - Finaliza Processo Sleeping]    Script Date: 03/27/2017 13:42:54 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 03/27/2017 13:42:54 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Kill Sleeping Sessions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [stpFinaliza_Processo_Sleeping]    Script Date: 03/27/2017 13:42:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'stpKill_Sleeping_Sessions', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpKill_Sleeping_Sessions', 
		@database_name=N'Curso_Protheus', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'stpKill_Sleeping_Sessions', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150411, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'223df2d5-a6df-4c15-8d4f-50c37dd47ebf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
