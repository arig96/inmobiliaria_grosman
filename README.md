# inmobiliaria_grosman
Entrega1 curso SQL Coderhouse


La base de datos consta de una serie de 6 tablas correspondientes a la ficticia inmobiliaria “Grosman”.

Introducción:
Se parte de la base de una empresa inmobiliaria donde el 100% de los procesos se realizan de manera manual y en papel, luego de un cambio de gestión la nueva gerencia decide encarar un ambicioso plan de modernización y expansión de la firma.
Como se puede ver a continuación el listado de tablas y entidad relación busca contar con una gestión integral del quehacer de la empresa, contando con tablas de propiedades, localidades, empleados, clientes, ventas y alquileres.


Situación Problemática:
El actual modelo de negocios requiere una presencialidad al 100% dado que los archivos se encuentran en formato papel guardados en ficheros por categoría además de esto, los empleados deben utilizar su tiempo para buscar en los ficheros la información necesaria y luego actualizarla de manera manual. Mediante la implementación de la base de datos el trabajo puede realizarse fácilmente de manera remota, se ahorrarán valiosas horas de búsqueda de documentos actualización, además se reducirán sensiblemente los errores humanos producto de la descoordinación y la pérdida de valiosa información. Por último, entendiendo la ambición de la nueva gerencia de expandir el negocio la base de datos aporta la flexibilidad necesaria para procesar un mayor volumen de propiedades y empleados, así como automatizar ciertos procesos e informes.

Modelo de Negocio:
Se busca profesionalizar el desempeño de la inmobiliaria pudiendo llevar cuenta de la operación de manera computalizada, reduciendo tiempos de proceso y haciendo el proceso facilmente auditable. En futuras versiones se buscará expandir el negocio y expandir la base de datos, particularmente se buscará crear usuarios con distintos permisos de acuerdo a su jerarquia como asesores y se buscará automatizar el tasado de propiedades siendo que al cargar las caracteristicas de la propiedad el asesor tenga una idea del valor de la propiedad.

DER y listado de tablas:
Como se muestra en la imagen adjunta la base de datos cuenta con las siguientes tablas:
1. Localidades lista de zonas o barrios cada propiedad está en una localidad.
2. Empleados son los asesores o vendedores. Cada propiedad tiene un asesor asignado.
3. Clientes son quienes interactuan con la inmobiliaria, dueños, inquilinos y compradores
4. Propiedades, de alguna manera la parte central de la base cuenta con datos de la propiedad asi como qué localidad, asesor y cliente le corresponden.
5. ventas, historial de ventas
6. alquileres historial de alquileres
   
Integridad de la base mediante claves foraneas:
propiedades.id_localidad → localidades.id_localidad
propiedades.id_empleado → empleados.id_empleado
propiedades.id_cliente → clientes.id_cliente (dueño actual, NOT NULL)
alquileres.id_propiedad → propiedades.id_propiedad
alquileres.id_inquilino → clientes.id_cliente
ventas.id_propiedad → propiedades.id_propiedad
ventas.id_comprador → clientes.id_cliente


