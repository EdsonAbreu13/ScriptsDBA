
/*

https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html


-- Eu habilito ou Auto Create e Auto Update Statistics

SELECT name, is_auto_update_stats_on, is_auto_create_stats_on
FROM sys.databases


*/

	

USE Curso_Protheus

-- drop table [SA1010_DBA_Routine]
CREATE TABLE [dbo].[SA1010_DBA_Routine](
	[A1_FILIAL] [varchar](2) NOT NULL,
	[A1_COD] [varchar](6) NOT NULL,
	[A1_LOJA] [varchar](2) NOT NULL,
	[A1_NOME] [varchar](40) NOT NULL,
	[A1_PESSOA] [varchar](1) NOT NULL,
	[A1_END] [varchar](80) NOT NULL,
	[A1_NREDUZ] [varchar](20) NOT NULL,
	[A1_BAIRRO] [varchar](40) NOT NULL,
	[A1_TIPO] [varchar](1) NOT NULL,
	[A1_EST] [varchar](2) NOT NULL,
	[A1_ESTADO] [varchar](20) NOT NULL,
	[A1_CEP] [varchar](8) NOT NULL,	
	[A1_CGC] [varchar](14) NOT NULL,
	[D_E_L_E_T_] [varchar](1) NOT NULL,
	[R_E_C_N_O_] [int] NOT NULL,
	[R_E_C_D_E_L_] [int] NOT NULL)
GO

-- Criação de alguns índices com fillfactor baixo de propósito para ficarem maiores.
CREATE CLUSTERED INDEX SK01_SA1010_DBA_Routine ON [SA1010_DBA_Routine] (R_E_C_N_O_) WITH(FILLFACTOR=50)
CREATE NONCLUSTERED INDEX SK02_SA1010_DBA_Routine ON [SA1010_DBA_Routine] ([A1_FILIAL]) WITH(FILLFACTOR=50)
CREATE NONCLUSTERED INDEX SK03_SA1010_DBA_Routine ON [SA1010_DBA_Routine] ([A1_COD]) WITH(FILLFACTOR=50)
CREATE NONCLUSTERED INDEX SK04_SA1010_DBA_Routine ON [SA1010_DBA_Routine] ([A1_LOJA]) WITH(FILLFACTOR=50)
CREATE NONCLUSTERED INDEX SK05_SA1010_DBA_Routine ON [SA1010_DBA_Routine] ([A1_NOME]) WITH(FILLFACTOR=50)



ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_FILIAL_DF]  DEFAULT ('  ') FOR [A1_FILIAL]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_COD_DF]  DEFAULT ('      ') FOR [A1_COD]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_LOJA_DF]  DEFAULT ('  ') FOR [A1_LOJA]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_NOME_DF]  DEFAULT ('                                        ') FOR [A1_NOME]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_PESSOA_DF]  DEFAULT (' ') FOR [A1_PESSOA]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_END_DF]  DEFAULT ('                                                                                ') FOR [A1_END]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_NREDUZ_DF]  DEFAULT ('                    ') FOR [A1_NREDUZ]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_BAIRRO_DF]  DEFAULT ('                                        ') FOR [A1_BAIRRO]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_TIPO_DF]  DEFAULT (' ') FOR [A1_TIPO]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_EST_DF]  DEFAULT ('  ') FOR [A1_EST]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_ESTADO_DF]  DEFAULT ('                    ') FOR [A1_ESTADO]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_CEP_DF]  DEFAULT ('        ') FOR [A1_CEP]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_D_E_L_E_T__DF]  DEFAULT (' ') FOR [D_E_L_E_T_]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_R_E_C_N_O__DF]  DEFAULT ((0)) FOR [R_E_C_N_O_]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_R_E_C_D_E_L__DF]  DEFAULT ((0)) FOR [R_E_C_D_E_L_]
GO

ALTER TABLE [dbo].[SA1010_DBA_Routine] ADD  CONSTRAINT [SA1010_DBA_Routine_A1_CGC_DF]  DEFAULT ('              ') FOR [A1_CGC]
GO


--Inserindo dados na tabela

--	TRUNCATE table [SA1010_DBA_Routine]
	SET NOCOUNT ON
	insert into [SA1010_DBA_Routine]([R_E_C_N_O_])
	SELECT RAND()*546465465
	GO 200000
	  
	insert into [SA1010_DBA_Routine]([R_E_C_N_O_])
	SELECT [R_E_C_N_O_] 
	FROM [SA1010_DBA_Routine]
	GO 3


	--Conferindo a fragmentação

	Declare @Nm_Tabela varchar(50)
	Set @Nm_Tabela = 'SA1010_DBA_Routine'
	select getdate(), @@servername,  db_Name(db_id()), @Nm_Tabela , B.Name, avg_fragmentation_in_percent,page_Count,fill_factor	
	from sys.dm_db_index_physical_stats(db_id(),object_Id(@Nm_Tabela),null,null,null) A
		join sys.indexes B on A.object_id = B.Object_id and A.index_id = B.index_id
	where Page_Count > 1000 


	-- Olhar as estatísticas
	SELECT TOP 1 *  FROM [SA1010_DBA_Routine] WHERE [A1_CEP] = ''
	SELECT TOP 1 * FROM [SA1010_DBA_Routine] WHERE [A1_EST] = ''
	SELECT TOP 1 * FROM [SA1010_DBA_Routine] WHERE [A1_ESTADO] = ''
	SELECT TOP 1 * FROM [SA1010_DBA_Routine] WHERE [A1_BAIRRO] = ''
	SELECT TOP 1 * FROM [SA1010_DBA_Routine] WHERE [A1_NREDUZ] = ''
	SELECT TOP 1 * FROM [SA1010_DBA_Routine] WHERE [A1_PESSOA] = ''

	UPDATE TOP (100000)  [SA1010_DBA_Routine] 
	SET [A1_CEP] = R_E_C_N_O_

	UPDATE TOP (100000)  [SA1010_DBA_Routine] 
	SET [A1_EST] = R_E_C_N_O_

	UPDATE TOP (100000)  [SA1010_DBA_Routine] 
	SET [A1_ESTADO] = R_E_C_N_O_

	UPDATE TOP (100000)  [SA1010_DBA_Routine] 
	SET [A1_BAIRRO] = R_E_C_N_O_

	UPDATE TOP (100000)  [SA1010_DBA_Routine] 
	SET [A1_NREDUZ] = R_E_C_N_O_

	UPDATE TOP (100000)  [SA1010_DBA_Routine] 
	SET [A1_PESSOA] = R_E_C_N_O_


	-- Tabela de Log dessa rotina
	TRUNCATE TABLE [CommandLog]


	--B. Rebuild or reorganize all indexes with fragmentation and update modified statistics on all user databases

	EXECUTE dbo.IndexOptimize
		@Databases = 'USER_DATABASES',
		@FragmentationLow = NULL,
		@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
		@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
		@FragmentationLevel1 = 5,
		@FragmentationLevel2 = 30,
		@UpdateStatistics = 'ALL',
		@OnlyModifiedStatistics = 'Y',
		@LogToTable = 'Y',
		@TimeLimit = 5 --segundos ****** parâmetro muito importante!!!!

			   		 		
	-- Tabela de Log dessa rotina
	SELECT StartTime,* 
	FROM [dbo].[CommandLog]
	ORDER BY 1 DESC


    