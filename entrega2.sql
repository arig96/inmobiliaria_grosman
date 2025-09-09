/* =========================================================
   creacion de base
   ========================================================= */
DROP DATABASE IF EXISTS inmobiliaria_grosman;
CREATE DATABASE IF NOT EXISTS inmobiliaria_grosman
  /* DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE inmobiliaria_grosman;

/* =========================================================
   1) Tablas maestras
   ========================================================= */

/* 1.1) localidades */
CREATE TABLE IF NOT EXISTS localidades (
  id_localidad INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre       VARCHAR(100) NOT NULL,
  provincia    VARCHAR(100),
  codigo_postal VARCHAR(10)
) ENGINE=InnoDB;

/* 1.2) empleados */
CREATE TABLE IF NOT EXISTS empleados (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre      VARCHAR(100) NOT NULL,
  apellido    VARCHAR(100) NOT NULL,
  email       VARCHAR(100),
  telefono    VARCHAR(20)
) ENGINE=InnoDB;

/* 1.3) Esta tabla guarda los datos de TODAS las personas (dueños, inquilinos, compradores) */
CREATE TABLE IF NOT EXISTS clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre     VARCHAR(100) NOT NULL,
  apellido   VARCHAR(100) NOT NULL,
  dni        VARCHAR(20) UNIQUE,
  email      VARCHAR(100),
  telefono   VARCHAR(20)
) ENGINE=InnoDB;

