USE pizzeria;

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

DELIMITER ;