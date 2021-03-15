
SELECT 'GRANT SELECT ON [' + SCHEMA_NAME(schema_id) + '].[' + name + '] TO [user]' FROM sys.tables WHERE name IN()