
--   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
--   SCRIPT 03: TRIGGERS PARA TABLAS TRANSACCIONALES
--   GRUPO 5 — Luis
--   Tablas: Ventas, DetalleVentas, Compras, DetalleCompras

USE SistemaVentas_G5;
GO

--   PASO PREVIO DE SEGURIDAD:
--   Validamos que la tabla Bitacora exista para evitar errores de ejecución.

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

--   TRIGGER: TR_Ventas_Auditoria
--   Audita INSERT, UPDATE y DELETE sobre dbo.Ventas

IF OBJECT_ID(N'dbo.TR_Ventas_Auditoria', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Ventas_Auditoria;
GO

CREATE TRIGGER dbo.TR_Ventas_Auditoria
ON dbo.Ventas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT: se registra la nueva venta. DetalleAccion queda NULL según la guía.
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'Ventas',
            CAST(i.IdVenta AS NVARCHAR(250)), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- UPDATE: se registran solo los campos modificados.
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'Ventas',
            CAST(i.IdVenta AS NVARCHAR(250)),
            CONCAT(
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.DUI_Cliente), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.DUI_Cliente), '')
                     THEN CONCAT('DUI_Cliente: [', ISNULL(CONVERT(NVARCHAR(MAX), d.DUI_Cliente), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.DUI_Cliente), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.FechaVenta), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.FechaVenta), '')
                     THEN CONCAT('FechaVenta: [', ISNULL(CONVERT(NVARCHAR(MAX), d.FechaVenta), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.FechaVenta), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.TotalVenta), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.TotalVenta), '')
                     THEN CONCAT('TotalVenta: [', ISNULL(CONVERT(NVARCHAR(MAX), d.TotalVenta), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.TotalVenta), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Estado), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), '')
                     THEN CONCAT('ID_Estado: [', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Estado), 'NULL'), ']; ')
                     ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.IdVenta = d.IdVenta;
    END

    -- DELETE: se registran datos principales eliminados.
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'Ventas',
            CAST(d.IdVenta AS NVARCHAR(250)),
            CONCAT(
                'IdVenta: ', CAST(d.IdVenta AS NVARCHAR(50)),
                ' | DUI_Cliente: ', ISNULL(CONVERT(NVARCHAR(MAX), d.DUI_Cliente), 'NULL'),
                ' | FechaVenta: ', ISNULL(CONVERT(NVARCHAR(MAX), d.FechaVenta), 'NULL'),
                ' | TotalVenta: ', ISNULL(CONVERT(NVARCHAR(MAX), d.TotalVenta), 'NULL'),
                ' | Estado: ', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), 'NULL')
            ),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

--   TRIGGER: TR_DetalleVentas_Auditoria
--   Audita INSERT, UPDATE y DELETE sobre dbo.DetalleVentas

IF OBJECT_ID(N'dbo.TR_DetalleVentas_Auditoria', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_DetalleVentas_Auditoria;
GO

CREATE TRIGGER dbo.TR_DetalleVentas_Auditoria
ON dbo.DetalleVentas
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
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'DetalleVentas',
            CAST(i.IdDetalleVenta AS NVARCHAR(250)), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'DetalleVentas',
            CAST(i.IdDetalleVenta AS NVARCHAR(250)),
            CONCAT(
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.IdVenta), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.IdVenta), '')
                     THEN CONCAT('IdVenta: [', ISNULL(CONVERT(NVARCHAR(MAX), d.IdVenta), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.IdVenta), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Producto), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), '')
                     THEN CONCAT('ID_Producto: [', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Producto), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.Cantidad), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), '')
                     THEN CONCAT('Cantidad: [', ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.Cantidad), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.PrecioUnitario), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.PrecioUnitario), '')
                     THEN CONCAT('PrecioUnitario: [', ISNULL(CONVERT(NVARCHAR(MAX), d.PrecioUnitario), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.PrecioUnitario), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.Subtotal), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), '')
                     THEN CONCAT('Subtotal: [', ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.Subtotal), 'NULL'), ']; ')
                     ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.IdDetalleVenta = d.IdDetalleVenta;
    END

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'DetalleVentas',
            CAST(d.IdDetalleVenta AS NVARCHAR(250)),
            CONCAT(
                'IdDetalleVenta: ', CAST(d.IdDetalleVenta AS NVARCHAR(50)),
                ' | IdVenta: ', ISNULL(CONVERT(NVARCHAR(MAX), d.IdVenta), 'NULL'),
                ' | ID_Producto: ', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), 'NULL'),
                ' | Cantidad: ', ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), 'NULL'),
                ' | PrecioUnitario: ', ISNULL(CONVERT(NVARCHAR(MAX), d.PrecioUnitario), 'NULL'),
                ' | Subtotal: ', ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), 'NULL')
            ),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

--   TRIGGER: TR_Compras_Auditoria
--  Audita INSERT, UPDATE y DELETE sobre dbo.Compras

