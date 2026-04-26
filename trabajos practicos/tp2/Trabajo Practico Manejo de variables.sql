--Trabajo Practico Manejo de variables

use AdventureWorks2008R2;
-- 1. Obtener el total de ventas del año 2006 y guardarlo en una variable llamada @TotalVentas, luego imprimir el resultado.

-- Tablas: Sales.SalesOrderDetail
-- Campos: LineTotal
select * from Sales.SalesOrderHeader where year(OrderDate) = 2006;
declare @TotalVentas decimal(10,2);

select @TotalVentas = sum(LineTotal)
from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on soh.SalesOrderID = sod.SalesOrderID
where year(soh.OrderDate) = 2006; --WHERE soh.OrderDate >= '2006-01-01' AND soh.OrderDate < '2007-01-01' (supuestamente es mejor hacerlo asi)

select @TotalVentas 'Total Ventas del año 2006'

-- 2. Obtener el promedio de precios y guardarlo en una variable llamada @Promedio luego hacer un reporte de todos los productos cuyo precio de venta sea menor al Promedio.

-- Tablas: Production.Product
-- Campos: ListPrice, ProductID

declare @Promedio decimal(10,2)

select @Promedio = avg(ListPrice)
from Production.Product

select ProductID, ListPrice, @Promedio 'Promedio de precios'
from Production.Product 
WHERE ListPrice < @Promedio
order by ListPrice desc

-- 3. Utilizando la variable @Promedio incrementar en un 10% el valor de los productos sean inferior al promedio.

-- Tablas: Production.Product
-- Campos: ListPrice

DECLARE @Promedio DECIMAL(10,4);

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

update Production.Product
set ListPrice = ListPrice * 1.10
WHERE ListPrice < @Promedio

-- 4. Crear un variable de tipo tabla con las categorías y subcategoría de productos y
-- reportar el resultado.

-- Tablas: Production.ProductSubcategory, Production.ProductCategory
-- Campos: Name

declare @CategoriasSubcategorias table(
	categoria nvarchar(100),
    subcategoria nvarchar(100)
);

insert into @CategoriasSubcategorias
select distinct pc.Name, ps.Name
from production.ProductCategory pc
join Production.ProductSubcategory ps on pc.ProductCategoryID = ps.ProductCategoryID

select * 
from @CategoriasSubcategorias

-- 5. Analizar el promedio de la lista de precios de productos, si su valor es menor a 500 imprimir el mensaje el PROMEDIO BAJO de lo contrario imprimir el mensaje PROMEDIO ALTO.

-- Tablas: Production.Product
-- Campos: ListPrice

declare @Promedio decimal(10,2);

select @Promedio = avg(ListPrice)
from Production.Product;

if @Promedio < 500
    begin
        print 'PROMEDIO BAJO'
    end
else
    begin
        print 'PROMEDIO ALTO'
    end

