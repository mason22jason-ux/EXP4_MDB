USE SistemaVentas_G5;
GO

SET NOCOUNT ON;

PRINT '======================================================================';
PRINT '  INICIANDO INSTALACIÓN DE COMPONENTES DE AUDITORÍA (SCRIPT 04)';
PRINT '======================================================================';

/* 1. ASEGURAMIENTO DE TABLAS BASE Y BITÁCORA */
PRINT '>>> [PASO 1] Verificando tablas del sistema...';

IF OBJECT_ID(N'dbo.Bitacora', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bitacora (
        IdBitacora       BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaHoraAccion  DATETIME2(3) DEFAULT SYSDATETIME(),
        UsuarioAccion    NVARCHAR(128) DEFAULT SUSER_SNAME(),
        TipoAccion       VARCHAR(20), 
        NombreTabla      NVARCHAR(128),
        DetalleAccion    NVARCHAR(MAX),
        HostName         NVARCHAR(128) DEFAULT HOST_NAME()
    );
    PRINT '    [OK] Tabla Bitácora creada.';
END
GO

/* 2. INSTALACIÓN DE TRIGGERS */
PRINT '>>> [PASO 2] Configurando Triggers de Trazabilidad...';

-- Trigger para EMPLEADOS
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_Auditoria_Empleados') DROP TRIGGER dbo.TR_Auditoria_Empleados;
GO
CREATE TRIGGER dbo.TR_Auditoria_Empleados ON dbo.Empleados AFTER INSERT, UPDATE, DELETE AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
        SELECT 'INSERT', 'Empleados', 'Alta de registro: ' + Nombre_Completo FROM inserted;
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
        SELECT 'UPDATE', 'Empleados', 'Actualización de datos: ' + i.Nombre_Completo FROM inserted i;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
        INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
        SELECT 'DELETE', 'Empleados', 'Eliminación física: ' + Nombre_Completo FROM deleted;
END;
GO

-- Trigger para INVENTARIO
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_Auditoria_Inventario') DROP TRIGGER dbo.TR_Auditoria_Inventario;
GO
CREATE TRIGGER dbo.TR_Auditoria_Inventario ON dbo.Inventario AFTER UPDATE AS
BEGIN
    INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
    SELECT 'STOCK_UPD', 'Inventario', 'Ajuste de stock' FROM inserted;
END;
GO

-- Trigger para USUARIOS
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_Auditoria_Usuarios') DROP TRIGGER dbo.TR_Auditoria_Usuarios;
GO
CREATE TRIGGER dbo.TR_Auditoria_Usuarios ON dbo.Usuarios AFTER INSERT, DELETE AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted)
        INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
        SELECT 'USER_ADD', 'Usuarios', 'Creación de acceso: ' + NombreUsuario FROM inserted;
    IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
        SELECT 'USER_DEL', 'Usuarios', 'Remoción de acceso: ' + NombreUsuario FROM deleted;
END;
GO

-- Trigger para PAGOS
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_Auditoria_Pagos') DROP TRIGGER dbo.TR_Auditoria_Pagos;
GO
CREATE TRIGGER dbo.TR_Auditoria_Pagos ON dbo.Pagos AFTER INSERT AS
BEGIN
    INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
    SELECT 'PAYMENT', 'Pagos', 'Registro de transacción financiera' FROM inserted;
END;
GO

-- Trigger para ROLES
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_Auditoria_Roles') DROP TRIGGER dbo.TR_Auditoria_Roles;
GO
CREATE TRIGGER dbo.TR_Auditoria_Roles ON dbo.Roles AFTER UPDATE AS
BEGIN
    INSERT INTO dbo.Bitacora (TipoAccion, NombreTabla, DetalleAccion) 
    SELECT 'ROLE_UPD', 'Roles', 'Modificación de perfil/rol' FROM inserted;
END;
GO

PRINT '✔️ [FINALIZADO] Todos los triggers se han instalado correctamente.';
PRINT '======================================================================';


