/* Trabajo Integrador Final Administración de Base de Datos
Ejercicio 1
Contexto: La empresa requiere realizar una actualización masiva en la lista de precios de sus productos debido a una nueva normativa impositiva. Para garantizar la consistencia de los datos, la operación debe ser atómica (todo o nada).
Consigna: Escribir un script en Transact-SQL que cumpla con los siguientes requerimientos:

    1.	Lógica de Negocio: Incrementar un 15% el precio (ListPrice) de todos los productos de la tabla Production.      Product cuyo precio actual sea mayor a cero.

    2.	Control de Transacciones: Si tras aplicar el incremento, el precio mínimo de los productos modificados no supera el promedio original de precios de la empresa, la operación debe considerarse riesgosa y revertirse por completo (ROLLBACK). De lo contrario, se debe confirmar (COMMIT).
    3.	Manejo de Errores Dinámico: Envolver toda la lógica en un bloque TRY...CATCH. Si ocurre un error inesperado en la base de datos (por ejemplo, un error aritmético de división por cero simulado dinámicamente), se debe:
        o	Verificar mediante funciones o variables del sistema si existe una transacción activa para revertirla. 
        o	Capturar las propiedades del error (ERROR_NUMBER(), ERROR_MESSAGE()).
        o	Relanzar un error personalizado utilizando THROW o RAISERROR informando la falla crítica. */
use AdventureWorks2008R2;

declare @PromedioOriginal money;
declare @MinimoPostIncremento money;
declare @FilasModificadas int;
begin try
    -- 1. Iniciamos la transaccion controlada
    begin tran;
        print '>>> Iniciando proceso de actualización masiva impositiva...';

        -- Obtener el promedio original antes del cambio
        select @PromedioOriginal = avg(ListPrice)
        from Production.Product
        where ListPrice > 0;

        print'Auditoria: Promedio original de precios: ' + cast(@PromedioOriginal as varchar);

        -- 2. Aplicamos la logica de negocio: Incremento del 15% 
        -- Nota: Para probar el catch y el throw,podes descomentar la linea de division por cero
        update Production.Product
        set ListPrice = (ListPrice * 1.15) -- / 0 <--Descomentar para forzar el error aritmetico
        where ListPrice > 0;

        --Capturamos las filas afectadas inmediatamente usando la variable de distema
        set @FilasModificadas = @@ROWCOUNT;
        print 'Auditoria: Productos afectados por el incremento: ' + cast(@FilasModificadas as varchar);

        -- 3. Validacion de regla de negocio post-incrmento
        select @MinimoPostIncremento = min(ListPrice)
        from Production.Product
        where ListPrice > 0;
        print 'Auditoria: Precio mínimo post-incremento: ' + cast(@MinimoPostIncremento as varchar);

        --Evaluamos la condicion de riesgo
        if @MinimoPostIncremento <= @PromedioOriginal
        begin
            -- Si no supera el promedio, forzamos la reversion por regla de negocio
            rollback tran;
            print '>>> Operación revertida: El precio minimo no supero el promedio original. Datos intactos.';
        end
        else
        begin
            -- Si pasa la validacion, confirmammos los cambios de forma permanente.
            commit tran;
            print '>>> Operación confirmada: Los precios se actualizaron exitosamente en un 15%.';
        end
end try
begin catch
    -- 4. Gestion y captura de errores criticos del sistema
    print '⚠ SE DETECTO UN CRITICO EN LA EJECUCION ⚠';

    -- Verificacion de transaccion activa mediante variable del sistema.
    if @@TRANCOUNT > 0
    begin
        rollback tran;
        print '>>> Transacción revertida automáticamente debido a error crítico.';
    end;

    -- Captura de datos del error para la auditoria interna antes del throw
    print'-----------------------------------------------------------------';
    print 'Codigo de Error: ' + cast(ERROR_NUMBER() as varchar);
    print 'Descripcion: ' + ERROR_MESSAGE();
    print 'Severidad: ' + cast(ERROR_SEVERITY() as varchar);
    print'-----------------------------------------------------------------';

    --lanzamos el error formal hacia la aplicacion o usuario utilizando THROW
    --(usa el codigo 51000 que es el rango estandar para errores personalizados de usuario)

    THROW 51000, 'Error de Proceso: La actualizacion masiva fallo debido a un problema tecnico o aritmetico interno. Operacion cancelada.', 1;
end catch


-- Ejercicio 2
-- Contexto: La cadena de complejos deportivos "SportNet" requiere el diseño desde cero de su infraestructura de base de datos corporativa. Debido al alto volumen de transacciones de accesos diarios, se exige una arquitectura que distribuya físicamente la información para optimizar el rendimiento de los discos, organice los módulos por responsabilidades mediante capas lógicas y estandarice tipos de datos críticos.

-- Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes directivas de arquitectura física y lógica:

--      1.	Infraestructura de Almacenamiento (Sistema de Archivos): Crear la base de datos SportNetDB distribuyendo sus archivos en dos grupos diferenciados:
--          o	PRIMARY (Datos operativos y de configuración): Un archivo .MDF de 10 MB con crecimiento de 2 MB.
--          o	HISTORICO (Registro masivo de accesos/auditoría): Un grupo de archivos secundario con un archivo .NDF de 15 MB para balancear la carga de lectura/escritura de datos antiguos.
--          o	LOG (Transacciones): Un archivo .LDF de 5 MB con crecimiento de 1 MB.
--      2.	Organización de Objetos (Esquemas): Estructurar la base de datos dividiéndola en dos áreas de negocio bien delimitadas: Socios (para datos personales y membresías) y Facturacion (para cobros y aranceles).
--      3.	Estandarización de Dominios (UDT): Crear tipos de datos definidos por el usuario para asegurar la integridad semántica de la base de datos:
--          o	TipoDocumento (basado en VARCHAR(12), obligatorio).
--          o	CodigoPostal (basado en CHAR(8), opcional).
--      4.	Construcción de Tablas Relacionales: Diseñar tres tablas interactuando con los esquemas y los UDT creados, definiendo correctamente sus claves primarias, externas y asignaciones de Filegroups:
--          o	Socios.FichaPersonal (Almacenada en el Filegroup PRIMARY).
--          o	Socios.RegistroAccesos (Almacenada explícitamente en el Filegroup HISTORICO).
--          o	Facturacion.CobrosMensuales (Almacenada en el Filegroup PRIMARY).

-- ===================================================================
-- 1. CREACION DE LA BASE DE DATOS CON ARQUITECTURA MULTI-FILEGROUP
-- ===================================================================

create database SportNetDB
on Primary(
            name = N'SportNetData',
            filename = N'C:\DATA\SportNet.MDF',
            size = 10 MB,
            maxsize = 100 MB,
            filegrowth = 2 MB
        ),
FILEGROUP HISTORICO
        (
            name= N'SportNetHistoricoData',
            filename = N'C:\DATA\SportNetHistorico.NDF',
            size = 15 MB,
            maxsize = 200 MB,
            filegrowth = 1 MB
        )   
LOG ON
            (
                name = N'SportNet_Log',
                filename = N'c:\DATA\SportNet_Log.LDF',
                size = 5 MB,
                maxsize = 50 MB,
                filegrowth = 1 MB
            );
GO

-- Poner en uso la base de datos e iniciar operaciones logicas
USE SportNetDB;
GO

-- Verificacion de la base de datos en el catalogo general.
select name, database_id, create_date, recovery_model_desc 
from sys.databases 
where name = 'SportNetDB';
go

-- ====================================================
-- 2. CREACION DE ESQUEMAS Y TIPOS DE DATOS DEFINIDOS
-- ====================================================
create SCHEMA Socios;
go
create SCHEMA Facturacion;
GO

