--------------------------------------------------------------------------------------------------------------------------------
Executando um Restore por cima dessa database
--------------------------------------------------------------------------------------------------------------------------------
--	Restore por cima de uma database já existente
RESTORE DATABASE TreinamentoDBA
FROM DISK = 'C:\TEMP\TreinamentoDBA_Dados.bak'
WITH RECOVERY, REPLACE, STATS = 5

--------------------------------------------------------------------------------------------------------------------------------
--	5.2)	Realizando um Restore de uma database que ainda não existe
-------------------------------------------------------------------------------------------------------------------------------
USE MASTER 

--	Exclui a database caso ela já exista
IF DATABASEPROPERTYEX (N'TreinamentoDBA_TesteRestore', N'Version') > 0
BEGIN
	ALTER DATABASE TreinamentoDBA_TesteRestore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TreinamentoDBA_TesteRestore;
END

--	Apenas para validar o nome lógico dos arquivos de dados e logs
RESTORE FILELISTONLY
FROM DISK = 'C:\TEMP\TreinamentoDBA_Dados.bak'

-- Restore criando uma nova database
RESTORE DATABASE TreinamentoDBA_TesteRestore
FROM DISK = 'C:\TEMP\TreinamentoDBA_Dados.bak'
WITH RECOVERY,STATS = 1,
MOVE 'TreinamentoDBA' TO 'C:\TEMP\TreinamentoDBA_TesteRestore.mdf',
MOVE 'TreinamentoDBA_log' TO 'C:\TEMP\TreinamentoDBA_TesteRestore_Log.ldf'


--
-- Mata as Conexões da Database

DECLARE @SPID AS VARCHAR(5) 
IF( Object_id('tempdb..#Processos') IS NOT NULL )
  DROP TABLE #processos
SELECT Cast(spid AS VARCHAR(5)) AS spid 
INTO   #processos 
FROM   master.dbo.sysprocesses A 
       JOIN master.dbo.sysdatabases B 
         ON A.dbid = B.dbid 
WHERE  B.NAME = 'base' 
       AND spid > 50 -- APENAS PROCESSOS DE USUARIO 
-- SELECT * FROM #Processos 

WHILE ( (SELECT Count(*)
         FROM   #processos) > 0 ) 
BEGIN
      SET @SPID = (SELECT TOP 1 spid
                            FROM   #processos) 
      EXEC ('Kill ' + @SPID) 
      DELETE FROM #processos 
      WHERE  spid = @SPID 
  END

