EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Enter valid database profile name',
    @recipients = 'Enter Valid Email Address',
    @body = 'This is a test email sent from TEST server',
    @subject = 'TEST EMAIL',
    @importance ='HIGH'
	
	
	
	-- Habilitar aplicativos menos seguros para enviar email Gmail
https://myaccount.google.com/lesssecureapps

https://www.sqlshack.com/configure-database-mail-sql-server/
Gmail -> Configurações -> Encaminhamento e POP/IMAO -> Ativar IMAP
	
	
-- VERIFICAR FILA DE E-MAILS 
SELECT  
    A.send_request_date AS DataEnvio,  
    A.sent_date AS DataEntrega,  
    (CASE      
        WHEN A.sent_status = 0 THEN '0 - Aguardando envio'  
        WHEN A.sent_status = 1 THEN '1 - Enviado'  
        WHEN A.sent_status = 2 THEN '2 - Falhou'  
        WHEN A.sent_status = 3 THEN '3 - Tentando novamente'  
    END) AS Situacao,  
    A.from_address AS Remetente,  
    A.recipients AS Destinatario,  
    A.subject AS Assunto,  
    A.reply_to AS ResponderPara,  
    A.body AS Mensagem,  
    A.body_format AS Formato,  
    A.importance AS Importancia,  
    A.file_attachments AS Anexos,  
    A.send_request_user AS Usuario,  
    B.description AS Erro,  
    B.log_date AS DataFalha  
FROM   
    msdb.dbo.sysmail_mailitems                  A    WITH(NOLOCK)  
    LEFT JOIN msdb.dbo.sysmail_event_log        B    WITH(NOLOCK)    ON A.mailitem_id = B.mailitem_id
ORDER BY DataEnvio DESC

-- verificar  EMAILS falhos
SELECT TOP 50
    SEL.event_type,
    SEL.log_date,
    SEL.description,
    SF.mailitem_id,
    SF.recipients,
    SF.copy_recipients,
    SF.blind_copy_recipients,
    SF.subject,
    SF.body,
    SF.sent_status,
    SF.sent_date
FROM msdb.dbo.sysmail_faileditems AS SF 
JOIN msdb.dbo.sysmail_event_log AS SEL ON SF.mailitem_id = SEL.mailitem_id
order by log_date DESC





-- CONSULTAS / TROUBLESHOOTING
-- Contas cadastradas no SQL
select * from msdb.dbo.sysmail_account
 
-- Perfis existentes
select * from msdb.dbo.sysmail_profile
 
-- Associações Perfil & Conta
select * from msdb.dbo.sysmail_profileaccount
 
-- Emails enviados
select * from msdb.dbo.sysmail_mailitems
 
-- Consultar logs do gerenciador de e-mails
select * from msdb.dbo.sysmail_log
 