/*
-- REORGANIZE
	- Não utiliza espaço em disco a mais para realizar essa operação
	- Reorganiza os LEAF LEVEL dos índices
	- Não atualiza as estatísticas dos índices
	- Se cancelado, não perde o que foi feito. O REBUILD perde.

-- REBUILD
	- Utiliza espaço temporário em disco para realização do REBUILD 
	- Destrói o índice e cria novamente
	- Atualiza as estatísticas dos índices
	- Causa um Lock grande na tabela quando executado de forma OFFLINE. A versão Enterprise do SQL permite que o comando se execute o REBUILD ONLINE. Onde ele mantém uma versão dos dados na tempdb e faz a operação com poucos Locks.

	
-- QUANDO USAR?
	- Se o percentual de fragmentação for menor que 10% não faz nada
	- Se a fragmentação estiver entre 10% e 30% REORGANIZE
	- Se a fragmentação estiver acima de 30% REBUILD
	- Índices com menos de 1000 páginas devem ser ignorados
*/

-- COMANDO
ALTER INDEX IX_Teste_Fragmentacao ON Teste_Fragmentacao REORGANIZE
ALTER INDEX IX_Teste_Fragmentacao ON Teste_Fragmentacao REBUILD
-- REBUILD COM COMPACTAÇÃO
ALTER INDEX IX_Teste_Fragmentacao ON Teste_Fragmentacao REBUILD WITH(DATA_COMPRESSION=PAGE)


--	Query para verificar a fragmentação de índices
SELECT index_Type_desc,avg_page_space_used_in_percent
	,avg_fragmentation_in_percent	
	,index_level
	,record_count
	,page_count
	,fragment_count
	,avg_record_size_in_bytes
FROM sys.dm_db_index_physical_stats(DB_ID('TreinamentoDBA'),OBJECT_ID('TestesIndices'),NULL,NULL,'DETAILED')