-- Verificacion de esquemas agregados (Filtramos esquemas del sistema)
select name, schema_id, principal_id
from sys.schemas
where name IN ('Socios', 'Facturacion');
go

-- ===============================================
-- 3. CREACION DE TIPOS DE DATOS DE USUARIO (UDT)
-- ===============================================
print'>>> Creando tipos de datos personalizados (UDT)...';
CREATE TYPE TipoDocumento FROM VARCHAR(12) NOT NULL;
GO
CREATE TYPE CodigoPostal FROM CHAR(8) NULL;
GO

-- Verificacion de tipos de datos en las vistas del sistema
select name, system_type_id, max_length, is_nullable
from sys.types
where is_user_defined = 1;  
go

-- ==================================================================
-- 4. CONSTRUCCION DE TABLAS OPERATIVAS Y ASIGNACION DE FILEGROUPS
-- ==================================================================
print '>>> Creando estructuras de tablas con segmentacion fisica...';

-- Tabla de Socios en el Filegroup Principal (PRIMARY por defecto)
CREATE TABLE Socios.FichaPersonal
(
    SocioID INT IDENTITY(1,1),
    Apellido VARCHAR(50) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Documento TipoDocumento,
    CP CodigoPostal,
    FechaAlta DATE DEFAULT GETDATE(),
    CONSTRAINT Pk_FichaPersonal PRIMARY KEY (SocioID)
) ON [PRIMARY];
go

-- Tabla de Registro de Accesos Historicos direccionada al Filegroup de Alto Rendimiento [HISTORICO]
CREATE TABLE Socios.RegistroAccesos
(
    AccesoID BIGINT IDENTITY(1,1),
    SocioID INT NOT NULL,
    FechaHora DATETIME DEFAULT GETDATE(),
    DispositivoID INT NOT NULL,
    CONSTRAINT Pk_RegistroAccesos PRIMARY KEY (AccesoID),
    CONSTRAINT FK_RegistroAccesos_Socios FOREIGN KEY (SocioID) REFERENCES Socios.FichaPersonal(SocioID)
) ON [HISTORICO];
go

-- Tabla de Cobros Mensuales en el Filegroup Principal (PRIMARY)
CREATE TABLE Facturacion.CobrosMensuales
(
    CobroID INT IDENTITY(1,1),
    SocioID INT NOT NULL,
    Mes INT NOT NULL,
    Anio INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaCobro DATE DEFAULT GETDATE(),
    CONSTRAINT Pk_CobrosMensuales PRIMARY KEY (CobroID),
    CONSTRAINT FK_CobrosMensuales_Socios FOREIGN KEY (SocioID) REFERENCES Socios.FichaPersonal(SocioID)
) ON [PRIMARY];
go

-- Ejercicio 3
-- Contexto: El departamento de desarrollo de software ha detectado serios problemas de redundancia, anomalías de actualización y falta de integridad en el almacenamiento de las solicitudes de cotización. Se presenta una estructura no normalizada (vistas de tabla única o "tabla plana") y se solicita su proceso de normalización completo.
-- Consigna: Dada la siguiente estructura de datos plana:
-- Presupuesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad + Precio_Total
-- Aplicar el proceso de normalización paso a paso explicando las transformaciones para alcanzar la Primera (1FN), Segunda (2FN) y Tercera (3FN) Forma Normal. Omitir los atributos derivados o calculados en el modelo físico final para respetar las buenas prácticas de bases de datos relacionales.

-- Presupuesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad + Precio_Total

-- >>> 1FN (Estructura de datos sin grupos repetitivos)
-- Presupuesto_Solicitado = @#Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente +  Precio_Total
-- Detalle_Presupuesto =@#Presupuesto + @#Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad 

-- >>> 2FN (Eliminación de dependencias parciales)
-- Presupuesto_Solicitado = @#Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Precio_Total
-- Detalle_Presupuesto = @#Presupuesto + @#Codigo_Producto + Cantidad + Precio_x_Cantidad
-- Producto = @#Codigo_Producto + Descripcion_Producto + Precio_Unitario

-- >>> 3FN (Eliminación de dependencias transitivas)
-- Presupuesto_Solicitado = @#Presupuesto + #Cliente + Fecha_Dia + Fecha_Caducidad + Precio_Total 
-- Cliente = @#Cliente + Razon_Social_Cliente
-- Detalle_Presupuesto = @#Presupuesto + @#Codigo_Producto + Cantidad + Precio_x_Cantidad
-- Producto = @#Codigo_Producto + Descripcion_Producto + Precio_Unitario

-- Precio_x_Cantidad = precio_unitario * cantidad
-- Precio_Total = sum(precio_unitario * cantidad)

-- Estructura Normalizada

-- Presupuesto_Solicitado = @#Presupuesto + #Cliente + Fecha_Dia + Fecha_Caducidad 
-- Cliente = @#Cliente + Razon_Social_Cliente
-- Detalle_Presupuesto = @#Presupuesto + @#Codigo_Producto + Cantidad
-- Producto = @#Codigo_Producto + Descripcion_Producto + Precio_Unitario

-- Ejercicio 4

-- Contexto: El departamento de auditoría detectó que las búsquedas y reportes sobre la tabla de socios están sufriendo serios problemas de rendimiento debido a la falta de una estrategia de indexación sólida. Además, se han reportado ingresos de números de documentos duplicados. Se solicita rediseñar la estructura de índices de la tabla para garantizar la máxima velocidad de consulta y asegurar la integridad de los datos.

-- Consigna: Escribir un script unificado en Transact-SQL que simule y resuelva el ciclo de vida de optimización de la tabla Socios.FichaPersonal cumpliendo las siguientes directivas:
--      1.	Punto de Partida Ineficiente: Crear la estructura base sin asignación automática de índices y cargar registros que fuercen la existencia de apellidos duplicados.
--      2.	Conflicto de Unicidad: Intentar aplicar un índice agrupado único sobre una columna con datos duplicados para analizar el comportamiento del motor.
--      3.	Estrategia de Indexación Mixta: * Implementar un índice agrupado no único para optimizar búsquedas por rangos alfabéticos de apellidos.
--      4.	Garantía de Integridad: Crear un índice único no agrupado para el documento de identidad y verificar el bloqueo ante intentos de duplicación.
--      5.	Reingeniería Estructural (Refactorización): Demostrar la capacidad de reestructurar la tabla eliminando el índice anterior y regenerando la Clave Primaria para que sea, finalmente, el índice agrupado principal de la tabla.

USE SportNetDB;
GO

-- ============================================================================
-- 1. PREPARACIÓN DEL ESCENARIO (ESTRUCTURA BASE SIN ÍNDICES AUTOMÁTICOS)
-- ============================================================================
PRINT '>>> 1. Creando tabla de optimización de socios...';

-- Eliminamos la tabla si ya existía del punto 2 para hacer la simulación limpia
IF OBJECT_ID('Socios.FichaPersonal') IS NOT NULL 
    DROP TABLE Socios.FichaPersonal;
GO

CREATE TABLE Socios.FichaPersonal
(
    SocioID CHAR(5) NOT NULL,
    Documento CHAR(8) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    Nombre VARCHAR(30) NOT NULL,
    ArancelMensual DECIMAL(10,2) NULL
);
GO

-- Inserción de registros de prueba (con apellidos duplicados adrede)
INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
VALUES  
('S0001', '40123456', 'Pérez', 'Juan', 8500.00),
('S0002', '41123457', 'Pérez', 'María', 7250.00),
('S0003', '42123458', 'Gómez', 'Lucas', 9000.00),
('S0004', '43123459', 'Rodríguez', 'Ana', 6500.00),
('S0005', '44123460', 'Fernández', 'Luis', 4000.00),
('S0006', '45123461', 'López', 'Laura', 9750.00);
GO

