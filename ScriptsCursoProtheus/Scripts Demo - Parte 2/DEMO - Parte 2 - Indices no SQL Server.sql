USE master

CREATE DATABASE [Curso_Protheus] COLLATE Latin1_General_BIN

ALTER DATABASE [Curso_Protheus] SET RECOVERY SIMPLE

USE Curso_Protheus

CREATE TABLE [dbo].[SA1010](
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
 CONSTRAINT [SA1010_PK] PRIMARY KEY CLUSTERED 
(	[R_E_C_N_O_] ASC)
) 
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_FILIAL_DF]  DEFAULT ('  ') FOR [A1_FILIAL]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_COD_DF]  DEFAULT ('      ') FOR [A1_COD]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_LOJA_DF]  DEFAULT ('  ') FOR [A1_LOJA]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_NOME_DF]  DEFAULT ('                                        ') FOR [A1_NOME]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_PESSOA_DF]  DEFAULT (' ') FOR [A1_PESSOA]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_END_DF]  DEFAULT ('                                                                                ') FOR [A1_END]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_NREDUZ_DF]  DEFAULT ('                    ') FOR [A1_NREDUZ]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_BAIRRO_DF]  DEFAULT ('                                        ') FOR [A1_BAIRRO]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_TIPO_DF]  DEFAULT (' ') FOR [A1_TIPO]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_EST_DF]  DEFAULT ('  ') FOR [A1_EST]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_ESTADO_DF]  DEFAULT ('                    ') FOR [A1_ESTADO]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_CEP_DF]  DEFAULT ('        ') FOR [A1_CEP]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_D_E_L_E_T__DF]  DEFAULT (' ') FOR [D_E_L_E_T_]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_R_E_C_N_O__DF]  DEFAULT ((0)) FOR [R_E_C_N_O_]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_R_E_C_D_E_L__DF]  DEFAULT ((0)) FOR [R_E_C_D_E_L_]
GO

ALTER TABLE [dbo].[SA1010] ADD  CONSTRAINT [SA1010_A1_CGC_DF]  DEFAULT ('              ') FOR [A1_CGC]
GO


/*
 -- Fontes
 -- https://www.sqlshack.com/how-to-generate-random-sql-server-test-data-using-t-sql/
 -- https://www.mssqltips.com/sqlservertip/3157/different-ways-to-get-random-data-for-sql-server-data-sampling/
 
	--truncate table [SA1010]
*/

-- 3 minutos no meu PC
declare @Qt_linhas int

