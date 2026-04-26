/* =========================================================
   EXPERIENCIA 4: TRAZABILIDAD DE LOS DATOS
   SCRIPT 01: CREACIÓN DE TABLA BITÁCORA
   GRUPO 5
   ========================================================= */

USE master;
GO

IF DB_ID(N'SistemaVentas_G5') IS NULL
BEGIN
    RAISERROR('La base de datos SistemaVentas_G5 no existe. Verifique el nombre de la base de datos.', 16, 1);
    RETURN;
END;
GO

USE SistemaVentas_G5;
GO

/* =========================================================
   CREACIÓN DE TABLA BITÁCORA
   ========================================================= */

IF OBJECT_ID(N'dbo.Bitacora', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bitacora (
        IdBitacora BIGINT IDENTITY(1,1) NOT NULL,
        UsuarioAccion NVARCHAR(128) NOT NULL,
        UsuarioBaseDatos NVARCHAR(128) NULL,
        FechaHoraAccion DATETIME2(3) NOT NULL 
            CONSTRAINT DF_Bitacora_FechaHoraAccion DEFAULT SYSDATETIME(),
        TipoAccion VARCHAR(10) NOT NULL,
        NombreTabla NVARCHAR(128) NOT NULL,
        ClaveReferencia NVARCHAR(250) NOT NULL,
        DetalleAccion NVARCHAR(MAX) NULL,
        HostName NVARCHAR(128) NULL,
        ApplicationName NVARCHAR(256) NULL,

        CONSTRAINT PK_Bitacora PRIMARY KEY (IdBitacora),
        CONSTRAINT CK_Bitacora_TipoAccion 
            CHECK (TipoAccion IN ('INSERT', 'UPDATE', 'DELETE'))
    );

    PRINT 'Tabla dbo.Bitacora creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.Bitacora ya existe. No se creó nuevamente.';
END;
GO

/* =========================================================
   ÍNDICES RECOMENDADOS PARA CONSULTA DE AUDITORÍA
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Bitacora_FechaHoraAccion'
      AND object_id = OBJECT_ID(N'dbo.Bitacora')
)
BEGIN
    CREATE INDEX IX_Bitacora_FechaHoraAccion
    ON dbo.Bitacora (FechaHoraAccion DESC);

    PRINT 'Índice IX_Bitacora_FechaHoraAccion creado correctamente.';
END;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_Bitacora_TablaAccion'
      AND object_id = OBJECT_ID(N'dbo.Bitacora')
)
BEGIN
    CREATE INDEX IX_Bitacora_TablaAccion
    ON dbo.Bitacora (NombreTabla, TipoAccion, FechaHoraAccion DESC);

    PRINT 'Índice IX_Bitacora_TablaAccion creado correctamente.';
END;
GO

/* =========================================================
   VALIDACIÓN DE CREACIÓN
   ========================================================= */

SELECT 
    COLUMN_NAME AS Campo,
    DATA_TYPE AS TipoDato,
    CHARACTER_MAXIMUM_LENGTH AS Longitud,
    IS_NULLABLE AS PermiteNulos
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Bitacora'
ORDER BY ORDINAL_POSITION;
GO