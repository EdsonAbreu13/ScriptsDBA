-- VERIFICAR TRACE FLAGS ATIVOS 
DBCC TRACESTATUS()

--ATIVAR/DESATIVAR TRACE FLAG 
DBCC TRACEON (2371, -1)  -- -1 para global, senão é aplicado para sessão
DBCC TRACEOFF (2371, -1)

-- TRACE FLAG 2371
-- default >= v. 2016,  habilita um treshold de auto update de statictics de acordo com o tamanho da tabela. (padrão <v. 2016 = 20%)


-- VERIFICAR TRACES EM EXECUÇÃO 
select * from fn_trace_getinfo(null)

-- FUNÇÃO PARA ACESSAR UM TRACE
select * from sys.fn_trace_gettable('C:\path\to\myTraceFile.trc', default)
