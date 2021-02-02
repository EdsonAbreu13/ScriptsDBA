if OBJECT_ID('_Alert_CPU') is  null
begin
	CREATE TABLE [dbo].[_Alert_CPU](
		[Id_Alert_CPU] [int] IDENTITY(1,1) NOT NULL,
		[record_id] [int] NULL,
		[SQLProcessUtilization] [int] NULL,
		[OtherProcessUtilization] [int] NULL,
		[SystemIdle] [int] NULL,
		[CPU_Utilization] [int] NULL,
		[Dt_Log] [datetime] NULL
	) ON [PRIMARY]
END
GO

if OBJECT_ID('stpLoad_SQL_Counter') is not null
	drop procedure stpLoad_SQL_Counter

GO
CREATE PROCEDURE stpLoad_SQL_Counter
AS
begin
	
 DECLARE @BatchRequests INT,@User_Connection INT, @CPU INT, @PLE int,@SQLCompilations int,@PS bigint  
  
 DECLARE @RequestsPerSecondSample1 BIGINT,  @RequestsPerSecondSample2 BIGINT  
 DECLARE @SQLCompilationsSample1  BIGINT,  @SQLCompilationsSample2  BIGINT  
  
 SELECT @RequestsPerSecondSample1  = (case when counter_name = 'Batch Requests/sec' then cntr_value end)  
 FROM sys.dm_os_performance_counters   
 WHERE counter_name in ('Batch Requests/sec','SQL Compilations/sec')  
   
 SELECT @RequestsPerSecondSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'  
 SELECT @SQLCompilationsSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'SQL Compilations/sec'  
   
 WAITFOR DELAY '00:00:05'  
  
 SELECT @RequestsPerSecondSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'  
 SELECT @SQLCompilationsSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'SQL Compilations/sec'  
  
 SELECT @BatchRequests = (@RequestsPerSecondSample2 - @RequestsPerSecondSample1)/5  
 SELECT @SQLCompilations = (@SQLCompilationsSample2 - @SQLCompilationsSample1)/5  
  
 select @User_Connection = cntr_Value  
 from sys.dm_os_performance_counters  
 where counter_name = 'User Connections'  
         
	insert into _Alert_CPU ([record_id], [SQLProcessUtilization], [OtherProcessUtilization], [SystemIdle], [CPU_Utilization], [Dt_Log])
	SELECT top 1
		[record_id],
		[SQLProcessUtilization],
		(100 - SystemIdle - SQLProcessUtilization) as [OtherProcessUtilization],
		[SystemIdle],
		(100 - SystemIdle) AS [CPU_Utilization],
		GETDATE() as Dt_Log
	FROM	( 
				SELECT	record.value('(./Record/@id)[1]', 'int')													AS [record_id], 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')			AS [SystemIdle],
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')	AS [SQLProcessUtilization], 
						[timestamp] 
				FROM ( 
						SELECT [timestamp], CONVERT(XML, [record]) AS [record] 
						FROM [sys].[dm_os_ring_buffers] 
						WHERE	[ring_buffer_type] = N'RING_BUFFER_SCHEDULER_MONITOR' 
								AND [record] LIKE '%<SystemHealth>%'
					) AS X					   
			) AS Y

     select top 1 @CPU = CPU_Utilization from [_Alert_CPU] order by Dt_Log desc
	 
	 SELECT @PLE = cntr_value   
	 FROM sys.dm_os_performance_counters  
	 WHERE  counter_name = 'Page life expectancy'  
	  and object_name like '%Buffer Manager%'  
	  
	 SELECT @PS = cntr_value  
	 FROM sys.dm_os_performance_counters  
	 WHERE object_name like '%Access Methods%'   
	 and counter_name = 'Page Splits/sec';  
	  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 1,@BatchRequests  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 2,@User_Connection  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 3,@CPU  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 4,@PLE  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 5,@SQLCompilations  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 6,@PS  

END

