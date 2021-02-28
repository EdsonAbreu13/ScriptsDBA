select DATEDIFF (minute, fim, getdate()) "Ultimo BKP EXEC há (minutos)", * from (
select max (backup_start_date) inicio, max (backup_finish_date) fim, database_name, type
from msdb..backupset where type = 'L' and database_name not in ('DADOS_TST')
group by database_name, type) a