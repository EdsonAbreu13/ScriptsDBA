EXEC sys.sp_configure N'max server memory (MB)', N'24000'
GO
RECONFIGURE WITH OVERRIDE
GO

USE Curso_Protheus

-- drop table [SA1010_Compression]
CREATE TABLE [dbo].[SA1010_Compression](
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
	[R_E_C_D_E_L_] [int] NOT NULL,
 CONSTRAINT [SA1010_Compression_PK] PRIMARY KEY CLUSTERED 
(	[R_E_C_N_O_] ASC)
) 
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_FILIAL_DF]  DEFAULT ('  ') FOR [A1_FILIAL]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_COD_DF]  DEFAULT ('      ') FOR [A1_COD]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_LOJA_DF]  DEFAULT ('  ') FOR [A1_LOJA]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_NOME_DF]  DEFAULT ('                                        ') FOR [A1_NOME]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_PESSOA_DF]  DEFAULT (' ') FOR [A1_PESSOA]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_END_DF]  DEFAULT ('                                                                                ') FOR [A1_END]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_NREDUZ_DF]  DEFAULT ('                    ') FOR [A1_NREDUZ]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_BAIRRO_DF]  DEFAULT ('                                        ') FOR [A1_BAIRRO]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_TIPO_DF]  DEFAULT (' ') FOR [A1_TIPO]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_EST_DF]  DEFAULT ('  ') FOR [A1_EST]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_ESTADO_DF]  DEFAULT ('                    ') FOR [A1_ESTADO]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_CEP_DF]  DEFAULT ('        ') FOR [A1_CEP]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_D_E_L_E_T__DF]  DEFAULT (' ') FOR [D_E_L_E_T_]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_R_E_C_N_O__DF]  DEFAULT ((0)) FOR [R_E_C_N_O_]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_R_E_C_D_E_L__DF]  DEFAULT ((0)) FOR [R_E_C_D_E_L_]
GO

ALTER TABLE [dbo].[SA1010_Compression] ADD  CONSTRAINT [SA1010_Compression_A1_CGC_DF]  DEFAULT ('              ') FOR [A1_CGC]
GO


/*
 -- Fontes
 -- https://www.sqlshack.com/how-to-generate-random-sql-server-test-data-using-t-sql/
 -- https://www.mssqltips.com/sqlservertip/3157/different-ways-to-get-random-data-for-sql-server-data-sampling/
 
	--truncate table [SA1010_Compression]
*/


	declare @Qt_linhas int

	set @Qt_linhas = 1000000

	;with randowvalues
		as(
		   select 1 id, CAST(RAND(CHECKSUM(NEWID()))*1000000 as int) randomnumber
		   --select 1 id, RAND(CHECKSUM(NEWID()))*100 randomnumber
			union  all
			select id + 1, CAST(RAND(CHECKSUM(NEWID()))*1000000 as int)  randomnumber
			--select id + 1, RAND(CHECKSUM(NEWID()))*100  randomnumber
			from randowvalues
			where 
			  id < @Qt_linhas
		  )
	  
		insert into [SA1010_Compression]([R_E_C_N_O_])
		select id [R_E_C_N_O_]
		from randowvalues
		OPTION(MAXRECURSION 0)


	SELECT TOP 1000 * FROM [SA1010_Compression]

	sp_spaceused [SA1010_Compression]


	--Sem compressão
	SA1010_Compression	1000000             	286856 KB	285720 KB	1072 KB	64 KB

	ALTER INDEX SA1010_Compression_PK ON [SA1010_Compression] REBUILD with(DATA_COMPRESSION=ROW)

	-- Compressão de Linha
	SA1010_Compression	1000000             	267304 KB	266680 KB	528 KB	96 KB


	ALTER INDEX SA1010_Compression_PK ON [SA1010_Compression] REBUILD with(DATA_COMPRESSION=PAGE)

	-- Compressão de Página
	SA1010_Compression	1000000             	14984 KB	14864 KB	48 KB	72 KB





