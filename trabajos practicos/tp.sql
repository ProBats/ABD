use adventureworks2008R2;
-- TPN1 Writing Queries con SQL Server	
-- select - where

--1. mostrar los empleados que tienen mas de 90 horas de vacaciones
use AdventureWorks2008R2;
select * 
from HumanResources.Employee
where vacationHours > 90;

-- 2. mostrar el nombre, precio y precio con iva de los productos fabricados
select Name Nombre, ListPrice Precio, ListPrice*1.21 'Precio con IVA'
from Production.Product;

-- 3. mostrar los diferentes titulos de trabajo que existen
select JobTitle 
from HumanResources.Employee 
group by JobTitle;
	
-- 4. mostrar todos los posibles colores de productos 
select color 
from Production.Product 
GROUP BY color;
-- 5. mostrar todos los tipos de personas que existen 
select PersonType 
from Person.Person 
group by PersonType;
-- 6. mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea johnson
select FirstName +' '+LastName Nombre
from Person.Person;
-- 7. mostrar todos los productos cuyo precio sea inferior a 150$ de color rojo o cuyo precio sea mayor a 500$ de color negro
select * 
from Production.Product
where ListPrice < 150 and color = 'red' or ListPrice > 500 and color='black';

-- 8. mostrar el codigo, fecha de ingreso y horas de vacaciones de los empleados ingresaron a partir del año 2000
select * from HumanResources.Employee
select BusinessEntityID Codigo, HireDate 'Fecha de ingreso', VacationHours 'Horas de vacaciones'
from HumanResources.Employee
where year(HireDate) >= 2000;

-- 9. mostrar el nombre,nmero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos cuya fecha de fin de venta sea anerior al dia de hoy
select * from Production.Product
select ProductID, Name, ListPrice, ListPrice * 1.1 'Aumento del 10%'
from Production.Product
where SellEndDate < getdate();

-- between & in

-- 10. mostrar todos los porductos cuyo precio de lista este entre 200 y 300 

select *
from Production.Product
where ListPrice between 200 and 300;

-- 11. mostrar todos los empleados que nacieron entre 1970 y 1985 
select *
from HumanResources.Employee
where year(BirthDate) between 1970 and 1985;

-- 12. mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770 
select * from Sales.SalesOrderDetail;
select SalesOrderDetailID, ProductID, OrderQty, UnitPrice
from Sales.SalesOrderDetail
where ProductID in (750,753,770)

-- 13. mostrar todos los porductos cuyo color sea verde, blanco y azul 

select *
from Production.Product
where color in ('green','white','blue')

-- 14. mostrar el la fecha,nuero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 
select * from Sales.SalesOrderHeader
select OrderDate, AccountNumber,SubTotal
from Sales.SalesOrderHeader
where year(OrderDate) between 2005 and 2006

-- like

-- 15. mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos

select * from Production.Product;
select Name, ListPrice, Color
from Production.Product
where ListPrice > 100 and Name like '%seat%'

-- 16. mostrar las bicicletas de montaña que  cuestan entre $1000 y $1200 

select Name, ListPrice
from Production.Product
where ListPrice between 1000 and 1200 and Name like '%mountain bike%'

-- 17. mostrar los nombre de los productos que tengan cualquier combinacion de ‘mountain bike’ 
select Name
from Production.Product
where Name like '%mountain%bike%'

-- 18. mostrar las personas que su nombre empiece con la letra y 

select FirstName, LastName
from Person.Person
where FirstName like 'y%'

-- 19. mostrar las personas que la segunda letra de su apellido es una s 

select FirstName, LastName
from Person.Person
where LastName like '_s%'

-- 20. mostrar el nombre concatenado con el apellido de las personas cuyo apellido tengan terminacion española (ez)
select	FirstName + ' ' + LastName as Persona
from	Person.Person
where	LastName like '%ez'

-- 21. mostrar los nombres de los productos que su nombre termine en un numero 
select	Name as Producto
from	Production.Product
where	Name like '%[0-9]'

