-- A cache de planos
-- Usando o CROSS APPLY para ver o texto e o plano
SELECT *
FROM sys.dm_exec_cached_plans as ECP
CROSS APPLY sys.dm_exec_sql_text(ECP.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(ECP.plan_handle)
ORDER BY ECP.usecounts DESC
GO

-- Qual a diferença entre os dois?
SELECT *
FROM sys.dm_exec_query_stats as EQS
CROSS APPLY sys.dm_exec_sql_text(EQS.sql_handle)
CROSS APPLY sys.dm_exec_query_plan(EQS.plan_handle)
WHERE EQS.plan_handle = 0x06000500CC51772AF068D91D5802000001000000000000000000000000000000000000000000000000000000
GO


--Caso esteja gerando prepared query para cada tamanho de variavel, tem que acertar o tamanho da variavel na aplicação, com o tmanho da coluna
-- de dentro do banco podemos habiltiar o Trace flag 144 (T144) - Internals Modulo 2, pt1
-- !!! Cuidado com o parameter sniffing