IF OBJECT_ID(N'dbo.TR_Compras_Auditoria', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Compras_Auditoria;
GO

CREATE TRIGGER dbo.TR_Compras_Auditoria
ON dbo.Compras
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
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'Compras',
            CAST(i.IdCompra AS NVARCHAR(250)), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'Compras',
            CAST(i.IdCompra AS NVARCHAR(250)),
            CONCAT(
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.IdProveedor), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.IdProveedor), '')
                     THEN CONCAT('IdProveedor: [', ISNULL(CONVERT(NVARCHAR(MAX), d.IdProveedor), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.IdProveedor), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.FechaCompra), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.FechaCompra), '')
                     THEN CONCAT('FechaCompra: [', ISNULL(CONVERT(NVARCHAR(MAX), d.FechaCompra), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.FechaCompra), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.TotalCompra), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.TotalCompra), '')
                     THEN CONCAT('TotalCompra: [', ISNULL(CONVERT(NVARCHAR(MAX), d.TotalCompra), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.TotalCompra), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Estado), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), '')
                     THEN CONCAT('ID_Estado: [', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Estado), 'NULL'), ']; ')
                     ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.IdCompra = d.IdCompra;
    END

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'Compras',
            CAST(d.IdCompra AS NVARCHAR(250)),
            CONCAT(
                'IdCompra: ', CAST(d.IdCompra AS NVARCHAR(50)),
                ' | IdProveedor: ', ISNULL(CONVERT(NVARCHAR(MAX), d.IdProveedor), 'NULL'),
                ' | FechaCompra: ', ISNULL(CONVERT(NVARCHAR(MAX), d.FechaCompra), 'NULL'),
                ' | TotalCompra: ', ISNULL(CONVERT(NVARCHAR(MAX), d.TotalCompra), 'NULL'),
                ' | Estado: ', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), 'NULL')
            ),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

--   TRIGGER: TR_DetalleCompras_Auditoria
--   Audita INSERT, UPDATE y DELETE sobre dbo.DetalleCompras

IF OBJECT_ID(N'dbo.TR_DetalleCompras_Auditoria', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_DetalleCompras_Auditoria;
GO

CREATE TRIGGER dbo.TR_DetalleCompras_Auditoria
ON dbo.DetalleCompras
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
            SUSER_SNAME(), USER_NAME(), 'INSERT', 'DetalleCompras',
            CAST(i.IdDetalleCompra AS NVARCHAR(250)), NULL, HOST_NAME(), APP_NAME()
        FROM inserted i;
    END

    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'UPDATE', 'DetalleCompras',
            CAST(i.IdDetalleCompra AS NVARCHAR(250)),
            CONCAT(
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.IdCompra), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.IdCompra), '')
                     THEN CONCAT('IdCompra: [', ISNULL(CONVERT(NVARCHAR(MAX), d.IdCompra), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.IdCompra), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Producto), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), '')
                     THEN CONCAT('ID_Producto: [', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Producto), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.Cantidad), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), '')
                     THEN CONCAT('Cantidad: [', ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.Cantidad), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.PrecioUnitario), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.PrecioUnitario), '')
                     THEN CONCAT('PrecioUnitario: [', ISNULL(CONVERT(NVARCHAR(MAX), d.PrecioUnitario), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.PrecioUnitario), 'NULL'), ']; ')
                     ELSE '' END,
                CASE WHEN ISNULL(CONVERT(NVARCHAR(MAX), i.Subtotal), '') <> ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), '')
                     THEN CONCAT('Subtotal: [', ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), 'NULL'), '] -> [', ISNULL(CONVERT(NVARCHAR(MAX), i.Subtotal), 'NULL'), ']; ')
                     ELSE '' END
            ),
            HOST_NAME(), APP_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.IdDetalleCompra = d.IdDetalleCompra;
    END

    -- DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora
            (UsuarioAccion, UsuarioBaseDatos, TipoAccion, NombreTabla,
             ClaveReferencia, DetalleAccion, HostName, ApplicationName)
        SELECT
            SUSER_SNAME(), USER_NAME(), 'DELETE', 'DetalleCompras',
            CAST(d.IdDetalleCompra AS NVARCHAR(250)),
            CONCAT(
                'IdDetalleCompra: ', CAST(d.IdDetalleCompra AS NVARCHAR(50)),
                ' | IdCompra: ', ISNULL(CONVERT(NVARCHAR(MAX), d.IdCompra), 'NULL'),
                ' | ID_Producto: ', ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), 'NULL'),
                ' | Cantidad: ', ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), 'NULL'),
                ' | PrecioUnitario: ', ISNULL(CONVERT(NVARCHAR(MAX), d.PrecioUnitario), 'NULL'),
                ' | Subtotal: ', ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), 'NULL')
            ),
            HOST_NAME(), APP_NAME()
        FROM deleted d;
    END
END;
GO

--   VALIDACIÓN RÁPIDA DE TRIGGERS CREADOS

SELECT 
    name AS TriggerCreado,
    OBJECT_NAME(parent_id) AS TablaAuditada,
    create_date,
    modify_date
FROM sys.triggers
WHERE name IN (
    'TR_Ventas_Auditoria',
    'TR_DetalleVentas_Auditoria',
    'TR_Compras_Auditoria',
    'TR_DetalleCompras_Auditoria'
)
ORDER BY TablaAuditada, TriggerCreado;
GO

PRINT 'Triggers de tablas transaccionales creados correctamente.';
GO
