
USE SistemaVentas_G5;
GO

PRINT '============================================================';
PRINT 'SCRIPT 04 - VALIDACIÓN DE TABLAS DE APOYO';
PRINT '============================================================';

PRINT 'Verificando tablas existentes en la base de datos...';
GO

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

PRINT 'Verificando triggers creados hasta el momento...';
GO

SELECT 
    tr.name AS NombreTrigger,
    OBJECT_NAME(tr.parent_id) AS TablaAsociada,
    tr.create_date,
    tr.modify_date
FROM sys.triggers tr
ORDER BY TablaAsociada, NombreTrigger;
GO

PRINT 'No se crean triggers de apoyo porque la base actual no contiene tablas adicionales de apoyo.';
PRINT 'Script 04 ejecutado correctamente.';
GO
