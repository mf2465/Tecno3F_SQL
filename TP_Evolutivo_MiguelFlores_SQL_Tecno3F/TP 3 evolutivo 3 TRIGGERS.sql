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

/*
*/

select * from usuario;
INSERT INTO usuario (dni) VALUES (0);  -- Esto fallará debido al trigger.
select * from usuario;
INSERT INTO usuario (dni) VALUES (-1);  -- Esto fallará debido al trigger.
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

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-03 09:41:00', 'planta', 43, 19, 2, 6, 44);

SELECT * FROM ENSAYO;





