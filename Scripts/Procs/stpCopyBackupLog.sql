ALTER procedure  stpCopyBackupLog
as

set nocount on
declare @caminho_copia varchar(max) = '\\10.0.1.40\Backup\Log'
		,@string varchar(8000)
		,@database sysname

select	--top 1
		db.name
		,x.caminho
	into #temp
	from 
		sys.databases db
	cross apply(			
			SELECT	top 1 backup_start_date, 'E:\Backup\Log\'+ database_name + '\' + name + '.trn' caminho		
			FROM msdb.dbo.backupset B
				  INNER JOIN msdb.dbo.backupmediafamily BF ON B.media_set_id = BF.media_set_id
			where 1=1			
			and type in ('L')
			and database_name = db.name
			order by backup_start_date desc
	)x
	where 
		db.recovery_model_desc <> 'SIMPLE'



-- FLAG DE CONTROLE DO CMDSHELL
DECLARE @Fl_Habilitar_CMDSHELL BIT = 0

-- SE A OPÇÃO CMDSHELL ESTIVER DESABILITADA, IRA HABILITAR TEMPORARIAMENTE E DESABILITAR DEPOIS
IF	(
		select value_in_use
		from sys.configurations
		where name in(	'xp_cmdshell')
	) = 0
BEGIN
	-- MARCA A FLAG PARA DESABILITAR O CMDSHELL NO FINAL DO SCRIPT
	SELECT @Fl_Habilitar_CMDSHELL = 1

	EXEC sp_configure 'advanced options', 1
	RECONFIGURE
	
	EXEC sp_configure 'xp_cmdshell', 1
	RECONFIGURE
END

CREATE TABLE #TEMP2 (
	retorno varchar(8000)
)

while (select count(1) from #temp) > 0	
begin
	select top 1 @database = name, @caminho_copia = caminho from #temp order by name
	
	set @string = 'xcopy "'+@caminho_copia+'" "\\10.0.1.40\Backup\Log\'+@database +'\"'

	INSERT INTO #TEMP2
	EXEC master.dbo.xp_cmdshell @string

	delete from #temp  where caminho = @caminho_copia
end



-- DESABILITA O OPÇÃO DO CMDSHELL
IF (@Fl_Habilitar_CMDSHELL = 1)
BEGIN
	EXEC sp_configure 'advanced options', 1
	RECONFIGURE

	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE

	EXEC sp_configure 'advanced options', 0
	RECONFIGURE
END
