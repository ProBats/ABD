-- EJERCITACIÓN

-- 1-Crear una tabla llamada alumnos con los siguientes campos:
  
  legajo: char(5) not null
  documento: char(8) not null
  apellido: varchar(30)
  nombre: varchar(30)
  nota: decimal(4,2)

create database tp9;
GO
use tp9;
GO

create table alumnos (
                        legajo char(5) not null,
                        documento char(8) not null,
                        apellido varchar(30),
                        nombre varchar(30),
                        nota decimal(4,2)
)

drop table alumnos;
-- 2-Ingresar 6 registros con, al menos, 2 registros con igual apellido.

INSERT INTO alumnos (legajo, documento, apellido, nombre, nota) VALUES
('A0001', '30111222', 'García', 'Juan', 8.50),
('A0002', '28999888', 'Pérez', 'María', 7.25),
('A0003', '31555444', 'García', 'Carlos', 9.00),
('A0004', '32777666', 'Rodríguez', 'Lucía', 6.75),
('A0005', '29888777', 'Pérez', 'Ana', 8.00),
('A0006', '33444555', 'Fernández', 'Miguel', 5.50);

-- 3-Intente crear un índice agrupado único para el campo "apellido".

create unique clustered index I_alumnos_apellido
on alumnos(apellido);

sp_helpindex alumnos;

-- 4-Cree un índice agrupado, no único, para el campo "apellido".
create clustered index I_alumnos_apellido
on alumnos(apellido);

-- 5-Intente establecer una restricción "primary key" al campo "legajo" especificando que cree un índice agrupado.



-- 6-Establezca la restricción "primary key" al campo "legajo" especificando que cree un índice no agrupado.

-- 7-Vea los índices y las restricciones de la tabla alumnos:

-- 8-Cree un índice unique no agrupado para el campo "documento".

-- 9-Intente ingresar un alumno con documento duplicado.

-- 10-Elimine el indice agrupado al campo apellido.

-- 11-Regenere el indice del campo legajo para que sea agrupado.

alter table alumnos