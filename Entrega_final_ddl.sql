/* =========================================================
   Inmobiliaria Grosman – DDL (creación de objetos)
   ========================================================= */
DROP DATABASE IF EXISTS inmobiliaria_grosman;
CREATE DATABASE IF NOT EXISTS inmobiliaria_grosman
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE inmobiliaria_grosman;

/* =====================
   Tablas maestras
   ===================== */
CREATE TABLE IF NOT EXISTS localidades (
  id_localidad  INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre        VARCHAR(100) NOT NULL,
  provincia     VARCHAR(100),
  codigo_postal VARCHAR(10)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS empleados (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre      VARCHAR(100) NOT NULL,
  apellido    VARCHAR(100) NOT NULL,
  email       VARCHAR(100),
  telefono    VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre     VARCHAR(100) NOT NULL,
  apellido   VARCHAR(100) NOT NULL,
  dni        VARCHAR(20) NOT NULL,
  email      VARCHAR(100),
  telefono   VARCHAR(20),
  CONSTRAINT uq_clientes_dni UNIQUE (dni)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tipos_propiedad (
  id_tipo_propiedad INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  nombre            VARCHAR(50) NOT NULL,
  CONSTRAINT uq_tipos_propiedad_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

/* =====================
   Tablas de negocio
   ===================== */
CREATE TABLE IF NOT EXISTS propiedades (
  id_propiedad       INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  direccion          VARCHAR(255) NOT NULL,
  id_localidad       INT NOT NULL,
  id_tipo_propiedad  INT NOT NULL,
  ambientes          SMALLINT UNSIGNED,
  superficie         INT UNSIGNED,
  precio             DECIMAL(12,2),
  en_alquiler        TINYINT(1) NOT NULL DEFAULT 0,
  en_venta           TINYINT(1) NOT NULL DEFAULT 0,
  id_empleado        INT NOT NULL,
  id_cliente         INT NOT NULL,
  vendida            TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT chk_superficie_positiva CHECK (superficie > 0),
  CONSTRAINT chk_booleans CHECK (en_alquiler IN (0,1) AND en_venta IN (0,1) AND vendida IN (0,1)),
  CONSTRAINT chk_precio_positivo CHECK (precio IS NULL OR precio >= 0),
  precio_m2 DECIMAL(10,2) GENERATED ALWAYS AS (
    CASE WHEN superficie > 0 THEN ROUND(precio / superficie, 2) ELSE NULL END
  ) STORED,
  CONSTRAINT fk_prop_localidad  FOREIGN KEY (id_localidad)      REFERENCES localidades(id_localidad),
  CONSTRAINT fk_prop_tipo       FOREIGN KEY (id_tipo_propiedad) REFERENCES tipos_propiedad(id_tipo_propiedad),
  CONSTRAINT fk_prop_empleado   FOREIGN KEY (id_empleado)       REFERENCES empleados(id_empleado),
  CONSTRAINT fk_prop_cliente    FOREIGN KEY (id_cliente)        REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

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
  CONSTRAINT uq_venta_unica_por_prop UNIQUE (id_propiedad),
  CONSTRAINT fk_ven_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad),
  CONSTRAINT fk_ven_comprador FOREIGN KEY (id_comprador) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

/* =====================
   Índices
   ===================== */
CREATE INDEX idx_propiedades_localidad  ON propiedades(id_localidad);
CREATE INDEX idx_propiedades_tipo       ON propiedades(id_tipo_propiedad);
CREATE INDEX idx_propiedades_empleado   ON propiedades(id_empleado);
CREATE INDEX idx_propiedades_cliente    ON propiedades(id_cliente);
CREATE INDEX idx_propiedades_estado     ON propiedades(en_venta, en_alquiler, vendida);
CREATE INDEX idx_alquileres_propiedad   ON alquileres(id_propiedad);
CREATE INDEX idx_alquileres_inquilino   ON alquileres(id_inquilino);
CREATE INDEX idx_ventas_propiedad       ON ventas(id_propiedad);
CREATE INDEX idx_ventas_comprador       ON ventas(id_comprador);
CREATE INDEX idx_ventas_fecha           ON ventas(fecha_venta);

/* =====================
   Triggers
   ===================== */
DROP TRIGGER IF EXISTS trg_ventas_after_insert;
DROP TRIGGER IF EXISTS trg_ventas_after_delete;
DROP TRIGGER IF EXISTS trg_ventas_after_update;
DROP TRIGGER IF EXISTS trg_alquileres_before_insert;
DROP TRIGGER IF EXISTS trg_alquileres_no_overlap_before_insert;
DROP TRIGGER IF EXISTS trg_alquileres_no_overlap_before_update;

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

DELIMITER //
CREATE TRIGGER trg_alquileres_no_overlap_before_insert
BEFORE INSERT ON alquileres
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
      FROM alquileres a
     WHERE a.id_propiedad = NEW.id_propiedad
       AND (NEW.fecha_fin   IS NULL OR a.fecha_inicio <= NEW.fecha_fin)
       AND (a.fecha_fin     IS NULL OR NEW.fecha_inicio <= a.fecha_fin)
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Solapamiento de alquileres para la misma propiedad';
  END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_alquileres_no_overlap_before_update
BEFORE UPDATE ON alquileres
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
      FROM alquileres a
     WHERE a.id_propiedad = NEW.id_propiedad
       AND a.id_alquiler <> OLD.id_alquiler
       AND (NEW.fecha_fin   IS NULL OR a.fecha_inicio <= NEW.fecha_fin)
       AND (a.fecha_fin     IS NULL OR NEW.fecha_inicio <= a.fecha_fin)
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Solapamiento de alquileres para la misma propiedad (UPDATE)';
  END IF;
END//
DELIMITER ;

/* =====================
   Vista
   ===================== */
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
    p.vendida,
    CONCAT(c.nombre, ' ', c.apellido) AS propietario,
    CONCAT(e.nombre, ' ', e.apellido) AS asesor
FROM propiedades p
JOIN localidades      l  ON l.id_localidad = p.id_localidad
JOIN tipos_propiedad  tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN clientes         c  ON c.id_cliente   = p.id_cliente
JOIN empleados        e  ON e.id_empleado  = p.id_empleado;

/* =====================
   Stored Procedures
   ===================== */
DROP PROCEDURE IF EXISTS sp_propiedades_en_venta;
DROP PROCEDURE IF EXISTS sp_buscar_propiedades_por_localidad;
DROP PROCEDURE IF EXISTS sp_registrar_venta;
DROP PROCEDURE IF EXISTS sp_registrar_alquiler;

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

DELIMITER //
CREATE PROCEDURE sp_buscar_propiedades_por_localidad(IN p_localidad VARCHAR(100))
BEGIN
  SELECT p.id_propiedad,
         p.direccion,
         tp.nombre AS tipo,
         p.precio,
         p.precio_m2,
         p.en_alquiler,
         p.en_venta,
         p.vendida
  FROM propiedades p
  JOIN localidades      l  ON l.id_localidad = p.id_localidad
  JOIN tipos_propiedad  tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
  WHERE l.nombre LIKE CONCAT('%', p_localidad, '%');
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_registrar_venta(
    IN p_id_propiedad INT,
    IN p_id_comprador INT,
    IN p_fecha DATE,
    IN p_precio DECIMAL(12,2)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error registrando la venta (transacción revertida)';
  END;

  START TRANSACTION;

  IF NOT EXISTS (SELECT 1 FROM propiedades WHERE id_propiedad = p_id_propiedad) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Propiedad inexistente';
  END IF;

  IF EXISTS (SELECT 1 FROM ventas WHERE id_propiedad = p_id_propiedad) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La propiedad ya tiene una venta registrada';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_comprador) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Comprador inexistente';
  END IF;

  INSERT INTO ventas (id_propiedad, id_comprador, fecha_venta, precio_venta)
  VALUES (p_id_propiedad, p_id_comprador, p_fecha, p_precio);

  COMMIT;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_registrar_alquiler(
    IN p_id_propiedad INT,
    IN p_id_inquilino INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_precio_mensual DECIMAL(10,2)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error registrando el alquiler (transacción revertida)';
  END;

  START TRANSACTION;

  IF NOT EXISTS (SELECT 1 FROM propiedades WHERE id_propiedad = p_id_propiedad) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Propiedad inexistente';
  END IF;

  IF EXISTS (SELECT 1 FROM propiedades WHERE id_propiedad = p_id_propiedad AND vendida = 1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede alquilar una propiedad vendida';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_inquilino) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inquilino inexistente';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM alquileres a
     WHERE a.id_propiedad = p_id_propiedad
       AND (p_fecha_fin   IS NULL OR a.fecha_inicio <= p_fecha_fin)
       AND (a.fecha_fin   IS NULL OR p_fecha_inicio <= a.fecha_fin)
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Solapamiento de alquileres para la misma propiedad';
  END IF;

  INSERT INTO alquileres (id_propiedad, id_inquilino, fecha_inicio, fecha_fin, precio_mensual)
  VALUES (p_id_propiedad, p_id_inquilino, p_fecha_inicio, p_fecha_fin, p_precio_mensual);

  UPDATE propiedades
     SET en_alquiler = 1
   WHERE id_propiedad = p_id_propiedad;

  COMMIT;
END//
DELIMITER ;


/* =====================
   Vistas adicionales
   ===================== */

/* 1) Propiedades en venta (no vendidas) */
DROP VIEW IF EXISTS vista_propiedades_en_venta;
CREATE VIEW vista_propiedades_en_venta AS
SELECT p.id_propiedad, p.direccion, l.nombre AS localidad, tp.nombre AS tipo,
       p.ambientes, p.superficie, p.precio, p.precio_m2,
       CONCAT(c.nombre,' ',c.apellido) AS propietario,
       CONCAT(e.nombre,' ',e.apellido) AS asesor
FROM propiedades p
JOIN localidades l ON l.id_localidad = p.id_localidad
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN empleados e ON e.id_empleado = p.id_empleado
WHERE p.en_venta = 1 AND p.vendida = 0;

/* 2) Propiedades en alquiler (publicadas) */
DROP VIEW IF EXISTS vista_propiedades_en_alquiler;
CREATE VIEW vista_propiedades_en_alquiler AS
SELECT p.id_propiedad, p.direccion, l.nombre AS localidad, tp.nombre AS tipo,
       p.ambientes, p.superficie, p.precio, p.precio_m2,
       CONCAT(c.nombre,' ',c.apellido) AS propietario,
       CONCAT(e.nombre,' ',e.apellido) AS asesor
FROM propiedades p
JOIN localidades l ON l.id_localidad = p.id_localidad
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN empleados e ON e.id_empleado = p.id_empleado
WHERE p.en_alquiler = 1 AND p.vendida = 0;

/* 3) Ventas con detalle */
DROP VIEW IF EXISTS vista_ventas_detalle;
CREATE VIEW vista_ventas_detalle AS
SELECT v.id_venta, v.fecha_venta, v.precio_venta,
       p.id_propiedad, p.direccion, tp.nombre AS tipo, l.nombre AS localidad,
       CONCAT(ccompr.nombre,' ',ccompr.apellido) AS comprador,
       CONCAT(cprop.nombre,' ',cprop.apellido)   AS propietario
FROM ventas v
JOIN propiedades p      ON p.id_propiedad = v.id_propiedad
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN localidades l      ON l.id_localidad = p.id_localidad
JOIN clientes ccompr    ON ccompr.id_cliente = v.id_comprador
JOIN clientes cprop     ON cprop.id_cliente  = p.id_cliente;

/* 4) Alquileres vigentes */
DROP VIEW IF EXISTS vista_alquileres_vigentes;
CREATE VIEW vista_alquileres_vigentes AS
SELECT a.id_alquiler, a.fecha_inicio, a.fecha_fin, a.precio_mensual,
       p.id_propiedad, p.direccion, tp.nombre AS tipo, l.nombre AS localidad,
       CONCAT(cinqui.nombre,' ',cinqui.apellido) AS inquilino,
       CONCAT(cprop.nombre,' ',cprop.apellido)   AS propietario
FROM alquileres a
JOIN propiedades p      ON p.id_propiedad = a.id_propiedad
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN localidades l      ON l.id_localidad = p.id_localidad
JOIN clientes cinqui    ON cinqui.id_cliente = a.id_inquilino
JOIN clientes cprop     ON cprop.id_cliente  = p.id_cliente
WHERE a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE();

/* =====================
   Funciones opcionales
   ===================== */
DROP FUNCTION IF EXISTS fn_meses_entre;
DELIMITER //
CREATE FUNCTION fn_meses_entre(p_inicio DATE, p_fin DATE)
RETURNS INT DETERMINISTIC
BEGIN
  IF p_inicio IS NULL OR p_fin IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN (YEAR(p_fin)*12 + MONTH(p_fin)) - (YEAR(p_inicio)*12 + MONTH(p_inicio));
END//
DELIMITER ;

DROP FUNCTION IF EXISTS fn_contrato_vigente;
DELIMITER //
CREATE FUNCTION fn_contrato_vigente(p_inicio DATE, p_fin DATE, p_ref DATE)
RETURNS TINYINT DETERMINISTIC
BEGIN
  IF p_inicio IS NULL THEN RETURN 0; END IF;
  IF p_fin IS NULL THEN
    RETURN (p_ref >= p_inicio);
  END IF;
  RETURN (p_ref BETWEEN p_inicio AND p_fin);
END//
DELIMITER ;
