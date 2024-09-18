-- PROYECTO CENTRO MEDICO DG

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE centro_medico_dg;

-- NOS PARAMOS EN LA NUEVA BASE CREADA
USE centro_medico_dg;

-- CREACION DE LAS TABLAS

CREATE TABLE IF NOT EXISTS especialidad(
    idEspecialidad INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR (100) NOT NULL
);

CREATE TABLE IF NOT EXISTS genero(
    idGenero INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    genero ENUM('Masculino','Femenino','No Binario','S/D')
);

CREATE TABLE IF NOT EXISTS nacionalidad(
    idNacionalidad INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR (100) NOT NULL
);

CREATE TABLE IF NOT EXISTS localidad(
    idLocalidad INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR (100) NOT NULL
);

CREATE TABLE IF NOT EXISTS provincia(
    idProvincia INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR (100) NOT NULL
);

CREATE TABLE IF NOT EXISTS diagnostico(
    idDiagnostico INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR (100) NOT NULL
);

CREATE TABLE IF NOT EXISTS obraSocial(
    idObraSocial INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    razonSocial VARCHAR (255) NOT NULL,
    cuit VARCHAR (15),
    direccion VARCHAR (255)
);

CREATE TABLE IF NOT EXISTS planObraSocial(
    idPlanObraSocial INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    plan VARCHAR (200),
    idObraSocial INT NOT NULL,
    FOREIGN KEY (idObraSocial) REFERENCES obraSocial(idObraSocial)
);   

CREATE TABLE IF NOT EXISTS consultorio(
    idConsultorio INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255),
    direccion VARCHAR (255),
    CP INT (4) DEFAULT 0,
    telefono VARCHAR (100) NOT NULL,
    mail VARCHAR(200) NOT NULL,
    idProvincia INT NOT NULL,
    idLocalidad INT NOT NULL,
    FOREIGN KEY (idProvincia) REFERENCES provincia(idProvincia),
    FOREIGN KEY (idLocalidad) REFERENCES localidad(idLocalidad)
);    

CREATE TABLE IF NOT EXISTS paciente(
    idPaciente INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    apellido VARCHAR (255) NOT NULL,
    email VARCHAR (255) UNIQUE,
    fechaNacimiento DATE NOT NULL,
	direccion VARCHAR (255),
    dni VARCHAR(30) NOT NULL, 
    idGenero INT NOT NULL,
    idNacionalidad INT NOT NULL,
    idPlanObraSocial INT NOT NULL,
    idProvincia INT NOT NULL,
    idLocalidad INT NOT NULL,
    FOREIGN KEY (idGenero) REFERENCES genero(idGenero),
    FOREIGN KEY (idPlanObraSocial) REFERENCES planObraSocial(idPlanObraSocial),
    FOREIGN KEY (idNacionalidad) REFERENCES nacionalidad(idNacionalidad),
    FOREIGN KEY (idProvincia) REFERENCES provincia(idProvincia),
    FOREIGN KEY (idLocalidad) REFERENCES localidad(idLocalidad)
);


CREATE TABLE IF NOT EXISTS medico(
    idMedico INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    apellido VARCHAR (255) NOT NULL,
    fechaNacimiento DATE,
    matricula VARCHAR(200) NOT NULL,
    idGenero INT NOT NULL,
    idEspecialidad INT NOT NULL,
    idNacionalidad INT NOT NULL,
	FOREIGN KEY (idGenero) REFERENCES genero(idGenero),
    FOREIGN KEY (idEspecialidad) REFERENCES especialidad (idEspecialidad),
    FOREIGN KEY (idNacionalidad) REFERENCES nacionalidad (idNacionalidad)
); 


CREATE TABLE IF NOT EXISTS medico_planObraSocial(
    idMedico INT NOT NULL,
    idPlanObraSocial INT NOT NULL,
    FOREIGN KEY (idMedico) REFERENCES medico (idMedico),
    FOREIGN KEY (idPlanObraSocial) REFERENCES planObraSocial (idPlanObraSocial)
);

CREATE TABLE IF NOT EXISTS turno(
    idTurno INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fechaTurno DATETIME NOT NULL,
    fechaSolicitud DATE NOT NULL,
    idMedico INT NOT NULL,
    idPaciente INT NOT NULL,
    idConsultorio INT NOT NULL,
    FOREIGN KEY (idMedico) REFERENCES medico (idMedico),
    FOREIGN KEY (idPaciente) REFERENCES paciente (idPaciente),
    FOREIGN KEY (idConsultorio) REFERENCES consultorio (idConsultorio)
);

CREATE TABLE IF NOT EXISTS consulta(
    idConsulta INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    consulta VARCHAR (255),
    idTurno INT NOT NULL,
    idDiagnostico INT NOT NULL,
    FOREIGN KEY (idTurno) REFERENCES turno (idTurno),
    FOREIGN KEY (idDiagnostico) REFERENCES diagnostico (idDiagnostico)
);

-- SET FOREIGN_KEY_CHECKS=1;
-- TRUNCATE TABLE turno;
/*
SELECT * FROM especialidad; 
SELECT * FROM genero; 
SELECT * FROM nacionalidad; 
SELECT * FROM localidad; 
SELECT * FROM provincia; 
SELECT * FROM diagnostico;
SELECT * FROM obraSocial; 
SELECT * FROM planObraSocial; 
SELECT * FROM consultorio; 
SELECT * FROM paciente; 
SELECT * FROM medico; 
SELECT * FROM medico_planObraSocial; 
SELECT * FROM turno; 
SELECT * FROM consulta;  
*/
