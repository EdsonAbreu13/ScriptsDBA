SELECT c.name,
       t.name,
       c.max_length,
       c.precision,
       c.scale,
       c.is_nullable
  FROM sys.columns c
  JOIN sys.types   t
    ON c.user_type_id = t.user_type_id
  JOIN sys.tables tb
	ON tb.object_id = c.object_id
 WHERE 1=1
	 and c.object_id    = Object_id('dbo.Log_Whoisactive_Teste') -- por tabela
	 and t.name = 'money'
