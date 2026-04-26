# Experiencia de Aprendizaje 4 - Trazabilidad de los Datos

## Descripción general

Este proyecto corresponde a la **Experiencia de Aprendizaje 4: Trazabilidad de los Datos**.

El objetivo principal es implementar un mecanismo de auditoría en **SQL Server** mediante el uso de **triggers**, permitiendo registrar las acciones realizadas sobre las tablas principales de la base de datos.

La auditoría permitirá identificar:

- Quién realizó la acción.
- En qué momento se realizó.
- Qué tipo de acción fue ejecutada.
- En qué tabla ocurrió la acción.
- Qué registro fue afectado.
- Qué cambios se realizaron, cuando aplique.

Las operaciones auditadas son:

- `INSERT`
- `UPDATE`
- `DELETE`

---

## Integrantes y distribución de trabajo

| Integrante | Responsabilidad |
|---|---|
| Integrante 1 | Creación de la tabla `Bitacora`, plantilla base de triggers y README |
| Integrante 2 | Creación de triggers para tablas maestras |
| Integrante 3 | Creación de triggers para tablas transaccionales |
| Integrante 4 | Creación de triggers para tablas de apoyo, pruebas e integración final |

---

## Estructura del proyecto

La carpeta del proyecto debe manejar la siguiente estructura:

```text
Experiencia_4_Trazabilidad/
│
├── 00_Plantilla_Trigger_Auditoria.sql
├── 01_Crear_Tabla_Bitacora.sql
├── 02_Triggers_Tablas_Maestras.sql
├── 03_Triggers_Tablas_Transaccionales.sql
├── 04_Triggers_Tablas_Apoyo.sql
├── 05_Pruebas_Auditoria.sql
└── README.md
```

---

## Requisitos

Para ejecutar este proyecto se requiere:

- Microsoft SQL Server.
- SQL Server Management Studio.
- Base de datos creada previamente.
- Scripts del proyecto ejecutados en el orden indicado.

---

## Nombre de la base de datos

El proyecto está diseñado para trabajar con la siguiente base de datos:

```sql
SistemaVentas_G5
```

En caso de utilizar otro nombre de base de datos, se debe modificar la línea correspondiente en los scripts:

```sql
USE SistemaVentas_G5;
```

---

## Orden de ejecución de los scripts

Los scripts deben ejecutarse en el siguiente orden:

1. `01_Crear_Tabla_Bitacora.sql`
2. `02_Triggers_Tablas_Maestras.sql`
3. `03_Triggers_Tablas_Transaccionales.sql`
4. `04_Triggers_Tablas_Apoyo.sql`
5. `05_Pruebas_Auditoria.sql`

El archivo `00_Plantilla_Trigger_Auditoria.sql` no forma parte obligatoria del orden de ejecución, ya que funciona como una guía independiente para crear los triggers.

---

## Tabla Bitacora

La tabla `Bitacora` almacena todos los registros de auditoría generados por los triggers.

Campos principales:

| Campo | Descripción |
|---|---|
| `IdBitacora` | Identificador único del registro de auditoría |
| `UsuarioAccion` | Usuario que ejecutó la acción |
| `UsuarioBaseDatos` | Usuario reconocido por SQL Server |
| `FechaHoraAccion` | Fecha y hora en que ocurrió la acción |
| `TipoAccion` | Tipo de acción realizada: INSERT, UPDATE o DELETE |
| `NombreTabla` | Nombre de la tabla afectada |
| `ClaveReferencia` | Llave primaria del registro afectado |
| `DetalleAccion` | Detalle de la acción realizada |
| `HostName` | Nombre del equipo desde donde se ejecutó la acción |
| `ApplicationName` | Aplicación utilizada para ejecutar la acción |

---

## Guía para crear los triggers

Para crear los triggers de auditoría, todos los integrantes deben usar como referencia el archivo:

```text
00_Plantilla_Trigger_Auditoria.sql
```

Este archivo contiene la estructura base y los lineamientos técnicos que deben seguirse para mantener uniformidad en el proyecto.

La plantilla no debe ejecutarse directamente sin modificar.  
Cada integrante debe copiarla y adaptarla según la tabla que le corresponde.

Cada integrante debe modificar:

```text
NombreTabla
IdNombreTabla
Campo1
Campo2
Campo3
```

