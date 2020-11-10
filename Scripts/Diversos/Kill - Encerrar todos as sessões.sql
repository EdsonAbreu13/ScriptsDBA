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
