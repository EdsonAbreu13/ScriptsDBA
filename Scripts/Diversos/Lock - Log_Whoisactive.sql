
IF OBJECT_ID('tempdb..#w') is not null drop table #w;

 

-- Ajustar o filtro aqui

select * into #w from Log_Whoisactive

where Dt_log  >= '20210128 10:30' and Dt_log < '20210128 10:33'

 

 -- Daqui pra baixo , nao precisa mexer.

;with LockChain AS (

    select

         RootSessionId = session_id

        ,DT_Log

        ,session_id

        ,blocking_session_id

        ,sql_text

        ,Level = 1

        ,LockPath = CONVERT(varchar(4000),session_id)

    from

        #w

    where

        blocking_session_id is null

 

    UNION ALL

 

    select

         l.RootSessionId

        ,#w.DT_Log

        ,#w.session_id

        ,#w.blocking_session_id

        ,#w.sql_text

        ,L.Level + 1

        ,LockPath = CONVERT(varchar(4000),LockPath   + '->' + CONVERT(varchar(50),#w.session_id))

    from

        #w

        join

        LockChain     L

            ON L.Dt_Log = #w.Dt_Log

            and L.session_id = #w.blocking_session_id

)

SELECT

    *

FROM

    LockChain l

where

    exists (Select * From LockChain lc where lc.RootSessionId = l.RootSessionId and level > 1 and l.dt_log = lc.dt_log)

ORDER BY

    DT_Log,LockPath