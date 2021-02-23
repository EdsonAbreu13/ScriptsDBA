


--drop table traces..Compressao_Indices
 
SELECT [s].[name] AS [Schema],
	   [t].[name] AS [Table], 
		   [i].[name] AS [Index],  
		   [p].[partition_number] AS [Partition],
		   [p].[data_compression_desc] AS [Compression], 
		   [i].[fill_factor],
		   [p].[rows],
	'ALTER INDEX [' + [i].[name] + '] ON [' + [s].[name] + '].[' + [t].[name] + 
	'] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE' +
	CASE WHEN [i].[fill_factor] BETWEEN 1 AND 89 THEN ', FILLFACTOR = 90' ELSE '' END + ' )' AS Ds_Comando
	into traces..Compressao_Indices
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
	AND [t].[name] not like 'DB_AGING_BUYER%'
ORDER BY [p].[rows] -- PARA VERIFICAR O TAMANHO DOS INDICES
 
--cria tabela de resultado da compressão
--drop table traces..Resultado_Compressao
create table traces..Resultado_Compressao
(
object_name varchar(256),
schema_name varchar(256),
index_id int,
partition_number int,
size_with_current_compression_setting_KB bigint,
size_with_requested_compression_setting_KB bigint,
sample_size_with_current_compression_setting_KB bigint,
sample_size_with_requested_compression_setting_KB bigint
)
 
--cria tabela temporária para controle dos indices que faltam ser comprimidos
--drop table traces.._Compressao
select  *
into traces.._Compressao
from traces..Compressao_Indices with(nolock)
 
 
declare @Nm_Table varchar(256)
 
--while para executar a estimativa de compressão de cada indice
while exists(select top 1 null from traces.._Compressao with(nolock))
begin
select @Nm_Table = min([table]) from traces.._Compressao with(nolock)
 
insert into traces..Resultado_Compressao 
exec sp_estimate_data_compression_savings 'dbo', @Nm_Table, NULL, null, 'PAGE' 
 
delete from traces.._Compressao where [table] = @Nm_Table
end


SELECT TOP (1000) [object_name]
      ,[schema_name]
      ,[index_id]
      ,[partition_number]
      ,[size_with_current_compression_setting_KB]
      ,[size_with_requested_compression_setting_KB]
      ,[sample_size_with_current_compression_setting_KB]
      ,[sample_size_with_requested_compression_setting_KB]
  FROM [Traces].[dbo].[Resultado_Compressao]


  select sum(size_with_current_compression_setting_KB)/1000000 Antes_GB, 
sum(size_with_requested_compression_setting_KB)/1000000 Depois_GB , 
(sum(size_with_current_compression_setting_KB)- sum(size_with_requested_compression_setting_KB))/1000000 Ganho_GB
from traces..Resultado_Compressao with(nolock)