-- 22. mostrar las personas cuyo  nombre tenga una c o C como primer caracter, cualquier otro como segundo caracter, ni d ni D ni f ni g como tercer caracter, cualquiera entre j y r o entre s y w como cuarto caracter y el resto sin restricciones
select	FirstName Nombre
from	Person.Person
where	FirstName like '[c,C]_[^dDfg][j-w]%'

-- 23. mostrar las personas ordernadas primero por su apellido y luego por su nombre
select		FirstName + '            ' + LastName as Persona 
from		Person.Person
order by	LastName asc, FirstName asc

-- 24. mostrar cinco productos mas caros y su nombre ordenado en forma alfabetica
select	top 5	*
from			Production.Product
order by		ListPrice desc, Name asc

-- 25. mostrar la fecha mas reciente de venta
select	MAX(OrderDate) as 'fecha mas reciente de venta'
from	Sales.SalesOrderHeader


-- 26. mostrar el precio mas barato de todas las bicicletas 

select	MIN(ListPrice) as 'bici mas barata'
from	Production.Product
where	Name like '%bike%'

-- 27. mostrar la fecha de nacimiento del empleado mas joven 
select	Max(BirthDate) as 'Nacimiento del empleado mas joven'
from	HumanResources.Employee

-- 28. mostrar los representantes de ventas (vendedores) que no tienen definido el numero de territorio
SELECT *
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL


-- 29. mostrar el peso promedio de todos los articulos. si el peso no estuviese definido, reemplazar por cero
select	AVG(ISNULL(Weight, 0)) as 'Peso Promedio'
from	Production.Product

-- group by

-- 30. mostrar el codigo de subcategoria y el precio del producto mas barato de cada una de ellas 
select		ProductSubcategoryID as Subcategoria,
			MIN(ListPrice) 'Precio mas barato'
from		Production.Product
group by	ProductSubcategoryID

-- 31. mostrar los productos y la cantidad total vendida de cada uno de ellos
select		ProductID as Producto,
			SUM(OrderQty) as 'Total de Ventas'
from		Sales.SalesOrderDetail
group by	ProductID
order by	1

-- 32. mostrar los productos y la cantidad total vendida de cada uno de ellos, ordenarlos por mayor cantidad de ventas

select		ProductID as Producto,
			SUM(OrderQty) as 'Total de Ventas'
from		Sales.SalesOrderDetail
group by	ProductID
order by	'Total de Ventas' desc


-- 33. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por numero de factura.
select		SalesOrderID as Factura,
			SUM(OrderQty * UnitPrice) as Subtotal
from		Sales.SalesOrderDetail
group by	SalesOrderID
-- order by	1
-- order by	SalesOrderID
order by	Factura

-- having

--34. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por nro de factura  pero solo de aquellas ordenes superen un total de $10.000
select		SalesOrderID as Factura,
			SUM(OrderQty * UnitPrice) as Subtotal
from		Sales.SalesOrderDetail
group by	SalesOrderID
having		SUM(OrderQty * UnitPrice) > 10000
order by	1

-- 35. mostrar la cantidad de facturas que vendieron mas de 20 unidades 

select	SalesOrderID,
		SUM(OrderQty) as 'Total de Ventas'
from	Sales.SalesOrderDetail
group by SalesOrderID
having SUM(OrderQty) > 20

--36. mostrar las subcategorias de los productos que tienen dos o mas productos que cuestan menos de $150 
select		ProductSubcategoryID as 'Subcategoria de Producto',
			COUNT(*) as Cantidad
from		Production.Product
where		ListPrice < 150
group by	ProductSubcategoryID
having		COUNT(*) >= 2
order by	2 desc

--37. mostrar todos los codigos de categorias existentes junto con la cantidad de productos y el precio de lista promedio por cada uno de aquellos productos que cuestan mas de $70 y el precio promedio es mayor a $300 
select		ProductSubcategoryID as 'Subcategoria de Producto',
			COUNT(*) as cantidad,
			AVG(ListPrice) as 'Precio Promedio'
from		Production.Product
where		ListPrice > 70
group by	ProductSubcategoryID
having		AVG(ListPrice) > 300
order by	2 desc

-- compute

-- 38. mostrar numero de factura, el monto vendido y al final totalizar la facturacion 

-- joins