/* 1.4) a fin de normalizar los tipos de propiedad: */
CREATE TABLE IF NOT EXISTS tipos_propiedad (
  id_tipo_propiedad INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre            VARCHAR(50) NOT NULL,
  CONSTRAINT uq_tipos_propiedad_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

/* =========================================================
   2) Tablas de negocio
   ========================================================= */

/* 2.1) Propiedades (dueño directo: id_cliente NOT NULL) */
CREATE TABLE IF NOT EXISTS propiedades (
  id_propiedad       INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  direccion          VARCHAR(255) NOT NULL,
  id_localidad       INT NOT NULL,
  id_tipo_propiedad  INT NOT NULL,  /* normalizado */
  ambientes          SMALLINT UNSIGNED,
  superficie         INT UNSIGNED,
  precio             DECIMAL(12,2),
  en_alquiler        TINYINT(1) NOT NULL DEFAULT 0,
  en_venta           TINYINT(1) NOT NULL DEFAULT 0,
  id_empleado        INT NOT NULL,
  id_cliente         INT NOT NULL,  -- DUEÑO directo
  /* sugerido por IA */
  precio_m2 DECIMAL(10,2) GENERATED ALWAYS AS (
    CASE WHEN superficie > 0 THEN ROUND(precio / superficie, 2) ELSE NULL END
  ) STORED,
  /* checks de calidad de datos */
  CONSTRAINT chk_superficie_positiva CHECK (superficie > 0),
  CONSTRAINT chk_booleans            CHECK (en_alquiler IN (0,1) AND en_venta IN (0,1)),
  CONSTRAINT chk_precio_positivo     CHECK (precio IS NULL OR precio >= 0),
  /* FKs */
  CONSTRAINT fk_prop_localidad  FOREIGN KEY (id_localidad)      REFERENCES localidades(id_localidad),
  CONSTRAINT fk_prop_tipo       FOREIGN KEY (id_tipo_propiedad) REFERENCES tipos_propiedad(id_tipo_propiedad),
  CONSTRAINT fk_prop_empleado   FOREIGN KEY (id_empleado)       REFERENCES empleados(id_empleado),
  CONSTRAINT fk_prop_cliente    FOREIGN KEY (id_cliente)        REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

/* 2.2) Operaciones
        Inquilino y comprador referencian a clientes */
CREATE TABLE IF NOT EXISTS alquileres (
  id_alquiler    INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  id_propiedad   INT NOT NULL,
  id_inquilino   INT NOT NULL,
  fecha_inicio   DATE,
  fecha_fin      DATE,
  precio_mensual DECIMAL(10,2),
  CONSTRAINT chk_rango_fechas       CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
  CONSTRAINT chk_precio_mensual_pos CHECK (precio_mensual IS NULL OR precio_mensual >= 0),
  CONSTRAINT fk_alq_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad),
  CONSTRAINT fk_alq_inquilino FOREIGN KEY (id_inquilino) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ventas (
  id_venta     INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  id_propiedad INT NOT NULL,
  id_comprador INT NOT NULL,
  fecha_venta  DATE,
  precio_venta DECIMAL(12,2),
  CONSTRAINT chk_precio_venta_pos CHECK (precio_venta IS NULL OR precio_venta >= 0),
  CONSTRAINT chk_fecha_venta      CHECK (fecha_venta IS NOT NULL),
  /* Regla de inmobiliaria: no se pueden vender 2 veces la misma propiedad */
  CONSTRAINT uq_venta_unica_por_prop UNIQUE (id_propiedad),
  CONSTRAINT fk_ven_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad),
  CONSTRAINT fk_ven_comprador FOREIGN KEY (id_comprador) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

/* =========================================================
   3) Datos de ejemplo (semillas)
   ========================================================= */

/* 3.1) localidades */
INSERT INTO localidades (nombre, provincia, codigo_postal) VALUES
('Palermo',   'Buenos Aires', '1425'),
('Belgrano',  'Buenos Aires', '1428'),
('Recoleta',  'Buenos Aires', '1118'),
('San Telmo', 'Buenos Aires', '1064'),
('Caballito', 'Buenos Aires', '1424');

/* 3.2) empleados */
INSERT INTO empleados (nombre, apellido, email, telefono) VALUES
('Lucía',  'Martínez', 'lucia@inmo.com', '1160000001'),
('Juan',   'Pérez',    'juan@inmo.com',  '1160000002'),
('Carla',  'Gómez',    'carla@inmo.com', '1160000003'),
('Diego',  'Santos',   'diego@inmo.com', '1160000004'),
('Mariana','Rivas',    'mariana@inmo.com','1160000005');

/* 3.3) clientes */
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

/* 3.4) tipos_propiedad (oficiales de tu inmobiliaria) */
INSERT IGNORE INTO tipos_propiedad (nombre) VALUES
('Casa'),
('Departamento'),
('Local Comercial'),
('Galpón'),
('Cochera');

/* 3.5) propiedades (ya normalizadas; “PH” mapeado a “Casa”) */
INSERT INTO propiedades
(direccion, id_localidad, id_tipo_propiedad, ambientes, superficie, precio, en_alquiler, en_venta, id_empleado, id_cliente)
VALUES
('Av. Santa Fe 1234', 1, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'), 3,  70, 140000, 0, 1, 1, 1),
('Calle Falsa 123',   3, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          5, 180, 250000, 1, 0, 2, 2),
('Av. Cabildo 2300',  2, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Local Comercial'),1, 45, 110000, 1, 1, 3, 3),
('Amenábar 3500',     2, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'),  2,  55,  98000, 1, 1, 1, 1),
('Defensa 800',       4, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          4, 120, 185000, 0, 1, 4, 4), /* antes “PH” → Casa */
('Av. Rivadavia 5200',5, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          6, 200, 310000, 0, 1, 2, 6),
('Juana Manso 1500',  1, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'),  2,  65, 220000, 1, 1, 3, 7),
('Paraguay 5400',     1, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Local Comercial'),1, 40, 102000, 0, 1, 4, 8),
('Av. Corrientes 7000',5,(SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Departamento'),  4,  90, 160000, 1, 1, 5, 9),
('Estados Unidos 500',4, (SELECT id_tipo_propiedad FROM tipos_propiedad WHERE nombre='Casa'),          3,  95, 175000, 0, 1, 1, 5);

/* 3.6) ventas (cumple UNIQUE por propiedad) */
INSERT INTO ventas (id_propiedad, id_comprador, fecha_venta, precio_venta) VALUES
(1, 2, '2024-11-15', 135000.00),
(4, 4, '2025-03-10',  97000.00),
(5, 6, '2024-12-20', 180000.00),
(8, 5, '2025-01-05', 100000.00);

/* 3.7) alquileres */
INSERT INTO alquileres (id_propiedad, id_inquilino, fecha_inicio, fecha_fin, precio_mensual) VALUES
(2,  3, '2025-01-01', '2025-12-31', 75000.00),
(3,  4, '2025-02-01', '2025-08-31', 65000.00),
(7, 10, '2025-03-01', '2025-09-30', 72000.00),
(9,  2, '2025-04-01', '2025-10-31', 95000.00);

/* =========================================================
   4) view del estado actual de propiedades
   ========================================================= */
DROP VIEW IF EXISTS vista_propiedades_master;
CREATE VIEW vista_propiedades_master AS
SELECT
    p.id_propiedad,
    p.direccion,
    l.nombre AS localidad,
    tp.nombre AS tipo,
    p.ambientes,
    p.superficie,
    p.precio,
    p.precio_m2,
    p.en_alquiler,
    p.en_venta,
    CONCAT(c.nombre, ' ', c.apellido) AS propietario,
    CONCAT(e.nombre, ' ', e.apellido) AS asesor
FROM propiedades p
JOIN localidades      l  ON l.id_localidad = p.id_localidad
JOIN tipos_propiedad  tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN clientes         c  ON c.id_cliente   = p.id_cliente
JOIN empleados        e  ON e.id_empleado  = p.id_empleado;

/* para ver las propiedades en venta */
SELECT * FROM vista_propiedades_master WHERE en_venta = 1;

/* propiedades en alquiler */
SELECT * FROM vista_propiedades_master WHERE en_alquiler = 1;

/* =========================================================
   5) Índices recomendados (performance)
   ========================================================= */
CREATE INDEX idx_propiedades_localidad  ON propiedades(id_localidad);
CREATE INDEX idx_propiedades_tipo       ON propiedades(id_tipo_propiedad);
CREATE INDEX idx_propiedades_empleado   ON propiedades(id_empleado);
CREATE INDEX idx_propiedades_cliente    ON propiedades(id_cliente);
CREATE INDEX idx_propiedades_estado     ON propiedades(en_venta, en_alquiler);
CREATE INDEX idx_alquileres_propiedad   ON alquileres(id_propiedad);
CREATE INDEX idx_alquileres_inquilino   ON alquileres(id_inquilino);
CREATE INDEX idx_ventas_propiedad       ON ventas(id_propiedad);
CREATE INDEX idx_ventas_comprador       ON ventas(id_comprador);
CREATE INDEX idx_ventas_fecha           ON ventas(fecha_venta);

/* =========================================================
   6) Triggers para automatizar la actualización de propiedades una vez vendidas
   ========================================================= */

/* Flag vendida */
ALTER TABLE propiedades
  ADD COLUMN vendida TINYINT(1) NOT NULL DEFAULT 0,
  ADD CONSTRAINT chk_vendida CHECK (vendida IN (0,1));

/* Reset por si existen */
DROP TRIGGER IF EXISTS trg_ventas_after_insert;
DROP TRIGGER IF EXISTS trg_ventas_after_delete;
DROP TRIGGER IF EXISTS trg_ventas_after_update;
DROP TRIGGER IF EXISTS trg_alquileres_before_insert;

/* Al crear una venta marcar como vendida y sacar de publicación */
DELIMITER //
CREATE TRIGGER trg_ventas_after_insert
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
  UPDATE propiedades
     SET vendida = 1,
         en_venta = 0
   WHERE id_propiedad = NEW.id_propiedad;
END//
DELIMITER ;

/* Al borrar una venta: la propiedad ya no está vendida */
/* (Si querés relistarla automáticamente, agregar en_venta = 1) */
DELIMITER //
CREATE TRIGGER trg_ventas_after_delete
AFTER DELETE ON ventas
FOR EACH ROW
BEGIN
  UPDATE propiedades
     SET vendida = 0
   WHERE id_propiedad = OLD.id_propiedad;
END//
DELIMITER ;

/* Si se actualiza ventas y cambia id_propiedad:
   - la vieja deja de estar vendida
   - la nueva pasa a vendida y fuera de venta */
DELIMITER //
CREATE TRIGGER trg_ventas_after_update
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
  IF OLD.id_propiedad <> NEW.id_propiedad THEN
    UPDATE propiedades
       SET vendida = 0
     WHERE id_propiedad = OLD.id_propiedad;

    UPDATE propiedades
       SET vendida = 1,
           en_venta = 0
     WHERE id_propiedad = NEW.id_propiedad;
  END IF;
END//
DELIMITER ;

/* Evitar alquiler en propiedades vendidas */
DELIMITER //
CREATE TRIGGER trg_alquileres_before_insert
BEFORE INSERT ON alquileres
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
      FROM propiedades
     WHERE id_propiedad = NEW.id_propiedad
       AND vendida = 1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No se puede crear un alquiler para una propiedad vendida';
  END IF;
END//
DELIMITER ;

/* Verificar lo creado */
SHOW TRIGGERS;

/* =========================================================
   7) SP 
   a fin de tener un mejor conocimiento de las propiedades listadas y dar un mejor servicio
   se crea un SP para buscar propiedades por localidad y busqueda de propiedades en alquiler
   ========================================================= */

/* Limpieza previa */
DROP PROCEDURE IF EXISTS sp_propiedades_en_venta;
DROP PROCEDURE IF EXISTS sp_buscar_propiedades_por_localidad;
DROP PROCEDURE IF EXISTS sp_registrar_venta;
DROP PROCEDURE IF EXISTS sp_registrar_alquiler;

/* Listar propiedades en venta (no vendidas) */
DELIMITER //
CREATE PROCEDURE sp_propiedades_en_venta()
BEGIN
  SELECT p.id_propiedad,
         p.direccion,
         l.nombre AS localidad,
         tp.nombre AS tipo,
         p.ambientes,
         p.superficie,
         p.precio,
         p.precio_m2
  FROM propiedades p
  JOIN localidades      l  ON l.id_localidad = p.id_localidad
  JOIN tipos_propiedad  tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
  WHERE p.en_venta = 1 AND p.vendida = 0;
END//
DELIMITER ;
/* Ejemplo de uso:
   CALL sp_propiedades_en_venta();
*/

/* Buscar propiedades por localidad */
DELIMITER //
CREATE PROCEDURE sp_buscar_propiedades_por_localidad(IN localidad_nombre VARCHAR(100))
BEGIN
  SELECT p.id_propiedad,
         p.direccion,
         tp.nombre AS tipo,
         p.precio,
         p.precio_m2,
         p.en_alquiler,
         p.en_venta
  FROM propiedades p
  JOIN localidades      l  ON l.id_localidad = p.id_localidad
  JOIN tipos_propiedad  tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
  WHERE l.nombre = localidad_nombre;
END//
DELIMITER ;
/* Ejemplo de uso:
   CALL sp_buscar_propiedades_por_localidad('Palermo');
*/

/* Registrar una nueva venta (la FK UNIQUE evita doble venta) */
DELIMITER //
CREATE PROCEDURE sp_registrar_venta(
    IN p_id_propiedad INT,
    IN p_id_comprador INT,
    IN p_fecha DATE,
    IN p_precio DECIMAL(12,2)
)
BEGIN
  INSERT INTO ventas (id_propiedad, id_comprador, fecha_venta, precio_venta)
  VALUES (p_id_propiedad, p_id_comprador, p_fecha, p_precio);

  /*
END//
DELIMITER ;
/* Ejemplo de uso:
   CALL sp_registrar_venta(3, 2, '2025-09-05', 150000.00);
*/

/* Registrar un nuevo alquiler */
DELIMITER //
CREATE PROCEDURE sp_registrar_alquiler(
    IN p_id_propiedad INT,
    IN p_id_inquilino INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_precio_mensual DECIMAL(10,2)
)
BEGIN
  INSERT INTO alquileres (id_propiedad, id_inquilino, fecha_inicio, fecha_fin, precio_mensual)
  VALUES (p_id_propiedad, p_id_inquilino, p_fecha_inicio, p_fecha_fin, p_precio_mensual);

  UPDATE propiedades
    SET en_alquiler = 1
  WHERE id_propiedad = p_id_propiedad;
END//
DELIMITER ;
/* Ejemplo de uso:
   CALL sp_registrar_alquiler(2, 5, '2025-10-01', '2026-09-30', 80000.00);
*/

/* =========================================================
   8) Consultas de verificación
   ========================================================= */

/* para ver las propiedades en venta (vista) */
SELECT * FROM vista_propiedades_master WHERE en_venta = 1;

/* para ver las propiedades en alquiler (vista) */
SELECT * FROM vista_propiedades_master WHERE en_alquiler = 1;

/* ver definición de la vista */
SHOW CREATE VIEW vista_propiedades_master\G

/* ver SPs */
SHOW PROCEDURE STATUS LIKE 'sp_%';
