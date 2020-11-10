-- Verificar histórico de leituras de log do Log Reader
-- dessa forma conseguimos identificar picos onde muitas transação são lidas e entram pra serem processadas
select * from Distribution..MSlogreader_history


--VERIFICAR STATUS DE SINCRONIZAÇÃO AWAYS ON
select @@SERVERNAME Servidor, b.name, a.last_hardened_lsn, b.log_reuse_wait_desc, synchronization_state_desc, log_send_queue_size, redo_queue_size from sys.dm_hadr_database_replica_states a
 inner join sys.databases b on a.database_id = b.database_id
 where  b.name like '%KurierTribunal2'

select ag.name
 , ags.primary_replica
 , db_name(drs.database_id) as database_name
 , rcs.replica_server_name
 , drs.synchronization_health_desc
 , drs.synchronization_state_desc
 , drs.log_send_queue_size
 , drs.log_send_rate
 , drs.redo_queue_size
 , drs.redo_rate
 , drs.last_received_time
 , drs.last_redone_time
 from sys.availability_groups ag
 inner join sys.dm_hadr_availability_group_states ags on ags.group_id = ag.group_id
 inner join sys.dm_hadr_database_replica_states drs on drs.group_id = ag.group_id
 inner join sys.dm_hadr_availability_replica_cluster_states rcs on rcs.replica_id = drs.replica_id
 where db_name(drs.database_id) = 'KurierTribunal2'
 order by drs.redo_queue_size desc


 
-- REDO LAG
;WITH 
    AG_Stats AS 
            (
            SELECT AR.replica_server_name,
                   HARS.role_desc, 
                   Db_name(DRS.database_id) [DBName], 
                   DRS.redo_queue_size redo_queue_size_KB,
                   DRS.redo_rate redo_rate_KB_Sec
            FROM   sys.dm_hadr_database_replica_states DRS 
            INNER JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id 
            INNER JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id 
                AND AR.replica_id = HARS.replica_id 
            ),
    Pri_CommitTime AS 
            (
            SELECT    replica_server_name
                    , DBName
                    , redo_queue_size_KB
                    , redo_rate_KB_Sec
            FROM    AG_Stats
            WHERE    role_desc = 'PRIMARY'
            ),
    Sec_CommitTime AS 
            (
            SELECT    replica_server_name
                    , DBName
                    --Send queue and rate will be NULL if secondary is not online and synchronizing
                    , redo_queue_size_KB
                    , redo_rate_KB_Sec
            FROM    AG_Stats
            WHERE    role_desc = 'SECONDARY'
            )
SELECT p.replica_server_name [primary_replica]
    , p.[DBName] AS [DatabaseName]
    , s.replica_server_name [secondary_replica]
    , CAST(s.redo_queue_size_KB / s.redo_rate_KB_Sec AS BIGINT) [Redo_Lag_Secs]
    , (CAST(s.redo_queue_size_KB / s.redo_rate_KB_Sec AS BIGINT))/60.0 [Redo_Lag_mins]
FROM Pri_CommitTime p
LEFT JOIN Sec_CommitTime s ON [s].[DBName] = [p].[DBName]
WHERE p.[DBName] = 'KurierTribunal2'

