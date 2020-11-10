SET STATISTICS IO OFF

use Curso_Protheus

--Limpar o Buffer Cache, onde ficam as páginas de dados dos nossos índices/Tabelas
DBCC DROPCLEANBUFFERS


-- Utilização de memória por base de dados
SELECT  CASE database_id
          WHEN 32767 THEN 'ResourceDb'
          ELSE DB_NAME(database_id)
        END AS database_name ,
        COUNT(*) AS cached_pages_count ,
        COUNT(*) * .0078125 AS cached_megabytes /* Each page is 8kb, which is .0078125 of an MB */
FROM    sys.dm_os_buffer_descriptors
GROUP BY DB_NAME(database_id) ,
        database_id
ORDER BY cached_pages_count DESC ;

--Se a memória não zerar rodar um Checkpoint( Processo que leva as páginas alteradas da memória para o disco)
CHECKPOINT

--Limpa novamente o buffer cache
DBCC DROPCLEANBUFFERS


-- Query para o SQL Server aumentar o uso da memória
SELECT *
FROM SA1010
WHERE R_E_C_N_O_ like '%2465465865465%'


-- Validar se o índice que o SQL usou na query acima foi para a mamória
SELECT TOP 5 COUNT(*) AS cached_pages_count,COUNT(*)/128.0000 MB,
name AS BaseTableName, IndexName,
IndexTypeDesc
FROM sys.dm_os_buffer_descriptors AS bd
	INNER JOIN	(
				SELECT s_obj.name, s_obj.index_id,
				s_obj.allocation_unit_id, s_obj.OBJECT_ID,
				i.name IndexName, i.type_desc IndexTypeDesc
				FROM
					(SELECT OBJECT_NAME(OBJECT_ID) AS name,	index_id ,
						allocation_unit_id, OBJECT_ID
					 FROM sys.allocation_units AS au
					    INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id	AND (au.TYPE = 1 OR au.TYPE = 3)
					 UNION ALL
					 SELECT OBJECT_NAME(OBJECT_ID) AS name,
						index_id, allocation_unit_id, OBJECT_ID
					 FROM sys.allocation_units AS au
						INNER JOIN sys.partitions AS p ON au.container_id = p.partition_id	AND au.TYPE = 2
					) AS s_obj
					LEFT JOIN sys.indexes i ON i.index_id = s_obj.index_id
			    	AND i.OBJECT_ID = s_obj.OBJECT_ID 
			    ) AS obj ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = DB_ID()
GROUP BY name, index_id, IndexName, IndexTypeDesc
ORDER BY cached_pages_count DESC;


--Rodar essa query que utiliza outro índice e ver se vai aparecer outro índice em memória
SELECT *
FROM SA1010
WHERE A1_NOME like '%Fabricio%'



-- Configure a mamória para deixar o máximo para o SQL Server e um pouco livre no SO 

--Validar qual o PLE
SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life expectancy'

--Reduzindo minha memória
EXEC sys.sp_configure N'max server memory (MB)', N'1000'
GO
RECONFIGURE WITH OVERRIDE
GO

SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life expectancy'

-- rodar e conferir o uso da memória no SQL Server
--544.32031250	SA1010	SA1010W10
SELECT *
FROM SA1010
WHERE A1_ESTADO like '%ES%'

-- rodar e conferir o uso da memória no SQL Server
SELECT *
FROM SA1010
WHERE R_E_C_N_O_ like '%2465465865465%'

0.16406250	SA1010	SA1010_PK

SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life expectancy'


-- rodar e conferir o uso da memória no SQL Server
SELECT *
FROM SA1010
WHERE A1_BAIRRO like '%Fabricio%'

SELECT *
FROM SA1010
WHERE A1_NOME like '%Fabricio%'


SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life expectancy'


--Reduzindo minha memória
EXEC sys.sp_configure N'max server memory (MB)', N'8000'
GO
RECONFIGURE WITH OVERRIDE
GO



-- Fui testar reduzir para 500 MB e meu SQL morreu.
EXEC sys.sp_configure N'max server memory (MB)', N'500'
GO
RECONFIGURE WITH OVERRIDE
GO

--Quando isso acontece você tem que subir o SQL via linha de comando com as configurações mínimas e subir novamente o limite de memória via SQLCMD

--Primeiro artigo que achei no google para me relembrar a sintaxe
https://alisharifiblog.wordpress.com/2015/03/04/213/

