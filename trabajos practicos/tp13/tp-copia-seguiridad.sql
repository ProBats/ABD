--TRABAJO PRÁCTICO COPIA DE SEGURIDAD 

--Caso de Estudio: Distribuidora de Tecnología "TecnoGBA"

--Objetivo: Diseñar, ejecutar y validar una política de respaldos tradicional (Full, Diferencial y Log de Transacciones) para garantizar que la empresa no pierda ventas ante una falla catastrófica de hardware.

--FASE 1: CREACIÓN DEL ENTORNO DE TRABAJO (Punto de partida)
--Antes de iniciar la secuencia de backups, como DBA debes preparar el escenario montando la base de datos de la distribuidora, sus tablas principales y el inventario inicial de la empresa.
USE master;
GO

-- 1. Crear la base de datos limpia
CREATE DATABASE [TecnoGBA];
GO

USE [TecnoGBA];
GO

-- 2. Crear tabla de Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Localidad VARCHAR(100) NOT NULL
);
GO

-- 3. Crear tabla de Pedidos (Ventas)
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT FOREIGN KEY REFERENCES Clientes(ClienteID),
    Producto VARCHAR(100) NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPedido DATETIME DEFAULT GETDATE()
);
GO

-- 4. Carga Inicial de Datos (Estado de la empresa a las 08:00 AM)
INSERT INTO Clientes (Nombre, Localidad) VALUES 
('Erica Ramos', 'Palermo'),
('Jorge Galván', 'Almagro'),
('Estudio Multimedial', 'Caballito');

INSERT INTO Pedidos (ClienteID, Producto, Monto) VALUES 
(1, 'Notebook Samsung Book3', 1200000.00),
(2, 'Monitor Samsung Odyssey G4', 450000.00);
GO

--Paso 1: Configurar el Modelo de Recuperación Obligatorio
--Para poder respaldar los registros minuto a minuto, la base de datos no puede estar en modo simple.
ALTER DATABASE [TecnoGBA] SET RECOVERY FULL;
GO

--Paso 2: Generar la Línea Base General (Backup Full)
--A las 09:00 AM se realiza el respaldo completo inicial del sistema.
--Escribi aca tu respuesta:



--Paso 3: Simulación de Ventas de la Mañana
--A las 10:00 AM ingresa una nueva venta al sistema.
--Escribi aca tu respuesta:



--Paso 4: Generar Punto de Control Acumulativo (Backup Diferencial)
--A las 11:00 AM, para salvaguardar los cambios de la mañana sin saturar el disco duro, se ejecuta un respaldo diferencial.
--Escribi aca tu respuesta:



--Paso 5: Nuevas Ventas de la Tarde y Primer Backup del Log
--A las 12:00 PM se registra un nuevo pedido de la sucursal de Palermo.
--Escribi aca tu respuesta:



--Inmediatamente, se realiza el primer respaldo del Log de Transacciones (capturando esta última venta):
--Escribi aca tu respuesta:



--Paso 6: Última Venta de la Jornada y Segundo Backup del Log
--A las 02:00 PM ingresa la última venta del laboratorio.
--Escribi aca tu respuesta:



--Se ejecuta el segundo respaldo del Log transaccional para cerrar el día seguro:
--Escribi aca tu respuesta:



--FASE 3: EL DESASTRE OPERATIVO
--Escenario de Emergencia: A las 02:30 PM el disco duro principal que aloja la base de datos activa sufre un fallo mecánico total e irrecuperable. Los archivos de datos en producción han desaparecido. La empresa está paralizada.

--FASE 4: PROTOCOLO DE RECUPERACIÓN DE EMERGENCIA (Restauración)
--Instrucciones para el alumno: Como DBA de la distribuidora, debe reconstruir la base de datos utilizando única y exclusivamente los archivos de respaldo resguardados en la carpeta externa (c:\backups\).

--Para tener éxito, se debe respetar el orden cronológico estricto y el uso adecuado de las llaves de estado del motor (NORECOVERY y RECOVERY).
USE master;
GO

-- 1. Desconectar cualquier intento de reconexión de usuarios/aplicaciones
--Escribi aca tu respuesta:


-- 2. Paso A: Restaurar la estructura base fundamental (Full)
--Escribi aca tu respuesta:


-- 3. Paso B: Adelantar el tiempo con el punto acumulativo (Diferencial)
--Escribi aca tu respuesta:


-- 4. Paso C: Aplicar primer tramo de transacciones perdidas (Log 1)
--Escribi aca tu respuesta:


-- 5. Paso D: Aplicar el último tramo y abrir la empresa al público (Log 2 + RECOVERY)
--Escribi aca tu respuesta:


--FASE 5: VALIDACIÓN DE DATOS (Verificación del Alumno)
--Para finalizar el TP y dar por aprobado el laboratorio, tenes que verificar que no se perdió absolutamente ningún registro comercial. Al ejecutar la siguiente consulta, el sistema debe devolver la cantidad de pedidos en total:
USE TecnoGBA;
GO
SELECT P.PedidoID, C.Nombre, C.Localidad, P.Producto, P.Monto 
FROM Pedidos P
INNER JOIN Clientes C ON P.ClienteID = C.ClienteID;
GO




