SELECT	database_name, name,backup_start_date, datediff(mi, backup_start_date, backup_finish_date) [tempo (min)],
		position, server_name, recovery_model, isnull(logical_device_name, ' ') logical_device_name, device_type, 
		type, cast(backup_size/1024/1024 as numeric(15,2)) [Tamanho (MB)]
FROM msdb.dbo.backupset B
	  INNER JOIN msdb.dbo.backupmediafamily BF ON B.media_set_id = BF.media_set_id
where 1=1
--  and backup_start_date >=  dateadd(hh, -24 ,getdate()  )
--  and type in ('D','I')
 and database_name = ''
order by backup_start_date desc



SELECT TOP 1 physical_device_name AS BackupLocation
    ,CASE WHEN [TYPE]='D' THEN 'FULL'
    WHEN [TYPE]='I' THEN 'DIFFERENTIAL'
    WHEN [TYPE]='L' THEN 'LOG'
    WHEN [TYPE]='F' THEN 'FILE / FILEGROUP'
    WHEN [TYPE]='G'  THEN 'DIFFERENTIAL FILE'
    WHEN [TYPE]='P' THEN 'PARTIAL'
    WHEN [TYPE]='Q' THEN 'DIFFERENTIAL PARTIAL'
  END AS BackupType
    ,backup_finish_date AS BackupFinishDate
FROM msdb.dbo.backupset JOIN msdb.dbo.backupmediafamily
ON(backupset.media_set_id=backupmediafamily.media_set_id)
Where database_name Like 'Traces'
ORDER BY backup_finish_date DESC