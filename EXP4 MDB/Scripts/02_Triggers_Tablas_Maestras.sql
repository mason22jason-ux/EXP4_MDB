/* =========================================================
   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
   SCRIPT 02: TRIGGERS PARA TABLAS MAESTRAS
   GRUPO 5 — INTEGRANTE 2
   Tablas: Clientes, Productos
   ========================================================= */

USE SistemaVentas_G5;
GO

/* PASO PREVIO DE SEGURIDAD:
   Validamos que la tabla Bitacora exista. Si no existe, la creamos 
   automáticamente para asegurar la ejecución del script.
*/
IF OBJECT_ID(N'dbo.Bitacora', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bitacora (
        IdBitacora BIGINT IDENTITY(1,1) PRIMARY KEY,
        UsuarioAccion NVARCHAR(128),
        UsuarioBaseDatos NVARCHAR(128),
        FechaHoraAccion DATETIME2(3) DEFAULT SYSDATETIME(),
        TipoAccion VARCHAR(10),
        NombreTabla NVARCHAR(128),
        ClaveReferencia NVARCHAR(250),
        DetalleAccion NVARCHAR(MAX),
        HostName NVARCHAR(128),
        ApplicationName NVARCHAR(256)
    );
    PRINT 'Aviso: Se creó la tabla Bitacora porque no se encontró en el esquema.';
END;
GO

/* =========================================================
   TRIGGER: TR_Clientes_Auditoria
   Tabla: dbo.Clientes | PK: DUI
   ========================================================= */

CREATE OR ALTER TRIGGER dbo.TR_Clientes_Auditoria
ON dbo.Clientes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- [INSERT] 
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT 
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'Clientes', 
            CONVERT(NVARCHAR(250), i.DUI), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- [UPDATE] Comparamos campo por campo usando COALESCE para evitar errores con NULL
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT 
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'Clientes', 
            CONVERT(NVARCHAR(250), i.DUI),
            CONCAT(
                CASE WHEN ISNULL(d.Nombre_Completo,'') <> ISNULL(i.Nombre_Completo,'') THEN CONCAT('Nombre: [', d.Nombre_Completo, '] -> [', i.Nombre_Completo, ']; ') ELSE '' END,
                CASE WHEN ISNULL(d.Email,'') <> ISNULL(i.Email,'') THEN CONCAT('Email: [', d.Email, '] -> [', i.Email, ']; ') ELSE '' END,
                CASE WHEN ISNULL(d.ID_Estado,-1) <> ISNULL(i.ID_Estado,-1) THEN CONCAT('Estado: [', d.ID_Estado, '] -> [', i.ID_Estado, ']; ') ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.DUI = d.DUI;
    END

    -- [DELETE] 
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT 
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'Clientes', 
            CONVERT(NVARCHAR(250), d.DUI),
            CONCAT('DUI: ', d.DUI, ' | Nombre: ', d.Nombre_Completo, ' | Email: ', ISNULL(d.Email, 'N/A')),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

/* =========================================================
   TRIGGER: TR_Productos_Auditoria
   Tabla: dbo.Productos | PK: ID_Producto
   ========================================================= */

CREATE OR ALTER TRIGGER dbo.TR_Productos_Auditoria
ON dbo.Productos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- [INSERT]
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT 
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'Productos', 
            CONVERT(NVARCHAR(250), i.ID_Producto), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- [UPDATE]
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT 
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'Productos', 
            CONVERT(NVARCHAR(250), i.ID_Producto),
            CONCAT(
                CASE WHEN d.Nombre_Producto <> i.Nombre_Producto THEN CONCAT('Nombre: [', d.Nombre_Producto, '] -> [', i.Nombre_Producto, ']; ') ELSE '' END,
                CASE WHEN d.Precio_Venta <> i.Precio_Venta THEN CONCAT('Venta: [', d.Precio_Venta, '] -> [', i.Precio_Venta, ']; ') ELSE '' END,
                CASE WHEN d.Stock_Actual <> i.Stock_Actual THEN CONCAT('Stock: [', d.Stock_Actual, '] -> [', i.Stock_Actual, ']; ') ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.ID_Producto = d.ID_Producto;
    END

    -- [DELETE]
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT 
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'Productos', 
            CONVERT(NVARCHAR(250), d.ID_Producto),
            CONCAT('Producto: ', d.Nombre_Producto, ' | Stock Final: ', d.Stock_Actual),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

/* =========================================================
   PRUEBAS OBLIGATORIAS: Validar funcionamiento
   ========================================================= */

PRINT '--- INICIANDO PRUEBAS DE AUDITORÍA ---';

-- 1. INSERT de prueba
INSERT INTO dbo.Productos (Nombre_Producto, Precio_Costo, Margen_Ganancia, Precio_Venta, Stock_Actual, ID_Estado)
VALUES ('Producto Auditoria Test', 10.00, 20.00, 12.00, 50, 1);
GO

-- 2. UPDATE 1 (Cambio de nombre y precio)
UPDATE dbo.Productos 
SET Nombre_Producto = 'Producto Auditoria MOD', Precio_Venta = 15.00 
WHERE Nombre_Producto = 'Producto Auditoria Test';
GO

-- 3. UPDATE 2 (Cambio de stock)
UPDATE dbo.Productos SET Stock_Actual = 45 WHERE Nombre_Producto = 'Producto Auditoria MOD';
GO

-- 4. DELETE
DELETE FROM dbo.Productos WHERE Nombre_Producto = 'Producto Auditoria MOD';
GO

-- RESULTADO FINAL
SELECT TOP 10 
    TipoAccion, NombreTabla, ClaveReferencia, DetalleAccion, FechaHoraAccion 
FROM dbo.Bitacora 
ORDER BY IdBitacora DESC;
GO

PRINT 'Script 02 completado y verificado.';