-- 39.mostrar  los empleados que también son vendedores 
select e.*
from HumanResources.Employee e
join Sales.SalesPerson s on e.BusinessEntityID = s.BusinessEntityID

-- 40. mostrar  los empleados ordenados alfabeticamente por apellido y por nombre 
select * from HumanResources.Employee;
select * from Person.Person;
select p.LastName + ' '+ p.FirstName Empleado
from Person.Person p
inner join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
ORDER BY 1;

-- 41. mostrar el codigo de logueo, numero de territorio y sueldo basico de los vendedores 
select e.LoginID 'Codigo de Logue', s.TerritoryID 'Numero de Territorio', s.Bonus 'Sueldo Basico'
from HumanResources.Employee e join Sales.SalesPerson s on e.BusinessEntityID = s.BusinessEntityID;

-- 42.mostrar los productos que sean ruedas 
select * from Production.Product;
select *
from Production.Product p 
join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name = 'Wheels';

-- 43. mostrar los nombres de los productos que no son bicicletas 
select * from Production.Product;
select *
from Production.Product p 
join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name not LIKE '%bikes%';

-- 44.mostrar los precios de venta de aquellos  productos donde el precio de venta sea inferior al precio de lista recomendado  para ese producto ordenados por nombre de producto
select * from Production.Product;
select * from Sales.SalesOrderDetail;
select p.Name, s.UnitPrice 'Precio Unitario', p.ListPrice 'Precio lista' 
from Production.Product p
join Sales.SalesOrderDetail s on s.ProductID = p.ProductID
where s.UnitPrice < p.ListPrice
order by 1;

-- SELF JOIN --

-- 45. mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares. codigo y nombre de cada uno de los dos productos y el precio de ambos.ordenar por precio en forma descendente 

select p1.Name 'Producto 1', p2.Name 'Producto 2',p1.ListPrice 'Precio 1 ', p2.ListPrice 'Precio 2' 
from Production.Product p1
join Production.Product p2 on p1.ListPrice = p2.ListPrice
where p1.ProductID >p2.ProductID
ORDER BY p1.ListPrice desc; 
-- 46.mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares. codigo y nombre de cada uno de los dos productos y el precio de ambos mayoes a $15

select p1.Name 'Producto 1', p2.Name 'Producto 2',p1.ListPrice 'Precio 1', p2.ListPrice 'Precio 2' , p1.ProductID 'codigo 1',p2.ProductID 'codigo 2'
from Production.Product p1
join Production.Product p2 on p1.ListPrice = p2.ListPrice
where p1.ProductID > p2.ProductID and p1.ListPrice > 15
ORDER BY 1; 

-- 47.mostrar el nombre de los productos y de los proveedores cuya subcategoria es 15 ordenados por nombre de proveedor 

select p.Name Producto, v.Name Proveedor
from Production.Product p 
join Purchasing.ProductVendor pv on p.ProductID = pv.ProductID
join Purchasing.Vendor v on pv.BusinessEntityID = v.BusinessEntityID
where p.ProductSubcategoryID = 15
ORDER BY v.name;

-- 48.mostrar todas las personas (nombre y apellido) y en el caso que sean empleados mostrar tambien el login id, sino mostrar null 

select p.LastName + ' ' + p.FirstName Persona, e.LoginID
from Person.Person p
left join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID;

-- 49. mostrar los vendedores (nombre y apellido) y el territorio asignado a c/u(identificador y nombre de territorio). En los casos en que un territorio no tiene vendedores mostrar igual los datos del territorio unicamente sin datos de vendedores

SELECT p.FirstName + ' '+ p.LastName 'Vendedor' ,st.Name 'Nombre del territorio'
FROM Sales.SalesTerritory st
left join Sales.SalesPerson sp on sp.TerritoryID = st.TerritoryID
join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID;

-- 50.mostrar el producto cartesiano ente la tabla de vendedores cuyo numero de identificacion de negocio sea 280 y el territorio de venta sea el de francia 
select *
FROM Sales.SalesPerson sp
cross join Sales.SalesTerritory st
where sp.BusinessEntityID = 280 and st.Name like'france';


