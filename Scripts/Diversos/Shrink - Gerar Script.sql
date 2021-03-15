DECLARE  @base varchar(max) = 'StackOverflow2010'		-- Nome da base, ou NULL para gerar de todas as bases
		,@system_databases bit = 0						-- Caso queira gerar script para bases de sistema tambem, informe NULL no parametro anterior e 1 neste parametro
		,@intervalo_reducao int = 50					-- Intervalo em MB que deseja gerar o shrink

SET NOCOUNT ON;


IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
	DROP TABLE #TEMP

IF OBJECT_ID('tempdb..#ESPACO_DATABASES') IS NOT NULL
	DROP TABLE #ESPACO_DATABASES

CREATE TABLE #ESPACO_DATABASES (
	DRIVE CHAR(1)
	,BASE SYSNAME
	,GROUP_ID BIT
	,TAMANHO_ARQUIVO DECIMAL(15, 2)
	,ESPACO_UTILIZADO DECIMAL(15, 2)
	,ESPACO_LIVRE DECIMAL(15, 2)
	,ARQUIVO VARCHAR(100)
	,CAMINHO_ARQUIVO VARCHAR(255)
	)
	

INSERT INTO #ESPACO_DATABASES
	EXEC master.sys.sp_MSforeachdb ' USE [?];
	   SELECT  SUBSTRING(A.FILENAME, 1, 1) AS DRIVE
		  ,''[?]'' AS BASE
		  ,GROUPID AS GROUP_ID
		  ,CONVERT(DECIMAL(12, 2), ROUND(A.SIZE / 128.000, 2)) AS TAMANHO_ARQUIVO
		  ,CONVERT(DECIMAL(12, 2), ROUND(FILEPROPERTY(A.NAME, ''SPACEUSED'') / 128.000, 2)) AS ESPACO_UTILIZADO
		  ,CONVERT(DECIMAL(12, 2), ROUND((A.SIZE - FILEPROPERTY(A.NAME, ''SPACEUSED'')) / 128.000, 2)) AS ESPACO_LIVRE
		  ,A.NAME AS ARQUIVO
		  ,A.FILENAME AS CAMINHO_ARQUIVO
		FROM dbo.sysfiles A
		ORDER BY BASE, GROUPID DESC, ARQUIVO
			,DRIVE
	   '

IF @system_databases = 0 DELETE FROM #ESPACO_DATABASES WHERE  (BASE) IN ('[master]','[model]','[msdb]','[tempdb]')
IF @base IS NOT NULL DELETE FROM #ESPACO_DATABASES WHERE  (BASE) <> QUOTENAME(@base)
ALTER TABLE #ESPACO_DATABASES ADD ID INT IDENTITY

SELECT *,ROW_NUMBER() OVER (PARTITION BY BASE, GROUP_ID ORDER BY BASE, GROUP_ID DESC, ARQUIVO) RNK INTO #TEMP FROM #ESPACO_DATABASES t 

SELECT * FROM #TEMP ORDER BY BASE, GROUP_ID DESC, ARQUIVO

DECLARE @arquivo varchar(max)
		,@id int
		,@controle_reducao int
		,@espaco_livre int
		,@espaco_min INT
		,@espaco_alocado int

WHILE (SELECT COUNT(1) FROM #TEMP) > 0
	BEGIN
		SELECT TOP 1 @base = BASE, @id = ID, @arquivo = ARQUIVO, @espaco_alocado = FLOOR(TAMANHO_ARQUIVO), @espaco_min=FLOOR(ESPACO_UTILIZADO), @controle_reducao=FLOOR(TAMANHO_ARQUIVO),@espaco_livre=FLOOR(ESPACO_LIVRE) FROM #TEMP ORDER BY BASE, GROUP_ID DESC, ARQUIVO
		PRINT 'USE ' + @base +'
GO'
		PRINT ''
		PRINT '--ESPAÇO ALOCADO: ' + CAST(@espaco_alocado AS VARCHAR(10)) + 'MB'
		PRINT '--ESPAÇO UTILIZADO: ' + CAST(@espaco_min AS VARCHAR(10)) + 'MB'
		PRINT ''


		IF @espaco_alocado - @espaco_min > @intervalo_reducao
		BEGIN
			WHILE @controle_reducao > @espaco_min + @intervalo_reducao
			BEGIN
				SET @controle_reducao = @controle_reducao - @intervalo_reducao
				PRINT 'DBCC SHRINKFILE (N'''+@arquivo+''', '+CAST(@controle_reducao AS VARCHAR(10))+')
GO'				
			END
		END
		PRINT ''
		PRINT '--ESPAÇO LIVRE APOS SHRINK: ' + CAST(@controle_reducao - @espaco_min AS VARCHAR(10)) + 'MB'
		PRINT ''
		PRINT ''
		PRINT ''
		
		DELETE FROM #TEMP WHERE ID = @id
END