Por los nombres reales de su tabla, llave primaria y campos a auditar.

Ejemplo:

```text
NombreTabla      → Clientes
IdNombreTabla    → IdCliente
Campo1           → Nombre
Campo2           → Telefono
Campo3           → Correo
```

---

## Estándar para nombrar triggers

Todos los triggers deben utilizar el siguiente formato:

```sql
TR_NombreTabla_Auditoria
```

Ejemplos:

```sql
TR_Clientes_Auditoria
TR_Productos_Auditoria
TR_Ventas_Auditoria
TR_DetalleVenta_Auditoria
```

---

## Reglas generales para los triggers

Cada trigger debe cumplir con las siguientes reglas:

1. Debe registrar acciones de tipo `INSERT`, `UPDATE` y `DELETE`.
2. Debe insertar el registro correspondiente en la tabla `dbo.Bitacora`.
3. Debe registrar el usuario que realizó la acción.
4. Debe registrar la fecha y hora de la acción.
5. Debe registrar el nombre de la tabla afectada.
6. Debe registrar la llave primaria del registro afectado.
7. En operaciones `INSERT`, el campo `DetalleAccion` puede quedar en `NULL`.
8. En operaciones `DELETE`, el campo `DetalleAccion` debe concatenar los campos principales del registro eliminado.
9. En operaciones `UPDATE`, el campo `DetalleAccion` debe mostrar solamente los campos modificados.
10. Los triggers deben funcionar aunque se afecte más de un registro en una sola operación.

---

## Funciones recomendadas en SQL Server

Para mantener uniformidad en todos los triggers, se recomienda usar las siguientes funciones:

```sql
ORIGINAL_LOGIN()
```

Registra el usuario original que inició sesión.

```sql
SUSER_SNAME()
```

Registra el usuario reconocido por SQL Server.

```sql
SYSDATETIME()
```

Registra la fecha y hora exacta de la acción.

```sql
HOST_NAME()
```

Registra el nombre del equipo desde donde se ejecutó la acción.

```sql
APP_NAME()
```

Registra la aplicación desde donde se ejecutó la acción, por ejemplo SQL Server Management Studio.

---

## Importante sobre los triggers en SQL Server

En SQL Server, un trigger se ejecuta **una vez por operación**, no una vez por cada fila afectada.

Por esa razón, no se deben crear triggers pensando que siempre se insertará, actualizará o eliminará un solo registro.

No recomendado:

```sql
DECLARE @IdCliente INT;

SELECT @IdCliente = IdCliente
FROM inserted;
```

El problema de esta práctica es que, si una operación afecta varios registros, la variable solo almacenará uno de ellos y se perderá la trazabilidad de los demás registros.

Forma recomendada:

```sql
INSERT INTO dbo.Bitacora (...)
SELECT ...
FROM inserted;
```

Para actualizaciones, se debe comparar `inserted` con `deleted`:

```sql
INSERT INTO dbo.Bitacora (...)
SELECT ...
FROM inserted i
INNER JOIN deleted d
    ON i.IdCliente = d.IdCliente;
```

---

## Uso de las tablas lógicas inserted y deleted

SQL Server utiliza dos tablas lógicas dentro de los triggers:

| Tabla lógica | Uso |
|---|---|
| `inserted` | Contiene los datos nuevos |
| `deleted` | Contiene los datos anteriores o eliminados |

### INSERT

En una inserción, solo existe información en `inserted`.

### DELETE

En una eliminación, solo existe información en `deleted`.

### UPDATE

En una actualización, existe información en ambas tablas:

- `deleted`: datos antes del cambio.
- `inserted`: datos después del cambio.

---

## Recordatorio para los integrantes

Cada integrante debe revisar el archivo:

```text
00_Plantilla_Trigger_Auditoria.sql
```

Antes de crear sus triggers, ya que allí se muestra la forma correcta de manejar:

- Inserciones.
- Modificaciones.
- Eliminaciones.
- Comparación de campos modificados.
- Concatenación de datos eliminados.
- Uso correcto de `inserted` y `deleted`.
- Registro automático en la tabla `Bitacora`.

---

## Información que cada integrante debe confirmar antes de crear sus triggers

Antes de programar un trigger, cada integrante debe identificar la siguiente información:

```text
Nombre de la tabla:
Nombre de la llave primaria:
Campos principales para registrar en DELETE:
Campos que se deben comparar en UPDATE:
```

