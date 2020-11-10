SELECT [SQL Server Start Time] = CONVERT(VARCHAR(23), a.sql_start, 121),
       [SQL Agent Start Time] = CONVERT(VARCHAR(23), a.agent_start, 121),
       [SQL Uptime] = CONVERT(VARCHAR(15),
                      RIGHT(10000000+Datediff(dd, 0, Getdate()-a.sql_start), 4)
                      + ' '
                      + CONVERT(VARCHAR(20), Getdate()-a.sql_start, 108)),
       [Agent Uptime] = CONVERT(VARCHAR(15),
RIGHT(10000000+Datediff(dd, 0, Getdate()-a.agent_start), 4)
+ ' '
+ CONVERT(VARCHAR(20), Getdate()-a.agent_start, 108))
FROM   (SELECT SQL_Start = Min(aa.login_time),
               Agent_Start = NULLIF(Min(CASE
                                          WHEN aa.program_name LIKE 'SQLAgent %'
                                        THEN
                                          aa.login_time
                                          ELSE '99990101'
                                        END), CONVERT(DATETIME, '99990101'))
        FROM   master.dbo.sysprocesses aa
        WHERE  aa.login_time > '20000101') a 
		
		
		
========================================================================================================		
		
		
SET NOCOUNT ON
DECLARE
@crdate DATETIME
, @days VARCHAR(3)
, @hr VARCHAR(50)
, @min VARCHAR(5)

SELECT @crdate=crdate FROM master.dbo.sysdatabases WHERE NAME='tempdb'

SELECT @days=((DATEDIFF ( mi, @crdate,GETDATE()))/60)/24

SELECT @hr=((DATEDIFF ( mi, @crdate,GETDATE()))/60)- (@days * 24)

IF ((DATEDIFF ( mi, @crdate,GETDATE()))/60)=0
SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))
ELSE
SELECT @min=(DATEDIFF ( mi, @crdate,GETDATE()))-((DATEDIFF( mi, @crdate,GETDATE()))/60)*60

PRINT 'SQL Server ' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME'))+' is Online for the past '
+@days+' days & '
+@hr+' hours & '
+@min+' minutes'

IF NOT EXISTS (SELECT 1 FROM master.dbo.sysprocesses WHERE program_name = N'SQLAgent – Generic Refresher')
BEGIN
PRINT 'SQL Server is running but SQL Server Agent running'
END
ELSE
BEGIN
PRINT 'SQL Server and SQL Server Agent both are running'
END


========================================================================================================


DECLARE @MasterPath nvarchar(512);
DECLARE @LogPath nvarchar(512);
DECLARE @ErrorLog nvarchar(512);
DECLARE @ErrorLogPath nvarchar(512);

