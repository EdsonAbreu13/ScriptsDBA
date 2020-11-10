use Curso_Protheus

SELECT TOP 50 *  FROM [dbo].SA1010

UPDATE SA1010
SET A1_NOME = 'Fabricio Lima'
WHERE R_E_C_N_O_ = 50

CREATE NONCLUSTERED INDEX SA1010W04 ON SA1010(A1_NOME) 

sp_spaceused SA1010

SET STATISTICS TIME ON
-- CTRL+M

SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_BIN LIKE '%Fabricio Lima%'
GO
SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CS_AS LIKE '%Fabricio Lima%'
GO
SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%Fabricio Lima%'
GO  



SELECT 3016/21000.00

--Obs.:
-- Se usar uma coluna Nvarchar ao invés de varchar, isso não acontece. O tempo é o mesmo.


-- link referência explicando um pouco do motivo disso acontecer.
-- https://support.microsoft.com/en-us/help/322112/comparing-sql-collations-to-windows-collations

--Post sobre o assunto
https://www.fabriciolima.net/blog/2017/02/08/improve-the-query-performance-with-like-string-changing-only-the-collation/