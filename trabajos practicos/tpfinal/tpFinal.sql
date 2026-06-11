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
declare @Filas money;
begin try
    begin tran

        select @PromedioOriginal = avg(ListPrice)
        from Production.Product
        where ListPrice > 0;

        print'Auditoria'

        update Production.Product
        set ListPrice = (ListPrice * 1.15)
        where ListPrice > 0

        --Capturamos las filas afectadas



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

-- 1)
create database SportNetDB

on Primary(
            name = N'SportNetData',
            filename = N'C:\DATA\SportNet.MDF',
            size = 10 MB,
            filegrowth = 2 MB
        ),
FILEGROUP [HISTORICO]
        (
            name= N'SportNetHistoricoData2',
            filename = N'C:\DATA\SportNetDB.MDF',
            size = 15 MB,
            filegrowth = 1 MB
        )   
LOG ON
            (
                name = N'SportNet_Log',
                filename = N'c:\DATA\SportNet_Log.LDF',
                size = 5 MB
            );

-- Ejercicio 3
-- Contexto: El departamento de desarrollo de software ha detectado serios problemas de redundancia, anomalías de actualización y falta de integridad en el almacenamiento de las solicitudes de cotización. Se presenta una estructura no normalizada (vistas de tabla única o "tabla plana") y se solicita su proceso de normalización completo.
-- Consigna: Dada la siguiente estructura de datos plana:
-- Presupuesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad + Precio_Total
-- Aplicar el proceso de normalización paso a paso explicando las transformaciones para alcanzar la Primera (1FN), Segunda (2FN) y Tercera (3FN) Forma Normal. Omitir los atributos derivados o calculados en el modelo físico final para respetar las buenas prácticas de bases de datos relacionales.

-- Presupuesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad + Precio_Total

1FN
-- Presupuesto_Solicitado = @#Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente +  Precio_Total
-- Producto = @#Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad 

Ejercicio 4
Contexto: El departamento de auditoría detectó que las búsquedas y reportes sobre la tabla de socios están sufriendo serios problemas de rendimiento debido a la falta de una estrategia de indexación sólida. Además, se han reportado ingresos de números de documentos duplicados. Se solicita rediseñar la estructura de índices de la tabla para garantizar la máxima velocidad de consulta y asegurar la integridad de los datos.
Consigna: Escribir un script unificado en Transact-SQL que simule y resuelva el ciclo de vida de optimización de la tabla Socios.FichaPersonal cumpliendo las siguientes directivas:
1.	Punto de Partida Ineficiente: Crear la estructura base sin asignación automática de índices y cargar registros que fuercen la existencia de apellidos duplicados.
2.	Conflicto de Unicidad: Intentar aplicar un índice agrupado único sobre una columna con datos duplicados para analizar el comportamiento del motor.
3.	Estrategia de Indexación Mixta: * Implementar un índice agrupado no único para optimizar búsquedas por rangos alfabéticos de apellidos.
o	Configurar la clave primaria de forma "No Agrupada" para evitar conflictos estructurales inmediatos.
4.	Garantía de Integridad: Crear un índice único no agrupado para el documento de identidad y verificar el bloqueo ante intentos de duplicación.
5.	Reingeniería Estructural (Refactorización): Demostrar la capacidad de reestructurar la tabla eliminando el índice anterior y regenerando la Clave Primaria para que sea, finalmente, el índice agrupado principal de la tabla.

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

Ejercicio 5
Contexto: El volumen de transacciones de preventas y detalles de órdenes en AdventureWorks ha crecido exponencialmente, ralentizando los índices y aumentando los tiempos de mantenimiento de backups. Como Ingeniero de Datos / DBA, se le solicita diseñar e implementar una arquitectura de tabla particionada para la auditoría de ventas trimestrales del año 2011(Sales.SalesOrderDetail), distribuyendo la carga en almacenamiento físico diferenciado para optimizar el rendimiento de entrada/salida (I/O).
Consigna: Desarrollar un script en Transact-SQL que ejecute paso a paso las siguientes fases de ingeniería de almacenamiento:
1.	Infraestructura Física: Crear 4 Filegroups independientes con un archivo secundario (.ndf) cada uno en el directorio de datos.
2.	Lógica de Particionado: Definir una función de partición basada en rangos temporales para segmentar los trimestres de un año fiscal y mapearlos mediante un esquema de partición a los Filegroups creados.
3.	Migración Masiva: Construir una réplica de la tabla de órdenes de venta particionada, poblarla con la información histórica real de AdventureWorks y testear inserciones en los límites de los rangos.
4.	Metadatos y Auditoría: Consultar las vistas del sistema para auditar la distribución de registros por partición exacta, documentando detalladamente las diferencias operativas de las funciones de partición.
5.	Rollback Estructural: Proveer la secuencia de desmantelamiento seguro y ordenado de los objetos creados para limpieza del entorno.