-- 51.listar todos las productos cuyo precio sea inferior al precio promedio de todos los productos 
select *
FROM Production.Product
where ListPrice < (select avg(ListPrice) from Production.Product);

-- 52.listar el nombre, precio de lista, precio promedio y diferencia de precios entre cada producto y el valor promedio general 
select * from Production.Product;
SELECT Name Nombre,ListPrice Precio, (select avg(ListPrice) from Production.Product)  Promedio, ListPrice - (select avg(ListPrice) from Production.Product)  Diferencia
from Production.Product
order by ListPrice desc; 

-- 53. mostrar el o los codigos del producto mas caro 

select * from Production.Product;
select Name Producto, ProductID Codigo
from Production.Product
where ListPrice = (select max(ListPrice) from Production.Product)
order by 1;

-- 54. mostrar el producto mas barato de cada subcategoría. mostrar subcaterogia, codigo de producto y el precio de lista mas barato ordenado por subcategoria 
select * from Production.ProductSubcategory;

select ps.Name Subcategoria, p.ProductID Codigo, p.ListPrice Precio
from Production.Product p
join Production.ProductSubcategory ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
where ListPrice = (select min(ListPrice) from Production.Product where ProductSubcategoryID = ps.ProductSubcategoryID)
order by ps.Name;


-- subconsultas con exists

-- 55.mostrar los nombres de todos los productos presentes en la subcategoría de ruedas 

select * from Production.Product;
select * from Production.ProductSubcategory;
select Name Producto, ProductSubcategoryID Subcategoria
from Production.Product p
where exists (select * from Production.ProductSubcategory where Name = 'wheels' and ProductSubcategoryID = p.ProductSubcategoryID);


-- 56.mostrar todos los productos que no fueron vendidos

select * from Sales.SalesOrderDetail;
select * from Production.Product;
select * from Production.Product p
where not exists (select 1 from Sales.SalesOrderDetail sso where sso.ProductID = p.ProductID);

-- 57. mostrar la cantidad de personas que no son vendedores

select * from HumanResources.Employee;
select * from Person.Person;

select count(businessentityid) Cantidad
from Person.Person 
--where not EXISTS;

-- 58.mostrar todos los vendedores (nombre y apellido) que no tengan asignado un territorio de ventas 

-- x join
select p.FirstName + ' ' + p.LastName Vendedor
from Person.Person p
join Sales.SalesPerson sp
on p.BusinessEntityID = sp.BusinessEntityID
left join Sales.SalesTerritory t
on sp.TerritoryID = t.TerritoryID
where t.TerritoryID is null;

--con not exists
select p.FirstName + ' ' + p.LastName Vendedor
from Person.Person p
join Sales.SalesPerson sp
on p.BusinessEntityID = sp.BusinessEntityID
where not exists (select 1 from Sales.SalesTerritory t where sp.TerritoryID = t.TerritoryID);

-- subconsultas con in y not in

-- 59. mostrar las ordenes de venta que se hayan facturado en territorio de estado unidos unicamente 'us'

-- joins
select *
from Sales.SalesOrderHeader soh
join Sales.SalesTerritory st on soh.TerritoryID = st.TerritoryID
where st.CountryRegionCode ='us';

-- subconsulta
select *
from Sales.SalesOrderHeader 
where TerritoryID in (select TerritoryID from Sales.SalesTerritory where CountryRegionCode ='us');
-- 60. al ejercicio anterior agregar ordenes de francia e inglaterra
select * from Sales.SalesTerritory;
select *
from Sales.SalesOrderHeader
where TerritoryID in(select TerritoryID 
						from Sales.SalesTerritory 
						where CountryRegionCode in('us','gb','fr'));
-- 61.mostrar los nombres de los diez productos mas caros
select Name, ListPrice
from Production.Product
where ListPrice in (select top 10 ListPrice 
					from Production.Product 
					order by ListPrice desc);


-- 62.mostrar aquellos productos cuya cantidad de pedidos de venta sea igual o superior a 20.
select *
from Production.Product
where ProductID in(select ProductID
					from Sales.SalesOrderDetail 
					group by ProductID 
					having COUNT(*) >= 20);
