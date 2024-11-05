USE servicios_terceros_lh;

DELIMITER //

CREATE TRIGGER comprobar_DNI
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF NEW.dni <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe ser un valor positivo';
    END IF;
END //
