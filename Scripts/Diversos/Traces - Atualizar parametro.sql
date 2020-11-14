
USE TRACES
GO

SELECT * FROM Alert_Parameter WHERE Id_Alert_Parameter = 17

BEGIN TRAN

UPDATE Alert_Parameter SET Vl_Parameter = 90 WHERE  Id_Alert_Parameter = 17

COMMIT