IF ( OBJECT_ID('[dbo].[stpAlert_CPU_Utilization]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].[stpAlert_CPU_Utilization]
GO

CREATE PROCEDURE [dbo].[stpAlert_CPU_Utilization]
AS
BEGIN
	  SET NOCOUNT ON
             

                DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
                               @Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
                               @Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
                
                DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)                 

                declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 
				                                                                               
                -- Alert information
                SELECT @Id_Alert_Parameter = Id_Alert_Parameter, 
                               @Fl_Enable = Fl_Enable, 
                               @Vl_Parameter = Vl_Parameter,                             -- Minutes,
                               @Ds_Email = Ds_Email,
                               @Fl_Language = Fl_Language,
                               @Ds_Profile_Email = Ds_Profile_Email,
                               @Vl_Parameter_2 = Vl_Parameter_2,                   --minute
                               @Dt_Now = GETDATE(),
                               @Ds_Message_Alert_ENG = Ds_Message_Alert_ENG,
                               @Ds_Message_Clear_ENG = Ds_Message_Clear_ENG,
                               @Ds_Message_Alert_PTB = Ds_Message_Alert_PTB,
                               @Ds_Message_Clear_PTB = Ds_Message_Clear_PTB,
                               @Ds_Email_Information_1_ENG = Ds_Email_Information_1_ENG,
                               @Ds_Email_Information_2_ENG = Ds_Email_Information_2_ENG,
                               @Ds_Email_Information_1_PTB = Ds_Email_Information_1_PTB,
                                @Ds_Email_Information_2_PTB = Ds_Email_Information_2_PTB
                FROM [dbo].Alert_Parameter 
                WHERE Nm_Alert = 'CPU Utilization'

                IF @Fl_Enable = 0
                               RETURN

                -- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
                SELECT @Fl_Type = [Fl_Type]
                FROM [dbo].[Alert]
                WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )                

                --------------------------------------------------------------------------------------------------------------------------------
                -- CPU Utilization
                --------------------------------------------------------------------------------------------------------------------------------             
                IF ( OBJECT_ID('tempdb..#CPU_Utilization') IS NOT NULL )
                               DROP TABLE #CPU_Utilization
                
                -- Retorna os valores de CPU nos últimos x minutos
                SELECT
                               record_id,
                               [SQLProcessUtilization],
                               OtherProcessUtilization,
                               [SystemIdle],
                               CPU_Utilization,
                               Dt_Log
                INTO #CPU_Utilization
                FROM _Alert_CPU
                where
                               Dt_Log >= DATEADD(minute,-1*@Vl_Parameter_2,getdate())
                ORDER BY record_id DESC
                
                -- Apenas se todos os valores de CPU nos últimos 5 minutos forem maiores que o parâmetro
                IF (select MIN(CPU_Utilization) from #CPU_Utilization) >= @Vl_Parameter
                BEGIN
                               --BEGIN
                                               IF ISNULL(@Fl_Type, 0) = 0          -- Control Alert/Clear
                                               BEGIN
                                                               IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
                                                                               DROP TABLE ##Email_HTML
                                                                                              
                                                               -- CPU Information
                                                               select    
                                                                                              CAST([SQLProcessUtilization] AS VARCHAR) [SQL Process (%)],
                                                                                              CAST(OtherProcessUtilization AS VARCHAR) as [Other Process (%)],
                                                                                              CAST([SystemIdle] AS VARCHAR) AS [System Idle (%)],
                                                                                              CAST(CPU_Utilization AS VARCHAR) AS [CPU Utilization (%)],
                                                                                              CONVERT(VARCHAR(30),Dt_Log,13) AS [Log Date]
                                                               INTO ##Email_HTML
                                                               from #CPU_Utilization
                                                               order by Dt_Log DESC                                                                                                  
                                               
                                                               IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
                                                                               DROP TABLE ##Email_HTML_2  
                                                                              
                                                               SELECT TOP 50 *
                                                               INTO ##Email_HTML_2
                                                               FROM ##WhoIsActive_Result                    
                                                               
                                                               -- Get HTML Informations
                                                               SELECT @Company_Link = Company_Link,
                                                                               @Line_Space = Line_Space,
                                                                               @Header_Default = Header
                                                               FROM HTML_Parameter
                                               

                                               IF @Fl_Language = 1 --Portuguese
                                               BEGIN
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',replace(@Ds_Email_Information_1_PTB,'###1',@Vl_Parameter_2))
                                                               SET @Ds_Subject = REPLACE(REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter),'###2',@Vl_Parameter_2)+@@SERVERNAME 
                                               END
          ELSE 
                                  BEGIN
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',replace(@Ds_Email_Information_1_ENG,'###1',@Vl_Parameter_2))
                                                               SET @Ds_Subject = REPLACE(REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter),'###2',@Vl_Parameter_2)+@@SERVERNAME 
                                  END                                                   
                                                                               
                                               EXEC dbo.stpExport_Table_HTML_Output
                                                               @Ds_Tabela = '##Email_HTML', 
                                                               @Ds_Alinhamento  = 'center',
                                                               @Ds_OrderBy = '[Log Date] desc',
                                                               @Ds_Saida = @HTML OUT          

                                               -- First Result
                                               SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space                              
                                                               
                                               EXEC dbo.stpExport_Table_HTML_Output
                                                               @Ds_Tabela = '##Email_HTML_2', -- varchar(max)
                                                               @Ds_Alinhamento  = 'center',
                                                               @Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
                                                               @Ds_Saida = @HTML OUT                                                         -- varchar(max)                                

                                               IF @Fl_Language = 1
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
                                               ELSE 
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)                                                    

                                               -- Second Result
                                               SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link                                            

                                                               EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'                                                                                                                        
                               
                                               -- Fl_Type = 1 : ALERT    
                                               INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
                                               SELECT @Id_Alert_Parameter, @Ds_Subject, 1                                 
                               END
                --END                    -- END - ALERT
                END
                ELSE 
                BEGIN   -- BEGIN - CLEAR
                               -- Apenas se todos os valores de CPU nos últimos 5 minutos forem menores que o parâmetro.
                               IF (@Fl_Type = 1 and ((select MAX(CPU_Utilization) from #CPU_Utilization) < @Vl_Parameter))
                               BEGIN                                  
                                               
                                               IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
                                                                               DROP TABLE ##Email_HTML_CLEAR
                                                                                              
                                                               -- CPU Information
                                                               select    
                                                                                              CAST([SQLProcessUtilization] AS VARCHAR) [SQL Process (%)],
                                                                                              CAST(OtherProcessUtilization AS VARCHAR) as [Other Process (%)],
                                                                                              CAST([SystemIdle] AS VARCHAR) AS [System Idle (%)],
                                                                                              CAST(CPU_Utilization AS VARCHAR) AS [CPU Utilization (%)],
                                                                                              CONVERT(VARCHAR(30),Dt_Log,13) AS [Log Date]
                                                               INTO ##Email_HTML_CLEAR
                                                               from #CPU_Utilization
                                                               order by Dt_Log DESC                                                                                                  
                                               
                                                               IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
                                                                               DROP TABLE ##Email_HTML_CLEAR_2  
                                                                              
                                                               SELECT TOP 50 *
                                                               INTO ##Email_HTML_CLEAR_2
                                                               FROM ##WhoIsActive_Result
                                               
                                                               
                                               -- Get HTML Informations
                                               SELECT @Company_Link = Company_Link,
                                                               @Line_Space = Line_Space,
                                                               @Header_Default = Header
                                               FROM HTML_Parameter
                                               

                                               IF @Fl_Language = 1 --Portuguese
                                               BEGIN
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',replace(@Ds_Email_Information_1_PTB,'###1',@Vl_Parameter_2))
                                                               SET @Ds_Subject = REPLACE(REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter),'###2',@Vl_Parameter_2)+@@SERVERNAME 
                                               END
          ELSE 
                                  BEGIN
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',replace(@Ds_Email_Information_1_ENG,'###1',@Vl_Parameter_2))
                                                               SET @Ds_Subject = REPLACE(REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter),'###2',@Vl_Parameter_2)+@@SERVERNAME 
                                  END                                       
                                  
                                               EXEC dbo.stpExport_Table_HTML_Output
                                                               @Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
                                                               @Ds_Alinhamento  = 'center',
                                                               @Ds_OrderBy = '[Log Date] desc',
                                                               @Ds_Saida = @HTML OUT                                                         -- varchar(max)

                                               -- First Result
                                               SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space                              
                                                               
                                               EXEC dbo.stpExport_Table_HTML_Output
                                                               @Ds_Tabela = '##Email_HTML_CLEAR_2', -- varchar(max)
                                                               @Ds_Alinhamento  = 'center',
                                                               @Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
                                                               @Ds_Saida = @HTML OUT                                                         -- varchar(max)                                

                                               IF @Fl_Language = 1
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
                                               ELSE 
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)                                                    

                                               -- Second Result
                                               SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link                                            

                                                               EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'          

                                               -- Fl_Type = 0 : CLEAR
                                               INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
                                               SELECT @Id_Alert_Parameter, @Ds_Subject, 0                 
                               END                       
                END                       -- END - CLEAR  

     
END
GO