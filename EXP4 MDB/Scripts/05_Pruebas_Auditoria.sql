USE SistemaVentas_G5;
GO

SET NOCOUNT ON;

PRINT '======================================================================';
PRINT '  EJECUTANDO BATERÍA DE PRUEBAS DE AUDITORÍA (SCRIPT 05)';
PRINT '======================================================================';

/* 1. PRUEBAS DML */
PRINT '>>> [TEST 1] Operaciones en Tabla: Empleados...';
INSERT INTO dbo.Empleados (Nombre_Completo, Cargo, Salario) VALUES ('Maka Auditoria Final', 'Ingeniera DB', 2500.00);
UPDATE dbo.Empleados SET Salario = 2800.00 WHERE Nombre_Completo = 'Maka Auditoria Final';

PRINT '>>> [TEST 2] Operaciones en Tabla: Inventario...';
INSERT INTO dbo.Inventario (IdProducto, StockActual) VALUES (123, 100);
UPDATE dbo.Inventario SET StockActual = 80 WHERE IdProducto = 123;

PRINT '>>> [TEST 3] Operaciones en Tabla: Seguridad (Roles y Usuarios)...';
INSERT INTO dbo.Roles (Nombre_Rol) VALUES ('Auditor_Temp');
INSERT INTO dbo.Usuarios (NombreUsuario, Clave, IdRol) 
SELECT 'maka_admin_test', 'pass2026', (SELECT TOP 1 IdRol FROM dbo.Roles WHERE Nombre_Rol = 'Auditor_Temp');
DELETE FROM dbo.Usuarios WHERE NombreUsuario = 'maka_admin_test';

PRINT '>>> [TEST 4] Operaciones en Tabla: Finanzas (Ventas y Pagos)...';
INSERT INTO dbo.Ventas (TotalVenta) VALUES (150.75);
INSERT INTO dbo.Pagos (IdVenta, MontoPago, MetodoPago) 
SELECT (SELECT TOP 1 IdVenta FROM dbo.Ventas ORDER BY IdVenta DESC), 150.75, 'Transferencia';

-- Limpieza de datos de prueba (deja rastro en bitácora)
DELETE FROM dbo.Empleados WHERE Nombre_Completo = 'G5 Auditoria Final';

PRINT '✔️ Ciclo de pruebas completado con éxito.';
PRINT '----------------------------------------------------------------------';

/* 2. REPORTE DE RESULTADOS */
PRINT '>>> GENERANDO REPORTE DE TRAZABILIDAD...';

SELECT 
    IdBitacora AS [FOLIO],
    FechaHoraAccion AS [TIMESTAMP],
    TipoAccion AS [EVENTO],
    NombreTabla AS [TABLA],
    DetalleAccion AS [DESCRIPCIÓN],
    UsuarioAccion AS [OPERADOR]
FROM dbo.Bitacora
ORDER BY IdBitacora DESC;

PRINT '======================================================================';
PRINT '  ENTREGA LISTA PARA REVISIÓN - G5 2026';
PRINT '======================================================================';