SELECT @MasterPath=substring(physical_name, 1, len(physical_name) - charindex('\', reverse(physical_name))) 
FROM master.sys.database_files 
WHERE name=N'master';

SELECT @LogPath=substring(physical_name, 1, len(physical_name) - charindex('\', reverse(physical_name))) 
FROM master.sys.database_files 
WHERE name=N'mastlog';

SELECT @ErrorLog=cast(SERVERPROPERTY(N'errorlogfilename') as nvarchar(512));

SELECT @ErrorLogPath=substring(@ErrorLog, 1, len(@ErrorLog) - charindex('\', reverse(@ErrorLog)));

DECLARE @SmoRoot nvarchar(512);
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
    , N'SOFTWARE\Microsoft\MSSQLServer\Setup'
    , N'SQLPath'
    , @SmoRoot OUTPUT;

IF OBJECT_ID('tempdb..#tmp_sp_get_sqlagent_properties') IS NOT NULL
DROP TABLE #tmp_sp_get_sqlagent_properties;
CREATE TABLE #tmp_sp_get_sqlagent_properties
(
    auto_start int null
    , msx_server_name sysname null
    , sqlagent_type int null
    , startup_account nvarchar(255) null
    , sqlserver_restart int null
    , jobhistory_max_rows int null
    , jobhistory_max_rows_per_job int null
    , errorlog_file nvarchar(255) null
    , errorlogging_level int null
    , error_recipient nvarchar(30) null
    , monitor_autostart int null
    , local_host_server sysname null
    , job_shutdown_timeout int null
    , cmdexec_account varbinary(64) null
    , regular_connections int null
    , host_login_name sysname null
    , host_login_password varbinary(512) null
    , login_timeout int null
    , idle_cpu_percent int null
    , idle_cpu_duration int null
    , oem_errorlog int null
    , sysadmin_only int null
    , email_profile nvarchar(64) null
    , email_save_in_sent_folder int null
    , cpu_poller_enabled int null
    , replace_alert_tokens_enabled int null
);

INSERT INTO #tmp_sp_get_sqlagent_properties
(
    auto_start
    , msx_server_name
    , sqlagent_type
    , startup_account
    , sqlserver_restart
    , jobhistory_max_rows
    , jobhistory_max_rows_per_job
    , errorlog_file
    , errorlogging_level
    , error_recipient
    , monitor_autostart
    , local_host_server
    , job_shutdown_timeout
    , cmdexec_account
    , regular_connections
    , host_login_name
    , host_login_password
    , login_timeout
    , idle_cpu_percent
    , idle_cpu_duration
    , oem_errorlog
    , sysadmin_only
    , email_profile
    , email_save_in_sent_folder
    , cpu_poller_enabled
    , replace_alert_tokens_enabled
)
EXEC msdb.dbo.sp_get_sqlagent_properties;

DECLARE @DatabaseMailProfile nvarchar(255);
DECLARE @AgentMailType int;
DECLARE @ServiceStartMode int;
DECLARE @ServiceAccount nvarchar(512);
DECLARE @AgtGroup nvarchar(512);

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
    , N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent'
    , N'DatabaseMailProfile'
    , @param = @DatabaseMailProfile OUT
    , @no_output = N'no_output';

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
    , N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent'
    , N'UseDatabaseMail'
    , @param = @AgentMailType OUT
    , @no_output = N'no_output';

EXEC master.sys.xp_instance_regread 'HKEY_LOCAL_MACHINE'
    , 'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT'
    , N'Start'
    , @ServiceStartMode OUTPUT;

EXEC master.sys.xp_instance_regread 'HKEY_LOCAL_MACHINE'
    , 'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT'
    , N'ObjectName'
    , @ServiceAccount OUTPUT;

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
    , N'SOFTWARE\Microsoft\MSSQLServer\Setup'
    , N'AGTGroup'
    , @AgtGroup OUTPUT;

SELECT Items.*
FROM #tmp_sp_get_sqlagent_properties AS tsgsp
CROSS APPLY (VALUES 
     ('Name', CAST(serverproperty(N'ServerName') AS sql_variant))
    , ('MsxServerName', ISNULL(tsgsp.msx_server_name,N''))
    , ('JobServerType', CONVERT(sql_variant, tsgsp.sqlagent_type))
    , ('SqlServerRestart', CONVERT(sql_variant, tsgsp.sqlserver_restart))
    , ('SqlAgentRestart', CONVERT(sql_variant, tsgsp.monitor_autostart))
    , ('MaximumHistoryRows', CONVERT(sql_variant, tsgsp.jobhistory_max_rows))
    , ('MaximumJobHistoryRows', CONVERT(sql_variant, tsgsp.jobhistory_max_rows_per_job))
    , ('ErrorLogFile', CONVERT(sql_variant, tsgsp.errorlog_file))
    , ('AgentLogLevel', CONVERT(sql_variant, tsgsp.errorlogging_level))
    , ('NetSendRecipient', CONVERT(sql_variant, ISNULL(tsgsp.error_recipient,N'')))
    , ('AgentShutdownWaitTime', CONVERT(sql_variant, tsgsp.job_shutdown_timeout))
    , ('SqlAgentMailProfile', CONVERT(sql_variant, ISNULL(tsgsp.email_profile,N'')))
    , ('SaveInSentFolder', CONVERT(sql_variant, CAST(tsgsp.email_save_in_sent_folder AS bit)))
    , ('WriteOemErrorLog', CONVERT(sql_variant, CAST(tsgsp.oem_errorlog AS bit)))
    , ('IsCpuPollingEnabled', CONVERT(sql_variant, CAST(tsgsp.cpu_poller_enabled AS bit)))
    , ('IdleCpuPercentage', CONVERT(sql_variant, tsgsp.idle_cpu_percent))
    , ('IdleCpuDuration', CONVERT(sql_variant, tsgsp.idle_cpu_duration))
    , ('LoginTimeout', CONVERT(sql_variant, tsgsp.login_timeout))
    , ('HostLoginName', CONVERT(sql_variant, ISNULL(tsgsp.host_login_name,N'')))
    , ('LocalHostAlias', CONVERT(sql_variant, ISNULL(tsgsp.local_host_server,N'')))
    , ('SqlAgentAutoStart', CONVERT(sql_variant, tsgsp.auto_start))
    , ('ReplaceAlertTokensEnabled', CONVERT(sql_variant, tsgsp.replace_alert_tokens_enabled))
    , ('DatabaseMailProfile', CONVERT(sql_variant, ISNULL(@DatabaseMailProfile,N'')))
    , ('AgentMailType', CONVERT(sql_variant, ISNULL(@AgentMailType, 0)))
    , ('SysAdminOnly', CONVERT(sql_variant, 1))
    , ('ServiceStartMode', CONVERT(sql_variant, @ServiceStartMode))
    , ('ServiceAccount', CONVERT(sql_variant, ISNULL(@ServiceAccount,N'')))
    , ('AgentDomainGroup', CONVERT(sql_variant, ISNULL(suser_sname(sid_binary(ISNULL(@AgtGroup,N''))),N'')))
    )Items(ItemName, ItemValue)
UNION ALL
SELECT Items.* 
FROM (VALUES 
      ('IsCaseSensitive', CAST(case when 'a' <> 'A' then 1 else 0 end AS bit))
    , ('MaxPrecision', @@MAX_PRECISION)
    , ('ErrorLogPath', @ErrorLogPath)
    , ('RootDirectory', @SmoRoot)
    , ('IsFullTextInstalled', CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS bit))
    , ('MasterDBLogPath', @LogPath)
    , ('MasterDBPath', @MasterPath)
    , ('VersionString', SERVERPROPERTY(N'ProductVersion'))
    , ('Edition', CAST(SERVERPROPERTY(N'Edition') AS sysname))
    , ('ProductLevel', CAST(SERVERPROPERTY(N'ProductLevel') AS sysname))
    , ('IsSingleUser', CAST(SERVERPROPERTY('IsSingleUser') AS bit))
    , ('EngineEdition', CAST(SERVERPROPERTY('EngineEdition') AS int))
    , ('Collation', convert(sysname, serverproperty(N'collation')))
    , ('NetName', CAST(SERVERPROPERTY(N'MachineName') AS sysname))
    , ('IsClustered', CAST(SERVERPROPERTY('IsClustered') AS bit))
    , ('ResourceVersionString', SERVERPROPERTY(N'ResourceVersion'))
    , ('ResourceLastUpdateDateTime', SERVERPROPERTY(N'ResourceLastUpdateDateTime'))
    , ('CollationID', SERVERPROPERTY(N'CollationID'))
    , ('ComparisonStyle', SERVERPROPERTY(N'ComparisonStyle'))
    , ('SqlCharSet', SERVERPROPERTY(N'SqlCharSet'))
    , ('SqlCharSetName', SERVERPROPERTY(N'SqlCharSetName'))
    , ('SqlSortOrder', SERVERPROPERTY(N'SqlSortOrder'))
    , ('SqlSortOrderName', SERVERPROPERTY(N'SqlSortOrderName'))
    , ('BuildClrVersionString', SERVERPROPERTY(N'BuildClrVersion'))
    , ('ComputerNamePhysicalNetBIOS', SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS'))
    )Items(ItemName, ItemValue)
ORDER BY Items.ItemName;