set @Qt_linhas = 10000000

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
	  
	insert into [SA1010]([R_E_C_N_O_],[A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC],R_E_C_D_E_L_)
    select id [R_E_C_N_O_], '01' [A1_FILIAL], cast(randomnumber as char(6)) [A1_COD],
	CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) [A1_LOJA],

		CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
			CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
			CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) [A1_NOME],

			CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
			CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + 
            CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 97) [A1_CGC],id
    from randowvalues
    OPTION(MAXRECURSION 0)

	--30 segundos no meu PC
	update  [SA1010]
	set A1_END = A1_NOME + A1_CGC, A1_BAIRRO = substring(A1_NOME,1,5) + substring(A1_NOME,1,5) ,A1_ESTADO = SUBSTRING(A1_NOME,1,2)

	-- Conferindo os dados da tabela
	select top 10 * 
	from [SA1010]


	--50 segundos para criar os índices
	CREATE UNIQUE NONCLUSTERED INDEX [SA1010_UNQ] ON [dbo].[SA1010]
	(
		[A1_FILIAL] ASC,
		[A1_COD] ASC,
		[A1_LOJA] ASC,
		[R_E_C_D_E_L_] ASC
	)

	CREATE NONCLUSTERED INDEX [SA10101] ON [dbo].[SA1010]
	(
		[A1_FILIAL] ASC,
		[A1_COD] ASC,
		[A1_LOJA] ASC,
		[R_E_C_N_O_] ASC,
		[D_E_L_E_T_] ASC
	)

	CREATE NONCLUSTERED INDEX [SA10102] ON [dbo].[SA1010]
	(
		[A1_FILIAL] ASC,
		[A1_NOME] ASC,
		[A1_LOJA] ASC,
		[R_E_C_N_O_] ASC,
		[D_E_L_E_T_] ASC
	)

	CREATE NONCLUSTERED INDEX [SA10103] ON [dbo].[SA1010]
	(
		[A1_FILIAL] ASC,
		[A1_CGC] ASC,
		[R_E_C_N_O_] ASC,
		[D_E_L_E_T_] ASC
	)


	-- ALT+F1 para conferir os objetos dessa tabela
	[SA1010]

	--Conferindo o espaço utilizado da nossa tabela
	exec sp_spaceused [SA1010]



	--Já conhecia???
	set statistics io,time on
	
	select  [A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC] 
	from [SA1010]
	where A1_CGC = 'dpiobvqxcdgnys'

	-- Query do bairro
	select  [A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC]
	from [SA1010]
	where A1_BAIRRO = 'srvplsrvpl'

	create nonclustered index SA1010W01 on SA1010(A1_BAIRRO) with(FILLFACTOR=90)



	-- Rodar a query do bairro novamente

	create nonclustered index SA1010W02 on SA1010(A1_BAIRRO) 
	include([A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC])
	with(FILLFACTOR=90)	
	
	-- Rodar a query do bairro novamente

	-- Seek, Scan ou Seek + Lookup? 
	select  [A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC]
	from [SA1010] 
	where A1_COD = '144823'
		and A1_FILIAL = '01'

	create nonclustered index SA1010W03 on SA1010([A1_COD],[A1_FILIAL]) 
	include([A1_LOJA],[A1_NOME],[A1_CGC])
	with(FILLFACTOR=90)	

	-- Seek, Scan ou Seek + Lookup? 
	select  [A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC]
	from [SA1010]
	where A1_COD = '144823'
		and A1_FILIAL = '01'

	--Comparando com o anterior
	select  [A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC]
	from [SA1010] with(index=SA1010_UNQ)
	where A1_COD = '144823'
		and A1_FILIAL = '01'
			   	
	-- Fazendo uma query com Join
	
	--drop table _SA1010_BKP

	select *
	into _SA1010_BKP
	from [SA1010]

	create nonclustered index _SA1010_BKPW01 on _SA1010_BKP(A1_COD, A1_FILIAL)
	create nonclustered index _SA1010_BKPW02 on _SA1010_BKP(A1_FILIAL,A1_COD)

	select  count(*)
	from [SA1010] A 
		INNER JOIN _SA1010_BKP B with(index=_SA1010_BKPW01)on A.[A1_COD] = B.[A1_COD] and A.A1_FILIAL = B.A1_FILIAL 

	select  count(*)
	from [SA1010] A 
		INNER JOIN _SA1010_BKP B with(index=_SA1010_BKPW02) on A.[A1_COD] = B.[A1_COD] and A.A1_FILIAL = B.A1_FILIAL    
	
	-- *********************** Outro exemplo sobre a seletividade
	CREATE TABLE Cliente (Id_Cliente INT identity,Fl_Sexo CHAR(1),Endereco VARCHAR(500))
	 
 	INSERT INTO Cliente(Fl_Sexo,Endereco)
	SELECT 'M',REPLICATE('0',500)
	INSERT INTO Cliente(Fl_Sexo,Endereco)
	SELECT 'F',REPLICATE('0',500)
	
	-- Com poucos registros, não consegui mostrar essa diferença grande. Somente com MUITOS registros.
	-- E isso demorou muito na minha máquina. Se não quiser simular isso, veja só o vídeo e acredite em mim.

	--Demorou bastante na minha máquina parruda
	INSERT INTO Cliente(Fl_Sexo,Endereco)
	SELECT Fl_Sexo,Endereco
	FROM dbo.Cliente
	GO 30


    CREATE NONCLUSTERED INDEX SK_Sexo ON Cliente(Fl_Sexo,Id_Cliente) INCLUDE(Endereco)
    CREATE NONCLUSTERED INDEX SK_Cliente ON Cliente(Id_Cliente,Fl_Sexo) INCLUDE(Endereco)

	SET STATISTICS IO,TIME ON

	select *
	from Cliente A    WITH(INDEX=SK_Cliente)   
	where A.Fl_Sexo = 'F'
		and Id_Cliente = 12

	select *
	from Cliente A    WITH(NOLOCK,INDEX=SK_Sexo)
	where A.Fl_Sexo = 'F'
		and Id_Cliente = 12    
	
	select TOP 1000 *
	from Cliente A    WITH(NOLOCK,INDEX=SK_Cliente)
	 JOIN Cliente B WITH(NOLOCK,INDEX=SK_Cliente) ON A.Fl_Sexo = B.Fl_Sexo AND A.Id_Cliente = B.Id_Cliente
           

	select TOP 1000 *
	from Cliente A    WITH(NOLOCK,INDEX=SK_Sexo)
	 JOIN Cliente B WITH(NOLOCK,INDEX=SK_Sexo) ON A.Fl_Sexo = B.Fl_Sexo AND A.Id_Cliente = B.Id_Cliente

	 --*****************************************




	---------------
	-- Seek, Scan ou Lookup?
	select *
	from [SA1010]
	where A1_COD = '144823'	
	   
	-- Gerando mais dados	
	insert into [SA1010]([R_E_C_N_O_],[A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],[A1_CGC],R_E_C_D_E_L_)
	select top 300000 [R_E_C_N_O_]+100001,'01','144823','05',[A1_NOME],[A1_CGC],R_E_C_D_E_L_+100001
	from [SA1010]
	order by [R_E_C_N_O_] DESC	
	

	-- Seek, Scan ou Lookup?
	select *
	from [SA1010]
	where A1_COD = '144823'

	 	 
	--Sou mais esperto que o SQL, vou forçar ele a fazer o seek no índice SA1010W03
	select *
	from [SA1010] with(index=SA1010W03)
	where A1_COD = '144823'	


	
	--Com um código com pouca linha de resultado, o SQL Server volta a usar um seek + lookup
	select *
	from [SA1010]
	where A1_COD = '695478'	


