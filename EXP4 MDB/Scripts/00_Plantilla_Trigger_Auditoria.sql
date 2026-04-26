/* =========================================================
   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
   PLANTILLA ESTÁNDAR PARA TRIGGERS DE AUDITORÍA
   =========================================================

   INSTRUCCIONES:
   1. Cambiar NombreTabla por el nombre real de la tabla.
   2. Cambiar IdNombreTabla por la PK real de la tabla.
   3. Cambiar Campo1, Campo2, Campo3 por los campos reales.
   4. Cada trigger debe registrar INSERT, UPDATE y DELETE.
   5. No asumir que solo se afecta un registro. Los triggers deben manejar varios registros.
   ========================================================= */

CREATE OR ALTER TRIGGER dbo.TR_NombreTabla_Auditoria
ON dbo.NombreTabla
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* =====================================================
       CASO 1: UPDATE
       Existe información en inserted y deleted.
       inserted = datos nuevos
       deleted  = datos anteriores
       ===================================================== */
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
            'NombreTabla',
            CONVERT(NVARCHAR(250), i.IdNombreTabla),
            CONCAT(
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Campo1), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Campo1), N'<<NULL>>')
                    THEN CONCAT(
                        'Campo1: ',
                        COALESCE(CONVERT(NVARCHAR(MAX), d.Campo1), N'NULL'),
                        ' -> ',
                        COALESCE(CONVERT(NVARCHAR(MAX), i.Campo1), N'NULL'),
                        '; '
                    )
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Campo2), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Campo2), N'<<NULL>>')
                    THEN CONCAT(
                        'Campo2: ',
                        COALESCE(CONVERT(NVARCHAR(MAX), d.Campo2), N'NULL'),
                        ' -> ',
                        COALESCE(CONVERT(NVARCHAR(MAX), i.Campo2), N'NULL'),
                        '; '
                    )
                    ELSE ''
                END,
                CASE 
                    WHEN ISNULL(CONVERT(NVARCHAR(MAX), d.Campo3), N'<<NULL>>') 
                       <> ISNULL(CONVERT(NVARCHAR(MAX), i.Campo3), N'<<NULL>>')
                    THEN CONCAT(
                        'Campo3: ',
                        COALESCE(CONVERT(NVARCHAR(MAX), d.Campo3), N'NULL'),
                        ' -> ',
                        COALESCE(CONVERT(NVARCHAR(MAX), i.Campo3), N'NULL'),
                        '; '
                    )
                    ELSE ''
                END
            ),
            HOST_NAME(),
            APP_NAME()
        FROM inserted i
        INNER JOIN deleted d
            ON i.IdNombreTabla = d.IdNombreTabla;
    END;

    /* =====================================================
       CASO 2: INSERT
       Solo existe información en inserted.
       Según la indicación, en inserción el detalle puede ir NULL.
       ===================================================== */
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
            'NombreTabla',
            CONVERT(NVARCHAR(250), i.IdNombreTabla),
            NULL,
            HOST_NAME(),
            APP_NAME()
        FROM inserted i;
    END;

    /* =====================================================
       CASO 3: DELETE
       Solo existe información en deleted.
       Se concatenan los campos principales del registro eliminado.
       ===================================================== */
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
            'NombreTabla',
            CONVERT(NVARCHAR(250), d.IdNombreTabla),
            CONCAT(
                'Campo1: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Campo1), N'NULL'), '; ',
                'Campo2: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Campo2), N'NULL'), '; ',
                'Campo3: ', COALESCE(CONVERT(NVARCHAR(MAX), d.Campo3), N'NULL')
            ),
            HOST_NAME(),
            APP_NAME()
        FROM deleted d;
    END;
END;
GO