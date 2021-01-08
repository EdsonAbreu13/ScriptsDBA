https://suporte.powertuning.com.br/kb/article/136456/tempdb-identificando-consumidores-de-espaco?preview=true&revisionId=469453


USE tempdb;

 
SELECT

       file_id
       ,name
       ,type_desc
       ,TamMB = SUM(size/128)
       ,UsedMB = SUM(FILEPROPERTY(name,'SpaceUsed')/128)
       ,PercUsed = SUM(FILEPROPERTY(name,'SpaceUsed'))*100./SUM(size)
FROM
       sys.database_files
GROUP BY
       GROUPING SETS (

             (file_id,name,type_desc)

             ,()

       )

 

 