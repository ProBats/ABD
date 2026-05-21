-- EJERCITACI�N

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
('A0001', '30111222', 'Garc�a', 'Juan', 8.50),
('A0002', '28999888', 'P�rez', 'Mar�a', 7.25),
('A0003', '31555444', 'Garc�a', 'Carlos', 9.00),
('A0004', '32777666', 'Rodr�guez', 'Luc�a', 6.75),
('A0005', '29888777', 'P�rez', 'Ana', 8.00),
('A0006', '33444555', 'Fern�ndez', 'Miguel', 5.50);

-- 3-Intente crear un �ndice agrupado �nico para el campo "apellido".

create unique clustered index I_alumnos_apellido
on alumnos(apellido);

sp_helpindex alumnos;

-- 4-Cree un �ndice agrupado, no �nico, para el campo "apellido".
create clustered index I_alumnos_apellido
on alumnos(apellido);

-- 5-Intente establecer una restricci�n "primary key" al campo "legajo" especificando que cree un �ndice agrupado.

-- Ya existe un indice clustered(solo puede haer 1 por tabla) 

alter table alumnos 
add constraint PK_alumnos_legajo
primary key clustered(legajo);

-- 6-Establezca la restricci�n "primary key" al campo "legajo" especificando que cree un �ndice no agrupado.

alter table alumnos 
add constraint PK_alumnos_legajo
primary key nonclustered(legajo);

-- 7-Vea los �ndices y las restricciones de la tabla alumnos:

sp_helpindex alumnos;

-- 8-Cree un �ndice unique no agrupado para el campo "documento".

create unique nonclustered index I_alumnos_documento
on alumnos(documento);

drop index alumnos.I_alumnos_documento;
-- 9-Intente ingresar un alumno con documento duplicado.

-- No se pueden registrar alumnos con el mismo documento.
INSERT INTO alumnos (legajo, documento, apellido, nombre, nota) VALUES
('A0008', '30111223', 'García', 'Jacinta', 5.50);

select * from alumnos;
-- 10-Elimine el indice agrupado al campo apellido.

drop index alumnos.I_alumnos_apellido;
-- 11-Regenere el indice del campo legajo para que sea agrupado.

alter table alumnos
drop constraint PK_alumnos_legajo
GO

alter table alumnos
add constraint PK_alumnos_legajo
primary key clustered(legajo)
go

exec sp_helpindex alumnos
go
exec sp_helpconstraint alumnos;