-- 63. listar el nombre y apellido de los empleados que tienen un sueldo basico de 5000 pesos.Utilizar subconsltas con operador in

select p.FirstName + ' ' + p.LastName Empleado
from HumanResources.Employee e
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
where e.BusinessEntityID in(select BusinessEntityID
							from Sales.SalesPerson
							where Bonus = 5000);

-- subconsultas con all y any

-- 64.mostrar los nombres de todos los productos de ruedas que fabrica adventure works cycles. resolver por subconsulta = any

select Name Producto
from Production.Product
where ProductSubcategoryID = any (select ProductSubcategoryID
									from Production.ProductSubcategory
									where Name ='wheels');
--hecho por mi
select p.Name
from Production.Product p
join Purchasing.ProductVendor pv on p.ProductID = pv.ProductID
where pv.BusinessEntityID = all(select BusinessEntityID from Purchasing.Vendor where Name like 'advanced bicycles')

-- 65.mostrar los clientes ubicados en un territorio no cubierto por ning�n vendedor 
--por subconsulta not in

select c.*
from Sales.Customer c
where c.TerritoryID not in(select TerritoryID from Sales.SalesPerson);

-- por subconsulta all
select c.*
from Sales.Customer c
where c.TerritoryID <> all(select TerritoryID from Sales.SalesPerson);
-- 66. listar los productos cuyos precios de venta sean mayores o iguales que el precio de venta m�ximo de cualquier subcategor�a de producto.
select Name Producto, ListPrice
from Production.Product
where ListPrice >= any(select MAX(ListPrice)
						from Production.Product
						group by ProductSubcategoryID)

-- expresion case

-- 67.listar el nombre de los productos, el nombre de la subcategoria a la que pertenece junto a su categor�a de precio. La categor�a de precio se calcula de la siguiente manera. 
--	-si el precio est� entre 0 y 1000 la categor�a es econ�mica.
--	-si la categor�a est� entre 1000 y 2000, normal 
--	-y si su valor es mayor a 2000 la categor�a es cara. 

select	p.Name product,
		p.ListPrice Precio,
		ps.Name subcategoria,
		(case
			when ListPrice between 0 and 1000 then 'Economica'
			when ListPrice between 1000 and 2000 then 'Normal'
			else 'Cara'
		end) Categoria
from	Production.Product p
join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
order by p.ListPrice desc;
-- 68.tomando el ejercicio anterior, mostrar unicamente aquellos productos cuya categoria sea "economica"
select *
from (
		select	p.Name product,
				p.ListPrice Precio,
				ps.Name subcategoria,
				(case
					when ListPrice between 0 and 1000 then 'Economica'
					when ListPrice between 1000 and 2000 then 'Normal'
					else 'Cara'
				end) Categoria
		from	Production.Product p
		join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID) subconsulta
where subconsulta.Categoria = 'Economica';

--  insert, update y delete

-- 69.aumentar un 20% el precio de lista de todos los productos  
update Production.Product
set ListPrice = ListPrice *1.2;

-- 70.aumentar un 20% el precio de lista de los productos del proveedor 1540 
update Production.Product
set ListPrice = ListPrice *1.2
where ProductID in (select ProductID
					from Purchasing.ProductVendor
					where BusinessEntityID = 1540);

--por join
update p
set ListPrice = ListPrice *1.2
from Production.Product p
join Purchasing.ProductVendor pv on p.ProductID = pv.ProductID
where pv.BusinessEntityID =1540;
-- 71.agregar un dia de vacaciones a los 10 empleados con mayor antiguedad.
update e
set VacationHours = VacationHours +24
from HumanResources.Employee e
where BusinessEntityID in(select top 10 BusinessEntityID
							from HumanResources.Employee
							order by HireDate);	
-- 72. eliminar los detalles de compra (purchaseorderdetail) cuyas fechas de vencimiento pertenezcan al tercer trimestre del a�o 2006 
delete from Purchasing.PurchaseOrderDetail
-- where DueDate between '2006-07-01' and '2006-09-30'
where year(DueDate) = 2006 and MONTH(DueDate) between 7 and 9;

