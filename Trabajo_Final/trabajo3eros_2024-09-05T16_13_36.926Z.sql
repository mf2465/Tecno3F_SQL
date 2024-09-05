CREATE TABLE `usuario` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`usuario` VARCHAR(255),
	`password` VARCHAR(255),
	`nombre` VARCHAR(255),
	`apellido` VARCHAR(255),
	`dni` INTEGER,
	`email` VARCHAR(255),
	`last_session` DATETIME,
	`activacion` INTEGER,
	`token` VARCHAR(255),
	`token_password` VARCHAR(255),
	`password_request` VARCHAR(255),
	`tipo_usuario` INTEGER,
	`empresa` INTEGER,
	`cargo_empresa` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE TABLE `empresa` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`cuit` INTEGER,
	`nombre` VARCHAR(255),
	`direccion` VARCHAR(255),
	`mail` VARCHAR(255),
	`telefono` NUMERIC,
	`direccion_deposito` VARCHAR(255),
	PRIMARY KEY(`id`)
);


CREATE TABLE `elemento` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`elemento` VARCHAR(255) COMMENT 'manguera, bomba, manometro, recipiente, correntometro',
	PRIMARY KEY(`id`)
);


CREATE TABLE `recurso` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`recurso` VARCHAR(255) COMMENT 'bomba_presudizadora, canal de vidrio, ADCP, molinete, sensor de presión',
	PRIMARY KEY(`id`)
);


CREATE TABLE `tipo_usuario` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`tipo_usuario` VARCHAR(255) COMMENT 'administrativo, registrado, solicitud, invitado, team, UNS, desarrollo, defensa_civil',
	PRIMARY KEY(`id`)
);


CREATE TABLE `manguera` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`tag` VARCHAR(255),
	`solicitud` DATETIME,
	`recepcion` INTEGER,
	`prueba` DATETIME,
	`informe` DATETIME,
	`aptitud` INTEGER,
	`variable1` INTEGER,
	`variable2` INTEGER,
	`variable3` INTEGER,
	`ficha_tecnica` INTEGER,
	`a_facturar` DATETIME,
	`retiro` DATETIME,
	`vigencia` INTEGER,
	`ensayo` INTEGER,
	`empresa` INTEGER,
	`realizo1` INTEGER,
	`realizo2` INTEGER,
	`realizo3` INTEGER,
	`firma` INTEGER,
	`recibio` INTEGER,
	`cotizo` INTEGER,
	`fecha_cotiza` DATETIME,
	`monto_cotiza` INTEGER,
	`entrega` INTEGER,
	`aceptado` DATETIME,
	`autorizo` INTEGER,
	`solicito` INTEGER,
	`remito_in` VARCHAR(255),
	`remito_out` VARCHAR(255),
	`egreso` DATETIME,
	`observaciones` VARCHAR(255),
	`precinto` VARCHAR(255),
	`certificado_nro` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE TABLE `cargo_empresa` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`cargo_empresa` VARCHAR(255) COMMENT 'administrativo, calidad, responsable_técnico, operario',
	PRIMARY KEY(`id`)
);


CREATE TABLE `personal` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`nombre` VARCHAR(255),
	`apellido` VARCHAR(255),
	`titulo` VARCHAR(255),
	`funcion` VARCHAR(255),
	`legajo` VARCHAR(255),
	`mail` VARCHAR(255),
	PRIMARY KEY(`id`)
);


CREATE TABLE `ensayo` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`fluido` VARCHAR(255),
	`presion_trabajo` VARCHAR(255),
	`maxima_presion` VARCHAR(255),
	`minima_presion` VARCHAR(255),
	`tiempo` INTEGER,
	`observaciones` VARCHAR(255),
	`norma` VARCHAR(255),
	`elemento` INTEGER,
	`recurso` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE TABLE `ficha_tecnica` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`referencia_fisica` VARCHAR(255),
	PRIMARY KEY(`id`)
);


CREATE TABLE `facturacion` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	PRIMARY KEY(`id`)
);


CREATE TABLE `remitos_IN` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`fecha` DATETIME,
	`nro` VARCHAR(255),
	`empresa` INTEGER,
	`detalle` VARCHAR(255),
	`recibio` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE TABLE `certificados` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	PRIMARY KEY(`id`)
);


CREATE TABLE `remitos_OUT` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`fecha` DATETIME,
	`nro` VARCHAR(255),
	`empresa` INTEGER,
	`detalle` VARCHAR(255),
	`realizo` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE TABLE `presupuesto` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`fecha_pres` DATETIME,
	`destinatario` INTEGER,
	`cotizador` INTEGER,
	`cantidad` INTEGER,
	`descripcion` VARCHAR(255),
	`precio_unitario` INTEGER,
	`bonificacion_1` INTEGER,
	`bonificacion_2` INTEGER,
	`transporte` INTEGER,
	`monto_total` INTEGER,
	`observaciones` VARCHAR(255),
	PRIMARY KEY(`id`)
);


ALTER TABLE `ficha_tecnica`
ADD FOREIGN KEY(`id`) REFERENCES `manguera`(`ficha_tecnica`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`ensayo`) REFERENCES `ensayo`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`empresa`) REFERENCES `empresa`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `usuario`
ADD FOREIGN KEY(`tipo_usuario`) REFERENCES `tipo_usuario`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `usuario`
ADD FOREIGN KEY(`empresa`) REFERENCES `empresa`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `usuario`
ADD FOREIGN KEY(`cargo_empresa`) REFERENCES `cargo_empresa`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `ensayo`
ADD FOREIGN KEY(`elemento`) REFERENCES `elemento`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `ensayo`
ADD FOREIGN KEY(`recurso`) REFERENCES `recurso`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`realizo1`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`realizo2`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`realizo3`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`firma`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`recibio`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`cotizo`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`entrega`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`autorizo`) REFERENCES `usuario`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`solicito`) REFERENCES `usuario`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `remitos_IN`
ADD FOREIGN KEY(`empresa`) REFERENCES `empresa`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `remitos_OUT`
ADD FOREIGN KEY(`empresa`) REFERENCES `empresa`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `remitos_OUT`
ADD FOREIGN KEY(`realizo`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `remitos_IN`
ADD FOREIGN KEY(`recibio`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `presupuesto`
ADD FOREIGN KEY(`destinatario`) REFERENCES `empresa`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `presupuesto`
ADD FOREIGN KEY(`cotizador`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `presupuesto`
ADD FOREIGN KEY(`cotizador`) REFERENCES `personal`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `manguera`
ADD FOREIGN KEY(`recepcion`) REFERENCES `remitos_IN`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;