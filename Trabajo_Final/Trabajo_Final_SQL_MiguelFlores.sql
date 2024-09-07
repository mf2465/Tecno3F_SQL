-- PROYECTO SERVICIOS A TERCEROS 
-- LABORATORIO DE HIDRAULICA / UNIVERSIDAD NACIONAL DEL SUR 
-- 2024

-- Borrar en caso de que exista la base
DROP DATABASE IF EXISTS servicios_terceros_LH;

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE servicios_terceros_LH;

-- NOS PARAMOS EN LA NUEVA BASE
USE servicios_terceros_LH;

-- CREACION DE TABLAS
-- En esta primera sección: sección usuarios y lo relacionado al Login al Sistema

CREATE TABLE IF NOT EXISTS tipo_usuario (
	idTipoUsuario INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	tipo_usuario VARCHAR (100) NOT NULL -- para jerarquizar y otorgar permisos de accesos a distintas entidades
    );
    
CREATE TABLE IF NOT EXISTS cargo_empresa (
	idCargoEmpresa INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	cargo_empresa VARCHAR (100) NOT NULL -- administrativo, control de calidad, supervisor, auditor, operario, jefe de mantenimiento
    );    

CREATE TABLE IF NOT EXISTS empresa (
	idEmpresa INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	cuit VARCHAR (50) NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    domicilio_facturacion VARCHAR (255) NOT NULL,
    domicilio_deposito VARCHAR (255) NOT NULL,
    mail_facturacion VARCHAR (50) NOT NULL UNIQUE,
    mail_deposito VARCHAR (50) NOT NULL,
    telefono VARCHAR (50) NOT NULL,
    telefono_alternativo VARCHAR (50)
    );
    

CREATE TABLE IF NOT EXISTS usuario (
	idUsuario INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100) NOT NULL,
	pass VARCHAR(100),
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL,
	dni INT NOT NULL,
	email VARCHAR(100) UNIQUE,
    email_alternativo VARCHAR (50),
	last_session DATETIME,
	activacion INT, -- se utiliza para verificar datos manualmente y otorgar el permiso desde un administrador persona
	token VARCHAR(255),
	token_password VARCHAR(255),
	password_request VARCHAR(255),
	tipo_usuario INT,
	empresa INT,
	cargo_empresa INT,
    FOREIGN KEY (tipo_usuario) REFERENCES tipo_usuario(idTipoUsuario),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (cargo_empresa) REFERENCES cargo_empresa(idCargoEmpresa)
	);    
    
CREATE TABLE IF NOT EXISTS personal (
	idPersonal INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR (100) NOT NULL,
    apellido VARCHAR (100) NOT NULL,
    dni INT NOT NULL,
    titulo VARCHAR (100) NOT NULL, -- tratamiento de Técnico, Ingeniero, Director, etc
    funcion VARCHAR (100) NOT NULL, -- responsabilidades
    mail VARCHAR (50) NOT NULL,
    mail_alternativo VARCHAR (50),
    legajo VARCHAR (50) NOT NULL
    );    
    
CREATE TABLE IF NOT EXISTS presupuesto (
	idPresupuesto INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	empresa int not null,
    usuario int,
    cotizador int not null, -- persona que realizó la cotización
    fecha datetime not null,
    cantidad int,
    descripcion varchar (255),
    precio_unitario float,
    valor_dolar float, -- para tener una referencia temporal del precio equivalente a la cotización del día de la confección
    total float,
    observaciones varchar(255),
    vigencia_oferta int,
    forma_pago varchar (50),
    plazo_entrega varchar (100),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (usuario) REFERENCES usuario(idUsuario),
    FOREIGN KEY (cotizador) REFERENCES personal(idPersonal)
    );
    
CREATE TABLE IF NOT EXISTS remito_in (
	idRemito_in INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    empresa int not null, 
    fecha datetime,
    recibe int, -- es quien recibe el material y se responsabiliza hasta el ensayo
    cantidad int,
    detalle varchar (255),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (recibe) REFERENCES personal(idPersonal)
    );

CREATE TABLE IF NOT EXISTS tipo_elemento (
	idTipo_elemento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    tipo_elemento varchar(255) -- manguera, manometro, molinete, bomba, modelo a escala
	);

