
--   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
--   SCRIPT 03: TRIGGERS PARA TABLAS TRANSACCIONALES
--   GRUPO 5 — Luis
--   Tablas: Ventas, DetalleVentas, Compras, DetalleCompras

/* =========================================================
   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
   SCRIPT 03: TRIGGERS DE TABLAS TRANSACCIONALES
   TABLAS: Pedidos y Detalle_Pedido
   ========================================================= */

USE SistemaVentas_G5;
GO

/* =========================================================
   TRIGGER: Pedidos
   ========================================================= */

CREATE OR ALTER TRIGGER dbo.TR_Pedidos_Auditoria
ON dbo.Pedidos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* UPDATE */
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (
            UsuarioAccion,
            UsuarioBaseDatos,
            FechaHoraAccion,
            TipoAccion,
            NombreTabla,
            ClaveReferencia,
            DetalleAccion,
            HostName,
            ApplicationName
        )
        SELECT
            ORIGINAL_LOGIN(),
            SUSER_SNAME(),
            SYSDATETIME(),
            'UPDATE',
            'Pedidos',
            CONVERT(NVARCHAR(250), i.ID_Pedido),
            CONCAT(
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.DUI_Cliente), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.DUI_Cliente), N'<<NULL>>')
                    THEN CONCAT('DUI_Cliente: ', COALESCE(CONVERT(NVARCHAR(MAX), d.DUI_Cliente), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.DUI_Cliente), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Fecha_Pedido), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Fecha_Pedido), N'<<NULL>>')
                    THEN CONCAT('Fecha_Pedido: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Fecha_Pedido), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.Fecha_Pedido), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Total_Venta), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Total_Venta), N'<<NULL>>')
                    THEN CONCAT('Total_Venta: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Total_Venta), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.Total_Venta), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Estado), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Estado), N'<<NULL>>')
                    THEN CONCAT('ID_Estado: ', COALESCE(CONVERT(NVARCHAR(MAX), d.ID_Estado), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.ID_Estado), N'NULL'), '; ')
                    ELSE ''
                END
            ),
            HOST_NAME(),
            APP_NAME()
        FROM inserted i
        INNER JOIN deleted d
            ON i.ID_Pedido = d.ID_Pedido;
    END;

    /* INSERT */
    ELSE IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora (
            UsuarioAccion,
            UsuarioBaseDatos,
            FechaHoraAccion,
            TipoAccion,
            NombreTabla,
            ClaveReferencia,
            DetalleAccion,
            HostName,
            ApplicationName
        )
        SELECT
            ORIGINAL_LOGIN(),
            SUSER_SNAME(),
            SYSDATETIME(),
            'INSERT',
            'Pedidos',
            CONVERT(NVARCHAR(250), i.ID_Pedido),
            NULL,
            HOST_NAME(),
            APP_NAME()
        FROM inserted i;
    END;

    /* DELETE */
    ELSE IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (
            UsuarioAccion,
            UsuarioBaseDatos,
            FechaHoraAccion,
            TipoAccion,
            NombreTabla,
            ClaveReferencia,
            DetalleAccion,
            HostName,
            ApplicationName
        )
        SELECT
            ORIGINAL_LOGIN(),
            SUSER_SNAME(),
            SYSDATETIME(),
            'DELETE',
            'Pedidos',
            CONVERT(NVARCHAR(250), d.ID_Pedido),
            CONCAT(
                'DUI_Cliente: ', COALESCE(CONVERT(NVARCHAR(MAX), d.DUI_Cliente), N'NULL'), '; ',
                'Fecha_Pedido: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Fecha_Pedido), N'NULL'), '; ',
                'Total_Venta: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Total_Venta), N'NULL'), '; ',
                'ID_Estado: ', COALESCE(CONVERT(NVARCHAR(MAX), d.ID_Estado), N'NULL')
            ),
            HOST_NAME(),
            APP_NAME()
        FROM deleted d;
    END;
END;
GO

