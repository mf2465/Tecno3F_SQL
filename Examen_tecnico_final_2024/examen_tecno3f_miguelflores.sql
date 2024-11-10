-- EXAMEN TECNICO FINAL 
-- SQL 2024 # Tecno3F # prof.: Diego Giménez + Gabriel Sebastián Román
-- Miguel Flores | DNI 24508119 | miguelflores.devops@gmail.com 

-- Borrar en caso de que exista la base
DROP DATABASE IF EXISTS examen_tecno3f_miguelflores;

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE examen_tecno3f_miguelflores;

-- uso este comando para efectivizar y genere sin problemas el Diagrama de Entidad Relación
USE examen_tecno3f_miguelflores;

-- CREACION DE TABLAS según Diagrama Entidad Relación dado

CREATE TABLE IF NOT EXISTS proveedores (
	idProveedor INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(50),
	direccion VARCHAR(50),
	ciudad VARCHAR(50),
	telefono VARCHAR(15)
	);

CREATE TABLE IF NOT EXISTS orden_de_compra (
	idOrdenCompra INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	fecha_emision DATETIME,
	fecha_entrega DATETIME,
	idProveedor INTEGER,
	FOREIGN KEY (idProveedor) REFERENCES proveedores(idProveedor)
);

CREATE TABLE IF NOT EXISTS producto (
	idProducto INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	descripcion VARCHAR(255),
	precio_costo FLOAT,
	precio_venta FLOAT,
	precio_mercado FLOAT	
);

CREATE TABLE IF NOT EXISTS detalle_orden (
	idDetalleOrden INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
	idOrdenCompra INTEGER,
	idProducto INTEGER,
	cantidad INTEGER,
	precio_venta FLOAT,
	FOREIGN KEY (idOrdenCompra) REFERENCES orden_de_compra(idOrdenCompra),
    FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
);

-- Ingreso de datos a las diferentes tablas paraunmodelo de negocio FERRETERIA

insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Juan Pablo Díaz', 'Av. Santa Fe 110', 'San Pedro', '03512345678');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Agustina Fernández', 'Av. Juan B. Justo 643', 'Paraná', '01145678901');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Camila Díaz', 'Calle San Martín 377', 'Luján', '03523487654');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Paula Fernández', 'San Juan 451', 'San Carlos de Bariloche', '01190876543');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Carolina Torres', 'Av. de Mayo 273', 'San Miguel de Tucumán', '01132104567');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Ricardo García', 'Belgrano 765', 'Quilmes', '02614235678');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Paula Fernández', 'Av. Urquiza 276', 'San Pedro', '035846781234');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Sofía González', 'Figueroa Alcorta 890', 'Formosa', '02278765432');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Emma Fernández', 'Av. Cabildo 305', 'Santa Fe', '03581234567');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Valentina López', 'Av. Juan B. Justo 470', 'Rosario', '023934567890');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Andrés Pérez', 'Belgrano 765', 'San Miguel de Tucumán', '03523487654');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Mariana Romero', 'Calle San Vicente 340', 'Santiago del Estero', '03413456789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Ana Pérez', 'Av. Rivadavia 204', 'Mercedes', '01143216789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Laura González', 'Av. Santa Fe 189', 'Neuquén', '03514235678');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Alejandro Martínez', 'San Martín 210', 'Posadas', '01123456789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Elena Romero', 'Av. Santa Fe 110', 'San Pedro', '01176894321');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Gabriel García', 'San Juan 451', 'Río Cuarto', '023187654321');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Diego González', 'Av. de Mayo 273', 'San Pedro', '01132104567');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Victoria Fernández', 'Av. Belgrano 764', 'Bahía Blanca', '02394325789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Patricia Sánchez', 'Santa Fe 340', 'Buenos Aires', '03514235678');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Raúl Pérez', 'Libertador 129', 'Posadas', '02245678902');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Leonardo García', 'Calle Rodríguez Peña 489', 'San Rafael', '01187654322');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Elena Romero', 'Av. Dorrego 643', 'Posadas', '01190876543');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Samuel Rodríguez', 'Libertador 129', 'El Palomar', '02234567891');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Emilia García', 'Av. Pueyrredón 493', 'Concordia', '03415555112');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Carlos Díaz', 'Av. San Martín 659', 'San Fernando', '02215478123');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Lucía López', 'Av. Brasil 423', 'San Martín', '01145612345');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Joaquín López', 'Calle San Martín 377', 'Mar del Plata', '034155551122');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Pablo Sánchez', 'Independencia 876', 'Mar del Plata', '01123456789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Victoria Fernández', 'San Juan 451', 'San Pedro', '02614235678');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Esteban Pérez', 'San Juan 451', 'Bahía Blanca', '01128374652');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Iván Romero', 'Calle Monroe 120', 'San Fernando', '02314567890');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'José Rodríguez', 'Av. San Martín 659', 'San Miguel de Tucumán', '03512387654');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Julieta Herrera', 'San Martín 210', 'Río Gallegos', '03523487654');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Juan Pérez', 'Figueroa Alcorta 890', 'Avellaneda', '02397236458');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Ramiro Sánchez', 'Av. Del Libertador 312', 'La Rioja', '03415555112');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Maximiliano Romero', 'Av. Rivadavia 204', 'Río Grande', '02315678901');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Patricia Sánchez', 'Río de Janeiro 512', 'Posadas', '01123456789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Andrés Pérez', 'Av. Cabildo 305', 'Río Gallegos', '01198765432');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Martín Martínez', 'Belgrano 765', 'Mercedes', '022356789876');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Emma Fernández', 'San Juan 451', 'Bahía Blanca', '02397236458');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Sofía González', 'Av. Cabildo 305', 'Trelew', '01156348765');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Gabriel García', 'Santa Fe 340', 'Río Grande', '01198765432');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Ricardo García', 'Calle Perú 231', 'Concordia', '034155551122');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Rodrigo Fernández', 'Calle Rodríguez Peña 489', 'Río Cuarto', '035123456789');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Pablo Sánchez', 'Pellegrini 357', 'Mendoza', '034155551122');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Valentina López', 'Av. Rivadavia 204', 'Río Cuarto', '01134567890');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Silvia García', 'Av. Santa Fe 110', 'Tucumán', '01187654322');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Camila Díaz', 'Av. Belgrano 764', 'Posadas', '01128374652');
insert into proveedores (idProveedor, nombre, direccion, ciudad, telefono) values (null, 'Lourdes García', 'Av. Entre Ríos 624', 'San Pedro', '01176894321');


-- select * from proveedores;  -- para verificar carga correcta