PRINT '>>> 2. Intentando crear indice agrupado unico sobre Apellido (con datos duplicados)...';
BEGIN TRY
    CREATE UNIQUE CLUSTERED INDEX I_FichaPersonal_Apellido ON Socios.FichaPersonal(Apellido); --Lanza un error por datos duplicados
END TRY

BEGIN CATCH
    PRINT '⚠ ERROR DETECTADO: No se puede crear un indice agrupado unico debido a datos duplicados.';
    PRINT 'Codigo de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Descripcion: ' + ERROR_MESSAGE();
END CATCH

print '>>> 3. Creando indice agrupado no unico sobre Apellido para optimizar busquedas...';
CREATE CLUSTERED INDEX I_FichaPersonal_Apellido ON Socios.FichaPersonal(Apellido);

print '>>> 4. Creando indice unico no agrupado sobre Documento para garantizar integridad...';
CREATE UNIQUE NONCLUSTERED INDEX I_FichaPersonal_Documento ON Socios.FichaPersonal(Documento);
GO
print '>>> 4. Intentando insertar un nuevo socio con documento duplicado para verificar el bloqueo...';
BEGIN TRY
    INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
    VALUES ('S0007', '40123456', 'Martínez', 'Sofía', 8000.00); --Documento duplicado
END TRY
BEGIN CATCH
    PRINT '⚠ ERROR DETECTADO: No se puede insertar un nuevo socio debido a documento duplicado.';
    PRINT 'Codigo de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Descripcion: ' + ERROR_MESSAGE();
END CATCH


print '>>> 5. Reestructurando la tabla para establecer SocioID o Documento como clave primaria agrupada...';

exec sp_helpindex 'Socios.FichaPersonal'; --Ver indices actuales antes de la refactorizacion

--    index_name                          index_description                              index_keys
--1   I_FichaPersonal_Apellido            clustered located on PRIMARY                   Apellido
--2   I_FichaPersonal_Documento           nonclustered, unique located on PRIMARY        Documento

--Eliminamos el indice agrupado actual para poder crear la nueva clave primaria agrupada
DROP INDEX I_FichaPersonal_Apellido 
ON Socios.FichaPersonal;
GO

--Creo el índice agrupado principal de la tabla sobre el campo SocioID, que ahora será la nueva clave primaria

ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal_SocioID
PRIMARY KEY CLUSTERED (SocioID) ON [PRIMARY]; --Podria ser Documento la clave primaria.
GO

--Verificamos la nueva estructura de indices despues de la refactorizacion.
exec sp_helpindex 'Socios.FichaPersonal';
go


--    index_name                      index_description                                       index_keys
--1   I_FichaPersonal_Documento       nonclustered, unique located on PRIMARY                 Documento
--2   PK_FichaPersonal_SocioID        clustered, unique, primary key located on PRIMARY       SocioID


-- Ejercicio 5
-- Contexto: El volumen de transacciones de preventas y detalles de órdenes en AdventureWorks ha crecido exponencialmente, ralentizando los índices y aumentando los tiempos de mantenimiento de backups. Como Ingeniero de Datos / DBA, se le solicita diseñar e implementar una arquitectura de tabla particionada para la auditoría de ventas trimestrales del año 2011(Sales.SalesOrderDetail), distribuyendo la carga en almacenamiento físico diferenciado para optimizar el rendimiento de entrada/salida (I/O).

-- Consigna: Desarrollar un script en Transact-SQL que ejecute paso a paso las siguientes fases de ingeniería de almacenamiento:

--      1.	Infraestructura Física: Crear 4 Filegroups independientes con un archivo secundario (.ndf) cada uno en el directorio de datos.
--      2.	Lógica de Particionado: Definir una función de partición basada en rangos temporales para segmentar los trimestres de un año fiscal y mapearlos mediante un esquema de partición a los Filegroups creados.
--      3.	Migración Masiva: Construir una réplica de la tabla de órdenes de venta particionada, poblarla con la información histórica real de AdventureWorks y testear inserciones en los límites de los rangos.
--      4.	Metadatos y Auditoría: Consultar las vistas del sistema para auditar la distribución de registros por partición exacta, documentando detalladamente las diferencias operativas de las funciones de partición.
--      5.	Rollback Estructural: Proveer la secuencia de desmantelamiento seguro y ordenado de los objetos creados para limpieza del entorno.

use AdventureWorks2008R2;
go

print '>>> 1. Creando Filegroups independientes para particionamiento...';
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fg1;
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fg2;
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fg3;
ALTER DATABASE AdventureWorks2008R2 ADD FILEGROUP fg4;

ALTER DATABASE AdventureWorks2008R2
ADD FILE (
            NAME = data1,
            FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\data1.ndf',
            size = 1MB,
            maxsize = 100MB,
            filegrowth = 1MB
            )
TO FILEGROUP fg1;
go
ALTER DATABASE AdventureWorks2008R2
ADD FILE (
            NAME = data2,
            FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\data2.ndf',
            size = 1MB,
            maxsize = 100MB,
            filegrowth = 1MB
            )
TO FILEGROUP fg2;
go
ALTER DATABASE AdventureWorks2008R2
ADD FILE (
            NAME = data3,
            FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\data3.ndf',
            size = 1MB,
            maxsize = 100MB,
            filegrowth = 1MB
            )
TO FILEGROUP fg3;
go
ALTER DATABASE AdventureWorks2008R2
ADD FILE (
            NAME = data4,
            FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\data4.ndf',
            size = 1MB,
            maxsize = 100MB,
            filegrowth = 1MB
            )
TO FILEGROUP fg4;
go

print '>>> 2. Definiendo funcion de particion y esquema de particion...';
CREATE PARTITION FUNCTION pf_SalesOrderHeader(DateTime)
AS RANGE RIGHT FOR VALUES 
(   '2011-04-01',
    '2011-07-01',
    '2011-10-01');

CREATE PARTITION SCHEME ps_OrderDate
AS PARTITION pf_SalesOrderHeader
TO (fg1, fg2, fg3, fg4);
GO

SELECT *
FROM sys.partition_functions;

print '>>> 3. Creando tabla de transacciones particionada y migrando datos...';
CREATE TABLE dbo.PartitionedTransactions
(
	TransactionID int IDENTITY(1,1) NOT NULL,
	ProductID int NOT NULL,
	TransactionDate datetime NOT NULL DEFAULT (getdate()),
	TransactionType nchar(1) NOT NULL
)
ON ps_OrderDate(TransactionDate)
GO

-- Migramos los datos históricos de SalesOrderHeader a la nueva tabla particionada, mapeando las fechas de orden a la columna TransactionDate
INSERT INTO dbo.PartitionedTransactions
SELECT	ProductID, TransactionDate, TransactionType
FROM Production.TransactionHistory
GO

-- Probamos inserciones en los límites de los rangos para verificar el correcto direccionamiento a las particiones
INSERT INTO dbo.PartitionedTransactions
VALUES
(1, '01/01/2011', 'S'),
(2, '03/31/2011', 'S'),
(3, '04/01/2011', 'S'),
(4, '06/30/2011', 'S'),
(5, '07/01/2011', 'S'),
(6, '09/30/2011', 'S'),
(7, '10/01/2011', 'S'),
(8, '12/31/2011', 'S');
GO

print '>>> 4. Consultando vistas del sistema para auditar la distribucion de registros por particion...';
-- Auditoria de la función de partición creada
SELECT * FROM sys.Partitions
WHERE [object_id] = OBJECT_ID('dbo.PartitionedTransactions')

