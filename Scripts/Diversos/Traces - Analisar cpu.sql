select * from Traces..Log_Counter where Id_Counter = 3 order by dt_log desc

select * from Traces..Log_Counter where Id_Counter = 3 and value>=60 order by dt_log desc

select cast(dt_log as date)date, avg(value)avg, max(value)max from Traces..Log_Counter where Id_Counter = 3 and datepart(WEEKDAY,dt_log)not in(1,7) group by cast(dt_log as date) order by 1 desc
