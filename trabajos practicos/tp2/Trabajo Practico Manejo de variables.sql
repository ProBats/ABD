--Trabajo Practico Manejo de variables

use AdventureWorks2008R2;
-- 1. Obtener el total de ventas del año 2006 y guardarlo en una variable llamada @TotalVentas, luego imprimir el resultado.

-- Tablas: Sales.SalesOrderDetail
-- Campos: LineTotal

select * from Sales.SalesOrderDetail
declare @Totalventas decimal(10,2)
set @Totalventas = select sum(LineTotal) from Sales.SalesOrderDetail; 
select sum(LineTotal) from Sales.SalesOrderDetail where year(ModifiedDate) = 2006;


-- 2. Obtener el promedio de precios y guardarlo en una variable llamada @Promedio luego hacer un reporte de todos los productos cuyo precio de venta sea menor al Promedio.

Tablas: Production.Product
Campos: ListPrice, ProductID


3. Utilizando la variable @Promedio incrementar en un 10% el valor de los productos sean inferior al promedio.

Tablas: Production.Product
Campos: ListPrice


4. Crear un variable de tipo tabla con las categorías y subcategoría de productos y
reportar el resultado.

Tablas: Production.ProductSubcategory, Production.ProductCategory
Campos: Name


5. Analizar el promedio de la lista de precios de productos, si su valor es menor a 500 imprimir el mensaje el PROMEDIO BAJO de lo contrario imprimir el mensaje PROMEDIO ALTO.

Tablas: Production.Product
Campos: ListPrice
