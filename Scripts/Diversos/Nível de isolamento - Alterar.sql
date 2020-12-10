SELECT    NAME
,CASE is_read_committed_snapshot_on
             WHEN 1 THEN 'ENABLED'
             WHEN 0 THEN 'DISABLED'
         END
AS 'Read_Committed_Snapshot'
FROM SYS.DATABASES
WHERE NAME = 'DEMO_RCSI'

--De <https://edvaldocastro.com/rcsi-2/> 



USE master
ALTER DATABASE DEMO_RCSI SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE