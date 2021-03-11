SELECT DATEDIFF(SECOND,aj.start_execution_date,GetDate()) AS Seconds
FROM msdb..sysjobactivity aj
JOIN msdb..sysjobs sj on sj.job_id = aj.job_id
WHERE aj.stop_execution_date IS NULL -- job hasn't stopped running
AND aj.start_execution_date IS NOT NULL -- job is currently running
AND sj.name = 'DBA - Alert DB - Every Minute'
and not exists( -- make sure this is the most recent run
    select 1
    from msdb..sysjobactivity new
    where new.job_id = aj.job_id
    and new.start_execution_date > aj.start_execution_date
)