---------------------------------------------------- DEMO FILLFACTOR

	--	Criação da tabela e do índice clustered através da primary key
	if object_id('TestesIndices') is not null 
		drop table TestesIndices

	create table TestesIndices(
		Cod int,
		Data datetime default(getdate()),
		Descricao varchar(1000)
	)

	insert into TestesIndices(Cod,Descricao)
	select cast(1000000000*rand()/1000 as int),replicate('0',1000)
	GO 100000

	create nonclustered index SK03_TestesIndices on TestesIndices(Data) INCLUDE(Descricao) with(FILLFACTOR=90) 
	create nonclustered index SK04_TestesIndices on TestesIndices(Data) INCLUDE(Descricao) with(FILLFACTOR=10) 

	--	Tamanho dos índices
	SELECT i.[name] AS IndexName
		,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
	FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
		AND s.[index_id] = i.[index_id]
		join sysobjects o ON i.[object_id] = o .id
	where o.name = 'TestesIndices'
	GROUP BY i.[name]
	ORDER BY 2 desc

	--Referência
	--https://www.fabriciolima.net/blog/2011/02/26/qual-o-valor-ideal-para-o-fillfactor-de-um-indice/

	-- Como validar o Fill Factor dos índices
	SELECT DB_NAME() AS Base
	, sc.name AS [Schema]
	, o.name AS Tabela
	, i.name AS Indice
	, i.type_desc AS Tipo_Indice
	, i.fill_factor [Fill Factor]
	FROM sys.indexes i
	INNER JOIN sys.objects o ON i.object_id = o.object_id
	INNER JOIN sys.schemas sc ON o.schema_id = sc.schema_id
	WHERE i.name IS NOT NULL
	AND o.type = 'U'
	ORDER BY i.fill_factor DESC, o.name 

------------------------------------------------ DEMO PAGE SPLIT