-- 73.quitar registros de la tabla salespersonquotahistory cuando las ventas del a�o hasta la fecha almacenadas en la tabla salesperson supere el valor de 2500000
delete from Sales.SalesPersonQuotaHistory
where BusinessEntityID in(select BusinessEntityID
							from Sales.SalesPerson
							where SalesYTD > 2500000)

-- bulk copy
use AdventureWorks2008R2
-- 74. clonar estructura y datos de los campos nombre ,color y precio de lista de la tabla production.product en una tabla llamada productos 
select * from Production.Product;
select Name Nombre, Color, ListPrice Precio
into productos
from Production.Product;

select * from productos;
-- 75. clonar solo estructura de los campos identificador ,nombre y apellido de la tabla person.person en una tabla llamada personas
select * from Person.Person; 
select BusinessEntityID, FirstName, LastName
into personas
from Person.Person
where 1=2;

select * from personas;

-- 76.insertar un producto dentro de la tabla productos.tener en cuenta los siguientes datos. el color de producto debe ser rojo, el nombre debe ser "bicicleta mountain bike" y el precio de lista debe ser de 4000 pesos.

insert into productos (Nombre, Color, Precio)
values('bicicleta mountain bike', 'rojo',4000);

select * from productos;
-- 77. copiar los registros de la tabla person.person a la tabla personas cuyo identificador este entre 100 y 200 

insert into personas(BusinessEntityID,FirstName,LastName)
select BusinessEntityID,FirstName,LastName
from Person.Person
where BusinessEntityID BETWEEN 100 and 200;

select * from personas;
-- 78. aumentar en un 15% el precio de los pedales de bicicleta
update productos
set Precio = Precio * 1.15
where Nombre like '%peda%'  
-- 79. eliminar de las personas cuyo nombre empiecen con la letra m
delete from personas
where FirstName like 'm%'
select * from personas;
-- 80. borrar todo el contenido de la tabla productos 
delete from productos;

select * from productos;
-- 81. borrar todo el contenido de la tabla personas sin utilizar la instrucci�n delete.
truncate table personas;

-- procedimientos almacenados

-- 82. crear un procedimiento almacenado que dada una determinada inicial ,devuelva codigo, nombre,apellido y direccion de correo de los empleados cuyo nombre coincida con la inicial ingresada.

select * from Person.Person;
select * from Person.EmailAddress;
select * from HumanResources.Employee;
go

create procedure buscarEmpleado
    @inicial varchar(1)
as 
BEGIN
    select pp.BusinessEntityID, FirstName +' '+LastName Empleado, pe.EmailAddress
    from Person.Person pp
    join Person.EmailAddress pe on pp.BusinessEntityID = pe.BusinessEntityID
    where FirstName LIKE @inicial +'%';
END;

go
create procedure InformarEmpleadoPorInicial (@inicial char(1))
AS
	BEGIN
		select BusinessEntityID, FirstName +' '+LastName Empleado, EmailAddress
		from HumanResources.vEmployee
		WHERE FirstName like @inicial +'%'
		order by FirstName
	end;
go

-- drop procedure buscarEmpleado;
EXEC buscarEmpleado @inicial ='j';
exec InformarEmpleadoPorInicial @inicial ='j'

-- 83. crear un procedimiento almacenado que devuelva los productos que lleven de fabricado la cantidad de dias que le pasemos como parametro
select * from Production.Product;
go
create procedure tiempoFabricado (@dias int = 1)
as
	begin
		select Name, ProductNumber,DaysToManufacture 
		from Production.Product
		where DaysToManufacture = @dias
	end



-- 84. crear un procedimiento almacenado que permita actualizar y ver los precios de un determinado producto que reciba como parametro

go
create procedure ActalizarPrecios(@cantidad float, @codigo int)
AS
	BEGIN
		update Production.Product
		set ListPrice = ListPrice*@cantidad
		where ProductID = @codigo

		select Name, ListPrice
		from Production.Product
		where ProductID=@codigo
	END