/************************************** CASO DE INSERTS NA HEAP ******************************************/


	-- drop table [SA1010_HEAP]
	SELECT * 
	INTO SA1010_HEAP
	FROM [SA1010_Compression]

	sp_spaceused SA1010_HEAP

	--Heap sem compressão
	SA1010_HEAP	1000000             	285768 KB	285720 KB	8 KB	40 KB

	ALTER TABLE [dbo].[SA1010_HEAP] REBUILD WITH (DATA_COMPRESSION = PAGE)

	--Heap com compressão
	SA1010_HEAP	1000000             	15112 KB	15032 KB	8 KB	72 KB


	-- Agora vamos fazer alguns inserts e ver o tamanho
	
		--Conferindo o tamanho após os inserts
		EXEC sp_spaceused [SA1010_Compression]

		EXEC sp_spaceused SA1010_HEAP


		  
		insert into [SA1010_Compression]([R_E_C_N_O_])
		SELECT [R_E_C_N_O_] +1000000
		FROM [SA1010_Compression]
		
		insert into SA1010_HEAP
		SELECT *
		FROM SA1010_HEAP

		--Conferindo o tamanho após os inserts
		EXEC sp_spaceused [SA1010_Compression]

		EXEC sp_spaceused SA1010_HEAP

		
		--Fazendo um rebuild para conferir se é fragmentação
		ALTER INDEX SA1010_Compression_PK ON [SA1010_Compression] REBUILD
		
		ALTER TABLE SA1010_HEAP REBUILD


		--Como eu retiro a compressão de um índice ou Heap
		ALTER INDEX SA1010_Compression_PK ON [SA1010_Compression] REBUILD with(DATA_COMPRESSION=NONE)
		ALTER TABLE [dbo].[SA1010_HEAP] REBUILD WITH (DATA_COMPRESSION = NONE)

		-- Conferindo novamente após um REBUILD
		EXEC sp_spaceused [SA1010_Compression]

		EXEC sp_spaceused SA1010_HEAP
			   		   		 
		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT [R_E_C_N_O_] +2000000
		FROM [SA1010_Compression]
		
		insert into SA1010_HEAP
		SELECT *
		FROM SA1010_HEAP

		--Conferindo o tamanho após os inserts
		EXEC sp_spaceused [SA1010_Compression]

		EXEC sp_spaceused SA1010_HEAP

		
		--Fazendo um rebuild para conferir se é fragmentação
		ALTER INDEX SA1010_Compression_PK ON [SA1010_Compression] REBUILD
		
		ALTER TABLE SA1010_HEAP REBUILD

		--Conferindo o tamanho após os inserts
		EXEC sp_spaceused [SA1010_Compression]

		EXEC sp_spaceused SA1010_HEAP

		-- Conclusão, uma tabela heap compactada que recebe novos inserts deve entrar na sua rotina de rebuild para que possa reaplicar o algorítimo de compressão.




