--PEGAR NOME DOS ARQUIVOS E CAMINHO
SELECT name,
physical_name AS CurrentLocation,
state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N’MSDB’);


--SETAR NOVO CAMINHO
ALTER DATABASE msdb
MODIFY FILE (NAME = MSDBData, FILENAME = ‘E:\SQlData\MSDBData.mdf’);
GO
ALTER DATABASE msdb
MODIFY FILE (NAME = MSDBLog, FILENAME = ‘F:\SQLLogs\MSDBLog.ldf’);
GO




-- COPIAR ARQUIVOS PARA NOVO LOCAL

-- STARTAR SQL

--VERIFICAR STATUS
SELECT name,
physical_name AS CurrentLocation,
state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N’MSDB’);


-- APÓS TUDO OK, APAGAR OS ARQUIVOS ANTIGOS 

-- VERIFICAR BACKUP
