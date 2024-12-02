USE pizzeria;

DELIMITER $$

CREATE FUNCTION `f_generar_cliente`() RETURNS varchar(60)
READS SQL DATA
BEGIN
    DECLARE int_nombre, int_apellido, int_resultado VARCHAR(60);
    SET int_nombre = (SELECT nombre FROM rdm_nombre ORDER BY RAND() LIMIT 1);
    SET int_apellido = (SELECT apellido FROM rdm_nombre ORDER BY RAND() LIMIT 1);
    SET int_resultado = CONCAT(int_nombre, ' ', int_apellido);
    RETURN int_resultado;
END $$

CREATE FUNCTION `f_rand_entrega`() RETURNS int
NO SQL
BEGIN
    DECLARE result INT;
    SET result = FLOOR((RAND() * 2) + 1);
    RETURN result;
END $$

CREATE FUNCTION `f_random`() RETURNS int
NO SQL
BEGIN
    DECLARE num_random INT;
    SET num_random = 0;
    SELECT FLOOR(RAND()*(999999-100+1))+100 INTO num_random;
    RETURN num_random;
END $$

CREATE FUNCTION `fventas`() RETURNS decimal(9,2)
DETERMINISTIC
BEGIN

    DECLARE total DECIMAL(9,2);
    SET total = 0.00;
    
    SELECT SUM(total_factura) FROM facturas INTO total;
    
    RETURN total;

END $$

CREATE FUNCTION `iva`(monto DECIMAL) RETURNS decimal(9,2)
DETERMINISTIC
BEGIN

    DECLARE total, iva DECIMAL(9,2);
    
    SET total = 0.00;
    SET iva = 1.15;
    
    SELECT monto * iva INTO total;
    
    RETURN total;

END $$

CREATE FUNCTION `calcular_provision`(cant_ideal DECIMAL(11,2), cant_actual DECIMAL(11,2))
RETURNS decimal(11,2)
DETERMINISTIC
BEGIN
	DECLARE resultado DECIMAL(11,2);
    SET resultado = (cant_ideal - cant_actual) * 1.1;
    RETURN resultado;
END $$

DELIMITER ;