Ejemplo:

```text
Nombre de la tabla: Clientes
Nombre de la llave primaria: IdCliente
Campos para DELETE: Nombre, Telefono, Correo
Campos para UPDATE: Nombre, Telefono, Correo, Direccion
```

Esto ayudará a que todos los triggers mantengan la misma estructura y evitará errores al ejecutar los scripts.

---

## Responsabilidades por archivo

### 00_Plantilla_Trigger_Auditoria.sql

Archivo independiente de referencia para crear los triggers de auditoría.

Este archivo no debe tomarse como un script obligatorio de ejecución, sino como una guía para que todos los integrantes mantengan el mismo formato.

Cada integrante debe copiar la estructura de esta plantilla y adaptarla a sus propias tablas, cambiando:

- Nombre de la tabla.
- Nombre de la llave primaria.
- Campos que se registrarán en `DELETE`.
- Campos que se compararán en `UPDATE`.

---

### 01_Crear_Tabla_Bitacora.sql

Contiene la creación de la tabla `Bitacora`.

Este script debe ejecutarse antes de crear cualquier trigger, ya que todos los triggers insertarán información en esta tabla.

---

### 02_Triggers_Tablas_Maestras.sql

Debe contener los triggers de tablas principales o maestras.

Ejemplos de tablas maestras:

- Clientes
- Productos
- Categorías
- Proveedores

---

### 03_Triggers_Tablas_Transaccionales.sql

Debe contener los triggers de tablas relacionadas con movimientos del sistema.

Ejemplos de tablas transaccionales:

- Ventas
- DetalleVenta
- Compras
- DetalleCompra

---

### 04_Triggers_Tablas_Apoyo.sql

Debe contener los triggers de tablas complementarias o de apoyo.

Ejemplos de tablas de apoyo:

- Usuarios
- Empleados
- Roles
- Inventario
- Pagos

---

### 05_Pruebas_Auditoria.sql

Debe contener las pruebas necesarias para validar que los triggers funcionan correctamente.

Debe incluir pruebas de:

- Inserción de registros.
- Modificación de registros.
- Eliminación de registros.
- Consulta final de la tabla `Bitacora`.

---

## Consulta para validar la auditoría

Después de ejecutar las pruebas, se puede consultar la tabla `Bitacora` con:

```sql
SELECT *
FROM dbo.Bitacora
ORDER BY IdBitacora DESC;
```

También se puede filtrar por tabla:

```sql
SELECT *
FROM dbo.Bitacora
WHERE NombreTabla = 'Clientes'
ORDER BY IdBitacora DESC;
```

O por tipo de acción:

```sql
SELECT *
FROM dbo.Bitacora
WHERE TipoAccion = 'UPDATE'
ORDER BY IdBitacora DESC;
```

---

## Pruebas esperadas

El archivo `05_Pruebas_Auditoria.sql` debe demostrar que los triggers funcionan correctamente.

Cada tabla auditada debería tener al menos una prueba de:

```sql
INSERT
UPDATE
DELETE
```

Después de cada prueba, se recomienda consultar la tabla `Bitacora` para verificar que el registro fue guardado correctamente.

Ejemplo:

```sql
SELECT *
FROM dbo.Bitacora
ORDER BY IdBitacora DESC;
```

---

## Criterios internos para revisar antes de entregar

Antes de entregar el proyecto, verificar que:

- Todos los scripts se ejecuten sin errores.
- La tabla `Bitacora` se cree correctamente.
- Cada trigger registre `INSERT`, `UPDATE` y `DELETE`.
- El campo `DetalleAccion` funcione correctamente.
- El `UPDATE` muestre únicamente los campos modificados.
- El `DELETE` registre información útil del registro eliminado.
- El archivo de pruebas demuestre que la auditoría funciona.
- El orden de ejecución esté claro en este README.
- Todos los archivos estén guardados en la carpeta correcta del proyecto.

---

## Notas importantes

No se deben modificar manualmente los registros de la tabla `Bitacora`, excepto en ambientes de prueba.

Los scripts deben ejecutarse en el orden indicado para evitar errores de dependencias.

El archivo `00_Plantilla_Trigger_Auditoria.sql` debe usarse como guía obligatoria para mantener uniformidad entre todos los triggers del proyecto.