/**************************** Teste de performance com e sem compressão ********************************/


	-- DROP TABLE 	[SA1010_Sem_Compression]
	CREATE TABLE [dbo].[SA1010_Sem_Compression](
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
		[R_E_C_D_E_L_] [int] NOT NULL,
	 CONSTRAINT [SA1010_Sem_Compression_PK] PRIMARY KEY CLUSTERED 
	(	[R_E_C_N_O_] ASC)
	) 
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_FILIAL_DF]  DEFAULT ('  ') FOR [A1_FILIAL]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_COD_DF]  DEFAULT ('      ') FOR [A1_COD]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_LOJA_DF]  DEFAULT ('  ') FOR [A1_LOJA]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_NOME_DF]  DEFAULT ('                                        ') FOR [A1_NOME]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_PESSOA_DF]  DEFAULT (' ') FOR [A1_PESSOA]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_END_DF]  DEFAULT ('                                                                                ') FOR [A1_END]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_NREDUZ_DF]  DEFAULT ('                    ') FOR [A1_NREDUZ]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_BAIRRO_DF]  DEFAULT ('                                        ') FOR [A1_BAIRRO]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_TIPO_DF]  DEFAULT (' ') FOR [A1_TIPO]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_EST_DF]  DEFAULT ('  ') FOR [A1_EST]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_ESTADO_DF]  DEFAULT ('                    ') FOR [A1_ESTADO]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_CEP_DF]  DEFAULT ('        ') FOR [A1_CEP]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_D_E_L_E_T__DF]  DEFAULT (' ') FOR [D_E_L_E_T_]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_R_E_C_N_O__DF]  DEFAULT ((0)) FOR [R_E_C_N_O_]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_R_E_C_D_E_L__DF]  DEFAULT ((0)) FOR [R_E_C_D_E_L_]
	GO

	ALTER TABLE [dbo].[SA1010_Sem_Compression] ADD  CONSTRAINT [SA1010_Sem_Compression_A1_CGC_DF]  DEFAULT ('              ') FOR [A1_CGC]
	GO

	

	declare @Qt_linhas int

	set @Qt_linhas = 1000000

	;with randowvalues
		as(
		   select 1 id, CAST(RAND(CHECKSUM(NEWID()))*1000000 as int) randomnumber
		   --select 1 id, RAND(CHECKSUM(NEWID()))*100 randomnumber
			union  all
			select id + 1, CAST(RAND(CHECKSUM(NEWID()))*1000000 as int)  randomnumber
			--select id + 1, RAND(CHECKSUM(NEWID()))*100  randomnumber
			from randowvalues
			where 
			  id < @Qt_linhas
		  )
	  
		insert into [SA1010_Sem_Compression]([R_E_C_N_O_])
		select id [R_E_C_N_O_]
		from randowvalues
		OPTION(MAXRECURSION 0)

		
		INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT [R_E_C_N_O_] +1000000
		FROM [SA1010_Sem_Compression]
				
		INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT [R_E_C_N_O_] +2000000
		FROM [SA1010_Sem_Compression]
				
		
		ALTER INDEX SA1010_Sem_Compression_PK ON [SA1010_Sem_Compression] REBUILD
		ALTER INDEX SA1010_Compression_PK ON [SA1010_Compression] REBUILD WITH(DATA_COMPRESSION=PAGE)
				
		EXEC sp_spaceused [SA1010_Sem_Compression]
		EXEC sp_spaceused [SA1010_Compression]

	
		-- Ligar o profile e monitorar esse SPID e com reads > 0
			   


		--validação de um update


		UPDATE [SA1010_Compression]
		SET A1_NOME = 'Fabricio França Lima 2'
		GO
		UPDATE [SA1010_Compression]
		SET A1_NOME = 'Fabricio França Lima 3'
		GO
		UPDATE [SA1010_Compression]
		SET A1_NOME = 'Fabricio França Lima 4'
				
		GO
		UPDATE [SA1010_Sem_Compression]
		SET A1_NOME = 'Fabricio França Lima 2'
		GO
		UPDATE [SA1010_Sem_Compression]
		SET A1_NOME = 'Fabricio França Lima 3'
		GO
		UPDATE [SA1010_Sem_Compression]
		SET A1_NOME = 'Fabricio França Lima 4'


		-- Update em 1 linha


		UPDATE TOP (1) [SA1010_Compression]
		SET A1_NOME = 'Fabricio França Lima 2'	
		GO
		UPDATE  TOP (1)[SA1010_Compression]
		SET A1_NOME = 'Fabricio França Lima 3'
		GO
		UPDATE  TOP (1)[SA1010_Compression]
		SET A1_NOME = 'Fabricio França Lima 4'

		
		GO
		UPDATE  TOP (1)[SA1010_Sem_Compression]
		SET A1_NOME = 'Fabricio França Lima 2'
		GO
		UPDATE  TOP (1)[SA1010_Sem_Compression]
		SET A1_NOME = 'Fabricio França Lima 3'
		GO
		UPDATE  TOP (1)[SA1010_Sem_Compression]
		SET A1_NOME = 'Fabricio França Lima 4'



		--Validação de um insert


		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT TOP 1000000 [R_E_C_N_O_] +20000000
		FROM [SA1010_Sem_Compression]
		GO
		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT TOP 1000000 [R_E_C_N_O_] +30000000
		FROM [SA1010_Sem_Compression]
		GO
		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT TOP 1000000 [R_E_C_N_O_] +40000000
		FROM [SA1010_Sem_Compression]

		GO
		INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT TOP 1000000 [R_E_C_N_O_] +20000000
		FROM [SA1010_Sem_Compression]
		GO
        INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT TOP 1000000 [R_E_C_N_O_] +30000000
		FROM [SA1010_Sem_Compression]
		GO
        INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT TOP 1000000 [R_E_C_N_O_] +40000000
		FROM [SA1010_Sem_Compression]



		--Inserindo 1 linha


		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT TOP 1 50000000
		FROM [SA1010_Sem_Compression]
		GO
		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT TOP 1 50000001
		FROM [SA1010_Sem_Compression]
		GO
		INSERT into [SA1010_Compression]([R_E_C_N_O_])
		SELECT TOP 1 50000002
		FROM [SA1010_Sem_Compression]

		GO
		INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT TOP 1 50000000
		FROM [SA1010_Sem_Compression]
		GO
        INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT TOP 1 50000001
		FROM [SA1010_Sem_Compression]
		GO
        INSERT into [SA1010_Sem_Compression]([R_E_C_N_O_])
		SELECT TOP 1 50000002
		FROM [SA1010_Sem_Compression]



		-- Validação de um seek
		

		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE R_E_C_N_O_ = 5
		GO
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE R_E_C_N_O_ = 5
		GO
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE R_E_C_N_O_ = 5
		GO
		SELECT *
		FROM [SA1010_Compression]
		WHERE R_E_C_N_O_ = 5
		GO
		SELECT *
		FROM [SA1010_Compression]
		WHERE R_E_C_N_O_ = 5
		GO
		SELECT *
		FROM [SA1010_Compression]
		WHERE R_E_C_N_O_ = 5

		-- validação de um scan com dados em memória (Buffer Cache)


		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
		GO
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
		GO
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'


		GO
		SELECT *
		FROM [SA1010_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
		GO
		SELECT *
		FROM [SA1010_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'				
		GO
		SELECT *
		FROM [SA1010_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
					

		-- validação de um scan sem dados em memória (Buffer Cache)


		DBCC DROPCLEANBUFFERS
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
		GO
       	DBCC DROPCLEANBUFFERS
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
		GO
		DBCC DROPCLEANBUFFERS
		SELECT *
		FROM [SA1010_Sem_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'
		
		GO
		DBCC DROPCLEANBUFFERS
		SELECT *
		FROM [SA1010_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'		   
		GO
		DBCC DROPCLEANBUFFERS
		SELECT *
		FROM [SA1010_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'		 
		GO
		DBCC DROPCLEANBUFFERS
		SELECT *
		FROM [SA1010_Compression]
		WHERE A1_NOME LIKE '%Ruim de bola%'		 

	

		--Validação de um delete

		DELETE TOP (1000000) FROM [SA1010_Compression]		
		GO
		DELETE TOP (1000000) FROM [SA1010_Compression]
		GO
		DELETE TOP (1000000) FROM [SA1010_Compression]

		GO

		DELETE TOP (1000000) FROM [SA1010_Sem_Compression]
		GO
		DELETE TOP (1000000) FROM [SA1010_Sem_Compression]
		GO
		DELETE TOP (1000000) FROM [SA1010_Sem_Compression]
		GO




/**************************** Script para compressão de todos os meus Índices ********************************/

/****************** MUITO IMPORTANTE 

- Mudar o recovery da base para SIMPLE e fazer o processo de voltar para FULL depois e continuar com bkp do log 

- REBUILD usa muito log e se não mudar seu log vai explodir de tamanho quando comprimir a base inteira.

--Curso onde falo sobre recovery FULL/SIMPLE e backup e Restore em geral:
https://cursos.powertuning.com.br/course?courseid=tarefas-do-dia-a-dia-de-um-dba

****************/

	-- Index compression (clustered index or non-clustered index)
	SELECT [t].[name] AS [Table], 
		   [i].[name] AS [Index],  
		   [p].[partition_number] AS [Partition],
		   [p].[data_compression_desc] AS [Compression], 
		   [i].[fill_factor],
		   [p].[rows],
		'ALTER INDEX [' + [i].[name] + '] ON [' + [s].[name] + '].[' + [t].[name] + 
		'] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE' +
		CASE WHEN [i].[fill_factor] BETWEEN 1 AND 89 THEN ', FILLFACTOR = 90' ELSE '' END + ' )'
	FROM [sys].[partitions] AS [p]
	INNER JOIN sys.tables AS [t] 
		 ON [t].[object_id] = [p].[object_id]
	INNER JOIN sys.indexes AS [i] 
		 ON [i].[object_id] = [p].[object_id] AND i.index_id = p.index_id
	INNER JOIN sys.schemas AS [s]
	   ON [t].[schema_id] = [s].[schema_id]
	WHERE [p].[index_id] > 0
	   AND [i].[name] IS NOT NULL
	   AND [p].[rows] > 10000
	   AND [p].[data_compression_desc] = 'NONE'
	Order by t.name
 
	-- Data (table) compression (heap)
	SELECT DISTINCT 
		[t].[name] AS [Table],
		   [p].[data_compression_desc] AS [Compression], 
		   [i].[fill_factor],
		   'ALTER TABLE [' + [s].[name] + '].[' + [t].[name] + '] REBUILD WITH (DATA_COMPRESSION = PAGE)'
	FROM [sys].[partitions] AS [p]
	INNER JOIN sys.tables AS [t] 
		 ON [t].[object_id] = [p].[object_id]
	INNER JOIN sys.indexes AS [i] 
		 ON [i].[object_id] = [p].[object_id]
	INNER JOIN sys.schemas AS [s]
	   ON [t].[schema_id] = [s].[schema_id]
	WHERE [p].[index_id]  = 0
	   AND [p].[rows] > 10000
	   AND [p].[data_compression_desc] = 'NONE'

      
	  sp_spaceused


  -- Shrink Database

  


  -- Rebuild de indices

  	DECLARE @Id int,@SQLString nvarchar(4000)
		
	drop table #Indices_Fragmentados
		
	select identity(int,1,1) Id, 
	--'ALTER INDEX ' + B.Name + ' ON ' + C.Name + 
	--	case when Avg_Fragmentation_In_Percent < 30 then ' REORGANIZE' else ' REBUILD' end Comando
		'ALTER INDEX ['+ B.Name+ '] ON ' + D.Name+'.['+ C.Name + 
		case when Avg_Fragmentation_In_Percent < 15 then '] REORGANIZE' else '] REBUILD' end Comando
		,avg_fragmentation_in_percent,
		Page_Count
	INTO #Indices_Fragmentados
	from sys.dm_db_index_physical_stats(db_id(),null,null,null,null) A
		join sys.indexes B on A.object_id = B.object_id and A.index_id = B.index_id
		join sys.sysobjects C on C.id = B.object_id
			join sys.objects E on C.id = E.object_id       
		join sys.schemas D on D.schema_id = E.schema_id
	where avg_fragmentation_in_percent > 5
		and Page_Count > 1000
		
		
	--rodar manualmente 
	select *
	from #Indices_Fragmentados
	where Comando is not null
	ORDER by Page_Count