CREATE TABLE IF NOT EXISTS protocolo (
	idProtocolo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	tipo_elemento int,
    fluido varchar(255),
    presion_trabajo int,
    presion_min int,
    presion_max int,
    tiempo_min int,
    tiempo_max int,
    velocidad float,
    caudal float,
    temperatura float,
    humedad int,
    barometrica int,
    coordenadas_gps varchar (255),
    observaciones varchar (255),
    metodologia varchar (255),
    link varchar (255),
    norma varchar (255),
    recurso int, -- equipos o instrumentos utilizados en el ensayo del elemento 
    ultima_revision datetime, -- para ver la obsolecencia y proceder a revisión con normas actuales
    FOREIGN KEY (tipo_elemento) REFERENCES tipo_elemento(idTipo_elemento)
    );
    
CREATE TABLE IF NOT EXISTS ensayo (
	idEnsayo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	fecha datetime,
    locacion varchar(255),
    operador1 int,
    operador2 int,
    operador3 int,
    operador4 int,
    protocolo int,
    FOREIGN KEY (operador1) REFERENCES personal(idPersonal),
    FOREIGN KEY (operador2) REFERENCES personal(idPersonal),
    FOREIGN KEY (operador3) REFERENCES personal(idPersonal),
    FOREIGN KEY (operador4) REFERENCES personal(idPersonal),
    FOREIGN KEY (protocolo) REFERENCES protocolo(idProtocolo)
    );
   
CREATE TABLE IF NOT EXISTS certificado (
	idCertificado INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	fecha datetime,
    ensayo int,
    observaciones varchar(255),
    aptitud int,
    vigencia_dias int,
    precinto varchar(255),
    confecciona int,
    revisa int,
    firma1 int,
    firma2 int,
    link varchar(255),
    FOREIGN KEY (ensayo) REFERENCES ensayo(idEnsayo),
    FOREIGN KEY (confecciona) REFERENCES personal(idPersonal),
    FOREIGN KEY (revisa) REFERENCES personal(idPersonal),
    FOREIGN KEY (firma1) REFERENCES personal(idPersonal),
    FOREIGN KEY (firma2) REFERENCES personal(idPersonal)
    );
    
CREATE TABLE IF NOT EXISTS facturacion (
	idFacturacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	fecha datetime,
    certificado int,
    FOREIGN KEY (certificado) REFERENCES certificado(idCertificado)
    );
    
CREATE TABLE IF NOT EXISTS ficha_tecnica (
	idFicha_tecnica INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    link varchar(255)
	);
    
CREATE TABLE IF NOT EXISTS remito_out (
	idRemito_out INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	empresa int not null, 
    fecha datetime,
    envia int, -- persona responsable el envío del material a la empresa
    cantidad int,
    detalle varchar (255),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (envia) REFERENCES personal(idPersonal)
    );
    
CREATE TABLE IF NOT EXISTS status_elemento (
	idStatus_elemento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    status_elemento varchar(255) -- ingresado, en ensayo, caduco, apto, etc, un flag para depurar
	);
    
CREATE TABLE IF NOT EXISTS elemento (
	idElemento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    tipo_elemento int not null,
    status_elemento int,
	tag_original VARCHAR (100) NOT NULL,
    precinto VARCHAR (100) NOT NULL,
    presupuesto INT,
    remito_in int,
    ficha_tecnica int,
    ensayo int,
    certificado int,
    observaciones varchar (255),
    facturacion int,
    remito_out int,
    FOREIGN KEY (tipo_elemento) REFERENCES tipo_elemento(idTipo_elemento),
	FOREIGN KEY (status_elemento) REFERENCES status_elemento(idStatus_elemento),
    FOREIGN KEY (ficha_tecnica) REFERENCES ficha_tecnica(idFicha_tecnica),
    FOREIGN KEY (presupuesto) REFERENCES presupuesto(idPresupuesto),
    FOREIGN KEY (remito_in) REFERENCES remito_in(idRemito_in),
    FOREIGN KEY (ensayo) REFERENCES ensayo(idEnsayo),
    FOREIGN KEY (certificado) REFERENCES certificado(idCertificado),
    FOREIGN KEY (facturacion) REFERENCES facturacion(idFacturacion),
    FOREIGN KEY (remito_out) REFERENCES remito_out(idRemito_out)
    ); 