INSERT INTO producto (idProducto, descripcion, precio_costo, precio_venta, precio_mercado)
VALUES
    (NULL, 'Pala', 38280, 52104, 56272),
    (NULL, 'Llave francesa', 9439, 12847, 13875),
    (NULL, 'Alicate', 6104, 8308, 8973),
    (NULL, 'Destornillador Eléctrico', 126229, 171811, 185556),
    (NULL, 'Bomba riego 0.6 HP', 99090, 134872, 145662),
    (NULL, 'Lijadora Orbital', 46376, 63122, 68172),
    (NULL, 'Pinza universal', 4082, 5556, 6001),
    (NULL, 'Sierra circular mano', 82350, 112088, 121055),
    (NULL, 'Sierra caladora', 55626, 75713, 81770),
    (NULL, 'Cinta métrica', 13428, 18277, 19739),
    (NULL, 'Rodillo microfibra', 3333, 4537, 4900),
    (NULL, 'Pintura látex interior 20L', 48571, 66111, 71400),
    (NULL, 'Martillo', 5191, 7066, 7631),
    (NULL, 'Pincel Nro 20', 2187, 2977, 3215),
    (NULL, 'Taladro 10 mm', 57018, 77607, 83816),
    (NULL, 'Tornillo tirafondo 8 mm x 10', 849, 1156, 1248),
    (NULL, 'Fertilizante 1Kg', 3823, 5204, 5620),
    (NULL, 'Tuercas x 100', 2619, 3565, 3850),
    (NULL, 'Pastillas Antihumedad', 6905, 9398, 10150),
    (NULL, 'Taladro de banco', 103739, 141201, 152497),
    (NULL, 'Prensa de banco', 121806, 165792, 179055),
    (NULL, 'Caja de herramientas chica', 4767, 6488, 7007),
    (NULL, 'Tornillo 6 mm x 10', 1224, 1666, 1799),
    (NULL, 'Antiparra de seguridad', 1972, 2684, 2899),
    (NULL, 'Pistola de pintura', 27754, 37777, 40799),
    (NULL, 'Cutter grande', 2156, 2935, 3170),
    (NULL, 'Bandejas de pintor', 1510, 2056, 2220),
    (NULL, 'Tuerca 12 mm x 10', 331, 451, 487),
    (NULL, 'Balde 20 lts', 4694, 6389, 6900),
    (NULL, 'Cinta de enmascarar', 1700, 2314, 2499),
    (NULL, 'Mangueras de jardín 15 mts', 16957, 23081, 24927),
    (NULL, 'Cepillo de alambre', 1863, 2535, 2738),
    (NULL, 'Sustrato para jardinería', 8503, 11574, 12500),
    (NULL, 'Soportes para estantería x 2', 3190, 4342, 4690),
    (NULL, 'Pincel Nro 40', 4530, 6166, 6660),
    (NULL, 'Arandela 18 mm x 10', 395, 538, 581),
    (NULL, 'Cortapluma multiuso', 4628, 6299, 6803),
    (NULL, 'Pinza pico de loro', 15203, 20694, 22349),
    (NULL, 'Cinta embalaje', 4548, 6190, 6685),
    (NULL, 'Tornillo para drywall x 100', 1224, 1666, 1799),
    (NULL, 'Trapo de microfibra auto', 1854, 2523, 2725),
    (NULL, 'Guantes de trabajo', 537, 731, 790),
    (NULL, 'Tapón termo cebador', 2507, 3412, 3685),
    (NULL, 'Lima cuadrada', 4868, 6626, 7156),
    (NULL, 'Canilla esférica patio 3/4', 4765, 6486, 7005),
    (NULL, 'Nivel de burbuja 70 cms', 9869, 13432, 14507),
    (NULL, 'Cinta bifaz', 3229, 4395, 4747),
    (NULL, 'Interruptor velador', 610, 830, 896),
    (NULL, 'Portalámpara', 431, 587, 634),
    (NULL, 'Enrollador persiana', 6190, 8426, 9100),
    (NULL, 'Cerradura puerta', 22042, 30002, 32402),
    (NULL, 'Carretilla', 45958, 62554, 67558),
    (NULL, 'Pegamento de contacto 23 grs', 1837, 2500, 2700);

-- select * from producto; --   para verificar carga correcta



insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-12-07 01:23:28', '2022-12-19 01:23:00', 19);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-26 16:21:08', '2022-12-08 16:21:00', 5);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-10-22 22:02:15', '2024-11-07 22:02:00', 27);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-10-09 07:32:16', '2023-10-12 07:32:00', 25);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-02-08 03:10:03', '2023-02-20 03:10:00', 2);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-15 12:56:37', '2022-11-27 12:56:00', 28);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-10-25 22:46:37', '2024-11-06 22:46:00', 25);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-10-09 01:34:22', '2023-10-21 01:34:00', 19);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-09-26 16:38:24', '2022-10-08 16:38:00', 30);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-06-25 16:33:46', '2024-07-07 16:33:00', 30);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-03-29 10:56:11', '2024-04-10 10:56:00', 8);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-08-19 15:03:23', '2022-08-31 15:03:00', 20);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-26 18:53:01', '2022-12-08 18:53:00', 44);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-03-06 17:47:50', '2024-03-18 17:47:00', 46);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-02-01 23:00:20', '2023-02-13 23:00:00', 8);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-02-18 00:28:24', '2024-03-05 00:28:00', 3);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-06-30 23:05:36', '2024-07-12 23:05:00', 20);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-08-29 09:10:04', '2022-09-10 09:10:00', 1);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-05-31 09:27:36', '2024-06-12 09:27:00', 9);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-09-24 23:20:41', '2022-10-06 23:20:00', 39);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-03-01 11:07:46', '2023-03-13 11:07:00', 11);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-04-01 19:31:54', '2024-04-13 19:31:00', 42);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-03-13 22:43:42', '2024-03-25 22:43:00', 40);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-08-09 07:26:38', '2023-08-21 07:26:00', 39);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-08-12 05:10:53', '2024-08-14 05:10:00', 14);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-20 19:32:48', '2024-01-01 19:32:00', 35);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-06-03 04:57:23', '2022-06-15 04:57:00', 11);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-09-18 08:17:53', '2024-09-30 08:17:00', 18);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-08-31 13:49:56', '2024-09-12 13:49:00', 13);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-11-08 01:59:12', '2023-11-20 01:59:00', 39);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-10-04 02:06:41', '2022-10-16 02:06:00', 39);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-19 15:55:20', '2023-12-31 15:55:00', 20);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-02-06 03:29:41', '2024-02-18 03:29:00', 27);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-07-21 08:38:40', '2024-08-02 08:38:00', 7);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-07 07:30:24', '2023-12-19 07:30:00', 17);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-07-30 09:37:18', '2023-08-11 09:37:00', 17);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-10-15 13:10:33', '2022-10-27 13:10:00', 35);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-13 00:31:00', '2023-12-15 00:31:00', 1);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-09-08 15:02:25', '2022-09-20 15:02:00', 13);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-07-24 00:05:08', '2024-07-25 00:05:00', 47);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-10-28 14:07:14', '2023-11-09 14:07:00', 37);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-11-14 11:32:30', '2023-11-26 11:32:00', 3);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-06-06 01:59:07', '2022-06-18 01:59:00', 18);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-05-04 17:45:32', '2024-05-16 17:45:00', 18);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-10-22 07:02:33', '2023-11-03 07:02:00', 12);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-06-25 05:25:00', '2023-07-07 05:25:00', 46);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-11-30 06:38:56', '2023-12-12 06:38:00', 24);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-03-12 18:58:45', '2023-03-24 18:58:00', 48);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-08-24 13:26:40', '2022-09-05 13:26:00', 18);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-12 01:19:45', '2022-11-24 01:19:00', 12);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-01-15 21:09:03', '2023-01-27 21:09:00', 40);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-06-24 09:17:57', '2023-07-06 09:17:00', 12);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-12-01 07:08:54', '2022-12-13 07:08:00', 26);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-05-28 11:48:19', '2022-06-09 11:48:00', 5);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-05-15 09:01:18', '2023-05-27 09:01:00', 33);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-06-19 12:55:48', '2024-07-01 12:55:00', 8);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-10-19 14:51:05', '2024-10-31 14:51:00', 16);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-10 16:54:33', '2022-11-22 16:54:00', 20);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-02-24 17:26:37', '2023-03-08 17:26:00', 30);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-03-04 20:30:34', '2023-03-16 20:30:00', 10);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-11-04 12:27:18', '2023-11-16 12:27:00', 15);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-06 03:00:37', '2023-12-18 03:00:00', 1);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-07-23 10:01:39', '2024-08-04 10:01:00', 2);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-07-16 23:20:29', '2024-07-28 23:20:00', 25);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-09-25 06:52:53', '2024-10-07 06:52:00', 21);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-02-14 05:13:51', '2024-02-16 05:13:00', 41);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-29 10:00:37', '2022-12-11 10:00:00', 20);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-05-29 08:43:33', '2024-06-10 08:43:00', 1);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-06-22 04:20:29', '2024-07-04 04:20:00', 40);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-08-06 15:57:31', '2023-08-18 15:57:00', 48);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-01-19 01:32:26', '2023-01-31 01:32:00', 1);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-12-29 14:41:11', '2023-01-10 14:41:00', 28);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-07-31 05:21:27', '2024-08-12 05:21:00', 26);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-10-11 02:11:23', '2024-10-23 02:11:00', 23);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-10-05 23:26:28', '2024-10-17 23:26:00', 21);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-07-03 07:41:23', '2024-07-15 07:41:00', 35);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-02-15 13:11:08', '2023-02-27 13:11:00', 19);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-08-27 03:39:42', '2022-09-08 03:39:00', 17);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-05-30 02:34:50', '2024-06-11 02:34:00', 15);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-03-11 13:04:53', '2023-03-23 13:04:00', 48);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-08-11 13:46:49', '2024-08-23 13:46:00', 16);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-02-02 21:09:53', '2024-02-03 21:09:00', 14);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-11-23 16:43:42', '2022-12-05 16:43:00', 11);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-09-22 21:08:51', '2023-10-04 21:08:00', 40);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-10-25 06:12:50', '2023-11-06 06:12:00', 36);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-17 08:24:27', '2023-12-29 08:24:00', 37);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-12-19 17:51:44', '2022-12-31 17:51:00', 39);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-02-25 08:30:07', '2024-03-08 08:30:00', 9);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-07-22 00:06:46', '2022-08-03 00:06:00', 34);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-02-27 11:54:39', '2024-03-10 11:54:00', 16);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-03-03 17:16:59', '2023-03-15 17:16:00', 18);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-06-05 00:02:10', '2024-06-17 00:02:00', 2);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-10-05 07:14:18', '2022-10-17 07:14:00', 44);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-06-23 03:07:42', '2023-07-05 03:07:00', 40);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-05-19 13:06:43', '2024-05-31 13:06:00', 29);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-12-03 13:31:06', '2022-12-06 13:31:00', 47);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-12-18 18:03:30', '2023-12-30 18:03:00', 33);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2023-03-24 09:22:25', '2023-04-05 09:22:00', 2);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2022-07-01 09:30:31', '2022-07-13 09:30:00', 26);
insert into orden_de_compra (idOrdenCompra, fecha_emision, fecha_entrega, idProveedor) values (null, '2024-06-21 03:01:37', '2024-07-03 03:01:00', 29);

