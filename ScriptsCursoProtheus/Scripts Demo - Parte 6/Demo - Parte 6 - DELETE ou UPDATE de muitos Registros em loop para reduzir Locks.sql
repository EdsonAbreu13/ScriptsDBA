
sp_spaceused 'SA1010'

SELECT TOP 1 * 
FROM dbo.SA1010



/************************************		INICIO DEMO INSERT				******************************************/

-- Preciso fazer um insert em massa em uma tabela
DECLARE @Max_R_E_C_N_O_ INT

SELECT @Max_R_E_C_N_O_ = MAX(R_E_C_N_O_)
FROM SA1010


INSERT INTO SA1010([A1_FILIAL], [A1_COD], [A1_LOJA], [A1_NOME], [A1_PESSOA], [A1_END], [A1_NREDUZ], [A1_BAIRRO], [A1_TIPO], [A1_EST], [A1_ESTADO], [A1_CEP], [A1_CGC], [D_E_L_E_T_], [R_E_C_N_O_], [R_E_C_D_E_L_])
SELECT [A1_FILIAL], @Max_R_E_C_N_O_+R_E_C_N_O_, [A1_LOJA], [A1_NOME], [A1_PESSOA], [A1_END], [A1_NREDUZ], [A1_BAIRRO], [A1_TIPO], [A1_EST], [A1_ESTADO], [A1_CEP], [A1_CGC], [D_E_L_E_T_], @Max_R_E_C_N_O_+R_E_C_N_O_, [R_E_C_D_E_L_]
FROM SA1010
WHERE R_E_C_N_O_ >= 1  AND R_E_C_N_O_ <= 1000000


-- Testar uma consulta no SSMS e 50 no SQLQueryStress
SELECT *
FROM dbo.SA1010 
WHERE R_E_C_N_O_ = 50


-- Acompanhar em outra conexão
DBCC SQLPERF(LOGSPACE)

EXEC sp_whoisactive



--Cancelar após um tempo o insert

DECLARE @Max_R_E_C_N_O_ INT, @Min_R_E_C_N_O_ INT, @Loop INT

SELECT @Min_R_E_C_N_O_ = MIN(R_E_C_N_O_), @Max_R_E_C_N_O_ = MAX(R_E_C_N_O_)
FROM SA1010

SET @Loop = @Min_R_E_C_N_O_

SELECT @Min_R_E_C_N_O_,@Max_R_E_C_N_O_

SET NOCOUNT ON

WHILE @Loop <= @Max_R_E_C_N_O_
BEGIN

	INSERT INTO SA1010([A1_FILIAL], [A1_COD], [A1_LOJA], [A1_NOME], [A1_PESSOA], [A1_END], [A1_NREDUZ], [A1_BAIRRO], [A1_TIPO], [A1_EST], [A1_ESTADO], [A1_CEP], [A1_CGC], [D_E_L_E_T_], [R_E_C_N_O_], [R_E_C_D_E_L_])
	SELECT [A1_FILIAL], @Max_R_E_C_N_O_+R_E_C_N_O_, [A1_LOJA], [A1_NOME], [A1_PESSOA], [A1_END], [A1_NREDUZ], [A1_BAIRRO], [A1_TIPO], [A1_EST], [A1_ESTADO], [A1_CEP], [A1_CGC], [D_E_L_E_T_], @Max_R_E_C_N_O_+R_E_C_N_O_, [R_E_C_D_E_L_]
	FROM SA1010
	WHERE [R_E_C_N_O_] >= @Loop AND [R_E_C_N_O_] < @Loop + 20000 

	set @Loop = @Loop + 20000 --intervalo
	
	--PRINT @Loop
	
	-- WAITFOR delay '00:00:00:200' -- esse tempo voce define de acordo com a criticidade do seu ambiente e horário que está executando
END

-- Testar uma consulta no SSMS e 50 no SQLQueryStress
SELECT *
FROM dbo.SA1010 
WHERE R_E_C_N_O_ = 50


-- Conferir o que já tinha sido inserido
SELECT COUNT(*) FROM SA1010 (NOLOCK)

/*
DELETE FROM SA1010
WHERE [R_E_C_N_O_] > 10000000
*/


/************************************		FIM DEMO INSERT				******************************************/



/************************************		INICIO DEMO UPDATE			******************************************/

/*
-- Rollback testes
UPDATE  SA1010
set D_E_L_E_T_ = ''
WHERE D_E_L_E_T_ = '*'

*/

-- Fazer um updade de 1 milhão de registros da coluna D_E_L_E_T_ para *
UPDATE TOP (2000000) SA1010
set D_E_L_E_T_ = '*'
WHERE D_E_L_E_T_ = ''


-- Testar uma consulta no SSMS e 50 no SQLQueryStress
SELECT *
FROM dbo.SA1010 
WHERE R_E_C_N_O_ = 50



IF OBJECT_ID('_UPDATE_TABELA_BLOCO') IS NOT NULL
	DROP TABLE _UPDATE_TABELA_BLOCO

SELECT TOP 2000000 R_E_C_N_O_
INTO _UPDATE_TABELA_BLOCO
FROM SA1010
WHERE D_E_L_E_T_ = ''

create unique clustered index pk_UPDATE_TABELA_BLOCO on _UPDATE_TABELA_BLOCO(R_E_C_N_O_)

SET NOCOUNT ON

declare @Loop INT, @min INT, @max int

select @min = MIN(R_E_C_N_O_), @max = MAX(R_E_C_N_O_)
from _UPDATE_TABELA_BLOCO

set @Loop = @min --min

while @Loop <= @max --max
begin
	DELETE B
	from _UPDATE_TABELA_BLOCO A
		join SA1010 B on A.R_E_C_N_O_ = B.R_E_C_N_O_
	where A.R_E_C_N_O_ >= @Loop and A.R_E_C_N_O_ <= @Loop + 50000
	
	set @Loop = @Loop + 50000 --intervalo
--	print @Loop
	--waitfor delay '00:00:01'
end



/************************************		FIM DEMO UPDATE			******************************************/




/************************************		INICIO DEMO DELETE			******************************************/


DELETE TOP (2000000) FROM SA1010
WHERE D_E_L_E_T_ = ''


-- Testar uma consulta no SSMS e 50 no SQLQueryStress
SELECT *
FROM dbo.SA1010 
WHERE R_E_C_N_O_ = 50



IF OBJECT_ID('_DELETE_TABELA_BLOCO') IS NOT NULL
	DROP TABLE _DELETE_TABELA_BLOCO

SELECT TOP 2000000 R_E_C_N_O_
INTO _DELETE_TABELA_BLOCO
FROM SA1010
WHERE D_E_L_E_T_ = ''

create unique clustered index pk_DELETE_TABELA_BLOCO on _DELETE_TABELA_BLOCO(R_E_C_N_O_)


SET NOCOUNT ON
declare @Loop INT, @min INT, @max int

select @min = MIN(R_E_C_N_O_), @max = MAX(R_E_C_N_O_)
from _DELETE_TABELA_BLOCO

set @Loop = @min --min

while @Loop <= @max --max
begin
	update B
	set B.D_E_L_E_T_ = '*'
	from _DELETE_TABELA_BLOCO A
		join SA1010 B on A.R_E_C_N_O_ = B.R_E_C_N_O_
	where A.R_E_C_N_O_ >= @Loop and A.R_E_C_N_O_ <= @Loop + 50000
	
	set @Loop = @Loop + 50000 --intervalo
	print @Loop
	--waitfor delay '00:00:01'
end



/************************************		FIM DEMO DELETE			******************************************/

