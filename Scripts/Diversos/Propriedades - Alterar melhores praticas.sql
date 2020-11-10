SELECT   

    name,
    CASE WHEN page_verify_option_desc <> 'CHECKSUM' THEN 'ALTER DATABASE [' + name + '] SET PAGE_VERIFY CHECKSUM' ELSE '' END AS [page verify option],
	CASE WHEN is_auto_close_on = 1 THEN 'ALTER DATABASE [' + name + '] SET AUTO_CLOSE OFF' ELSE '' END AS [auto close],
	CASE WHEN is_auto_shrink_on = 1 THEN 'ALTER DATABASE [' + name + '] SET AUTO_SHRINK OFF' ELSE '' END AS [auto shrink],
	CASE WHEN is_auto_create_stats_on = 0 THEN 'ALTER DATABASE [' + name + '] SET AUTO_CREATE_STATISTICS ON' ELSE '' END AS [auto create statistics],
	CASE WHEN is_auto_update_stats_on = 0 THEN 'ALTER DATABASE [' + name + '] SET AUTO_UPDATE_STATISTICS ON' ELSE '' END AS [auto update statistics]

 FROM sys.databases DB

 --WHERE        -- DESCOMENTAR A OPCAO DESEJADA ABAIXO

 --    CASE WHEN page_verify_option_desc <> 'CHECKSUM' THEN 'ALTER DATABASE [' + name + '] SET PAGE_VERIFY CHECKSUM' ELSE '' END <> ''        -- PAGE VERIFY

 --    CASE WHEN is_auto_close_on = 1 THEN 'ALTER DATABASE [' + name + '] SET AUTO_CLOSE OFF' ELSE '' END <> ''                            -- AUTO CLOSE

 --    CASE WHEN is_auto_shrink_on = 1 THEN 'ALTER DATABASE [' + name + '] SET AUTO_SHRINK OFF' ELSE '' END <> ''                            -- AUTO SHRINK

 --    CASE WHEN is_auto_create_stats_on = 0 THEN 'ALTER DATABASE [' + name + '] SET AUTO_CREATE_STATISTICS ON' ELSE '' END <> ''            -- AUTO CREATE STATISTICS

 --    CASE WHEN is_auto_update_stats_on = 0 THEN 'ALTER DATABASE [' + name + '] SET AUTO_UPDATE_STATISTICS ON' ELSE '' END <> ''            -- AUTO UPDATE STATISTICS

 ORDER BY name