--	Criação da tabela e do índice clustered através da primary key
if object_id('TestesIndices') is not null 
	drop table TestesIndices

create table TestesIndices(
	Cod int,
	Data datetime default(getdate()),
	Descricao varchar(1000)
)
create clustered index SK01_TestesIndices on TestesIndices(Cod) with(FILLFACTOR = 95)

insert into TestesIndices(Cod,Descricao)
select cast(1000000000*rand()/1000 as int),replicate('0',1000)
GO 100000

create nonclustered index SK03_TestesIndices on TestesIndices(Data) INCLUDE(Descricao) with(FILLFACTOR=90) 


--	Tamanho dos índices
SELECT i.[name] AS IndexName
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
	join sysobjects o ON i.[object_id] = o .id
where o.name = 'TestesIndices'
GROUP BY i.[name]
ORDER BY 2 desc

--	Indice 1 - Clustered (Cod, Data e Descrição) - 3 colunas
--  Indice 3 - NonClustered (Data , Descrição e Cod) - 3 colunas

-- Porque o índice 1 está muito maior que o 3??????

--Para resolver o problema

alter index SK01_TestesIndices on TestesIndices  REBUILD


--------------------------------------------------- DEMO INCLUDE

	--	Criação da tabela e do índice clustered através da primary key
	if object_id('TestesIndices') is not null 
		drop table TestesIndices

	create table TestesIndices(
		Cod int,
		Data datetime default(getdate()),
		Descricao varchar(1000)
	)



	insert into TestesIndices(Cod,Descricao)
	select cast(1000000000*rand()/1000 as int),replicate('0',1000)
	GO 10000

	insert into TestesIndices
	select *
	from TestesIndices
	GO 8

	ALTER TABLE TestesIndices ADD SimulandoVariasColunasNoInclude VARCHAR(100) 

	UPDATE  TestesIndices
	SET SimulandoVariasColunasNoInclude = REPLICATE('0',100)

	select top 10 * from TestesIndices

	create nonclustered index SK01_Com_Include on TestesIndices(Data) INCLUDE(SimulandoVariasColunasNoInclude) with(FILLFACTOR=95) 

	create nonclustered index SK02_Sem_Include on TestesIndices(Data,SimulandoVariasColunasNoInclude) with(FILLFACTOR=95) 

	-- Validar as colunas com include
	select SCHEMA_NAME (o.SCHEMA_ID) SchemaName
	  ,o.name ObjectName,i.name IndexName
	  ,i.type_desc
	  ,LEFT(list, ISNULL(splitter-1,len(list)))Columns
	  , SUBSTRING(list, indCol.splitter+1, 1000) includedColumns--len(name) - splitter-1) columns
	  , COUNT(1)over (partition by o.object_id)
	from sys.indexes i
	join sys.objects o on i.object_id= o.object_id
	cross apply (select NULLIF(charindex('|',indexCols.list),0) splitter , list
				 from (select cast((
							  select case when sc.is_included_column = 1 and sc.ColPos= 1 then'|'else '' end +
									 case when sc.ColPos > 1 then ', ' else ''end + name
								from (select sc.is_included_column, index_column_id, name
										   , ROW_NUMBER()over (partition by sc.is_included_column
																order by sc.index_column_id)ColPos
									   from sys.index_columns  sc
									   join sys.columns        c on sc.object_id= c.object_id
																and sc.column_id = c.column_id
									  where sc.index_id= i.index_id
										and sc.object_id= i.object_id) sc
					   order by sc.is_included_column
							   ,ColPos
						 for xml path (''),type) as varchar(max)) list)indexCols) indCol
	where indCol.splitter is not null
	order by SchemaName, ObjectName, IndexName

	
	SELECT ISNULL(i.[name],'HEAP') AS IndexName
		,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
	FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
		AND s.[index_id] = i.[index_id]
		join sysobjects o ON i.[object_id] = o .id
	where o.name = 'TestesIndices'
	GROUP BY i.[name]
	ORDER BY 2 DESC

	SELECT 331608*1.00/336024 

	SET STATISTICS IO ON

	-- Fazendo um seek
	select Data,SimulandoVariasColunasNoInclude
	FROM TestesIndices WITH(INDEX=SK01_Com_Include)
	where Data = '2017-06-24 10:29:14.817'

	select Data,SimulandoVariasColunasNoInclude
	FROM TestesIndices WITH(INDEX=SK02_Sem_Include)
	where Data = '2017-06-24 10:29:14.817'

	--Fazendo um scan
	if object_id('tempdb..#Teste1') is not null 
		drop table #Teste1

	if object_id('tempdb..#Teste2') is not null 
		drop table #Teste2

	select Data,SimulandoVariasColunasNoInclude
	into #Teste1
	FROM TestesIndices WITH(INDEX=SK01_Com_Include)

	select Data,SimulandoVariasColunasNoInclude
	into #Teste2
	FROM TestesIndices WITH(INDEX=SK02_Sem_Include)

	select 42029*1.0/45419

	-- Mesmo teste, mas agora com a coluna Descrição = varchar(1000)
	create nonclustered index SK03_Com_Include on TestesIndices(Data) INCLUDE(Descricao) with(FILLFACTOR=95) 
	create nonclustered index SK04_Sem_Include on TestesIndices(Data,Descricao) with(FILLFACTOR=95) 

	SELECT i.[name] AS IndexName
		,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
	FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
		AND s.[index_id] = i.[index_id]
		join sysobjects o ON i.[object_id] = o .id
	where o.name = 'TestesIndices'
	GROUP BY i.[name]
	ORDER BY 2 DESC

	SELECT 2936040*1.00/3413600

	SET STATISTICS IO ON

	-- Fazendo um seek
	select Data,Descricao
	FROM TestesIndices WITH(INDEX=SK03_Com_Include)
	where Data = '2017-06-24 10:29:14.817'

	select Data,Descricao
	FROM TestesIndices WITH(INDEX=SK04_Sem_Include)
	where Data = '2017-06-24 10:29:14.817'


	-- Fazendo um Scan
	if object_id('tempdb..#Teste1') is not null 
		drop table #Teste1

	if object_id('tempdb..#Teste2') is not null 
		drop table #Teste2
	
	select Data,Descricao
	into #Teste1
	FROM TestesIndices WITH(INDEX=SK03_Com_Include)

	select Data,Descricao
	into #Teste2
	FROM TestesIndices WITH(INDEX=SK04_Sem_Include)

	select 370351*1.0/554526


	---------- Teste o ORDER BY x INCLUDE

	set statistics io,time on

	select A1_FILIAL, A1_COD,A1_END
	from SA1010
	where A1_ESTADO = 'xm'
	order by A1_NOME

	insert into [SA1010]([R_E_C_N_O_],[A1_FILIAL],[A1_COD],[A1_LOJA],[A1_NOME],A1_ESTADO,[A1_CGC],R_E_C_D_E_L_)
	select top 100000 [R_E_C_N_O_]+100001,'01','144823','05',[A1_NOME],'xm',[A1_CGC],R_E_C_D_E_L_+100001
	from [SA1010]
	order by [R_E_C_N_O_] DESC	

	create nonclustered index SA1010W10 on SA1010(A1_ESTADO)include(A1_NOME,A1_FILIAL, A1_COD,A1_END)

	create nonclustered index SA1010W11 on SA1010(A1_ESTADO,A1_NOME)include(A1_FILIAL, A1_COD,A1_END)

	select A1_FILIAL, A1_COD,A1_END
	from SA1010 with(index=SA1010W10)
	where A1_ESTADO = 'xm'
	order by A1_NOME
	option(maxdop 1)
	
	--O índice que tem a coluna utilizada no order by (A1_NOME), não precisa usar o operador de sorte pois já tem a informação ordenada na arvore
	select A1_FILIAL, A1_COD,A1_END
	from SA1010 with(index=SA1010W11)
	where A1_ESTADO = 'xm'
	order by A1_NOME
	option(maxdop 1)

	