go
exec ActalizarPrecios 1.1, 886
select ListPrice from Production.Product where ProductID =886;
-- 85. armar un procedimineto almacenado que devuelva los proveedores que proporcionan el producto especificado por parametro. 
go
create procedure Proveedores(@producto varchar(30)='%')
AS
	select v.Name proveedor, p.Name producto
	from Purchasing.Vendor v
	join Purchasing.ProductVendor pv on v.BusinessEntityID = pv.BusinessEntityID
	join Production.Product p on pv.ProductID = p.ProductID
	where p.Name like @producto
	order by v.Name

GO
exec Proveedores 'r%'
exec Proveedores 'reflector'
exec Proveedores 

-- 86. crear un procedimiento almacenado que devuelva nombre,apellido y sector del empleado que le pasemos como argumento.no es necesario pasar el nombre y apellido exactos al procedimiento.
go
create procedure empleados
	@apellido nvarchar(50)='%',
	@nombre nvarchar(50)='%'

AS
	select FirstName +' '+ LastName, Department
	from HumanResources.vEmployeeDepartmentHistory
	where FirstName like @nombre and LastName like @apellido
go

exec empleados 'eric%'

exec empleados
-- funciones escalares

-- 87.armar una funcion que devuelva los productos que estan por encima del promedio de precios general
go
create function promedio()
returns MONEY
AS
BEGIN
	declare @promedio MONEY
	select @promedio = avg(ListPrice) from Production.Product
	return @promedio
end

--uso de la funcion
go
select * from Production.Product
where ListPrice > dbo.promedio()

select avg(ListPrice) from Production.Product

-- 88.armar una funci�n que dado un c�digo de producto devuelva el total de ventas para dicho producto luego, mediante una consulta, traer codigo, nombre y total de ventas ordenados por esta ultima columna
go
create function VentasProductos(@codigoProducto int)
returns int
as
	begin
		declare @total int
		select @total = sum(orderQty)
		from Sales.SalesOrderDetail
		where ProductID = @codigoProducto
		if(@total is null)
			set @total = 0
		return @total
	end

-- funciones de tabla en linea

--  89.armar una funci�n que dado un a�o , devuelva nombre y  apellido de los empleados que ingresaron ese a�o 
go
create function AñoIngresoEmpleado (@año int)
returns TABLE
AS
    RETURN
    (
        select FirstName +' '+ LastName Empleado, HireDate
        from Person.Person p
        join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
        where year(HireDate) = @año
    )
go
-- uso de la FUNCTION
select * from dbo.AñoIngresoEmpleado(2000)
-- 90.armar una funci�n que dado el codigo de negocio cliente de la fabrica, devuelva el codigo, nombre y las ventas del a�o hasta la fecha para cada producto vendido en el negocio ordenadas por esta ultima columna. 
go
create function VentasNegocio(@codigoNegocio int)
returns TABLE
as
    return(
        select p.ProductID, p.Name,sum(sd.LineTotal) Total
        from Production.Product p
        join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
        join Sales.SalesOrderHeader sh on sh.SalesOrderID = sd.SalesOrderID
        join Sales.Customer c on sh.CustomerID = c.CustomerID
        where c.StoreID = @codigoNegocio
        group by p.ProductID, p.Name
    )

go
--uso de la FUNCTION
select *
from dbo.VentasNegocio(1340)
order by 3 desc;

-- funciones de multisentencia
	
-- 91. crear una  funci�n llmada "ofertas" que reciba un par�metro correspondiente a un precio y nos retorne una tabla con c�digo,nombre, color y precio de todos los productos cuyo precio sea inferior al par�metro ingresado
go
create function Ofertas (@minimo decimal(6,2))
returns @oferta table(  
    codigo int, nombre varchar(50), color varchar(50),precio decimal(6,2) 
)
AS
    BEGIN
        insert @oferta
        select ProductID, Name, Color, ListPrice
        from Production.Product
        where ListPrice < @minimo
        return
    end
go
 select * from dbo.Ofertas(5)
-- datetime

-- 92. mostrar la cantidad de horas que transcurrieron desde el comienzo del a�o
select DATEDIFF(day,'06-28-1993',getdate())

-- 93. mostrar la cantidad de dias transcurridos entre la primer y la ultima venta 

select DATEDIFF(day,(select min(OrderDate) from Sales.SalesOrderHeader),
                    (select max(OrderDate) from Sales.SalesOrderHeader))