-- SELECT * FROM orden_de_compra;

SET FOREIGN_KEY_CHECKS = 0;

insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 65, 27, 5, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 64, 49, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 79, 13, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 12, 20, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 4, 31, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 92, 28, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 73, 16, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 11, 26, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 94, 27, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 31, 2, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 11, 7, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 18, 24, 5, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 75, 35, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 71, 41, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 64, 11, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 91, 38, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 81, 10, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 89, 46, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 74, 4, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 10, 37, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 31, 33, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 36, 42, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 50, 39, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 13, 21, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 76, 44, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 74, 30, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 42, 19, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 55, 13, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 10, 8, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 16, 11, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 44, 21, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 89, 15, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 89, 6, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 63, 4, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 97, 8, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 60, 9, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 72, 33, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 59, 43, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 34, 49, 5, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 37, 3, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 19, 1, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 90, 24, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 96, 41, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 37, 42, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 30, 40, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 12, 39, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 65, 7, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 17, 22, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 74, 44, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 30, 36, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 32, 43, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 37, 18, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 34, 11, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 4, 40, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 17, 10, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 97, 24, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 30, 12, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 73, 37, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 57, 21, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 85, 4, 9, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 69, 5, 5, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 12, 45, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 60, 12, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 86, 15, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 68, 37, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 50, 44, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 36, 34, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 77, 39, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 49, 42, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 70, 50, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 84, 29, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 32, 9, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 100, 4873, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 30, 6, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 59, 42, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 59, 16, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 86, 32, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 53, 37, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 34, 30, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 100, 15, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 45, 27, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 3, 5, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 6, 8, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 20, 28, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 42, 23, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 6, 2, 1, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 99, 34, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 12, 17, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 55, 11, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 62, 25, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 84, 9, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 9, 12, 2, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 69, 35, 6, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 93, 25, 10, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 99, 27, 3, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 44, 15, 5, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 39, 18, 4, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 2, 10, 8, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 40, 40, 7, 1);
insert into detalle_orden (idDetalleOrden, idOrdenCompra, idProducto, cantidad, precio_venta) values (null, 10, 17, 6, 1);

