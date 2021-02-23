drop  table if exists #BasesLetra;
CREATE TABLE #BasesLetra(name sysname, letra char(1));

insert into #BasesLetra 
	values
		( 'KurierBaixa','J' )
		,( 'KurierDocumentosSentencas','J' )
		,( 'KurierBiju','J' )
		,( 'KurierHTMLProcessos','S' )
		,( 'KurierRelatorioPiloto','S' )
		,( 'KurierArquivos','S' )
	

select
	*

	,'ALTER DATABASE '+Banco+' MODIFY FILE(name = '''+FileName+''', FILENAME = '''+NewPath+''' )'
	,'ALTER DATABASE '+Banco+' SET OFFLINE WITH ROLLBACK IMMEDIATE'
	,'mkdir -force '''+NewDir+''''
	,'copy -Verbose '''+OriginalPath+''' '''+NewDir+''''
from
(
	select
		  Banco = DB_NAME(database_id)
		 ,FileName = mf.name
		 ,OriginalPath = physical_name
		 ,OriginalDir = Traces.dbo.GetDir(physical_name)
		 ,NewPath = REPLACE(physical_name,LEFT(physical_name,1)+':\',BL.letra+':\')
		 ,NewDir = Traces.dbo.GetDir(REPLACE(physical_name,LEFT(physical_name,1)+':\',BL.letra+':\'))
		 ,FileSizeGb = size/131072.00
		 ,TotalSum = (SUM(size) OVER (PARTITION BY database_id))/131072.
	from
		sys.master_files mf
		join
		#BasesLetra BL
			ON BL.name = DB_NAME(database_id)
	WHERE
		LEFT(physical_name,1) IN ('X','Y','Z')
) F
WHERE
	Banco NOT IN ('Demarest')






 