select Dt_Log,[dd hh:mm:ss.mss],database_name,session_id,sql_text,login_name,wait_info,status,host_name,CPU, reads as CPU_delta, CPU_delta as reads from Log_Whoisactive where Dt_Log >= '20210201 19:00' order by Dt_Log