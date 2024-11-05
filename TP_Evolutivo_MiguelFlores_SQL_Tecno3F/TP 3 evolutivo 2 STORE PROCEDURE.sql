use servicios_terceros_lh;

/*
Se necesita realizar un listado de los usuarios inactivos para depurar la base de datos.
Previo a la eliminación se les enviará un mail con una invitación o una encuesta
con el objeto de revincularlos a la plataforma.
El procedimiento permitirá tomar como variable la cantidad de días deseado como corte anterior a la fecha actual
en que se realiza la consulta
*/

select * from usuario where last_session <= (now());

DROP PROCEDURE usuario_inactivo;

DELIMITER $$

CREATE PROCEDURE usuario_inactivo (IN dias_inactividad INT)
BEGIN
	DECLARE fecha_limite DATE;
	SET fecha_limite = DATE_SUB(CURDATE(), INTERVAL dias_inactividad DAY);
    SELECT 	nombre, apellido, email, last_session FROM usuario WHERE last_session < fecha_limite;
END
$$

-- se ingresa la cantidad de días a partir de la cual se considera inactivo
CALL usuario_inactivo(365);