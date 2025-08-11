# 🏠 Inmobiliaria Grosman
**Entrega 1 - Curso SQL - Coderhouse**

---

## 📖 Introducción
La base de datos consta de **6 tablas** correspondientes a la ficticia inmobiliaria *“Grosman”*.

---

## ⚠ Situación Problemática
El actual modelo de negocios requiere una presencialidad al 100% dado que los archivos se encuentran en formato papel guardados en ficheros por categoría. Además de esto, los empleados deben utilizar su tiempo para buscar en los ficheros la información necesaria y luego actualizarla de manera manual.  

Mediante la implementación de la base de datos el trabajo puede realizarse fácilmente de manera remota, se ahorrarán valiosas horas de búsqueda de documentos y actualización, además se reducirán sensiblemente los errores humanos producto de la descoordinación y la pérdida de valiosa información.  

Por último, entendiendo la ambición de la nueva gerencia de expandir el negocio, la base de datos aporta la flexibilidad necesaria para procesar un mayor volumen de propiedades y empleados, así como automatizar ciertos procesos e informes.

---

## 🎯 Modelo de Negocio
Se busca profesionalizar el desempeño de la inmobiliaria pudiendo llevar cuenta de la operación de manera computalizada, reduciendo tiempos de proceso y haciendo el proceso fácilmente auditable.  

En futuras versiones se buscará expandir el negocio y expandir la base de datos. Particularmente, se buscará crear usuarios con distintos permisos de acuerdo a su jerarquía como asesores y se buscará automatizar el tasado de propiedades, siendo que al cargar las características de la propiedad el asesor tenga una idea del valor de la propiedad.

---

## 🗄 Tablas y Relaciones
Como se muestra en el **DER**, la base de datos cuenta con las siguientes tablas:

1. **Localidades** → Lista de zonas o barrios; cada propiedad está en una localidad.
2. **Empleados** → Asesores o vendedores; cada propiedad tiene un asesor asignado.
3. **Clientes** → Personas que interactúan con la inmobiliaria: dueños, inquilinos o compradores.
4. **Propiedades** → Datos centrales de cada inmueble: ubicación, dueño, asesor, precio, m², estado.
5. **Ventas** → Historial de ventas.
6. **Alquileres** → Historial de alquileres.

---

## 🔗 Integridad mediante claves foráneas
- `propiedades.id_localidad` → `localidades.id_localidad`
- `propiedades.id_empleado` → `empleados.id_empleado`
- `propiedades.id_cliente` → `clientes.id_cliente` *(dueño actual, NOT NULL)*
- `alquileres.id_propiedad` → `propiedades.id_propiedad`
- `alquileres.id_inquilino` → `clientes.id_cliente`
- `ventas.id_propiedad` → `propiedades.id_propiedad`
- `ventas.id_comprador` → `clientes.id_cliente`

---

## 📊 Recursos
- 🖼 **[Diagrama Entidad–Relación](https://github.com/arig96/inmobiliaria_grosman/blob/main/entidad%20relacion.png)**
- 💻 **[Código SQL completo](https://github.com/arig96/inmobiliaria_grosman/blob/main/entrega1.sql)**

