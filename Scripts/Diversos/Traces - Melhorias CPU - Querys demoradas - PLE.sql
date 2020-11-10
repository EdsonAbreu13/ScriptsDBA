 --Queries que demorarm mais de 3 segundos 
select CAST(StartTime as DATE),COUNT(*)
from Traces..Queries_Profile
where datepart(hh,StartTime) between 7 and 19
--    and (StartTime <= '20141220' or StartTime >= '20150105') -- retira período de festas
--     and isnull(ApplicationName,'') <> 'Quest Diagnostic Server (Monitoring)' -- Ferramenta de monitoramento
and DATEPART(dw,StartTime) between 2 and 6 -- Só de segunda a sexta
--     and CAST(StartTime as DATE) <> '2014-12-12' --dia com 8 mil queries lentas
group by CAST(StartTime as DATE)
order by 1 DESC


-- Média do consumo de CPU por dia
SELECT cast(Dt_Log as DATE) ,avg(Value ), max(Value)
FROM Traces.dbo.Log_Counter A
    JOIN Traces.dbo.SQL_Counter B ON A.Id_Counter = B.Id_Counter
WHERE DATEPART(dw,Dt_Log) between 2 and 6 -- Só de segunda a sexta
--    and (Dt_Log <= '20141220' or Dt_Log >= '20150105') -- retira período de festas
and datepart(hh,Dt_Log) between 9 and 17 -- Só em um horário com mais utilização
and B.Nm_Counter = 'CPU'
group by cast(Dt_Log as DATE)
order by 1 DESC


-- Média do consumo de Page Life Expectancy por dia
SELECT cast(Dt_Log as DATE) ,avg(Value )
FROM Traces.dbo.Log_Counter A
    JOIN Traces.dbo.SQL_Counter B ON A.Id_Counter = B.Id_Counter
WHERE DATEPART(dw,Dt_Log) between 2 and 6 -- Só de segunda a sexta
--    and (Dt_Log <= '20141220' or Dt_Log >= '20150105') -- retira período de festas
and datepart(hh,Dt_Log) between 9 and 17 -- Só em um horário com mais utilização
and B.Nm_Counter = 'Page Life Expectancy'
group by cast(Dt_Log as DATE)
order by 1 DESC
