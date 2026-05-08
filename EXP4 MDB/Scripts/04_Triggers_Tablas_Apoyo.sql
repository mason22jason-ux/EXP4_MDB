/* =========================================================
   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
   SCRIPT 04: TRIGGERS DE TABLAS DE APOYO
   =========================================================

   NOTA:
   En la estructura actual de la base de datos SistemaVentas_G5
   no existen tablas adicionales de apoyo como Usuarios, Roles,
   Empleados, Inventario o Pagos.

   Las tablas existentes son:
   - Clientes
   - Productos
   - Pedidos
   - Detalle_Pedido
   - Bitacora

   Por esta razón, este script no crea triggers adicionales.
   La auditoría principal se implementa en los scripts:
   - 02_Triggers_Tablas_Maestras.sql
   - 03_Triggers_Tablas_Transaccionales.sql
   ========================================================= */

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
