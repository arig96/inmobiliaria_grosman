/* =========================================================
   Inmobiliaria Grosman – DML (datos de ejemplo)
   ========================================================= */

/* Localidades */
INSERT INTO localidades (nombre, provincia, codigo_postal) VALUES
('Palermo',   'Buenos Aires', '1425'),
('Belgrano',  'Buenos Aires', '1428'),
('Recoleta',  'Buenos Aires', '1118'),
('San Telmo', 'Buenos Aires', '1064'),
('Caballito', 'Buenos Aires', '1424');

/* Empleados */
INSERT INTO empleados (nombre, apellido, email, telefono) VALUES
('Lucía',  'Martínez', 'lucia@inmo.com', '1160000001'),
('Juan',   'Pérez',    'juan@inmo.com',  '1160000002'),
('Carla',  'Gómez',    'carla@inmo.com', '1160000003'),
('Diego',  'Santos',   'diego@inmo.com', '1160000004'),
('Mariana','Rivas',    'mariana@inmo.com','1160000005');

/* Clientes */
INSERT INTO clientes (nombre, apellido, dni, email, telefono) VALUES
('Ana',     'Pérez',     '30111222', 'ana@mail.com',     '1123456789'),
('Marcos',  'Fernández', '28999888', 'marcos@mail.com',  '1198765432'),
('Sofía',   'López',     '33444555', 'sofia@mail.com',   '1134567890'),
('Pablo',   'Ramírez',   '27777666', 'pablo@mail.com',   '1145678901'),
('Laura',   'García',    '31222333', 'laura@mail.com',   '1156789012'),
('Hernán',  'Torres',    '29888999', 'hernan@mail.com',  '1167890123'),
('Valeria', 'Suárez',    '32555666', 'valeria@mail.com', '1178901234'),
('Andrés',  'Méndez',    '34555666', 'andres@mail.com',  '1189012345'),
('Martina', 'Figueroa',  '35555666', 'martina@mail.com', '1190123456'),
('Rodrigo', 'Silva',     '36666777', 'rodrigo@mail.com', '1101234567');

/* Tipos de propiedad */
INSERT IGNORE INTO tipos_propiedad (nombre) VALUES
('Casa'),
('Departamento'),
('Local Comercial'),
('Galpón'),
('Cochera');

/* Propiedades */
INSERT INTO propiedades
(direccion, id_localidad, id_tipo_propiedad, ambientes, superficie, precio, en_alquiler, en_venta, id_empleado, id_cliente)
VALUES
('Av. Santa Fe 1234', 1, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'), 3,  70, 140000, 0, 1, 1, 1),
('Calle Falsa 123',   3, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          5, 180, 250000, 1, 0, 2, 2),
('Av. Cabildo 2300',  2, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Local Comercial'),1, 45, 110000, 1, 1, 3, 3),
('Amenábar 3500',     2, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'),  2,  55,  98000, 1, 1, 1, 1),
('Defensa 800',       4, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          4, 120, 185000, 0, 1, 4, 4),
('Av. Rivadavia 5200',5, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          6, 200, 310000, 0, 1, 2, 6),
('Juana Manso 1500',  1, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'),  2,  65, 220000, 1, 1, 3, 7),
('Paraguay 5400',     1, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Local Comercial'),1, 40, 102000, 0, 1, 4, 8),
('Av. Corrientes 7000',5,(SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'),  4,  90, 160000, 1, 1, 5, 9),
('Estados Unidos 500',4, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          3,  95, 175000, 0, 1, 1, 5);

/* Ventas */
INSERT INTO ventas (id_propiedad, id_comprador, fecha_venta, precio_venta) VALUES
(1, 2, '2024-11-15', 135000.00),
(4, 4, '2025-03-10',  97000.00),
(5, 6, '2024-12-20', 180000.00),
(8, 5, '2025-01-05', 100000.00);

/* Alquileres */
INSERT INTO alquileres (id_propiedad, id_inquilino, fecha_inicio, fecha_fin, precio_mensual) VALUES
(2,  3, '2025-01-01', '2025-12-31', 75000.00),
(3,  4, '2025-02-01', '2025-08-31', 65000.00),
(7, 10, '2025-03-01', '2025-09-30', 72000.00),
(9,  2, '2025-04-01', '2025-10-31', 95000.00);

/* Codigo para descargar datos clave y exportar a excel */
-- A) Vista maestra (inventario)
SELECT * FROM vista_propiedades_master;

-- B) Ventas por mes (para series)
SELECT DATE_FORMAT(fecha_venta, '%Y-%m-01') AS mes, 
       COUNT(*) AS cant_ventas,
       SUM(precio_venta) AS monto_vendido
FROM ventas
GROUP BY 1
ORDER BY 1;

-- C) Precio m2 por tipo
SELECT tp.nombre AS tipo, 
       ROUND(AVG(p.precio_m2),2) AS precio_m2_prom
FROM propiedades p
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
GROUP BY 1;

-- D) Precio m2 por localidad
SELECT l.nombre AS localidad, 
       ROUND(AVG(p.precio_m2),2) AS precio_m2_prom
FROM propiedades p
JOIN localidades l ON l.id_localidad = p.id_localidad
GROUP BY 1;

-- E) Alquileres (para vigentes y duración)
SELECT a.*, p.direccion, l.nombre AS localidad, tp.nombre AS tipo
FROM alquileres a
JOIN propiedades p      ON p.id_propiedad = a.id_propiedad
JOIN localidades  l     ON l.id_localidad = p.id_localidad
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad;
