/* =========================================================
   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
   SCRIPT 02: TRIGGERS PARA TABLAS MAESTRAS
   GRUPO 5 — INTEGRANTE 2
   Tablas: Clientes, Productos
   ========================================================= */

USE SistemaVentas_G5;
GO

/* 
   PASO PREVIO DE SEGURIDAD:
   Validamos que la tabla Bitacora exista para evitar errores de compilación.
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
   ========================================================= */

IF OBJECT_ID(N'dbo.TR_Clientes_Auditoria', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Clientes_Auditoria;
GO

CREATE TRIGGER dbo.TR_Clientes_Auditoria
ON dbo.Clientes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT: DetalleAccion queda NULL
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'Clientes',
            CAST(i.DUI AS NVARCHAR(250)), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- UPDATE: Solo registra campos que cambiaron
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'Clientes',
            CAST(i.DUI AS NVARCHAR(250)),
            CONCAT(
                CASE WHEN ISNULL(i.Nombre_Completo,'') <> ISNULL(d.Nombre_Completo,'')
                     THEN 'Nombre: [' + d.Nombre_Completo + '] -> [' + i.Nombre_Completo + ']; '
                     ELSE '' END,
                CASE WHEN ISNULL(i.Email,'') <> ISNULL(d.Email,'')
                     THEN 'Email: [' + ISNULL(d.Email,'NULL') + '] -> [' + ISNULL(i.Email,'NULL') + ']; '
                     ELSE '' END,
                CASE WHEN ISNULL(i.ID_Estado,-1) <> ISNULL(d.ID_Estado,-1)
                     THEN 'ID_Estado: [' + CAST(d.ID_Estado AS NVARCHAR(10)) + '] -> [' + CAST(i.ID_Estado AS NVARCHAR(10)) + ']; '
                     ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.DUI = d.DUI;
    END

    -- DELETE: Detalle con datos eliminados
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'Clientes',
            CAST(d.DUI AS NVARCHAR(250)),
            CONCAT('DUI: ', d.DUI, ' | Nombre: ', d.Nombre_Completo, ' | Email: ', ISNULL(d.Email, 'NULL'), ' | Estado: ', CAST(d.ID_Estado AS NVARCHAR(10))),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

/* =========================================================
   TRIGGER: TR_Productos_Auditoria
   ========================================================= */

IF OBJECT_ID(N'dbo.TR_Productos_Auditoria', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Productos_Auditoria;
GO

CREATE TRIGGER dbo.TR_Productos_Auditoria
ON dbo.Productos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'Productos',
            CAST(i.ID_Producto AS NVARCHAR(250)), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- UPDATE: Comparación campo por campo
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'Productos',
            CAST(i.ID_Producto AS NVARCHAR(250)),
            CONCAT(
                CASE WHEN i.Nombre_Producto <> d.Nombre_Producto THEN 'Nombre: [' + d.Nombre_Producto + '] -> [' + i.Nombre_Producto + ']; ' ELSE '' END,
                CASE WHEN i.Precio_Costo <> d.Precio_Costo THEN 'Costo: [' + CAST(d.Precio_Costo AS NVARCHAR(20)) + '] -> [' + CAST(i.Precio_Costo AS NVARCHAR(20)) + ']; ' ELSE '' END,
                CASE WHEN i.Margen_Ganancia <> d.Margen_Ganancia THEN 'Margen: [' + CAST(d.Margen_Ganancia AS NVARCHAR(20)) + '] -> [' + CAST(i.Margen_Ganancia AS NVARCHAR(20)) + ']; ' ELSE '' END,
                CASE WHEN i.Precio_Venta <> d.Precio_Venta THEN 'Venta: [' + CAST(d.Precio_Venta AS NVARCHAR(20)) + '] -> [' + CAST(i.Precio_Venta AS NVARCHAR(20)) + ']; ' ELSE '' END,
                CASE WHEN i.Stock_Actual <> d.Stock_Actual THEN 'Stock: [' + CAST(d.Stock_Actual AS NVARCHAR(10)) + '] -> [' + CAST(i.Stock_Actual AS NVARCHAR(10)) + ']; ' ELSE '' END,
                CASE WHEN ISNULL(i.ID_Estado,-1) <> ISNULL(d.ID_Estado,-1) THEN 'Estado: [' + CAST(d.ID_Estado AS NVARCHAR(10)) + '] -> [' + CAST(i.ID_Estado AS NVARCHAR(10)) + ']; ' ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.ID_Producto = d.ID_Producto;
    END

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'Productos',
            CAST(d.ID_Producto AS NVARCHAR(250)),
            CONCAT('Prod: ', d.Nombre_Producto, ' | Costo: ', CAST(d.Precio_Costo AS NVARCHAR(20)), ' | Venta: ', CAST(d.Precio_Venta AS NVARCHAR(20)), ' | Stock: ', CAST(d.Stock_Actual AS NVARCHAR(10))),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

/* =========================================================
   PRUEBAS OBLIGATORIAS: 1 INSERT, 2 UPDATES, 1 DELETE
   ========================================================= */

-- 1 INSERT
INSERT INTO dbo.Productos (Nombre_Producto, Precio_Costo, Margen_Ganancia, Precio_Venta, Stock_Actual, ID_Estado)
VALUES ('Lampara LED Test', 15.00, 30.00, 19.50, 20, 1);
GO

-- UPDATE 1
UPDATE dbo.Productos SET Nombre_Producto = 'Lampara LED Pro', Precio_Venta = 21.00 
WHERE Nombre_Producto = 'Lampara LED Test';
GO

-- UPDATE 2
UPDATE dbo.Productos SET Stock_Actual = 12 WHERE Nombre_Producto = 'Lampara LED Pro';
GO

-- DELETE
DELETE FROM dbo.Productos WHERE Nombre_Producto = 'Lampara LED Pro';
GO

-- VERIFICACIÓN
SELECT * FROM dbo.Bitacora WHERE NombreTabla IN ('Clientes', 'Productos') ORDER BY IdBitacora DESC;
GO

PRINT '¡Script 02 ejecutado con éxito y verificado!';