-- Auditoria de la distribución de registros 
SELECT TransactionID, TransactionDate, $Partition.pf_SalesOrderHeader(TransactionDate) PartitionNo
FROM dbo.PartitionedTransactions

-- Auditoria de la fecha mínima por partición para verificar el correcto direccionamiento
SELECT MIN(TransactionDate) FirstTran, $Partition.pf_SalesOrderHeader(TransactionDate) PartitionNo
FROM dbo.PartitionedTransactions
GROUP BY $Partition.pf_SalesOrderHeader(TransactionDate)
ORDER BY PartitionNo


print '>>> 5. Desmantelamiento seguro de objetos creados...';
DROP TABLE dbo.PartitionedTransactions
DROP PARTITION SCHEME ps_OrderDate
DROP PARTITION FUNCTION pf_SalesOrderHeader
ALTER DATABASE AdventureWorks REMOVE FILE data1
ALTER DATABASE AdventureWorks REMOVE FILE data2
ALTER DATABASE AdventureWorks REMOVE FILE data3
ALTER DATABASE AdventureWorks REMOVE FILE data4
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fg1
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fg2
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fg3
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fg4


-- Ejercicio 6
-- Contexto: La Fintech "CryptoAr" está expandiendo su infraestructura y requiere configurar la seguridad de acceso global para su nueva instancia de producción de SQL Server. La política corporativa exige auditorías estrictas de acceso, separación de funciones según el principio de "privilegio mínimo" y la habilitación segura de logins de aplicaciones.
-- Consigna: Escribir un script unificado en Transact-SQL que implemente la configuración de seguridad perimetral del servidor bajo los siguientes requerimientos:
--      1.	Auditoría de Instancia: Verificar programáticamente el modo de seguridad de la instancia. Si no admite logins internos, dejar documentado el procedimiento de cambio a modo mixto y el requerimiento operativo de infraestructura.
--      2.	Aprovisionamiento con Políticas: Crear tres logins de servidor para el nuevo personal del Centro de Operaciones de Red (NOC) y del Equipo de Seguridad (SecOps):
--          o	SecAuditor_Gomez
--          o	NocMonitor_Lopez
--          o	DbaJunior_Paz
--  Todos deben cumplir obligatoriamente con las políticas de expiración y complejidad del sistema operativo.
--      3.	Gestión de Ciclo de Vida: Simular una ventana de mantenimiento donde se bloqueen accesos sospechosos, se reestablezcan credenciales comprometidas y se reasigne el contexto de base de datos por defecto a un entorno seguro corporativo.
--      4.	Separación de Funciones (Server Roles): Asignar roles fijos de servidor específicos según el perfil técnico:
--          o	El auditor debe poder revisar logs y configuraciones globales (securityadmin).
--          o	El monitor del NOC debe analizar la salud, recursos y procesos del motor (processadmin).
--          o	El DBA Junior debe administrar el espacio en disco y archivos lógicos (diskadmin).
--      5.	Validación Dinámica: Consultar las vistas de catálogo del sistema para verificar estados y mapeos de roles vigentes.

print '>>> 1. Verificando el modo de seguridad de la instancia...';

-- Consultamos la propiedad del servidor para determinar el modo de autenticacion actual
SELECT 
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 1 THEN '⚠️ SOLO Windows Authentication (necesitas cambiarlo)'
        WHEN 0 THEN '✅ Mixed Mode (Windows + SQL Server)'
    END AS ModoAutenticacion;
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- Cambiar a MIXED MODE (Windows + SQL Server Authentication)
-- ────────────────────────────────────────────────────────────────────────────────
USE [master];
GO

EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode', 
    REG_DWORD, 
    2;  -- 2 = Mixed Mode (Windows + SQL Server)
GO

PRINT '✅ Configurado para cambiar a: Mixed Mode';
PRINT '⚠️ REINICIA SQL Server para aplicar cambios:';
PRINT '   CMD: net stop MSSQLSERVER && net start MSSQLSERVER';
PRINT '   PowerShell: Restart-Service -Name MSSQLSERVER -Force';
GO

SELECT 
    SERVERPROPERTY('IsIntegratedSecurityOnly') AS ValorNumerico,
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN '✅ Mixed Mode (Windows + SQL Server)'
        WHEN 1 THEN '🔒 Windows Only'
    END AS ModoActual;
GO

print '>>> 2.Creando tres logins de servidor para el nuevo personal del Centro de Operaciones de Red (NOC) y del Equipo de Seguridad (SecOps)...';

-- Login con opciones completas
CREATE LOGIN SecAuditor_Gomez
WITH PASSWORD = 'P@ssw0rd123!',
     DEFAULT_DATABASE = [master],
     CHECK_EXPIRATION = ON,-- dura 42 dias x defecto en windows
     CHECK_POLICY = ON;
GO
CREATE LOGIN NocMonitor_Lopez
WITH PASSWORD = 'P@ssw0rd123!',
     DEFAULT_DATABASE = [master],
     CHECK_EXPIRATION = ON,
     CHECK_POLICY = ON;
GO
CREATE LOGIN DbaJunior_Paz
WITH PASSWORD = 'P@ssw0rd123!',
     DEFAULT_DATABASE = [master],
     CHECK_EXPIRATION = ON,
     CHECK_POLICY = ON;
GO

-- Verificar que se crearon
SELECT 
    name AS LoginName,
    type_desc AS Type,
    create_date AS CreateDate
FROM sys.server_principals
WHERE type = 'S'  -- S = SQL Login
AND name IN ('SecAuditor_Gomez', 'NocMonitor_Lopez', 'DbaJunior_Paz')
ORDER BY name;
GO

-- Ver logins y sus roles de servidor
SELECT 
    sp.name AS LoginName,
    sp.type_desc AS Type,
    sr.name AS ServerRole
FROM sys.server_principals sp
LEFT JOIN sys.server_role_members srm ON sp.principal_id = srm.member_principal_id
LEFT JOIN sys.server_principals sr ON srm.role_principal_id = sr.principal_id
WHERE sp.type IN ('S', 'U', 'G')
ORDER BY sp.name;
GO

print '>>>3. Gestion de Ciclo de Vida: Bloqueo de acccesos sospechosos...'

--Cambiar contraseña de Login
ALTER LOGIN DbaJunior_Paz WITH PASSWORD ='Nueva_P@ssw0rd!'

-- Deshabilitar Login Sospechoso
ALTER LOGIN DbaJunior_Paz DISABLE;
ALTER LOGIN DbaJunior_Paz ENABLE;

-- Eliminar Login
DROP LOGIN DbaJunior_Paz;

-- Cambiar base de datos por defecto
ALTER LOGIN DbaJunior_Paz
WITH DEFAULT_DATABASE = [master];
GO

print '>>> 4. Asignacion de roles fijos de servidor...'

ALTER SERVER ROLE securityadmin
ADD MEMBER [SecAuditor_Gomez];
GO
ALTER SERVER ROLE processadmin
ADD MEMBER [NocMonitor_Lopez];
GO
ALTER SERVER ROLE diskadmin
ADD MEMBER [DbaJunior_Paz];
GO

print '>>>5. Validacion Dinamica'
-- ============================================
-- CONSULTAR SERVER ROLES
-- ============================================

-- Ver todos los server roles
SELECT name, type_desc, is_fixed_role
FROM sys.server_principals
WHERE type = 'R'
ORDER BY name;
GO

-- Ver miembros de un server role específico
SELECT 
    role.name AS RoleName,
    member.name AS MemberName,
    member.type_desc AS MemberType
