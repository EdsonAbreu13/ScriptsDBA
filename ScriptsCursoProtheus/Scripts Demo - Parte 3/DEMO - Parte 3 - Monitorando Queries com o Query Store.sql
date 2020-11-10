
	-- Habilitar o Query store

	-- Veja o meu post sobre o assunto
	-- https://www.fabriciolima.net/blog/2019/02/26/query-store-04-melhores-praticas-para-habilitar-o-query-store/
	
	-- Abrir via interface gráfica
	
	--Testar 
	USE Curso_Protheus

	--Executar e conferir no Query Store
	select  TOP 10 A.[A1_FILIAL],A.[A1_COD],A.[A1_LOJA],A.[A1_NOME],A.[A1_CGC]
	from [SA1010] A  		
	where A.A1_COD = '144823'
		and A.A1_FILIAL = '01'
	GO 10
		

	--Executar e conferir no Query Store
	IF OBJECT_ID('tempdb..#Result') IS NOT NULL DROP TABLE #Result

	select   A.[A1_FILIAL],A.[A1_COD],A.[A1_LOJA],A.[A1_NOME],A.[A1_CGC]
	INTO #Result
	from [SA1010] A  		
	where A.A1_COD = '144823'
		and A.A1_FILIAL = '01'

	IF OBJECT_ID('tempdb..#Result') IS NOT NULL DROP TABLE #Result

	select   A.[A1_FILIAL],A.[A1_COD],A.[A1_LOJA],A.[A1_NOME],A.[A1_CGC]
	INTO #Result
	from [SA1010] A  		
	where A.A1_COD  = '144s823'
		and A.A1_FILIAL = '01'
		

	--Cuidados

	-- Query Store (#03) – Lock grande ao tentar limpar o Query Store
	https://www.fabriciolima.net/blog/2019/02/26/query-store-04-melhores-praticas-para-habilitar-o-query-store/

	-- Query Store (#05) – Lock gerado ao executar o comando SET QUERY_STORE = OFF
	https://www.fabriciolima.net/blog/2019/06/01/query-store-05-lock-gerado-ao-executar-o-comando-set-query_store-off/

	-- Query Store (#06) – Queries do BD Travadas com o Wait QDS_STMT
	https://www.fabriciolima.net/blog/2020/08/26/query-store-06-queries-do-bd-travadas-com-o-wait-qds_stmt/