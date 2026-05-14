-- Trabajo Practico Sistema de Archivos



-- EJERCICIO 1: Creación de base de datos simple
-- Cree una base de datos llamada GestionPersonal con las siguientes
-- especificaciones para el archivo de datos principal (PRIMARY):

--   - Nombre lógico:  GestionPersonal_Data
--   - Archivo físico: C:\DATA\GestionPersonal.MDF
--   - Tamaño inicial:  5 MB
--   - Crecimiento:  1 MB

-- Y para el archivo de log de transacciones:

--   - Nombre lógico:  GestionPersonal_Log
--   - Archivo físico:  C:\DATA\GestionPersonal_Log.LDF
--   - Tamaño inicial:  2 MB
--   - Crecimiento:  1 MB

-- Luego, ponga en uso la base de datos creada.

create database GestionPersonal
on PRIMARY
            (
                name = N'GestionPersonalData',
                filename = N'C:\DATA\GestionPersonal.MDF',
                size = 5 MB,
                filegrowth = 1MB
            )
LOG ON
            (
                name = N'GestionPersonal_Log',
                filename = N'C:\DATA\GestionPersonal_Log.LDF',
                size = 2 MB,
                filegrowth = 1 MB
            )

-- EJERCICIO 2: Creación de base de datos con filegroup adicional
-- Cree una base de datos llamada Inventario con la siguiente estructura:

--  Filegroup PRIMARY (archivo principal):
--    - Nombre lógico: Inventario_Data1
--    - Archivo físico:  C:\DATA\Inventario1.MDF
--    - Tamaño inicial:  10 MB

--  Filegroup adicional llamado HISTORICO (archivo secundario):
--    - Nombre lógico: Inventario_Data2
--    - Archivo físico:  C:\DATA\Inventario2.NDF
--    - Tamaño inicial:  10 MB

--  Archivo de log:
--    - Nombre lógico: Inventario_Log
--    - Archivo físico:  C:\DATA\Inventario_Log.LDF
--    - Tamaño inicial:  5 MB

-- Luego de crear la base de datos, verifique que existe consultando
-- la vista del sistema SYS.DATABASES filtrando por el nombre Inventario.

create database Inventario
on PRIMARY
            (
                name = N'Inventario_Data1', 
                filename = N'c:\DATA\Inventario1.MDF',
                size = 10 MB
            ),
FILEGROUP [HISTORICO]
            (
                name = N'Inventario_Data2',
                filename = N'c:\DATA\Inventario2.MDF',
                size = 10 MB
            )
LOG ON
            (
                name = N'Inventario_Log',
                filename = N'c:\DATA\Inventario_Log.LDF',
                size = 5 MB
            );

select * from SYS.DATABASES where name='Inventario';

-- EJERCICIO 3: Creación y uso de esquemas
-- Dentro de la base de datos GestionPersonal (creada en el Ejercicio 1):

--  a) Cree los esquemas: Rrhh, Contabilidad y Logistica.
use GestionPersonal;

go
create schema Rrhh;
go
create schema Contabilidad;
go
create schema Logistica;
go
--  b) Consulte la vista SYS.SCHEMAS para verificar que los tres esquemas
--     fueron creados correctamente.

select * from SYS.SCHEMAS;

--  c) Cree la siguiente tabla dentro del esquema Rrhh:

--       Empleados (
--           EmpleadoID   int          PRIMARY KEY,
--           Apellido     varchar(40)  NOT NULL,
--           Nombre       varchar(30)  NOT NULL,
--           Cargo        varchar(30)  NULL,
--           FechaIngreso  date         NULL
--       )

create table Rrhh.Empleados(
                            EmpleadoID   int          PRIMARY KEY,
                            Apellido     varchar(40)  NOT NULL,
                            Nombre       varchar(30)  NOT NULL,
                            Cargo        varchar(30)  NULL,
                            FechaIngreso  date         NULL
                            )
--  d) Cree la siguiente tabla dentro del esquema Contabilidad:

--       CuentasContables (
--           CuentaID     int          PRIMARY KEY,
--           Descripcion  varchar(60)  NOT NULL,
--           Saldo        decimal(18,2) NULL
--       )

create table Contabilidad.CuentasContables(
                                            CuentaID     int          PRIMARY KEY,
                                            Descripcion  varchar(60)  NOT NULL,
                                            Saldo        decimal(18,2) NULL
                                        )

--  e) Intente eliminar el esquema Rrhh con DROP SCHEMA y observe
--     qué ocurre. Justifique el resultado con un comentario en el script.

drop schema Rrhh;
-- SQl no permite borrar un esquema que tiene objetos dentro.

-- EJERCICIO 4: Tipos de datos definidos por el usuario
-- Dentro de la base de datos GestionPersonal:

--  a) Cree los siguientes tipos de datos definidos por el usuario (UDT):