FROM sys.server_role_members srm
JOIN sys.server_principals role ON srm.role_principal_id = role.principal_id
JOIN sys.server_principals member ON srm.member_principal_id = member.principal_id
WHERE role.name = 'securityadmin'
ORDER BY member.name;
GO

-- Ver todos los roles de un login específico
SELECT 
    sp.name AS ServerRole
FROM sys.server_role_members srm
JOIN sys.server_principals sp ON srm.role_principal_id = sp.principal_id
WHERE srm.member_principal_id = (
    SELECT principal_id 
    FROM sys.server_principals 
    WHERE name = 'DbaJunior_Paz'
);
GO
    
-- Ejercicio 7
-- Contexto: La plataforma de streaming "StreamPlay" necesita configurar la seguridad interna de su base de datos de producción. 
-- El área de ciberseguridad exige aplicar de forma estricta el principio de "privilegio mínimo", resguardar datos 
-- sensibles de los clientes (como los métodos de pago) y dar acceso controlado al equipo de soporte, creadores de 
-- contenido y auditores de sistemas.
-- Consigna: Desarrollar un script unificado en Transact-SQL que implemente la infraestructura de seguridad lógica en la 
-- base de datos StreamPlayDB resolviendo los siguientes requerimientos prácticos:

--      1.	Modelado Base: Crear la base de datos y tres estructuras clave: Suscripciones (datos de usuarios y cobros), 
--                                                                      Catalogo (películas y series) y 
--                                                                      Visualizaciones (historial de reproducción).
--      2.	Aprovisionamiento Perimetral: Crear cinco logins a nivel de servidor y sus correspondientes usuarios mapeados 
-- exclusivamente dentro de la base de datos del negocio.
--      3.	Roles de Base de Datos: Asignar los roles fijos db_datareader y db_datawriter según corresponda para dar acceso 
-- de lectura global o control operativo de datos.
--      4.	Seguridad Granular (GRANT): Configurar permisos específicos tabla por tabla para perfiles gerenciales, limitando la 
-- capacidad de eliminación destructiva de registros.
--      5.	Restricción de Privilegios (DENY): Implementar bloqueos perimetrales absolutos mediante DENY. Se debe proteger 
-- el catálogo de modificaciones accidentales y ocultar columnas con datos financieros sensibles a nivel de celda.
--      6.	Seguridad Avanzada y Roles Personalizados: Crear un rol de auditoría a la medida que herede permisos de lectura 
-- y obtenga privilegios de inspección de código fuente (VIEW DEFINITION).
--      7.	Normalización de Permisos (REVOKE): Demostrar la remoción de privilegios explícitos para devolver una entidad 
-- a su estado heredado neutral.

print '>>>1. Modelado de la Base de Datos'
-- Crear base de dato

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'StreamPlay')
    DROP DATABASE StreamPlay;
GO

CREATE DATABASE StreamPlay;
GO

USE StreamPlay;
GO

-- ======================
-- TABLA: Suscripciones
-- ======================
CREATE TABLE dbo.Suscripciones(
    suscripcionID INT PRIMARY KEY IDENTITY (1,1),
    usuario NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    tipoPlan NVARCHAR(100) NOT NULL,
    MontoMensual DECIMAL(10,2) NOT NULL,
    FechaAlta DATE NOT NULL,
    Estado NVARCHAR(50) NOT NULL
);
GO
-- ======================
-- TABLA: Catalogo
-- ======================
CREATE TABLE dbo.Catalogo(
    catalogoID INT PRIMARY KEY IDENTITY (1,1),
    titulo NVARCHAR(200) NOT NULL,
    tipoContenido NVARCHAR(50) NOT NULL, --SERIE O PELICULA    
    genero NVARCHAR(50) NOT NULL,
    anioEstreno INT,
    duracion INT
);
GO
-- ======================
-- TABLA: Visualizaciones
-- ======================
CREATE TABLE dbo.Visualizaciones(
    visualizacionID INT IDENTITY(1,1) PRIMARY KEY,
    suscripcionID INT NOT NULL,
    catalogoID INT NOT NULL,
    fechaVisualizacion DATETIME NOT NULL,
    minutosVistos INT NOT NULL,

    CONSTRAINT FK_Visualizaciones_Suscripciones
        FOREIGN KEY (suscripcionID)
        REFERENCES Suscripciones(suscripcionID),

    CONSTRAINT FK_Visualizaciones_Catalogo
        FOREIGN KEY (catalogoID)
        REFERENCES Catalogo(catalogoID)
);
GO


-- Insert de datos 
INSERT INTO dbo.Suscripciones
(usuario, email, tipoPlan, MontoMensual, FechaAlta, Estado)
VALUES
('Max Rodriguez', 'max@email.com', 'Premium', 12999.99, '2025-01-10', 'Activo'),
('Ana Lopez', 'ana@email.com', 'Basico', 6999.99, '2025-02-15', 'Activo'),
('Juan Perez', 'juan@email.com', 'Estandar', 9999.99, '2025-03-20', 'Activo'),
('Maria Gomez', 'maria@email.com', 'Premium', 12999.99, '2025-04-05', 'Suspendido');
GO
INSERT INTO dbo.Catalogo
(titulo, tipoContenido, genero, anioEstreno, duracion)
VALUES
('The Matrix', 'Pelicula', 'Ciencia Ficcion', 1999, 136),
('Breaking Bad', 'Serie', 'Drama', 2008, NULL),
('Interstellar', 'Pelicula', 'Ciencia Ficcion', 2014, 169),
('Stranger Things', 'Serie', 'Terror', 2016, NULL);
GO
INSERT INTO dbo.Visualizaciones
(suscripcionID, catalogoID, fechaVisualizacion, minutosVistos)
VALUES
(1, 1, '2026-06-15 20:30:00', 136),
(2, 2, '2026-06-16 18:15:00', 45),
(3, 3, '2026-06-17 21:00:00', 120),
(4, 4, '2026-06-18 19:45:00', 50);
GO

-- ═══════════════════════════════════════════════
-- Crear LOGINS en el servidor (nivel servidor)
-- ═══════════════════════════════════════════════
print '>>> 2. Logins a nivel de servidor y sus correspondientes usuarios mapeados...'
USE [master];

CREATE LOGIN [usuario_ventas] WITH PASSWORD = 'Ventas2026!';
CREATE LOGIN [usuario_it] WITH PASSWORD = 'IT2026!';
CREATE LOGIN [usuario_rrhh] WITH PASSWORD = 'RRHH2026!';
CREATE LOGIN [usuario_gerente] WITH PASSWORD = 'Gerente2026!';
CREATE LOGIN [usuario_auditor] WITH PASSWORD = 'Auditor2026!';

--
PRINT '✅ Logins creados en el servidor';
GO

--  Crear Usuarios en la Base de Datos
USE StreamPlay;
GO

CREATE USER [usuario_ventas] FOR LOGIN [usuario_ventas];
GO
CREATE USER [usuario_it] FOR LOGIN [usuario_it];
GO
CREATE USER [usuario_rrhh] FOR LOGIN [usuario_rrhh];
GO
CREATE USER [usuario_gerente] FOR LOGIN [usuario_gerente];
GO
CREATE USER [usuario_auditor] FOR LOGIN [usuario_auditor];
GO


-- VALIDACIÓN:
SELECT 
    name AS UserName,
    type_desc AS UserType,
    create_date AS FechaCreacion
FROM sys.database_principals
WHERE type = 'S' AND name LIKE 'usuario_%'
ORDER BY name;
GO

print '>>> 3. Roles en la Base de Datos...'

