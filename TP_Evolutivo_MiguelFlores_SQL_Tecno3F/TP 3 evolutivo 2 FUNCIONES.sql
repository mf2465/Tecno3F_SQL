use servicios_terceros_lh;

/*
Se desea invitar a todos los clientes (usuarios) del Laboratorio
a un evento a fin de año para celebrar nuestro 10 aniversario en el rubro.
Se enviarán las tarjetas personalizadas a las distintas empresas a participar 
*/

DROP FUNCTION IF EXISTS get_nombre_empresa;

DELIMITER $$
CREATE FUNCTION get_nombre_empresa (p_empresa INT)
RETURNS VARCHAR(255)

READS SQL DATA

BEGIN
    DECLARE resultado VARCHAR(255);
    SET resultado = (SELECT nombre FROM empresa WHERE idEmpresa = p_empresa);
    RETURN resultado;
END
$$

DROP FUNCTION IF EXISTS get_cargo_empresa;

DELIMITER $$
CREATE FUNCTION get_cargo_empresa (p_cargo_empresa INT)
RETURNS VARCHAR(255)

READS SQL DATA
BEGIN
    DECLARE retorno VARCHAR(255);
    SET retorno = (SELECT cargo_empresa FROM cargo_empresa WHERE idCargoEmpresa = p_cargo_empresa);
    RETURN retorno;
END
$$

SELECT nombre, apellido, get_nombre_empresa(empresa) as 'Empresa', get_cargo_empresa(cargo_empresa) as 'Cargo',email FROM usuario order by empresa,cargo_empresa;


/*
El departamento comercial lanza una promoción para todas las cotizaciones realizadas en el año 2024
donde se otorga un beneficio de acuerdo a la forma de pago. Se establece que para la cancelación con transferencia
amplía el plazo a 90 días, si abona con tarjeta es de 60 y en caso de utilizar cheque, se reduce a 30.
*/


DROP FUNCTION IF EXISTS promo2024;

DELIMITER $$

CREATE FUNCTION promo2024 (p_forma_pago VARCHAR(50))
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE beneficio VARCHAR(50);

    IF p_forma_pago = 'transferencia' THEN
        SET beneficio = 'Plazo: 90 días';
    ELSEIF p_forma_pago = 'tarjeta' THEN
        SET beneficio = 'Plazo: 60 días';
    ELSEIF p_forma_pago = 'cheque' THEN
        SET beneficio = 'Plazo: 30 días';
    END IF;

    RETURN beneficio;
END $$

SELECT idPresupuesto, get_nombre_empresa(empresa) AS 'Empresa', fecha, forma_pago, promo2024(forma_pago) AS 'Beneficio_promo2024'
FROM presupuesto where fecha >= '2024-01-01' order by Beneficio_promo2024 desc ;