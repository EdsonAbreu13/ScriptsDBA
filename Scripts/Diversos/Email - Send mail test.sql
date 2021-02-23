use MSDB
go
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Database Mail Profile'
  , @recipients = 'nisargupadhyay87@outlook.com'
  , @subject = 'Automated Test Results (Successful)'
  , @body = 'The stored procedure finished successfully.'
Go