Ejercicio 6
Contexto: La Fintech "CryptoAr" está expandiendo su infraestructura y requiere configurar la seguridad de acceso global para su nueva instancia de producción de SQL Server. La política corporativa exige auditorías estrictas de acceso, separación de funciones según el principio de "privilegio mínimo" y la habilitación segura de logins de aplicaciones.
Consigna: Escribir un script unificado en Transact-SQL que implemente la configuración de seguridad perimetral del servidor bajo los siguientes requerimientos:
1.	Auditoría de Instancia: Verificar programáticamente el modo de seguridad de la instancia. Si no admite logins internos, dejar documentado el procedimiento de cambio a modo mixto y el requerimiento operativo de infraestructura.
2.	Aprovisionamiento con Políticas: Crear tres logins de servidor para el nuevo personal del Centro de Operaciones de Red (NOC) y del Equipo de Seguridad (SecOps):
o	SecAuditor_Gomez
o	NocMonitor_Lopez
o	DbaJunior_Paz
Todos deben cumplir obligatoriamente con las políticas de expiración y complejidad del sistema operativo.
3.	Gestión de Ciclo de Vida: Simular una ventana de mantenimiento donde se bloqueen accesos sospechosos, se reestablezcan credenciales comprometidas y se reasigne el contexto de base de datos por defecto a un entorno seguro corporativo.
4.	Separación de Funciones (Server Roles): Asignar roles fijos de servidor específicos según el perfil técnico:
o	El auditor debe poder revisar logs y configuraciones globales (securityadmin).
o	El monitor del NOC debe analizar la salud, recursos y procesos del motor (processadmin).
o	El DBA Junior debe administrar el espacio en disco y archivos lógicos (diskadmin).
5.	Validación Dinámica: Consultar las vistas de catálogo del sistema para verificar estados y mapeos de roles vigentes.



Ejercicio 7
Contexto: La plataforma de streaming "StreamPlay" necesita configurar la seguridad interna de su base de datos de producción. El área de ciberseguridad exige aplicar de forma estricta el principio de "privilegio mínimo", resguardar datos sensibles de los clientes (como los métodos de pago) y dar acceso controlado al equipo de soporte, creadores de contenido y auditores de sistemas.
Consigna: Desarrollar un script unificado en Transact-SQL que implemente la infraestructura de seguridad lógica en la base de datos StreamPlayDB resolviendo los siguientes requerimientos prácticos:
1.	Modelado Base: Crear la base de datos y tres estructuras clave: Suscripciones (datos de usuarios y cobros), Catalogo (películas y series) y Visualizaciones (historial de reproducción).
2.	Aprovisionamiento Perimetral: Crear cinco logins a nivel de servidor y sus correspondientes usuarios mapeados exclusivamente dentro de la base de datos del negocio.
3.	Roles de Base de Datos: Asignar los roles fijos db_datareader y db_datawriter según corresponda para dar acceso de lectura global o control operativo de datos.
4.	Seguridad Granular (GRANT): Configurar permisos específicos tabla por tabla para perfiles gerenciales, limitando la capacidad de eliminación destructiva de registros.
5.	Restricción de Privilegios (DENY): Implementar bloqueos perimetrales absolutos mediante DENY. Se debe proteger el catálogo de modificaciones accidentales y ocultar columnas con datos financieros sensibles a nivel de celda.
6.	Seguridad Avanzada y Roles Personalizados: Crear un rol de auditoría a la medida que herede permisos de lectura y obtenga privilegios de inspección de código fuente (VIEW DEFINITION).
7.	Normalización de Permisos (REVOKE): Demostrar la remoción de privilegios explícitos para devolver una entidad a su estado heredado neutral.


Ejercicio 8
Contexto: Para optimizar el espacio de almacenamiento de la plataforma "SportNet", el equipo de desarrollo solicitó que los registros de la tabla de accesos que tengan más de 30 días de antigüedad se eliminen de forma automática. De esta manera, se evita que la base de datos crezca indefinidamente con datos obsoletos.
Consigna: Escribir un script unificado en Transact-SQL utilizando el subsistema de msdb que configure un Job automatizado en el SQL Server Agent bajo las siguientes especificaciones:
1.	Configuración Global: Crear un Job llamado Limpieza_Automatica_Accesos_SportNet.
2.	Definición del Paso (Job Step): Configurar un paso de ejecución de tipo T-SQL que aplique un comando estándar de eliminación (DELETE) sobre la tabla Socios.RegistroAccesos de la base de datos SportNetDB. El comando debe borrar las filas cuya fecha sea menor a la actual. Establecer una política de 2 reintentos ante fallas.
3.	Planificación Horaria (Schedule): Programar la tarea para que se ejecute de forma recurrente todos los domingos a las 03:00 AM.
4.	Asignación de Destino: Enlazar el Job para que corra de manera local en la instancia del servidor actual.

Ejercicio 9
Contexto: La cadena "CoffeeHouse" opera con un sistema de puntos de venta centralizado. Debido a la criticidad de las transacciones comerciales, el área de sistemas exige implementar una política de respaldo bajo el modelo de recuperación completa (FULL). Como Administrador de Bases de Datos (DBA), debe simular el flujo diario de operaciones, ejecutar la secuencia de copias de seguridad programadas y, ante un escenario simulado de pérdida total de datos, liderar el protocolo de restauración de emergencia sin perder una sola venta.
Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes fases de contingencia:
1.	Infraestructura Base: Crear la base de datos CoffeeHouseDB junto con las tablas relacionales de clientes y órdenes de compra con una carga de datos inicial (Simulación: Estado de ventas a las 08:00 AM).
2.	Línea Base General (Backup Full): Configurar el modelo de recuperación en modo completo y generar el respaldo total de la estructura (Simulación: 09:00 AM).
3.	Punto de Control Acumulativo (Backup Diferencial): Insertar actividad comercial y generar un respaldo diferencial para empaquetar los cambios de la mañana (Simulación: 11:00 AM).
4.	Resguardos Transaccionales (Backups de Log): Intercalar nuevas ventas con la ejecución secuencial de dos copias del Log de transacciones para registrar la actividad de la tarde (Simulación: 12:00 PM y 02:00 PM).
5.	Protocolo de Recuperación: Simular un colapso crítico del sistema y reconstruir la base de datos de forma ordenada utilizando las cláusulas NORECOVERY y RECOVERY en el orden cronológico correcto.
6.	Validación de Integridad: Comprobar mediante consultas de combinación que la base de datos fue recuperada en su totalidad.

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
