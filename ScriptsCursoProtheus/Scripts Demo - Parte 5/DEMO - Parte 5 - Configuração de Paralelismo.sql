

EXEC sys.sp_configure N'max degree of parallelism', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO

SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CI_AI LIKE '%Fabricio Lima%'
GO

-- Abrir o SQLQueryStress
--https://www.microsoft.com/pt-br/p/sqlquerystress/9n46qj5sbgkb?activetab=pivot:overviewtab

--Usar essa query:
SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CI_AI LIKE '%Fabricio Lima%'
SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CI_AI LIKE '%Fabricio Lima%'
SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CI_AI LIKE '%Fabricio Lima%'
SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CI_AI LIKE '%Fabricio Lima%'


--Testar o select no SQLQueryStress com 1 threads

--Alterar o paralelismo para 8
EXEC sys.sp_configure N'max degree of parallelism', N'8'
GO
RECONFIGURE WITH OVERRIDE
GO

SELECT COUNT(*)
FROM SA1010
WHERE A1_NOME COLLATE Latin1_General_CI_AI LIKE '%Fabricio Lima%'
GO


--Testar novamente após a mudança do paralelismo: com 1 threads


--Testar novamente com 2 threads


--Alterar o paralelismo para 4
EXEC sys.sp_configure N'max degree of parallelism', N'4'
GO
RECONFIGURE WITH OVERRIDE
GO

--Testar novamente com 2 threads

--Testar novamente com 4 threads


--Alterar o paralelismo para 2
EXEC sys.sp_configure N'max degree of parallelism', N'2'
GO
RECONFIGURE WITH OVERRIDE
GO

--Testar novamente com 4 threads


--Alterar o paralelismo para 2
EXEC sys.sp_configure N'max degree of parallelism', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO

--Testar novamente com 4 threads