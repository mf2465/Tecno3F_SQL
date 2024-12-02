USE pizzeria;

CREATE OR REPLACE VIEW productos_a_pedir AS
SELECT
	p.nombre_proveedor 'Proveedor',
    s.nombre_producto AS 'Producto',
    calcular_provision(s.cantidad_ideal, s.cantidad_producto) AS 'Cantidad',
    s.medida_producto AS 'Unidad'
FROM stock s
LEFT JOIN proveedores p ON s.id_proveedor = p.id_proveedor
WHERE cantidad_producto < stock_minimo
ORDER BY p.nombre_proveedor;

CREATE OR REPLACE VIEW menu AS
SELECT *
FROM productos
WHERE id_producto IN (
    WITH cte1 AS (
        SELECT i.id_producto, COUNT(*) AS en_stock
        FROM ingredientes i
        JOIN stock s ON i.id_ingrediente = s.id_stock
        WHERE i.cantidad < s.cantidad_producto
        GROUP BY id_producto
    ),
    cte2 AS (
        SELECT id_producto, COUNT(*) AS necesarios
        FROM ingredientes
        GROUP BY id_producto
    )
    SELECT t1.id_producto
    FROM cte1 t1
    JOIN cte2 t2 ON t1.id_producto = t2.id_producto
    WHERE (t2.necesarios - t1.en_stock) = 0
);

CREATE OR REPLACE VIEW facturacion_mensual
AS
SELECT SUM(total_factura)
FROM facturas
WHERE fecha_factura BETWEEN (NOW() - INTERVAL 30 DAY) AND NOW();

CREATE OR REPLACE VIEW facturacion_trimestral
AS
WITH cte1 AS (
	SELECT SUM(total_factura) AS 'Mes 1'
	FROM facturas
	WHERE MONTH(fecha_factura) = MONTH(CURDATE() - INTERVAL 2 MONTH)
), cte2 AS (
	SELECT SUM(total_factura) AS 'Mes 2'
	FROM facturas
	WHERE MONTH(fecha_factura) = MONTH(CURDATE() - INTERVAL 1 MONTH)
), cte3 AS (
	SELECT SUM(total_factura) AS 'Mes 3'
	FROM facturas
	WHERE fecha_factura BETWEEN (NOW() - INTERVAL 30 DAY) AND NOW()
)
SELECT t1.*, t2.*, t3.*
FROM cte1 AS t1
JOIN cte2 AS t2
JOIN cte3 AS t3;

CREATE OR REPLACE VIEW `productos_mas_vendidos`
AS
SELECT p.nombre_producto, COUNT(*) AS cantidad
FROM ventas AS v
JOIN productos p ON p.id_producto = v.id_producto
GROUP BY p.nombre_producto
ORDER BY COUNT(*) DESC;