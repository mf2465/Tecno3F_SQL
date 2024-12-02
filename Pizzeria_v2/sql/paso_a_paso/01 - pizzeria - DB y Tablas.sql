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