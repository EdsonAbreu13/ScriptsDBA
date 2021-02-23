USE [Traces]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_CPU_Utilization]    Script Date: 13/11/2020 20:27:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[stpAlert_CPU_Utilization]
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
                
                -- Retorna os valores de CPU nos últimos 5 minutos
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
                


				--------------------------------------------------------------------------------------------------------------------------------  
                -- PROCESS TASK  
                --------------------------------------------------------------------------------------------------------------------------------      
				DECLARE @fl_ativo bit   
  
				IF (OBJECT_ID('tempdb..#TEMP') IS NOT NULL)  
					DROP TABLE #TEMP  
  
				CREATE TABLE #TEMP (  
					name   varchar(800),  
					minimum   int,  
					maximum   int,  
					config_value int,  
					run_value  int  
				)  
  
				INSERT INTO #TEMP  
				EXECUTE sp_configure  
  
   
				SELECT @fl_ativo = config_value FROM #TEMP WHERE name = 'show advanced options'  
  
				IF @fl_ativo = 0   
				BEGIN  
					-- To allow advanced options to be changed.    
					EXECUTE sp_configure 'show advanced options', 1       
  
					-- To update the currently configured value for advanced options.    
					RECONFIGURE;       
				END  
  
  
				SELECT @fl_ativo = config_value FROM #TEMP WHERE name = 'xp_cmdshell'  
  
  
				IF @fl_ativo = 0   
				BEGIN    
					-- To enable the feature.    
					EXECUTE sp_configure 'xp_cmdshell', 1       
  
					-- To update the currently configured value for this feature.    
					RECONFIGURE       
				END  
  
				IF (OBJECT_ID('tempdb..#TASKLIST') IS NOT NULL)  
					DROP TABLE #TASKLIST  
  
				DECLARE @tasklist TABLE (taskname NVARCHAR (500))  
  
				INSERT INTO @tasklist  
				EXEC xp_cmdshell 'tasklist'  
  
				DELETE FROM @tasklist WHERE taskname IS NULL OR taskname LIKE '%Image Name%' OR taskname LIKE '%Nome da imagem%' OR taskname LIKE '%Mem Usage%' OR taskname LIKE '%Uso de memór%' OR taskname LIKE '===%'  
				SELECT  
					LEFT(taskname,25) AS 'Image Name'   
					,CAST(REPLACE(REPLACE(LTRIM(RTRIM(RIGHT(taskname,12))),'K',''),'.','') AS INT) AS 'Mem Usage (Kb)'  
					,ROW_NUMBER() OVER(ORDER BY CAST(REPLACE(REPLACE(LTRIM(RTRIM(RIGHT(taskname,12))),'K',''),'.','') AS INT) DESC) 'Rank'  
					INTO #TASKLIST  
				FROM @tasklist  
  
  
				IF @fl_ativo = 0   
				BEGIN   
					-- To enable the feature.    
					EXECUTE sp_configure 'xp_cmdshell', 0      
  
					-- To update the currently configured value for this feature.    
					RECONFIGURE    
   
					-- To allow advanced options to be changed.    
					EXECUTE sp_configure 'show advanced options', 0       
  
					-- To update the currently configured value for advanced options.    
					RECONFIGURE;       
				END  
  

                -- Apenas se todos os valores de CPU nos últimos 5 minutos forem maiores que o parâmetro
                 IF  ((select MIN(CPU_Utilization) from #CPU_Utilization) >= @Vl_Parameter  
				  AND (DATEPART(HOUR, GETDATE())) >= 19  AND DATEPART(HOUR, GETDATE()) <= 22  
				  AND NOT EXISTS(select [Image Name] FROM #TASKLIST WHERE [Image Name] = 'CLBackup.exe')  
				 )OR  
  
				 ((select MIN(CPU_Utilization) from #CPU_Utilization) >= @Vl_Parameter  
				  AND (DATEPART(HOUR, GETDATE())) >= 19  AND DATEPART(HOUR, GETDATE()) <= 22  
				  AND EXISTS(select [Image Name] FROM #TASKLIST WHERE [Image Name] = 'CLBackup.exe')  
				  AND ((select SUM(SQLProcessUtilization) from #CPU_Utilization) > (select SUM(OtherProcessUtilization) from #CPU_Utilization))      
				 )OR  
  
				 ((select MIN(CPU_Utilization) from #CPU_Utilization) >= @Vl_Parameter  
				  AND (DATEPART(HOUR, GETDATE())) < 19  OR DATEPART(HOUR, GETDATE()) > 22) 


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
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
                                                               SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
                                               END
          ELSE 
                                  BEGIN
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
                                                               SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
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
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
                                                               SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
                                               END
           ELSE 
                                  BEGIN
                                                               SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
                                                               SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
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
