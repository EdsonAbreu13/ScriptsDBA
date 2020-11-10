---

declare @search_text NVARCHAR(MAX),
 @searchforthis NVARCHAR(MAX) = 'Ole Automation'

IF OBJECT_ID('tempdb..#search_results') IS NOT NULL
BEGIN	
	DROP TABLE #search_results;
END

CREATE TABLE #search_results
	(
		the__database sysname NOT NULL,
		the__schema sysname NOT NULL,
		procedure__name sysname NOT NULL,
		procedure__text NVARCHAR(4000) NOT NULL,
		colid int NOT NULL
	)

SELECT @search_text = 
'USE ?; 
INSERT INTO #search_results (the__database, the__schema, procedure__name, procedure__text, colid) 
SELECT db_name() AS the__database
	, OBJECT_SCHEMA_NAME(P.object_id) AS the__schema
	, P.name AS procedure__name 
	, C.text AS procedure__text
	, C.colid
FROM sys.procedures P WITH(NOLOCK)
	LEFT JOIN sys.syscomments C WITH(NOLOCK) ON P.object_id = C.id
WHERE C.text LIKE ' + '''' + '%' + @searchforthis + '%' + '''' + ';'

EXEC sys.sp_MSforeachdb @command1 = @search_text;

SELECT the__database
	 , the__schema
	 , procedure__name
	 , procedure__text 
FROM #search_results 
ORDER BY the__database
	, the__schema
	, procedure__name
	, colid;
