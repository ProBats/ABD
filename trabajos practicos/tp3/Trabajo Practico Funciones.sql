-- Trabajo Practico Funciones 

-- Funciones Escalares 

-- 1. Crear una función que devuelva el promedio de los productos.
-- Tablas: Production.Product
-- Campos: ListPrice

use AdventureWorks2008R2;

go
create function PromedioProductos()
returns decimal(10,2)
as
begin
    declare @promedio decimal(10,2);
    select @promedio = avg(ListPrice) from Production.Product;
    return @promedio;
end
go
select dbo.PromedioProductos() Promedio;

-- 2. Crear una función que dado un código de producto devuelva el total de ventas para dicho producto luego, mediante una consulta, traer código y total de ventas.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, LineTotal

go
create function TotalVentasProducto(@ProductID int)
returns decimal(10,2)
as
begin
    declare @totalVentas decimal(10,2);
    select @totalVentas = sum(LineTotal) from Sales.SalesOrderDetail where ProductID = @ProductID;
    return isnull(@totalVentas, 0);
end
GO
SELECT 
    707 AS ProductID,
    dbo.TotalVentasProducto(707) AS TotalVentas;

-- 3. Crear una función que dado un código devuelva la cantidad de productos vendidos o cero si no se ha vendido.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, OrderQty

go
create function CantidadVendidaProducto(@ProductID int)
returns int
as
begin
    declare @cantidadVendida int;
    select @cantidadVendida = sum(OrderQty) from Sales.SalesOrderDetail where ProductID = @ProductID;
    return isnull(@cantidadVendida, 0);
end
GO
SELECT 
    707 AS ProductID,
    dbo.CantidadVendidaProducto(707) AS CantidadVendida;

-- 4. Crear una función que devuelva el promedio total de venta, luego obtener los productos cuyo precio sea inferior al promedio.
-- Tablas: Sales.SalesOrderDetail, Production.Product
-- Campos: ProductID, ListPrice

go
create function PromedioTotalVenta()
returns decimal(10,2)
as
begin
    declare @promedio decimal(10,2);
    select @promedio = avg(LineTotal) from Sales.SalesOrderDetail;
    return @promedio;
end
go
SELECT 
    ProductID, ListPrice
FROM Production.Product
WHERE ListPrice < dbo.PromedioTotalVenta();

-- Funciones de Tabla en Línea

-- 5. Crear una función que dado un año, devuelva nombre y apellido de los empleados que ingresaron ese año.
-- Tablas: Person.Person, HumanResources.Employee
-- Campos: FirstName, LastName,HireDate, BusinessEntityID

go
create function EmpleadosIngresadosAno(@Ano int)
returns table
as
return (
    select p.FirstName, p.LastName
    from Person.Person p
    inner join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
    where year(e.HireDate) = @Ano
);
go
SELECT * FROM dbo.EmpleadosIngresadosAno(2005);

-- 6. Crear una función que reciba un parámetro correspondiente a un precio y nos retorna una tabla con código, nombre, color y precio de todos los productos cuyo precio sea inferior al parámetro ingresado.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice

go
create function ProductosInferioresPrecio(@Precio decimal(10,2))
returns table
as
return (
    select ProductID, Name, Color, ListPrice
    from Production.Product
    where ListPrice < @Precio
);
go  
SELECT * FROM dbo.ProductosInferioresPrecio(1000);

-- Funciones Multisentencia

-- 7. Realizar el mismo pedido que en el punto anterior, pero utilizando este tipo de función.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice
go
create function ProductosInferioresPrecioMulti(@Precio decimal(10,2))
returns @Productos table (
    ProductID int,
    Name nvarchar(50),
    Color nvarchar(15),
    ListPrice decimal(10,2)
)
as
begin
    insert into @Productos (ProductID, Name, Color, ListPrice)
    select ProductID, Name, Color, ListPrice
    from Production.Product
    where ListPrice < @Precio

    return
end
go
SELECT * FROM dbo.ProductosInferioresPrecioMulti(1000);