--       - DNI      basado en char(8),    NOT NULL
--       - Telefono basado en varchar(20), NULL
--       - Email    basado en varchar(80), NULL

create type DNI from char(8) not null;
create type Telefono from varchar(20) null;
create type Email from varchar(80) null;

--  b) Consulte la vista SYS.TYPES para verificar que los tipos
--     fueron registrados.

select * from sys.types;

-- c) Cree la tabla Rrhh.Contactos utilizando los tipos definidos:

--       Contactos (
--           ContactoID  int        PRIMARY KEY,
--           EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
--           Dni         DNI,
--           Celular     Telefono,
--           CorreoElec  Email
--       )

  --   Incluya la FOREIGN KEY hacia Rrhh.Empleados(EmpleadoID).

create table Rrhh.Contactos(
                            ContactoID  int        PRIMARY KEY,
                            EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
                            Dni         DNI,
                            Celular     Telefono,
                            CorreoElec  Email
                            Foreign Key (EmpleadoID) REFERENCES Rrhh.Empleados(EmpleadoID)
                        )


-- EJERCICIO 5: Ejercicio integrador
-- Cree una base de datos llamada Clínica con:
--   - Archivo principal en C:\DATA\Clinica.MDF, 8 MB de tamaño inicial,
--     crecimiento de 2 MB.
--   - Archivo de log en C:\DATA\Clinica_Log.LDF, 3 MB de tamaño inicial,
--     crecimiento de 1 MB.
create database Clinica
on PRIMARY
            (
                name = N'ClinicaData',
                filename = N'c:\DATA\Clinica.MDF',
                size = 8 MB,
                filegrowth = 2 MB
            )
Log ON
        (
            name = N'Clinica_Log',
            filename = N'c:\DATA\Clinica_Log.LDF',
            size = 3 MB,
            filegrowth = 1MB
        )

-- Dentro de Clínica:

--   a) Cree los esquemas: Pacientes y Médicos.
use Clinica;
go
create schema Pacientes;
go
create schema Medicos;
GO

--   b) Cree los tipos de datos de usuario:
--        - MatriculaMedica  basado en varchar(10), NOT NULL
--        - ObraSocial       basado en varchar(50), NULL

create type MatriculaMedica from varchar(10) not null;
create type ObraSocial from varchar(50) null;
--   c) Cree las siguientes tablas usando los esquemas y UDT correspondientes:

--        Medicos.Profesionales (
--            MedicoID    int               PRIMARY KEY,
--            Apellido    varchar(40)       NOT NULL,
--            Nombre      varchar(30)       NOT NULL,
--            Matricula   MatriculaMedica,
--            Especialidad varchar(40)      NULL
--        )

create table Medicos.Profesionales(
            MedicoID    int               PRIMARY KEY,
            Apellido    varchar(40)       NOT NULL,
            Nombre      varchar(30)       NOT NULL,
            Matricula   MatriculaMedica,
            Especialidad varchar(40)      NULL
        )

--        Pacientes.Personas (
--            PacienteID  int               PRIMARY KEY,
--            Apellido    varchar(40)       NOT NULL,
--            Nombre      varchar(30)       NOT NULL,
--            FechaNac    date              NULL,
--            Cobertura   ObraSocial
--        )

create table Pacientes.Personas (
            PacienteID  int               PRIMARY KEY,
            Apellido    varchar(40)       NOT NULL,
            Nombre      varchar(30)       NOT NULL,
            FechaNac    date              NULL,
            Cobertura   ObraSocial
        )


--        Pacientes.Turnos (
--            TurnoID     int               PRIMARY KEY,
--            PacienteID  int               NOT NULL,
--            MedicoID    int               NOT NULL,
--            FechaTurno  datetime          NOT NULL,
--            Observaciones varchar(200)    NULL,
--            FOREIGN KEY (PacienteID) REFERENCES Pacientes.Personas(PacienteID),
--            FOREIGN KEY (MedicoID)   REFERENCES Medicos.Profesionales(MedicoID)
--        )

create table Pacientes.Turnos (
            TurnoID     int               PRIMARY KEY,
            PacienteID  int               NOT NULL,
            MedicoID    int               NOT NULL,
            FechaTurno  datetime          NOT NULL,
            Observaciones varchar(200)    NULL,
            FOREIGN KEY (PacienteID) REFERENCES Pacientes.Personas(PacienteID),
            FOREIGN KEY (MedicoID)   REFERENCES Medicos.Profesionales(MedicoID)
        )

--   d) Consulte SYS.SCHEMAS y SYS.TABLES para listar los objetos creados.

select * from sys.schemas;
select * from sys.tables;

--   e) Al finalizar, elimine los UDT MatriculaMedica y ObraSocial.
--      ¿Es posible hacerlo directamente? Justifique con un comentario.

drop type MatriculaMedica;
drop type ObraSocial;
-- No es posible eliminarlas, ya que estan siendo utilizadas.
