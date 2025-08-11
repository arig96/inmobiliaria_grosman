-- creacion de base
CREATE DATABASE IF NOT EXISTS inmobiliaria_grosman;
USE inmobiliaria_grosman;

-- 2) Tablas
CREATE TABLE IF NOT EXISTS localidades (
  id_localidad INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  provincia VARCHAR(100),
  codigo_postal VARCHAR(10)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS empleados (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  telefono VARCHAR(20)
) ENGINE=InnoDB;

-- Esta tabla guarda los datos de TODAS las personas (dueños, inquilinos, compradores)
CREATE TABLE IF NOT EXISTS clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  dni VARCHAR(20) UNIQUE,
  email VARCHAR(100),
  telefono VARCHAR(20)
) ENGINE=InnoDB;

-- 3) Propiedades (dueño directo: id_cliente NOT NULL)
CREATE TABLE IF NOT EXISTS propiedades (
  id_propiedad INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  direccion VARCHAR(255) NOT NULL,
  id_localidad INT NOT NULL,
  tipo VARCHAR(50),
  ambientes INT,
  superficie INT,
  precio DECIMAL(12,2),
  en_alquiler BOOLEAN,
  en_venta BOOLEAN,
  id_empleado INT NOT NULL,
  id_cliente INT NOT NULL,  -- DUEÑO directo
  precio_m2 DECIMAL(10,2) GENERATED ALWAYS AS (
    CASE WHEN superficie > 0 THEN ROUND(precio / superficie, 2) ELSE NULL END
  ) STORED, -- sugerido por IA
  CONSTRAINT chk_superficie_positiva CHECK (superficie > 0),
  FOREIGN KEY (id_localidad) REFERENCES localidades(id_localidad),
  FOREIGN KEY (id_empleado)  REFERENCES empleados(id_empleado),
  FOREIGN KEY (id_cliente)   REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

-- 4) Operaciones
-- Inquilino y comprador referencian a clientes
CREATE TABLE IF NOT EXISTS alquileres (
  id_alquiler INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  id_propiedad INT NOT NULL,
  id_inquilino INT NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE,
  precio_mensual DECIMAL(10,2),
  FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad),
  FOREIGN KEY (id_inquilino) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ventas (
  id_venta INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  id_propiedad INT NOT NULL,
  id_comprador INT NOT NULL,
  fecha_venta DATE,
  precio_venta DECIMAL(12,2),
  FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad),
  FOREIGN KEY (id_comprador) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

-- insertamos casos
INSERT INTO localidades (nombre, provincia, codigo_postal) VALUES
('Palermo', 'Buenos Aires', '1425'),
('Belgrano', 'Buenos Aires', '1428'),
('Recoleta', 'Buenos Aires', '1118'),
('San Telmo', 'Buenos Aires', '1064'),
('Caballito', 'Buenos Aires', '1424');

INSERT INTO empleados (nombre, apellido, email, telefono) VALUES
('Lucía', 'Martínez', 'lucia@inmo.com', '1160000001'),
('Juan', 'Pérez', 'juan@inmo.com', '1160000002'),
('Carla', 'Gómez', 'carla@inmo.com', '1160000003'),
('Diego', 'Santos', 'diego@inmo.com', '1160000004'),
('Mariana', 'Rivas', 'mariana@inmo.com', '1160000005');

INSERT INTO clientes (nombre, apellido, dni, email, telefono) VALUES
('Ana', 'Pérez', '30111222', 'ana@mail.com', '1123456789'),   
('Marcos', 'Fernández', '28999888', 'marcos@mail.com', '1198765432'), 
('Sofía', 'López', '33444555', 'sofia@mail.com', '1134567890'),      
('Pablo', 'Ramírez', '27777666', 'pablo@mail.com', '1145678901'),     
('Laura', 'García', '31222333', 'laura@mail.com', '1156789012'),      
('Hernán', 'Torres', '29888999', 'hernan@mail.com', '1167890123'),    
('Valeria', 'Suárez', '32555666', 'valeria@mail.com', '1178901234'),  
('Andrés', 'Méndez', '34555666', 'andres@mail.com', '1189012345'),    
('Martina', 'Figueroa', '35555666', 'martina@mail.com', '1190123456'),
('Rodrigo', 'Silva', '36666777', 'rodrigo@mail.com', '1101234567');   

INSERT INTO propiedades (direccion, id_localidad, tipo, ambientes, superficie, precio, en_alquiler, en_venta, id_empleado, id_cliente) VALUES
('Av. Santa Fe 1234', 1, 'Departamento', 3, 70, 140000, FALSE, TRUE, 1, 1),
('Calle Falsa 123', 3, 'Casa', 5, 180, 250000, TRUE, FALSE, 2, 2),
('Av. Cabildo 2300', 2, 'Local Comercial', 1, 45, 110000, TRUE, TRUE, 3, 3),
('Amenábar 3500', 2, 'Departamento', 2, 55, 98000, TRUE, TRUE, 1, 1),
('Defensa 800', 4, 'PH', 4, 120, 185000, FALSE, TRUE, 4, 4),
('Av. Rivadavia 5200', 5, 'Casa', 6, 200, 310000, FALSE, TRUE, 2, 6),
('Juana Manso 1500', 1, 'Departamento', 2, 65, 220000, TRUE, TRUE, 3, 7),
('Paraguay 5400', 1, 'Local Comercial', 1, 40, 102000, FALSE, TRUE, 4, 8),
('Av. Corrientes 7000', 5, 'Departamento', 4, 90, 160000, TRUE, TRUE, 5, 9),
('Estados Unidos 500', 4, 'PH', 3, 95, 175000, FALSE, TRUE, 1, 5);

INSERT INTO ventas (id_propiedad, id_comprador, fecha_venta, precio_venta) VALUES
(1, 2, '2024-11-15', 135000.00),
(4, 4, '2025-03-10', 97000.00),
(5, 6, '2024-12-20', 180000.00),
(8, 5, '2025-01-05', 100000.00);

INSERT INTO alquileres (id_propiedad, id_inquilino, fecha_inicio, fecha_fin, precio_mensual) VALUES
(2, 3, '2025-01-01', '2025-12-31', 75000.00),
(3, 4, '2025-02-01', '2025-08-31', 65000.00),
(7, 10, '2025-03-01', '2025-09-30', 72000.00),
(9, 2, '2025-04-01', '2025-10-31', 95000.00);



-- view del estado actual de propiedades en venta
CREATE OR REPLACE VIEW vista_propiedades_master AS
SELECT
    p.id_propiedad,
    p.direccion,
    l.nombre AS localidad,
    CONCAT(c.nombre, ' ', c.apellido) AS propietario,
    CONCAT(e.nombre, ' ', e.apellido) AS asesor,
    p.precio,
    p.precio_m2,
    p.en_alquiler,
    p.en_venta
FROM propiedades p
JOIN localidades l ON l.id_localidad = p.id_localidad
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN empleados e ON e.id_empleado = p.id_empleado;

-- para ver las propiedades en venta
SELECT * FROM vista_propiedades_master WHERE en_venta = TRUE;

-- propiedades en alquiler
SELECT * FROM vista_propiedades_master WHERE en_alquiler = TRUE;