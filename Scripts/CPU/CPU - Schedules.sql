
select session_id, scheduler_id, start_time, status, command, wait_type, wait_time, last_wait_type, cpu_time, total_elapsed_time  
from sys.dm_exec_requests
where session_id > 50