-- Ejercicios Sakila Parte 2

# Usaremos la tabla payment
-- 1 Obtener el total de ventas junto al importe para cada miembro del staff

SELECT staff_id AS 'ID Staff'
,COUNT(staff_id) AS 'Total Cantidad Ventas'
,SUM(amount) AS 'Total Importe Ventas'
FROM payment
GROUP BY staff_id;

-- 2 lo mismo que el anterior.. pero entre las fechas 01/07/2005 hasta 31/09/2005

SELECT staff_id AS 'ID Staff'
,COUNT(staff_id) AS 'Total Cantidad Ventas'
,SUM(amount) AS 'Total Importe Ventas'
FROM payment
WHERE payment_date BETWEEN '2005-07-01' AND '2005-09-31'
GROUP BY staff_id;

-- 3 Promedio de importe por pago redondeando a 2 decimales
SELECT ROUND(AVG(amount),2) AS 'Promedio de importe'
FROM payment;

-- 4 Cantidad de pagos realizados en cada mes
SELECT MONTH(payment_date) AS 'Mes'
,COUNT(*) AS 'Cantidad de pagos'
FROM payment
GROUP BY MONTH(payment_date);

#También era aceptable

SELECT MONTHNAME(payment_date) AS 'Mes'
,COUNT(*) AS 'Cantidad de pagos'
FROM payment
GROUP BY MONTH(payment_date);

-- 5 Obtener el total de ventas por cada mes y año 

SELECT MONTH(payment_date) AS 'Mes'
,YEAR(payment_date) AS 'Año'
, SUM(amount) AS 'Total Ventas'
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY YEAR(payment_date), MONTH(payment_date); -- el order no era necesario

#También eran aceptables

SELECT MONTHNAME(payment_date) AS 'Mes'
,YEAR(payment_date) AS 'Año'
, SUM(amount) AS 'Total Ventas'
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY YEAR(payment_date), MONTH(payment_date);

SELECT CONCAT(MONTH(payment_date),' - ' ,YEAR(payment_date)) AS 'Mes - Año'
,SUM(amount) AS 'Total Ventas'
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY YEAR(payment_date), MONTH(payment_date);

SELECT CONCAT(MONTHNAME(payment_date),' - ' ,YEAR(payment_date)) AS 'Mes - Año'
,SUM(amount) AS 'Total Ventas'
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY YEAR(payment_date), MONTH(payment_date);


-- 6 Año con mayor cantidad de pagos y su importe total

SELECT YEAR(payment_date) AS 'Año'
,COUNT(*) AS 'Cantidad de pagos'
,SUM(amount) AS 'Importe total'
FROM payment
GROUP BY YEAR(payment_date)
ORDER BY COUNT(*) DESC
LIMIT 1;

#tabla film_actor
-- 7 encontrar los actores que han aparecido en más de 35 películas y ordenarlos por numero de peliculas

SELECT actor_id AS 'ID Actor'
,COUNT(*) AS 'Número de películas'
FROM film_actor
GROUP BY actor_id
HAVING COUNT(*) > 35
order by 2 ;

#También era aceptable

SELECT actor_id AS 'ID Actor'
,COUNT(*) AS 'Número de películas'
FROM film_actor
GROUP BY actor_id
HAVING COUNT(*) >= 36
order by 2 ;

#tabla film

/*
Este tema no se explico, pero esta en las diapositivas, deben leerla para resolverlo
*/

-- 8 clasificar las peliculas en mas larga , mas corta y otra segun su length

SELECT title, length,
       CASE WHEN length = (SELECT MAX(length) FROM film) THEN 'Más larga'
            WHEN length = (SELECT MIN(length) FROM film) THEN 'Más corta'
            ELSE 'Otra'
       END AS clasificación
FROM film
ORDER BY length DESC;