-- Usuario Ventas (Lectura)
ALTER ROLE [db_datareader] ADD MEMBER usuario_ventas;


-- Usuario it (Lectura y escritura)
ALTER ROLE [db_datareader] ADD MEMBER usuario_it;
ALTER ROLE [db_datawriter] ADD MEMBER usuario_it;

-- Usuario rrhh (Lectura )
ALTER ROLE [db_datareader] ADD MEMBER usuario_rrhh;

-- Usuario rrhh (Lectura )
ALTER ROLE [db_datareader] ADD MEMBER usuario_gerente;

-- Usuario rrhh (Lectura )
ALTER ROLE [db_datareader] ADD MEMBER usuario_auditor;

-- VALIDACIÓN:
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(member_principal_id) LIKE 'usuario_%'
ORDER BY Usuario, Rol;
GO

print '>>>4. Seguridad Granular: Permisos espeficicos para perfiles gerenciales...'

--Permisos en Suscripciones
GRANT SELECT ON dbo.Suscripciones TO [usuario_gerente];
GRANT INSERT ON dbo.Suscripciones TO [usuario_gerente];
GRANT UPDATE ON dbo.Suscripciones TO [usuario_gerente];

--Permisos en Catalogo
GRANT SELECT ON dbo.Catalogo TO [usuario_gerente];
GRANT INSERT ON dbo.Catalogo TO [usuario_gerente];
GRANT UPDATE ON dbo.Catalogo TO [usuario_gerente];

--Permisos en Visualizaciones
GRANT SELECT ON dbo.Visualizaciones TO [usuario_gerente];

-- VALIDACIÓN:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_gerente'
  AND class_desc = 'OBJECT_OR_COLUMN'
ORDER BY Tabla, Permiso;
GO

print '>>>5. Bloqueos perimetrales absolutos mediante DENY...'

-- usuario_ventas (no administra peliculas o series)
DENY INSERT,UPDATE,DELETE
ON dbo.Catalogo
TO usuario_ventas;
go

-- usuario_rrhh
DENY INSERT,UPDATE,DELETE
ON dbo.Catalogo
TO usuario_rrhh;
go

--usuario_auditor
DENY INSERT,UPDATE,DELETE
ON dbo.Catalogo
TO usuario_auditor;
go

-- b) VALIDACIÓN:
SELECT
    USER_NAME(grantee_principal_id) AS Usuario,
    permission_name,
    state_desc,
    OBJECT_NAME(major_id) AS Objeto
FROM sys.database_permissions
WHERE OBJECT_NAME(major_id) = 'Catalogo'
ORDER BY Usuario;

-- Ocultar columna de datos financieros

--usuario_rrhh
DENY SELECT ON dbo.Suscripciones(MontoMensual) TO [usuario_rrhh];
--usuario_auditor
DENY SELECT ON dbo.Suscripciones(MontoMensual) TO [usuario_auditor];

SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    COL_NAME(major_id, minor_id) AS Columna,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_auditor' --usuario_rrhh
  AND state_desc = 'DENY'
ORDER BY Tabla, Columna;
GO

print '>>>6. Seguridad Avanzada y Roles Personalizados'

-- a) Crear el rol AuditorRole
CREATE ROLE [AuditorRole];
GO

-- b) Asignar rol db_datareader al AuditorRole
ALTER ROLE [db_datareader] ADD MEMBER [AuditorRole];
GO

-- c) Otorgar permiso VIEW DEFINITION a nivel de base de datos
GRANT VIEW DEFINITION TO [AuditorRole];
GO

-- Otorgarle Rol a usuario_auditor
ALTER ROLE [AuditorRole] ADD MEMBER usuario_auditor;


-- VALIDACIÓN: Ver el rol y sus miembros
SELECT 
    USER_NAME(role_principal_id) AS Rol,
    USER_NAME(member_principal_id) AS Miembro
FROM sys.database_role_members
WHERE USER_NAME(role_principal_id) = 'AuditorRole'
   OR USER_NAME(member_principal_id) = 'AuditorRole';
GO
-- VALIDACIÓN: Ver permisos del rol
SELECT 
    USER_NAME(grantee_principal_id) AS Rol,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'AuditorRole';
GO

print '>>> 7.Normalización de Permisos (REVOKE)...'

REVOKE SELECT ON dbo.Suscripciones FROM [usuario_gerente];
REVOKE INSERT ON dbo.Suscripciones FROM [usuario_gerente];
REVOKE UPDATE ON dbo.Suscripciones FROM [usuario_gerente];
GO

PRINT '✅ Permisos REVOKE aplicados correctamente';
GO

-- VALIDACIÓN:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_gerente'
  AND class_desc = 'OBJECT_OR_COLUMN'
ORDER BY Tabla, Permiso;
GO

-- a) Listar TODOS los usuarios de la base de datos y sus roles
PRINT '📊 a) USUARIOS Y SUS ROLES:';
SELECT 
    dp.name AS Usuario,
    dp.type_desc AS TipoUsuario,
    STRING_AGG(role.name, ', ') AS Roles
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals role ON drm.role_principal_id = role.principal_id
WHERE dp.type IN ('S', 'U')  -- S = SQL user, U = Windows user
  AND dp.name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys', 'dbo')
GROUP BY dp.name, dp.type_desc
ORDER BY dp.name;
GO

PRINT '';

-- b) Listar TODOS los permisos GRANT otorgados a nivel de tabla
PRINT '📊 b) PERMISOS GRANT A NIVEL DE TABLA:';
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE class_desc = 'OBJECT_OR_COLUMN'
  AND state_desc = 'GRANT'
  AND major_id > 0
ORDER BY Usuario, Tabla, Permiso;
GO

-- c) Listar TODOS los permisos DENY activos en la base de datos
PRINT '📊 c) PERMISOS DENY ACTIVOS:';
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    CASE 
        WHEN class_desc = 'OBJECT_OR_COLUMN' THEN OBJECT_NAME(major_id)
        WHEN class_desc = 'DATABASE' THEN 'BASE DE DATOS'
        ELSE class_desc
    END AS ObjetoAfectado,
    CASE 
        WHEN minor_id > 0 THEN COL_NAME(major_id, minor_id)
        ELSE 'N/A'
    END AS Columna,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE state_desc = 'DENY'
ORDER BY Usuario, ObjetoAfectado;
GO

PRINT '';

-- d) Listar qué usuarios NO tienen ningún permiso asignado
PRINT '📊 d) USUARIOS SIN PERMISOS ASIGNADOS:';
SELECT 
    dp.name AS Usuario,
    dp.type_desc AS Tipo
FROM sys.database_principals dp
WHERE dp.type IN ('S', 'U')  -- Solo usuarios SQL y Windows
  AND dp.name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys', 'dbo')
  AND NOT EXISTS (
      -- No tienen permisos directos
      SELECT 1 FROM sys.database_permissions
      WHERE grantee_principal_id = dp.principal_id
  )
  AND NOT EXISTS (
      -- No están en ningún rol
      SELECT 1 FROM sys.database_role_members
      WHERE member_principal_id = dp.principal_id
  )
ORDER BY dp.name;
GO

PRINT '';

-- e) Ver un resumen de permisos por usuario
PRINT '📊 e) RESUMEN DE PERMISOS POR USUARIO:';
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    COUNT(*) AS TotalPermisos,
    SUM(CASE WHEN state_desc = 'GRANT' THEN 1 ELSE 0 END) AS TotalGRANT,
    SUM(CASE WHEN state_desc = 'DENY' THEN 1 ELSE 0 END) AS TotalDENY,
    SUM(CASE WHEN class_desc = 'OBJECT_OR_COLUMN' THEN 1 ELSE 0 END) AS PermisosEnTablas,
    SUM(CASE WHEN class_desc = 'DATABASE' THEN 1 ELSE 0 END) AS PermisosEnBD
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) LIKE 'usuario_%'
   OR USER_NAME(grantee_principal_id) = 'AuditorRole'
