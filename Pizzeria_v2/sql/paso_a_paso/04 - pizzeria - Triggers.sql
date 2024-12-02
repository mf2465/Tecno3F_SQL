USE pizzeria;

DELIMITER $$

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