SELECT serverproperty('SERVERNAME') [SERVIDOR], convert(varchar(10),GETDATE(),103) + ' '+ 
convert(varchar(10),GETDATE(),108) [DATA E HORA ATUAL]
GO
SELECT 'A INSTANCIA POSSUI N°' + '' + convert(char(3),COUNT(*)) + ' '+'LOCK(S) ATUALMENTE' [CONTADOR DE LOCK] 
FROM SYS.DM_EXEC_REQUESTS 
WHERE blocking_session_id <> 0
go

SELECT 
	 DATEDIFF(MINUTE,start_time,GETDATE()) [TEMPO EM MINUTOS DO LOCK],
	Session_ID, Blocking_Session_id As Blocking_ID, 
	(SELECT NAME FROM SYS.DATABASES WHERE DATABASE_ID='5') AS 'Database', 
	Start_time, Status, Command
FROM 
	SYS.DM_EXEC_REQUESTS 
WHERE 
	BLOCKING_SESSION_ID <> 0 ORDER BY start_time 
