-- Trabajo Practico Partición Lógica de Tablas

-- OBJETIVO:
--  Implementar una estrategia de particionamiento horizontal sobre una tabla de
--  historial de ventas, distribuyendo los datos en filegroups separados según
--  rangos anuales de fecha de orden.

-- ESCENARIO:
--   La empresa necesita mejorar el rendimiento de las consultas sobre la tabla
--   de órdenes de venta, que contiene millones de registros históricos.
--   Se decide particionar la tabla SalesOrderHeader por año de OrderDate,
--   creando 4 particiones:
--     - Partición 1: Órdenes anteriores al 01/01/2005
--     - Partición 2: Órdenes entre 01/01/2005 y 31/12/2005
--     - Partición 3: Órdenes entre 01/01/2006 y 31/12/2006
--     - Partición 4: Órdenes a partir del 01/01/2007

-- BASE DE DATOS: AdventureWorks
-- CONSIGNA 1: FUNCIÓN DE PARTICIÓN
-- Crear una función de partición llamada pf_SalesYear de tipo RANGE RIGHT
-- sobre un campo datetime, con valores límite:
--   '01/01/2005', '01/01/2006', '01/01/2007'

use AdventureWorks2008R2;
create PARTITION function pf_SalesYear (datetime)
AS RANGE RIGHT
FOR VALUES ('01/01/2005', '01/01/2006', '01/01/2007')
GO

-- PREGUNTA TEÓRICA:
--   ¿Qué diferencia hay entre RANGE LEFT y RANGE RIGHT?
--   ¿A qué partición pertenece la fecha '01/01/2006' con RANGE RIGHT?

-- CONSIGNA 2: FILEGROUPS Y ARCHIVOS DE DATOS
-- a) Agregar 4 filegroups a la base de datos AdventureWorks:
--       fgSales1, fgSales2, fgSales3, fgSales4
alter database AdventureWorks2008R2 add filegroup fgSales1
alter database AdventureWorks2008R2 add filegroup fgSales2
alter database AdventureWorks2008R2 add filegroup fgSales3
alter database AdventureWorks2008R2 add filegroup fgSales4

-- ver mis filegroups
SELECT 
    name AS Filegroup,
    type_desc,
    is_default
FROM sys.filegroups;
-- b) Agregar un archivo .ndf a cada filegroup con las siguientes características:
--       - Nombres lógicos:  salesdata1, salesdata2, salesdata3, salesdata4
--       - Ruta:  C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\
--       - Nombres físicos: SalesHist1.ndf, SalesHist2.ndf, SalesHist3.ndf, SalesHist4.ndf
--       - SIZE = 2MB, MAXSIZE = 200MB, FILEGROWTH = 2MB
backup log AdventureWorks2008R2 to disk = 'NUL';

alter database AdventureWorks2008R2
add file
(
    NAME = data1,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\SalesHist1.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
)
to filegroup fgSales1
GO

alter database AdventureWorks2008R2
add file
(
    NAME = data2,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\SalesHist2.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
)
to filegroup fgSales2
GO

alter database AdventureWorks2008R2
add file
(
    NAME = data3,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\SalesHist3.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
)
to filegroup fgSales3
GO
alter database AdventureWorks2008R2
add file
(
    NAME = data4,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\SalesHist4.ndf',
    SIZE = 1MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 1MB
)
to filegroup fgSales4
GO

-- PREGUNTA TEÓRICA:
--   ¿Para qué sirve distribuir particiones en filegroups distintos?
--   Mencione al menos dos ventajas operativas.

-- CONSIGNA 3: ESQUEMA DE PARTICIÓN
-- Crear un esquema de partición llamado ps_SalesYear que utilice la función
-- pf_SalesYear y asigne cada partición a su filegroup correspondiente:
--   Partición 1 → fgSales1
--   Partición 2 → fgSales2
--   Partición 3 → fgSales3
--   Partición 4 → fgSales4

create partition scheme ps_SalesYear
as partition pf_SalesYear
to (fgSales1, fgSales2, fgSales3, fgSales4)
go
-- CONSIGNA 4: TABLA PARTICIONADA
-- Crear la tabla dbo.SalesOrderHeader con la siguiente estructura,
-- particionada sobre el esquema ps_SalesYear usando la columna OrderDate:
--
--   SalesID        int IDENTITY(1,1) NOT NULL
--   SalesOrderID   int NOT NULL
--   CustomerID     int NOT NULL
--   OrderDate      datetime NOT NULL DEFAULT (getdate())
--   TotalDue       money NOT NULL
--   Status         tinyint NOT NULL

create table dbo.SalesOrderHeader
(
    SalesID int identity(1,1) not null,
    SalesOrderID int not null,
    CustomerID int not null,
    OrderDate datetime not null default (getdate()),
    TotalDue money not null,
    Status tinyint not null
)
on ps_SalesYear (OrderDate)
-- CONSIGNA 5: INSERCIÓN DE DATOS
-- a) Insertar en dbo.SalesOrderHeader los datos de la vista/tabla
--    Sales.SalesOrderHeader de AdventureWorks, tomando las columnas:
--    SalesOrderID, CustomerID, OrderDate, TotalDue, Status
--
-- b) Insertar manualmente un registro con:
--    SalesOrderID = 99999, CustomerID = 1, OrderDate = '06/15/2001',
--    TotalDue = 500.00, Status = 5
--    (Este registro debe caer en la Partición 1)
-- CONSIGNA 6: CONSULTAS DE VERIFICACIÓN
-- a) Mostrar todos los registros de dbo.SalesOrderHeader
-- b) Consultar sys.Partitions para obtener el número de filas por partición
--    de la tabla dbo.SalesOrderHeader
-- c) Mostrar SalesID, OrderDate y el número de partición de cada fila
-- d) Para cada partición, mostrar la fecha mínima y máxima de OrderDate
--    y la cantidad de registros. Ordenar por número de partición.
--
-- PREGUNTA TEÓRICA: ¿Los resultados coinciden con los rangos definidos
--    en la función de partición? Justifique.
-- LIMPIEZA - EJECUTAR AL FINALIZAR EL TP
-- ATENCIÓN: Ejecutar esta sección solo una vez completadas y verificadas
-- todas las consignas anteriores.
DROP TABLE dbo.SalesOrderHeader
DROP PARTITION SCHEME ps_SalesYear
DROP PARTITION FUNCTION pf_SalesYear
ALTER DATABASE AdventureWorks REMOVE FILE salesdata1
ALTER DATABASE AdventureWorks REMOVE FILE salesdata2
ALTER DATABASE AdventureWorks REMOVE FILE salesdata3
ALTER DATABASE AdventureWorks REMOVE FILE salesdata4
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales1
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales2
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales3
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales4
