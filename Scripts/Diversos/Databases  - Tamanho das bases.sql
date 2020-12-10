if exists (select * from tempdb.sys.all_objects where name like '%#dbsize%')
drop table #dbsize
create table #dbsize
(
[Database] varchar(30),
[Status Database] varchar(20),
[Recovery Model] varchar(10) default ('NA'),
[File Size MB] decimal(20,2) default (0),
[Space Used MB] decimal(20,2) default (0),
[Free Space MB] decimal(20,2) default (0)
)
go

insert into #dbsize([Database],[Status Database],[Recovery Model],[File Size MB],[Space Used MB],[Free Space MB])
exec sp_msforeachdb
'use [?];
select DB_NAME() AS [Database],
CONVERT(varchar(20),DatabasePropertyEx(''?'',''Status'')) ,
CONVERT(varchar(20),DatabasePropertyEx(''?'',''Recovery'')),
sum(size)/128.0 AS [File Size MB],
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as [Space Used MB],
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS [Free Space MB]
from sys.database_files where type=0 group by type'
go

select *
from #dbsize
order by [File Size MB] desc