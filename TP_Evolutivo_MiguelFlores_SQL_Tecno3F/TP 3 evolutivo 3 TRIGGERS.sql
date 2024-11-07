USE servicios_terceros_lh;

/* El procedimiento tiene por objeto validar el ingreso del DNI de un nuevo usuario
para evitar 0 y números negativos. Un mensaje de error aparece cuando se quebranta la regla.
*/

DROP TRIGGER IF EXISTS comprobar_DNI;

DELIMITER //

CREATE TRIGGER comprobar_DNI
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF NEW.dni <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe ser un valor positivo';
    END IF;
END //

select * from usuario;
INSERT INTO usuario (dni) VALUES (0);  -- para que genere error
select * from usuario;
INSERT INTO usuario (dni) VALUES (-1);  -- para que genere error
select * from usuario;

/*
El Laboratorio desea crear un bono o beneficio para su personal por productividad.
Para ello se diseña un trigger, con el fin de registrar en una tabla su participación 
cada vez que se realiza un ensayo. Luego se podría agruparlos por fecha, cantidad u otro criterio para efectivilizarlo.
*/

DROP TABLE IF EXISTS registro_operadores_ensayos;

CREATE TABLE registro_operadores_ensayos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    operador_id INT,
    fecha_ensayo DATETIME,
    FOREIGN KEY (operador_id) REFERENCES personal(idPersonal)
);

DROP TRIGGER IF EXISTS registrar_operadores_ensayo;

DELIMITER //
CREATE TRIGGER registrar_operadores_ensayo
AFTER INSERT ON ensayo
FOR EACH ROW
BEGIN
    
    IF NEW.operador1 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador1, NEW.fecha);
    END IF;

    IF NEW.operador2 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador2, NEW.fecha);
    END IF;

    IF NEW.operador3 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador3, NEW.fecha);
    END IF;

    IF NEW.operador4 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador4, NEW.fecha);
    END IF;
END //

SELECT * FROM registro_operadores_ensayos;

-- TRUNCATE TABLE registro_operadores_ensayos;

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-03 09:41:00', 'planta', 43, 19, 2, 6, 44);

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-04 12:34:00', 'movil', 24, 9, 45, 42, 27);

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-05 08:12:00', 'laboratorio', 34, 2, 11, 28, 6);

SELECT * FROM ENSAYO;
select * from cotizacion;

/*
Se desea realizar el módulo de auditoría para verificar modificaciones en las cotizaciones.
Es necesario incoporar la columna cotizador a la tabla para luego poder utilizar ese dato
en una tercera donde registrará la actividad del mismo en este sector que es tan sensible
en la rentabilidad del negocio.
*/

-- Agrego columna cotizador a la tabla cotizacion
ALTER TABLE cotizacion
ADD COLUMN cotizador INT;

-- Agrego clave foránea para que cotizador esté relacionado con idPersonal de la tabla personal
ALTER TABLE cotizacion
ADD CONSTRAINT fk_cotizador
FOREIGN KEY (cotizador) REFERENCES personal(idPersonal);

select * from cotizacion;

-- para el ejemplo, trabajaremos para cotizaciones que ingresen a partir del id= 50

DROP TABLE IF EXISTS auditoria_cotizaciones;

CREATE TABLE auditoria_cotizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCotizacion INT,
    fecha_actualizacion DATETIME,
    idCotizador INT,  -- Personal que realizó la actualización (cotizador), el que modifica
    accion VARCHAR(50), -- Tipo de acción: 'Actualización'
    idCotizador_OLD INT, -- antigüo cotizador
    cantidad INT,
    detalle_cotizacion INT,
    precio_unitario FLOAT,
    valor_dolar FLOAT,
    total FLOAT,
    observaciones varchar(255),
    FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion),
    FOREIGN KEY (idCotizador) REFERENCES personal(idPersonal)
);

DROP TRIGGER IF EXISTS registrar_auditoria_cotizacion;

DELIMITER //

CREATE TRIGGER registrar_auditoria_cotizacion
AFTER UPDATE ON cotizacion
FOR EACH ROW
BEGIN
    -- Insertar en la tabla de auditoría con la fecha de actualización, el cotizador y la cotización anterior, ya que la actualizada 
    -- estará en la tabla disponible
    
    INSERT INTO auditoria_cotizaciones (idCotizacion, fecha_actualizacion, idCotizador, accion, idCotizador_OLD, cantidad,
    detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones)
    VALUES (OLD.idCotizacion, NOW(), NEW.cotizador, 'Actualización', OLD.cotizador, OLD.cantidad,
    OLD.detalle_cotizacion, OLD.precio_unitario, OLD.valor_dolar, OLD.total, OLD.observaciones);
END //

-- inserción de ejemplos
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 11, 8, 497, 1286, 59517, 'nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh',1);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 4, 2, 1782, 1300, 14613, 'vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi',3);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 18, 5, 4346, 1076, 62181, 'nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta',5);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 4, 10, 4998, 1223, 47851, 'elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus',4);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 8, 6, 2329, 1339, 84743, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat',7);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 2, 3, 4763, 1487, 28111, 'eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc',8);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 29, 2, 1596, 1029, 1062, 'suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero',8);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 74, 2, 7694, 1445, 10915, 'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue',1);

-- disparo trigger

UPDATE cotizacion
SET cantidad = 110, precio_unitario = 115.00, cotizador = 6
WHERE idCotizacion = 51;

UPDATE cotizacion
SET cantidad = 225, precio_unitario = 124.00, cotizador = 8
WHERE idCotizacion = 54;

UPDATE cotizacion
SET cantidad = 96, precio_unitario = 88.00, cotizador = 4
WHERE idCotizacion = 55;

select * from auditoria_cotizaciones;
select * from cotizacion;

select * from cotizacion where idCotizacion > 50;

-- truncate table auditoria_cotizaciones;