GROUP BY grantee_principal_id
ORDER BY Usuario;
GO


-- Ejercicio 8
--  Contexto: Para optimizar el espacio de almacenamiento de la plataforma "SportNet", el equipo de desarrollo solicitó que 
--              los registros de la tabla de accesos que tengan más de 30 días de antigüedad se eliminen de forma automática. 
--              De esta manera, se evita que la base de datos crezca indefinidamente con datos obsoletos.
--  Consigna: Escribir un script unificado en Transact-SQL utilizando el subsistema de msdb que configure un Job automatizado 
--              en el SQL Server Agent bajo las siguientes especificaciones:
--      1.	Configuración Global: Crear un Job llamado Limpieza_Automatica_Accesos_SportNet.
--      2.	Definición del Paso (Job Step): Configurar un paso de ejecución de tipo T-SQL que aplique un comando estándar de eliminación (DELETE) sobre la tabla Socios.RegistroAccesos de la base de datos SportNetDB. El comando debe borrar las filas cuya fecha sea menor a la actual. Establecer una política de 2 reintentos ante fallas.
--      3.	Planificación Horaria (Schedule): Programar la tarea para que se ejecute de forma recurrente todos los 
--          domingos a las 03:00 AM.
--      4.	Asignación de Destino: Enlazar el Job para que corra de manera local en la instancia del servidor actual.

USE msdb ;
GO
print '>>>1. Configuracion Global...'

EXEC dbo.sp_add_job
    @job_name = N'Limpieza_Automatica_Accesos_SportNetDB_TSQL', 
    @enabled = 1,
    @description = N'Job automatizado para la limpieza de la tabla de Accesos cada 30 dias.' ;
GO

print '>>>2. job Step...'

EXEC sp_add_jobstep
    @job_name = N'Limpieza_Automatica_Accesos_SportNetDB_TSQL',
    @step_name = N'Eliminar Accesos obsoletos TSQL',
    @subsystem = N'TSQL',
    @command = N'DELETE FROM SportNetDB.Socios.RegistroAccesos
                 WHERE FechaHora < DATEADD(DAY,-30,GETDATE());', 
    @retry_attempts = 2,
    @retry_interval = 5 ;
GO

print '>>>3. Planificacion Horaria'

EXEC dbo.sp_add_jobschedule
    @job_name = N'Limpieza_Automatica_Accesos_SportNetDB_TSQL',
    @name = N'Domingos_03AM',
    @freq_type = 8,                   -- Frecuencia Semanal
    @freq_interval = 1,               -- Domingo
    @freq_recurrence_factor = 1,    -- Cada 1 semana
    @active_start_time = 030000 ;     -- Formato de hora estándar HHMMSS
GO

print '>>>4.Asignacion de Destino...'

EXEC dbo.sp_add_jobserver
    @job_name = N'Limpieza_Automatica_Accesos_SportNetDB_TSQL',
    @server_name = N'(local)' ;
GO


-- Ejercicio 9
-- Contexto: La cadena "CoffeeHouse" opera con un sistema de puntos de venta centralizado. Debido a la criticidad 
--           de las transacciones comerciales, el área de sistemas exige implementar una política de respaldo bajo 
--           el modelo de recuperación completa (FULL). Como Administrador de Bases de Datos (DBA), debe simular 
--           el flujo diario de operaciones, ejecutar la secuencia de copias de seguridad programadas y, ante un 
--           escenario simulado de pérdida total de datos, liderar el protocolo de restauración de emergencia sin 
--           perder una sola venta.
-- Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes fases de contingencia:
--      1.	Infraestructura Base: Crear la base de datos CoffeeHouseDB junto con las tablas relacionales de clientes
--          y órdenes de compra con una carga de datos inicial (Simulación: Estado de ventas a las 08:00 AM).
--      2.	Línea Base General (Backup Full): Configurar el modelo de recuperación en modo completo y generar el respaldo total 
--      de la estructura (Simulación: 09:00 AM).
--      3.	Punto de Control Acumulativo (Backup Diferencial): Insertar actividad comercial y generar un respaldo diferencial 
--          para empaquetar los cambios de la mañana (Simulación: 11:00 AM).
--      4.	Resguardos Transaccionales (Backups de Log): Intercalar nuevas ventas con la ejecución secuencial de dos copias del Log de transacciones para registrar la actividad de la tarde (Simulación: 12:00 PM y 02:00 PM).
--      5.	Protocolo de Recuperación: Simular un colapso crítico del sistema y reconstruir la base de datos de forma ordenada utilizando las cláusulas NORECOVERY y RECOVERY en el orden cronológico correcto.
--      6.	Validación de Integridad: Comprobar mediante consultas de combinación que la base de datos fue recuperada en su totalidad.

print '>>>1. Infraestructura Base'
-- ==========================================
-- Crear Base de Datos
-- ==========================================
USE master;
CREATE DATABASE CoffeeHouseDB;
GO

USE CoffeeHouseDB;
GO

-- ==========================================
-- Tabla Clientes
-- ==========================================
CREATE TABLE Clientes
(
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Telefono NVARCHAR(20) NULL,
    FechaRegistro DATE NOT NULL
);
GO

-- ==========================================
-- Tabla OrdenesCompra
-- ==========================================
CREATE TABLE OrdenesCompra
(
    OrdenID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT NOT NULL,
    FechaOrden DATETIME NOT NULL,
    Total DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrdenesCompra_Clientes
        FOREIGN KEY (ClienteID)
        REFERENCES Clientes(ClienteID)
);
GO

-- ==========================================
-- Carga Inicial de Clientes
-- ==========================================
INSERT INTO Clientes
(
    Nombre,
    Email,
    Telefono,
    FechaRegistro
)
VALUES
('Juan Perez', 'juan@email.com', '1122334455', '2026-01-15'),
('Maria Gomez', 'maria@email.com', '1133445566', '2026-02-10'),
('Ana Lopez', 'ana@email.com', '1144556677', '2026-03-05'),
('Carlos Rodriguez', 'carlos@email.com', '1155667788', '2026-04-20');
GO

-- ==========================================
-- Carga Inicial de Ordenes
-- ==========================================
INSERT INTO OrdenesCompra
(
    ClienteID,
    FechaOrden,
    Total
)
VALUES
(1, '2026-06-10 08:30:00', 1250.50),
(2, '2026-06-11 09:15:00', 980.00),
(3, '2026-06-12 11:45:00', 1575.75),
(1, '2026-06-13 14:20:00', 650.00);
GO
select * from OrdenesCompra;

-- Simulación de Ventas de la Mañana
--A las 8:00 AM ingresa una nueva venta al sistema.
INSERT INTO OrdenesCompra (ClienteID, FechaOrden, Total) VALUES 
(3, '2026-06-16 08:00:00', 2500000.00);
GO

print '>>>2. Configurar el modelo de recuperación en modo completo y generar el respaldo total...'
--Paso 1: Configurar el Modelo de Recuperación Obligatorio

ALTER DATABASE [CoffeeHouseDB] SET RECOVERY FULL;
GO

--Paso 2: Generar la Línea Base General (Backup Full)
--A las 09:00 AM se realiza el respaldo completo inicial del sistema.
BACKUP DATABASE [CoffeeHouseDB]
TO DISK = 'c:\backups\coffeehouse_full.bak'
WITH FORMAT, MEDIANAME = 'CoffeeHouse_Media', NAME = 'Full CoffeeHouse Backup';
GO

