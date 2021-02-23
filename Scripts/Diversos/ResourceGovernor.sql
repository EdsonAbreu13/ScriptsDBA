USE master
GO

-- Habilita o Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- DROP RESOURCE POOL ResourcePool_QlikSenseView
CREATE RESOURCE POOL ResourcePool_QlikSenseView
  WITH (MIN_MEMORY_PERCENT = 0, MAX_MEMORY_PERCENT = 20) 
-- Limitando pra usar somente 20% do Workspace memory grant disponível...
-- Hoje, tem 100%, ou seja, 750GB (75% do MaxServerMemory)
-- Com 20%, vai ter 150GB -- SELECT (20 * 750)/100
GO

-- DROP WORKLOAD GROUP WorkLoadGroup_QlikSenseView
CREATE WORKLOAD GROUP WorkLoadGroup_QlikSenseView
 WITH (REQUEST_MAX_MEMORY_GRANT_PERCENT = 5, MAX_DOP = 2)
 USING ResourcePool_QlikSenseView
GO
-- Cada query só pode máximo de 5% do workspace disponível
-- Hoje, uma query pode pegar até 187GB (25% dos 750GB) de grant
-- Com a nova config, vai pegar máximo de 7GB (5% de 150GB) de grant


/*
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
ALTER RESOURCE GOVERNOR RECONFIGURE
*/

-- DROP FUNCTION dbo.Func_ClassificaRG
GO
CREATE FUNCTION dbo.Func_ClassificaRG()
RETURNS SYSNAME
WITH SCHEMABINDING
AS
BEGIN
  DECLARE @Group SYSNAME

  IF APP_NAME() IN ('QlikView', 'Qlik Sense') 
    SET @Group = N'WorkLoadGroup_QlikSenseView'

  RETURN @Group
END
GO

-- Altera o RESOURCE GOVERNOR para usar a função criada.
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.Func_ClassificaRG)
ALTER RESOURCE GOVERNOR RECONFIGURE
GO


-- Query para verificar para qual Resorce Group os usuários foram mapeados
SELECT session_id AS 'Session ID',
       [host_name] AS 'Host Name',
       [program_name] AS 'Program Name',
       nt_user_name AS 'User Name',
       SDRGWG.[name] AS 'Group Assigned',
       DRGRP.[name] AS 'Pool Assigned'
FROM sys.dm_exec_sessions SDES
    INNER JOIN sys.dm_resource_governor_workload_groups SDRGWG
        ON SDES.group_id = SDRGWG.group_id
    INNER JOIN sys.dm_resource_governor_resource_pools DRGRP
        ON SDRGWG.pool_id = DRGRP.pool_id
WHERE SDES.session_id > 50;
GO