/* =========================================================
   TRIGGER: Detalle_Pedido
   ========================================================= */

CREATE OR ALTER TRIGGER dbo.TR_Detalle_Pedido_Auditoria
ON dbo.Detalle_Pedido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* UPDATE */
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (
            UsuarioAccion,
            UsuarioBaseDatos,
            FechaHoraAccion,
            TipoAccion,
            NombreTabla,
            ClaveReferencia,
            DetalleAccion,
            HostName,
            ApplicationName
        )
        SELECT
            ORIGINAL_LOGIN(),
            SUSER_SNAME(),
            SYSDATETIME(),
            'UPDATE',
            'Detalle_Pedido',
            CONVERT(NVARCHAR(250), i.ID_Detalle),
            CONCAT(
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Pedido), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Pedido), N'<<NULL>>')
                    THEN CONCAT('ID_Pedido: ', COALESCE(CONVERT(NVARCHAR(MAX), d.ID_Pedido), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.ID_Pedido), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.ID_Producto), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.ID_Producto), N'<<NULL>>')
                    THEN CONCAT('ID_Producto: ', COALESCE(CONVERT(NVARCHAR(MAX), d.ID_Producto), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.ID_Producto), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Cantidad), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Cantidad), N'<<NULL>>')
                    THEN CONCAT('Cantidad: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Cantidad), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.Cantidad), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Precio_Unitario), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Precio_Unitario), N'<<NULL>>')
                    THEN CONCAT('Precio_Unitario: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Precio_Unitario), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.Precio_Unitario), N'NULL'), '; ')
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Subtotal), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Subtotal), N'<<NULL>>')
                    THEN CONCAT('Subtotal: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Subtotal), N'NULL'), 
                                ' -> ', COALESCE(CONVERT(NVARCHAR(MAX), i.Subtotal), N'NULL'), '; ')
                    ELSE ''
                END
            ),
            HOST_NAME(),
            APP_NAME()
        FROM inserted i
        INNER JOIN deleted d
            ON i.ID_Detalle = d.ID_Detalle;
    END;

    /* INSERT */
    ELSE IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Bitacora (
            UsuarioAccion,
            UsuarioBaseDatos,
            FechaHoraAccion,
            TipoAccion,
            NombreTabla,
            ClaveReferencia,
            DetalleAccion,
            HostName,
            ApplicationName
        )
        SELECT
            ORIGINAL_LOGIN(),
            SUSER_SNAME(),
            SYSDATETIME(),
            'INSERT',
            'Detalle_Pedido',
            CONVERT(NVARCHAR(250), i.ID_Detalle),
            NULL,
            HOST_NAME(),
            APP_NAME()
        FROM inserted i;
    END;

    /* DELETE */
    ELSE IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Bitacora (
            UsuarioAccion,
            UsuarioBaseDatos,
            FechaHoraAccion,
            TipoAccion,
            NombreTabla,
            ClaveReferencia,
            DetalleAccion,
            HostName,
            ApplicationName
        )
        SELECT
            ORIGINAL_LOGIN(),
            SUSER_SNAME(),
            SYSDATETIME(),
            'DELETE',
            'Detalle_Pedido',
            CONVERT(NVARCHAR(250), d.ID_Detalle),
            CONCAT(
                'ID_Pedido: ', COALESCE(CONVERT(NVARCHAR(MAX), d.ID_Pedido), N'NULL'), '; ',
                'ID_Producto: ', COALESCE(CONVERT(NVARCHAR(MAX), d.ID_Producto), N'NULL'), '; ',
                'Cantidad: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Cantidad), N'NULL'), '; ',
                'Precio_Unitario: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Precio_Unitario), N'NULL'), '; ',
                'Subtotal: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Subtotal), N'NULL')
            ),
            HOST_NAME(),
            APP_NAME()
        FROM deleted d;
    END;
END;
GO

PRINT 'Triggers de tablas transaccionales creados correctamente.';
GO
