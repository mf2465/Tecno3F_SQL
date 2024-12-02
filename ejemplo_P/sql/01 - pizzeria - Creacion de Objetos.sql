CREATE DATABASE IF NOT EXISTS pizzeria;

USE pizzeria;

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre_cliente VARCHAR(30) NOT NULL,
    telefono_cliente VARCHAR(20),
    direccion_cliente VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS productos (
    id_producto INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(30) NOT NULL,
    precio_producto DECIMAL(9,2) NOT NULL,
    descripcion_producto VARCHAR(250),
    foto_producto VARCHAR(80) DEFAULT 'imagen-generica.jpg'
);

CREATE TABLE IF NOT EXISTS choferes (
    id_chofer INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre_chofer VARCHAR(30),
    telefono_chofer VARCHAR(20),
    activo TINYINT
);

CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre_proveedor VARCHAR(30) NOT NULL,
    telefono_proveedor VARCHAR(20),
    direccion_proveedor VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS facturas (
    id_factura INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_chofer INT,
    total_factura DECIMAL(9,2) NOT NULL,
    tipo_entrega TINYINT NOT NULL DEFAULT 0,
    fecha_factura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_chofer)
        REFERENCES choferes(id_chofer)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_factura INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT,
    sub_total DECIMAL(9,2),
    FOREIGN KEY (id_factura)
        REFERENCES facturas(id_factura)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS stock (
    id_stock INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    nombre_producto VARCHAR(30),
    cantidad_producto DECIMAL(5,2),
    medida_producto VARCHAR(10),
    stock_minimo INT NOT NULL,
    cantidad_ideal INT NOT NULL,
    FOREIGN KEY (id_proveedor)
        REFERENCES proveedores(id_proveedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ingredientes (
    id_interno_ingrediente INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_ingrediente INT NOT NULL,
    cantidad DECIMAL(9,2) NOT NULL,
    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_ingrediente)
        REFERENCES stock(id_stock)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS pedidos_proveedores (
    id_interno_pedido INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_proveedor)
        REFERENCES proveedores(id_proveedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cte_temp (
    id int NOT NULL AUTO_INCREMENT,
    venta_numero int DEFAULT NULL,
    res_temp_stock int DEFAULT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS fact_temp (
    id_factura int NOT NULL AUTO_INCREMENT,
    num_fact_temp int NOT NULL,
    id_prod int NOT NULL,
    cant int DEFAULT '0',
    total_factura decimal(9,2) NOT NULL,
    PRIMARY KEY (id_factura),
    UNIQUE KEY id_factura (id_factura),
    KEY facturas_ibfk_1 (num_fact_temp)
);

CREATE TABLE IF NOT EXISTS rdm_nombre (
    id int NOT NULL AUTO_INCREMENT,
    nombre varchar(60) DEFAULT NULL,
    apellido varchar(60) DEFAULT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE ventas_temp (
    id int NOT NULL AUTO_INCREMENT,
    venta_numero int NOT NULL,
    prod_id int NOT NULL,
    cant int NOT NULL DEFAULT '1',
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS logs (
    log_id int NOT NULL AUTO_INCREMENT,
    event_name varchar(60) NOT NULL,
    event_user varchar(100) NOT NULL,
    event_datetime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

CREATE TABLE IF NOT EXISTS log_clientes (
    log_id int NOT NULL AUTO_INCREMENT,
    event_name varchar(60) NOT NULL,
    client_name varchar(100) NOT NULL,
    session_username varchar(100) NOT NULL,
    event_datetime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

CREATE TABLE IF NOT EXISTS log_ventas (
    log_id int NOT NULL AUTO_INCREMENT,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    sub_total DECIMAL(11,2),
    session_username varchar(100) NOT NULL,
    event_datetime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

CREATE TABLE IF NOT EXISTS log_productos (
	log_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(40) NOT NULL,
    id_producto INT NOT NULL,
    nombre_anterior VARCHAR(100),
    nombre_nuevo VARCHAR(100),
    precio_anterior DECIMAL(11,2),
    precio_nuevo DECIMAL(11,2),
    descripcion_anterior VARCHAR(200),
    descripcion_nueva VARCHAR(200),
    foto_anterior VARCHAR(100),
    foto_nueva VARCHAR(100),
    session_username varchar(100) NOT NULL,
    event_datetime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

DELIMITER $$

CREATE PROCEDURE `sp_generar_venta`()
BEGIN
    DECLARE int_num_venta_random, int_id_cliente, int_tipo_entrega, int_cant_productos, int_unidades_por_producto, int_contador, int_random_prod INT;
    DECLARE int_nombre_cliente TEXT;
    
    SET int_num_venta_random = f_random(); -- Numero aleatorio para este pedido
    SET int_nombre_cliente = f_generar_cliente(); -- Nombre y Apellido aleatorios sacados de la DB para formar el nombre de cliente
    SET int_tipo_entrega = f_rand_entrega(); -- Tipo de entrega aleatoria
    SET int_contador = 1; -- Inicializamos el contador de articulos
    
    /* SECCION PARA CREAR O SELECCIONAR UN CLIENTE */
    
    SET int_id_cliente = 0;
    
    SET int_id_cliente = (SELECT EXISTS(SELECT 1 FROM clientes WHERE nombre_cliente LIKE CONCAT('%', int_nombre_cliente, '%')));
    
    IF int_id_cliente = 0 THEN
        INSERT INTO clientes (nombre_cliente) VALUES (int_nombre_cliente);
        SET int_id_cliente = LAST_INSERT_ID();
    ELSE
        SET int_id_cliente = (SELECT id_cliente FROM clientes WHERE nombre_cliente LIKE CONCAT('%', int_nombre_cliente, '%'));
    END IF;
    
    /* SECCION PARA CREAR LA LISTA DE ARTICULOS EN LA TABLA TEMPORAL CORRESPONDIENTE */
    
    SET int_cant_productos = FLOOR(RAND()*(5-1+1))+1;
    
    WHILE int_contador <= int_cant_productos DO -- Loop que se ejecutara tantas veces como articulos vendidos
        
        SET int_unidades_por_producto = FLOOR(RAND()*(2-1+1))+1;
        SET int_random_prod = (SELECT FLOOR(RAND()*((SELECT COUNT(*) FROM menu) - 1 + 1)) + 1);
        
        INSERT INTO ventas_temp (venta_numero, prod_id, cant)
        SELECT int_num_venta_random, id_producto, int_unidades_por_producto
        FROM menu
        WHERE id_producto = int_random_prod;
        
        SET int_contador = int_contador + 1;
        
    END WHILE;
    
    /* AHORA SIMPLEMENTE LLAMAMOS EL STORED PROCEDURE PARA PROCESAR LA VENTA */
    
    call sp_venta_completo(int_num_venta_random, int_id_cliente, int_tipo_entrega);
    
END $$

CREATE PROCEDURE `sp_venta_completo`(IN num_venta INT, IN id_cliente INT, IN in_tipo_entrega INT)
BEGIN
    DECLARE int_prod_id, int_cant_vendida, int_id_ingred, int_chofer_id INT;
    DECLARE int_cant_neces, int_cant_stock, int_total, int_nueva_cant_stock, int_total_temp DECIMAL(9,2);
    DECLARE err_msg TEXT DEFAULT 'Error desconocido';
    DECLARE int_fact_num INT;
    DECLARE int_prod_suficientes BOOL DEFAULT TRUE;
    DECLARE rollback_call BOOL DEFAULT FALSE;
    DECLARE exit_loop BOOLEAN DEFAULT FALSE;
    
    DECLARE venta_cursor CURSOR FOR SELECT prod_id, cant FROM ventas_temp WHERE venta_numero = num_venta;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop := TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET rollback_call := TRUE;
    
    START TRANSACTION;
    
    /* SECCION PARA REVISAR EL STOCK DE CADA INGREDIENTE Y ACTUALIZARLOS SEGUN EL PEDIDO. */
    /* SE HACE EN FORMA DE LOOP PRODUCTO POR PRODUCTO. */
    OPEN venta_cursor;
    venta_loop: LOOP
        FETCH FROM venta_cursor INTO int_prod_id, int_cant_vendida;
        IF exit_loop THEN
            CLOSE venta_cursor;
            LEAVE venta_loop;
        END IF;
        
        INSERT INTO cte_temp (venta_numero, res_temp_stock)
            WITH cte1 AS (
                SELECT i.id_ingrediente, s.id_stock, COUNT(*) as cuenta, SUM(CASE WHEN (s.cantidad_producto - (i.cantidad * int_cant_vendida)) > 0 THEN 1 ELSE 0 END) as suma
                FROM ingredientes i
                JOIN stock s ON i.id_ingrediente = s.id_stock
                WHERE i.id_producto = int_prod_id
                GROUP BY id_ingrediente, id_stock
            ) SELECT num_venta, IF (cuenta <> suma, 0, 1) as suma FROM cte1;
            
        UPDATE stock JOIN ingredientes ON stock.id_stock = ingredientes.id_ingrediente
        SET stock.cantidad_producto = stock.cantidad_producto - (ingredientes.cantidad * int_cant_vendida)
        WHERE ingredientes.id_producto = int_prod_id;
        
        SET int_total_temp = (SELECT precio_producto * int_cant_vendida FROM productos WHERE id_producto = int_prod_id);
        
        /* TAMBIEN SE INSERTA CADA PRODUCTO EN UNA TABLA DE FACTURACION TEMPORAL */
        INSERT INTO fact_temp (num_fact_temp, id_prod, cant, total_factura)
        VALUES (num_venta, int_prod_id, int_cant_vendida, int_total_temp);
        
    END LOOP venta_loop;
    
    /* DE LA TABLA DE FACTURACION TEMPORAL, SE OBTIENE EL TOTAL DE LA FACTURA FINAL */
    SET int_total_temp = (SELECT SUM(total_factura) FROM fact_temp WHERE num_fact_temp = num_venta);

    IF int_prod_suficientes = FALSE THEN
        SET rollback_call = TRUE;
        SET err_msg := 'No hay suficiente stock de algun producto';
    END IF;
    
    /* SI HASTA AHORA NO HAY ERRORES, SE PROCEDE CON LO SIGUIENTE */
    IF rollback_call = FALSE THEN
        /* SE GENERA LA FACTURA FINAL */
        INSERT INTO facturas (id_cliente, id_chofer, total_factura, tipo_entrega)
        VALUES (id_cliente, int_chofer_id, int_total_temp, in_tipo_entrega);
        
        SET int_fact_num = (SELECT LAST_INSERT_ID()); -- SE OBTIENE EL NUMERO DE FACTURA
        
        /* SE SELECCIONA EL CHOFER DENTRO DE LOS DISPONIBLES */
        IF in_tipo_entrega = 2 THEN
            SET int_chofer_id = (SELECT id_chofer FROM choferes WHERE activo = 1 ORDER BY RAND() LIMIT 1);
            IF int_chofer_id IS NULL THEN
                SET rollback_call = TRUE;
                SET err_msg := 'No hay ningun chofer disponible';
            END IF;
        END IF;
        
        /* SE MARCA COMO "OCUPADO" AL CHOFER SELECCIONADO */
        IF in_tipo_entrega = 2 THEN
            UPDATE choferes SET activo = 0 WHERE id_chofer = int_chofer_id;
        END IF;
        
        /* SE GENERA UN ERROR SI NO HAY STOCK SUFICIENTE DE ALGUN INGREDIENTE */
        IF ((SELECT COUNT(*) - SUM(res_temp_stock) FROM cte_temp WHERE venta_numero = num_venta) <> 0) THEN
            SET int_prod_suficientes = FALSE;
        ELSE
            SET int_prod_suficientes = TRUE;
        END IF;
        
    END IF;
        
    /* SI HAY ERRORES, SE VUELVE TODO PARA ATRAS. SI NO, SE PROCEDE A RELACIONAR LOS PRODUCTOS VENDIDOS CON SU FACTURA */
    IF rollback_call THEN
        ROLLBACK;
        SELECT CONCAT('Error: ', err_msg) AS 'Error';
    ELSE
        call sp_venta_extra(num_venta, int_fact_num);
        COMMIT;
        SELECT CONCAT('Venta generada con exito bajo el numero de factura: ', int_fact_num) AS 'Operacion completada';
    END IF;
END $$

CREATE PROCEDURE `sp_venta_extra`(IN num_venta INT, IN num_factura INT)
BEGIN
    DECLARE int_id_prod, int_cant INT;
    DECLARE int_total_factura DECIMAL(9,2);
    DECLARE rollback_call BOOL DEFAULT FALSE;
    DECLARE exit_loop BOOLEAN DEFAULT FALSE;
    
    DECLARE factura_cursor CURSOR FOR SELECT id_prod, cant, total_factura FROM fact_temp WHERE num_fact_temp = num_venta;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop := TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET rollback_call := TRUE;
    
    START TRANSACTION;
    
    /* LOOP PARA AGREGAR CADA PRODUCTO VENDIDO A LA TABLA VENTAS PARA TENER LA RELACION MUCHOS-MUCHOS */
    OPEN factura_cursor;
    factura_loop: LOOP
    
        FETCH FROM factura_cursor INTO int_id_prod, int_cant, int_total_factura;
        IF exit_loop THEN
            CLOSE factura_cursor;
            LEAVE factura_loop;
        END IF;
        
        INSERT INTO ventas (id_factura, id_producto, cantidad, sub_total)
        VALUES (num_factura, int_id_prod, int_cant, int_total_factura);
    
    END LOOP factura_loop;
    
    IF rollback_call THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END $$

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

CREATE TRIGGER clientes_AFTER_INSERT
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO logs (event_name, event_user)
    VALUES ('Nuevo cliente generado', SESSION_USER());
END $$

CREATE TRIGGER tr_logs
AFTER INSERT ON facturas
FOR EACH ROW
BEGIN
    INSERT INTO logs (event_name, event_user)
    VALUES ('Nueva Factura', SESSION_USER());
END $$

CREATE TRIGGER tr_clientes_alta
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
	INSERT INTO log_clientes (event_name, client_name, session_username)
    VALUES ('Alta de cliente', NEW.nombre_cliente, SESSION_USER());
END $$

CREATE TRIGGER tr_clientes_eliminacion
AFTER DELETE ON clientes
FOR EACH ROW
BEGIN
	INSERT INTO log_clientes (event_name, client_name, session_username)
    VALUES ('Eliminacion de cliente', OLD.nombre_cliente, SESSION_USER());
END $$

CREATE TRIGGER tr_nueva_venta
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
	INSERT INTO log_ventas (id_venta, id_producto, sub_total, session_username)
    VALUES (NEW.id_venta, NEW.id_producto, NEW.sub_total, SESSION_USER());
END $$

CREATE TRIGGER tr_agregar_producto
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
	INSERT INTO log_productos (event_name, id_producto, session_username)
    VALUES ('Nuevo producto', NEW.id_producto, SESSION_USER());
END $$

CREATE TRIGGER tr_modificar_producto
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
	INSERT INTO log_productos (event_name, id_producto, nombre_anterior, nombre_nuevo, precio_anterior, precio_nuevo, descripcion_anterior, descripcion_nueva, foto_anterior, foto_nueva, session_username)
    VALUES ('Edicion de producto', NEW.id_producto, OLD.nombre_producto, NEW.nombre_producto, OLD.precio_producto, NEW.precio_producto, OLD.descripcion_producto, NEW.descripcion_producto, OLD.foto_producto, NEW.foto_producto, SESSION_USER());
END $$

CREATE TRIGGER tr_eliminar_producto
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
	INSERT INTO log_productos (event_name, id_producto, session_username)
    VALUES ('Eliminacion de producto', OLD.id_producto, SESSION_USER());
END $$

DELIMITER ;

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