SET FOREIGN_KEY_CHECKS = 1;

 -- Actualizamos el precio_venta de detalle_orden usando el precio_venta de producto
 -- para que el ejemplo de base de datos quede consistente en los análisis de consultas
 
DELIMITER $$

CREATE PROCEDURE actualizar_precio_venta_detalle_orden()
BEGIN
    UPDATE detalle_orden AS deo
    INNER JOIN producto AS p ON deo.idProducto = p.idProducto
    SET deo.precio_venta = p.precio_venta;
END$$

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;

CALL actualizar_precio_venta_detalle_orden();

-- restauro las restricciones

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- select * from detalle_orden;

/* RESOLUCIONES DE CONSULTAS EXAMEN */

/*
1- Seleccionar los proveedores que ha emitido ordenes de compra que solo poseen un ítem del
producto galletita o bien que hayan emitido ordenes de compras en el año 2023 y 2024 inclusive.
No se admitirán ordenes de compras que no cumplan con la condición primera o que hayan
emitido ordenes solo en el 2023 o solo en el 2024.
idProveedor | nombre
*/

SELECT p.idProveedor, p.nombre 
FROM proveedores AS p
INNER JOIN orden_de_compra AS oc ON p.idProveedor = oc.idProveedor
INNER JOIN detalle_orden AS deo ON oc.idOrdenCompra = deo.idOrdenCompra
INNER JOIN producto AS po ON deo.idProducto = po.idProducto 
WHERE ( descripcion = 'galletita' and (SELECT COUNT(*) FROM detalle_orden WHERE idOrdenCompra = oc.idOrdenCompra) = 1) 
OR (YEAR(oc.fecha_emision) BETWEEN 2023 AND 2024)
GROUP BY p.idProveedor, p.nombre
HAVING COUNT(DISTINCT YEAR(oc.fecha_emision)) = 2
; 

 /*
 2- Eliminar los registros de los proveedores que hayan tenido menos de 3 ordenes de compras 
 en el año 2023
 */
 
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

-- cuento la cantidad de proovedores que cumplen con la condición antes de borrarlos
/*
SELECT COUNT(*)
FROM proveedores 
WHERE idProveedor IN (
    SELECT idProveedor
    FROM orden_de_compra
    WHERE YEAR(fecha_emision) = 2023
    GROUP BY idProveedor
    HAVING COUNT(idOrdenCompra) < 3
);
*/
 
DELETE
FROM proveedores 
WHERE idProveedor IN (
    SELECT idProveedor
    FROM orden_de_compra
    WHERE YEAR(fecha_emision) = 2023
    GROUP BY idProveedor
    HAVING COUNT(idOrdenCompra) < 3
);

-- verifico la diferencia por control interno de desarrollo
-- SELECT COUNT(*) FROM proveedores; 

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

/*
3- Modificar el precio de venta de los productos (solo en la tabla de DETALLE_ORDEN) a razón 
de 3 veces el precio de compra, solo para aquellos productos que estuvieron en alguna 
orden de compra cuya diferencia de días entre la "fecha entrega" y la "fecha de emisión" 
no supere los 3 días.
*/

-- Nota: Interpreto que el precio de compra se refiere a precio_costo de la tabla producto
-- También que precio_venta es igual a cantidad por precio de compra.

-- select * from orden_de_compra WHERE DATEDIFF(fecha_entrega, fecha_emision) <= 3;

DELIMITER $$

CREATE PROCEDURE actualizar_precio_venta_detalle_orden_x3_dif_3_dias()
BEGIN
    UPDATE detalle_orden AS deo
	INNER JOIN orden_de_compra AS oc ON deo.idOrdenCompra = oc.idOrdenCompra
	SET deo.precio_venta = deo.cantidad * (SELECT precio_costo FROM producto AS p WHERE p.idProducto = deo.idProducto) * 3
	WHERE DATEDIFF(oc.fecha_entrega, oc.fecha_emision) <= 3
    ;
END$$

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;

CALL actualizar_precio_venta_detalle_orden_x3_dif_3_dias();

SET SQL_SAFE_UPDATES = 1;

