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
	tipo_usuario VARCHAR (100) NOT NULL
    );
    
CREATE TABLE IF NOT EXISTS cargo_empresa (
	idCargoEmpresa INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	cargo_empresa VARCHAR (100) NOT NULL
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
	dni INTEGER NOT NULL,
	email VARCHAR(100) UNIQUE,
    email_alternativo VARCHAR (50),
	last_session DATETIME,
	activacion INTEGER,
	token VARCHAR(255),
	token_password VARCHAR(255),
	password_request VARCHAR(255),
	tipo_usuario INTEGER (100),
	empresa INTEGER (255),
	cargo_empresa INTEGER (100),
    FOREIGN KEY (tipo_usuario) REFERENCES tipo_usuario(idTipoUsuario),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (cargo_empresa) REFERENCES cargo_empresa(idCargoEmpresa)
	);    
    
CREATE TABLE IF NOT EXISTS personal (
	idPersonal INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR (100) NOT NULL,
    apellido VARCHAR (100) NOT NULL,
    dni INTEGER NOT NULL,
    titulo VARCHAR (100) NOT NULL,
    funcion VARCHAR (100) NOT NULL,
    mail VARCHAR (50) NOT NULL,
    mail_alternativo VARCHAR (50),
    legajo VARCHAR (50) NOT NULL
    );    