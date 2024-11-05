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
    SELECT 	nombre, apellido, email, last_session, now() as FECHA_HOY FROM usuario WHERE last_session < fecha_limite AND activacion > 0;
END
$$

-- se ingresa la cantidad de días a partir de la cual se considera inactivo
CALL usuario_inactivo(365);

/*
Se desea realizar un listado de los certificados próximos a caducar, ya que el personal
comenzará a tomar vacaciones y es necesario preveer una guardia para atender las necesidades de los clientes
en este período del año. El procedimiento contempla la cantidad de días a partir del día de la consulta del operador
*/

SELECT * FROM certificado;

DROP PROCEDURE certificado_proximo_a_vencer;

DELIMITER $$

CREATE PROCEDURE certificado_proximo_a_vencer (IN dias_a_cubrir INT)
BEGIN
    SELECT 
        idCertificado,
        fecha,
        ensayo,
        aptitud,
        vigencia_dias,
        precinto,
        DATE_ADD(fecha, INTERVAL vigencia_dias DAY) AS fecha_vencimiento,
        now() as FECHA_HOY
    FROM certificado
    WHERE DATE_ADD(fecha, INTERVAL vigencia_dias DAY) BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL dias_a_cubrir DAY) AND aptitud > 0;

END
$$

-- días a preveer de vencimientos de certificados para organizar esquema de licencias del personal
CALL certificado_proximo_a_vencer (30);