print '>>>3. Generar Backup Diferencial...'
--Paso 3: Simulación de Ventas de la Mañana
--A las 10:00 AM ingresa una nueva venta al sistema.
INSERT INTO OrdenesCompra (ClienteID, FechaOrden, Total) VALUES 
(2, '2026-06-16 10:00:00', 2000.00);
GO

--Paso 4: Backup Diferencial
--A las 10:00 AM, para salvaguardar los cambios de la mañana sin saturar el disco duro, se ejecuta un respaldo diferencial.
BACKUP DATABASE [CoffeeHouseDB]
TO DISK = 'c:\backups\coffeehouse_diff.bak'
WITH DIFFERENTIAL, FORMAT, MEDIANAME = 'CoffeeHouse_DiffMedia', NAME = 'Diff CoffeeHouse Backup';
GO

print '>>>4. Generar Resguardos Transaccionales (Backups de Log)...'

--Paso 5: Nuevas Ventas de la Tarde y Primer Backup del Log
--A las 12:00 PM se registra una nueva venta, y se ejecuta el primer respaldo del Log de transacciones para capturar esta actividad.
INSERT INTO OrdenesCompra (ClienteID, FechaOrden, Total) VALUES 
(2, '2026-06-16 12:00:00', 950.00);
GO

--Inmediatamente, se realiza el primer respaldo del Log de Transacciones (capturando esta última venta):
BACKUP LOG [CoffeeHouseDB]
TO DISK = 'c:\backups\coffeehouse_log1.trn'
WITH FORMAT, NAME = 'Log CoffeeHouse Backup 1';
GO

--A las 02:00 PM se registra una nueva venta.
INSERT INTO OrdenesCompra (ClienteID, FechaOrden, Total) VALUES 
(2, '2026-06-16 14:00:00', 950.00);
GO

--Inmediatamente, se realiza el segundo respaldo del Log de Transacciones (capturando esta última venta):
BACKUP LOG [CoffeeHouseDB]
TO DISK = 'c:\backups\coffeehouse_log2.trn'
WITH FORMAT, NAME = 'Log CoffeeHouse Backup 2';
GO

print '>>>5. Protocolo de Recuperación'
--FASE 4: PROTOCOLO DE RECUPERACIÓN DE EMERGENCIA (Restauración)

USE master;
GO

-- 1. Desconectar cualquier intento de reconexión de usuarios/aplicaciones
ALTER DATABASE [CoffeeHouseDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- 2. Paso A: Restaurar la estructura base fundamental (Full)
RESTORE DATABASE [CoffeeHouseDB]
FROM DISK = 'c:\backups\coffeehouse_full.bak'
WITH NORECOVERY, REPLACE;
GO

-- 3. Paso B: Adelantar el tiempo con el punto acumulativo (Diferencial)
RESTORE DATABASE [CoffeeHouseDB]
FROM DISK = 'c:\backups\coffeehouse_diff.bak'
WITH NORECOVERY;
GO

-- 4. Paso C: Aplicar primer tramo de transacciones perdidas (Log 1)
RESTORE LOG [CoffeeHouseDB]
FROM DISK = 'c:\backups\coffeehouse_log1.trn'
WITH NORECOVERY;
GO

-- 5. Paso D: Aplicar el último tramo y abrir la empresa al público (Log 2 + RECOVERY)
RESTORE LOG [CoffeeHouseDB]
FROM DISK = 'c:\backups\coffeehouse_log2.trn'
WITH RECOVERY;
GO

print '>>>6. Validacion de Integridad...'

--FASE 5: VALIDACIÓN DE DATOS 
--Para finalizar el TP y dar por aprobado el laboratorio, tenes que verificar que no se perdió absolutamente ningún registro comercial. Al ejecutar la siguiente consulta, el sistema debe devolver la cantidad de pedidos en total:
USE CoffeeHouseDB;
GO
SELECT o.OrdenID, C.Nombre, C.Email, o.ClienteID, o.Total 
FROM OrdenesCompra o
INNER JOIN Clientes C ON o.ClienteID = C.ClienteID;
GO

Ejercicio 10
Responde el siguiente cuestionario de múltiple choice sobre Alta Disponibilidad.
1. Si la prioridad absoluta de una empresa es poder utilizar el servidor secundario de respaldo para generar reportes pesados de forma aislada, ¿cuál es la solución tecnológica recomendada por defecto en la actualidad?
•	A) Clustering (FCI), porque el nodo pasivo permite lecturas transparentes.
•	B) Mirroring (Reflejo), ya que mantiene la base de datos en estado de recuperación legible.
•	C) Always On AG, debido a que permite configurar copias legibles (Secondaries Read-Only) para reportes.
•	D) Replicación, ya que es la opción que ofrece el failover automático más veloz del mercado.
2. Al analizar la infraestructura de almacenamiento de la tecnología Clustering (FCI), ¿cuál es el principal riesgo técnico asociado a su diseño?
•	A) Que duplica el uso de discos independientes por cada servidor, encareciendo los costos.
•	B) El uso de almacenamiento compartido (SAN/NAS), que introduce un riesgo de punto único de falla.
•	C) Que obliga a que la base de datos permanezca en un estado inaccesible llamado RECOVERING.
•	D) Que no requiere la configuración de un clúster de Windows (WSFC), perdiendo soporte del sistema operativo.
3. Un administrador de sistemas propone utilizar "Mirroring" (Reflejo) para proteger una base de datos individual en un proyecto nuevo. Según el estado actual de la tecnología (2026), ¿cuál es la postura correcta ante esta sugerencia?
•	A) Debe aceptarse, ya que es el estándar actual de la industria para bases de datos individuales.
•	B) Debe rechazarse, porque es una tecnología depreciada sin soporte activo por parte de Microsoft.
•	C) Debe aceptarse, porque ofrece un failover automático a nivel de grupo de bases de datos.
•	D) Debe rechazarse, únicamente porque requiere obligatoriamente la instalación de un clúster de Windows (WSFC).
4. ¿Cuál es la diferencia conceptual clave en el "Nivel de Protección" entre Clustering (FCI) y Always On AG ante una falla de hardware?
•	A) FCI protege objetos individuales (tablas/vistas) y Always On protege servidores físicos completos.
•	B) FCI ofrece failover manual y Always On es la única que permite failover automático.
•	C) FCI protege bases de datos individuales aisladas y Always On requiere discos compartidos SAN/NAS.
•	D) FCI protege la instancia completa de SQL Server, mientras que Always On protege un grupo de bases de datos elegidas.
5. ¿Qué requisito del sistema operativo Windows comparten obligatoriamente las tecnologías "Clustering (FCI)" y "Always On AG" para poder operar?
•	A) Ninguno, ambas tecnologías funcionan de forma nativa sin requerimientos especiales de Windows.
•	B) Ambas dependen estrictamente de un servidor de testigos externo (Witness).
•	C) Ambas dependen de la configuración de un Windows Server Failover Cluster (WSFC).
•	D) Ambas requieren que los discos de almacenamiento de los servidores estén físicamente duplicados.

Respuestas:
1. C) Always On AG, debido a que permite configurar copias legibles (Secondaries Read-Only) para reportes.
2. B) El uso de almacenamiento compartido (SAN/NAS), que introduce un riesgo de punto único de falla.
3. B) Debe rechazarse, porque es una tecnología depreciada sin soporte activo por parte de Microsoft.
4. D) FCI protege la instancia completa de SQL Server, mientras que Always On protege un grupo de bases de datos elegidas.
5. C) Ambas dependen de la configuración de un Windows Server Failover Cluster (WSFC).