/*
4- Devolver los 10 productos más vendidos del mes de Noviembre del año 2023,2024.
TOTAL | idProducto | descripcion
*/

-- Interpreto que se refire a los meses Noviembre 2023 y Noviembre 2024
-- y más vendidos, a los que mayor cantidad de producto se entregaron

SELECT 
    SUM(deo.cantidad) AS TOTAL,
    deo.idProducto,
    p.descripcion
FROM detalle_orden AS deo
INNER JOIN orden_de_compra AS oc ON deo.idOrdenCompra = oc.idOrdenCompra
INNER JOIN producto AS p ON deo.idProducto = p.idProducto
WHERE (YEAR(oc.fecha_emision) = 2023 AND MONTH(oc.fecha_emision) = 11) 
   OR (YEAR(oc.fecha_emision) = 2024 AND MONTH(oc.fecha_emision) = 11)
GROUP BY deo.idProducto, p.descripcion
ORDER BY TOTAL DESC
LIMIT 10;

/*
5- Crear una vista en el cual muestre el total de cada orden de compra
idOrdenCompra | Total | nombreProveedor
*/

CREATE VIEW vista_total_orden_de_compra AS
SELECT 
    oc.idOrdenCompra,
    SUM(deo.cantidad * deo.precio_venta) AS TOTAL,
    p.nombre AS nombreProveedor
FROM orden_de_compra AS oc
INNER JOIN detalle_orden AS deo ON oc.idOrdenCompra = deo.idOrdenCompra
INNER JOIN proveedores AS p ON oc.idProveedor = p.idProveedor
GROUP BY oc.idOrdenCompra, p.nombre
;

SELECT * FROM vista_total_orden_de_compra;

/*
6- Eliminar las ordenes de compra entre los ids 10 y la 15, 
y además los detalles que tiene cada orden.
*/

DELETE FROM detalle_orden
WHERE idOrdenCompra BETWEEN 10 AND 15;

DELETE FROM orden_de_compra
WHERE idOrdenCompra BETWEEN 10 AND 15;

-- existe la posibilidad de eliminar en cascada
-- para ello hay que modificar la estructura de las tablas ( ON DELETE CASCADE )
-- y luego se eliminará el contenido asociado automáticamente en un solo paso.

/*
7- Crear un SP que reciba 2 parametros: idProducto y porcentaje. 
Este debe actualizar el porcentaje del producto que se le esta enviando
por parametro, ademas se debe dejar un registro del producto que se actualizo , 
el porcentaje y la fecha en una tabla de historial. 
Si el producto no existe, debe arrojar un error y no se deberá
realizar el registro en la tabla de historial.
*/

CREATE TABLE IF NOT EXISTS historial_actualizaciones_producto (
    idHistorial INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    idProducto INTEGER,
    porcentaje_actualizado FLOAT,
    fecha_actualizacion DATETIME,
    FOREIGN KEY (idProducto) REFERENCES producto(idProducto)
);

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

DELIMITER $$

CREATE PROCEDURE actualizar_porcentaje_producto(
    IN p_idProducto INT,      -- Parámetro de entrada: ID del producto
    IN p_porcentaje FLOAT     -- Parámetro de entrada: porcentaje a actualizar
)
BEGIN
	DECLARE existencia INT;

    SELECT COUNT(*) INTO existencia
    FROM producto
    WHERE idProducto = p_idProducto;

    IF existencia = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    ELSE
        UPDATE producto
        SET precio_venta = precio_costo * (1 + (p_porcentaje)/100)
        WHERE idProducto = p_idProducto;

        INSERT INTO historial_actualizaciones_producto(idProducto, porcentaje_actualizado, fecha_actualizacion)
        VALUES (p_idProducto, p_porcentaje, NOW());
    END IF;
END $$

DELIMITER ;

-- llamamos al SP para actualizar el idProducto = 1, con el 15% de incremento al precio_costo

select * from producto where idProducto = 1;

CALL actualizar_porcentaje_producto(1, 15); 

select * from historial_actualizaciones_producto;
 
 select * from producto where idProducto = 1;
