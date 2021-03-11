--create index ixtemp on  msdb..backupset(database_name,type,is_copy_only) with(data_compression = page)
--criar uma lista de bancos  a serem restaurados numa tabela com o nome BasesRestore coluna name.
--        Vc pode criar um temporaria e trocar no script... pra evitar trabalho, o mais importante ? manter a coluna "name".

 

DECLARE 
    @BackupPath nvarchar(max) = 'D:\F\DEALERNETWF'
    ,@ReplacePath nvarchar(max) = 'F:\DEALERNETWF'

 

SELECT
     DatabaseName = R.name
    ,Lastull = b.backup_finish_date
    ,LastDiff = d.backup_finish_date
    ,LastLog = LastLog.LastLog
    ,FullRestoreSql = 'RESTORE DATABASE '+quotename(r.name)+' from disk = '''+b.FullRestorePath+''' WITH NORECOVERY,stats = 10'
    ,FullRestoreDiff = 'RESTORE DATABASE '+quotename(r.name)+' from disk = '''+d.DiffRestorePath+''' WITH NORECOVERY,stats = 10'
    ,LogsRestore = L.restoreslog
FROM
    BasesRestore R
    CROSS APPLY (
        select top 1  bs.backup_finish_date,backup_set_id
        ,FullRestorePath = REpLACE(f.physical_device_name,@ReplacePath,@BackupPath)
        From msdb..backupset bs
        join msdb..backupmediafamily f
            on f.media_set_id = bs.media_set_id
        
        where type = 'D' and database_name = R.name
        and  is_copy_only = 0
        order by backup_set_id desc
    ) b
    OUTER APPLY (
        select top 1  bs.backup_finish_date,backup_set_id
        ,DiffRestorePath = REpLACE(f.physical_device_name,@ReplacePath,@BackupPath)
        From msdb..backupset bs
        join msdb..backupmediafamily f
            on f.media_set_id = bs.media_set_id
        
        where type = 'I' and database_name = R.name
        and backup_set_id > b.backup_set_id
        and  is_copy_only = 0
        order by backup_set_id desc
    ) d
    outer APPLY (
        select 
            [data()] = 'RESTORE LOG '+quotename(r.name)+' from disk = '''+LogRestorePath+''' WITH NORECOVERY,stats = 10'+CHAR(13)+CHAR(10)
        from (
        select   bs.backup_finish_date
        ,LogRestorePath = REpLACE(f.physical_device_name,@ReplacePath,@BackupPath)
        From msdb..backupset bs
        join msdb..backupmediafamily f
            on f.media_set_id = bs.media_set_id
        
        where type = 'L' and database_name = R.name
        and  is_copy_only = 0
        AND backup_set_id > isnull(d.backup_set_id,b.backup_set_id)
        ) rl
        order by backup_finish_date
        FOR XML PATH(''),type
    ) l(restoreslog)
    outer APPLY (
        select  top 1 LastLog = bs.backup_finish_date
        From msdb..backupset bs
        join msdb..backupmediafamily f
            on f.media_set_id = bs.media_set_id
        
        where type = 'L' and database_name = R.name
        and  is_copy_only = 0
        AND backup_set_id > b.backup_set_id
        order by backup_set_id desc
    ) LastLog