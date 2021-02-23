List of essential tables to check the email status
Following is the list of tables, used to view configuration database mail, database account and status of the email.

Sr	Configuration	List of table and view or Query
1.	View list of profiles	

msdb.sys.sysmail_profile

2.	View list of accounts	

msdb.sys.sysmail_account

3.	View Mail server configuration	

msdb.sys.sysmail_server

msdb.sys.sysmail_servertype

msdb.sys.sysmail_configuration

4.	View Email Sent Status	

msdb.sysmail_allitems

msdb.sysmail_sentitems

msdb.sys.sysmail_unsentitems

msdb.sys.sysmail_faileditems

5.	View Status of events	

madb.sys.sysmail_event_log