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

SELECT nombre, apellido, get_nombre_empresa(empresa) as 'Empresa', get_cargo_empresa(cargo_empresa) as 'Cargo' FROM usuario order by empresa,cargo_empresa;

select* from usuario;

DROP FUNCTION IF EXISTS get_usuario_activo;

DELIMITER $$
CREATE FUNCTION get_usuario_activo (p_last_session date)
RETURNS date

READS SQL DATA
BEGIN
    DECLARE respuesta date;
    SET respuesta = (SELECT last_session FROM usuario WHERE last_session BETWEEN DATE_SUB(NOW(), INTERVAL 180 DAY) AND NOW());
    RETURN respuesta;
END
$$

SELECT nombre, apellido, get_nombre_empresa(empresa) as 'Empresa', get_cargo_empresa(cargo_empresa) as 'Cargo',  
get_usuario_activo (last_session) as 'last_session'
FROM usuario order by empresa,cargo_empresa;