drop database if exists tecno_3F_clase_3;
create database if not exists  tecno_3F_clase_3;
use tecno_3F_clase_3;

CREATE TABLE IF NOT EXISTS clase3_sql(
  idCliente INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    fechaNacimiento DATETIME,
    nacionalidad VARCHAR(100),
    sueldo FLOAT,
    sucursal INT
);

INSERT INTO clase3_sql  VALUES 
(NULL,'Diego','Fernandez','2007-06-13 12:00:00','Argentina',1000.50, 001),
(NULL,'Carolina','Bernachea','1992-03-18 13:00:00','Argentina',2000.50,002),
(NULL,'Melina','Torres','1999-06-06 14:50:00','Brasil',3000,002),
(NULL,'Lucas','Grosso','1980-07-21 17:00:00','Colombia',500,002),
(NULL,'Carlos','Rodriguez','1994-03-25 18:00:00','Canada',3012,004),
(NULL,'Laura','Fernandez','2000-03-18 19:00:00','Argelia',4000,003),
(NULL,'Fabian','Pérez','1999-11-11 19:00:00','España',3322.70,002),
(NULL,'Guillermo','Ballester','2003-07-07 21:31:05','Francia',1119.99,001);

-- SELECT * FROM	clase3_sql;

create table if not exists alumnos(
    DNI INT NOT NULL,
    TIPO_DNI VARCHAR(10) NOT NULL,
    NOMBRE VARCHAR(50),
    APELLIDO VARCHAR(50),
    PRIMARY KEY (DNI, TIPO_DNI)
);


INSERT INTO alumnos VALUES
(24508119,'DNI','MIGUEL','FLORES');

alter table clase3_sql
add telefono bigint default 0;

select * from clase3_sql;
alter table clase3_sql
modify telefono varchar(50) default 11;

insert into clase3_sql values 
(NULL,'Hector','Caballero','1994-03-25 18:00:00','Canada',3012,654654,7877);
select * from clase3_sql;
insert into clase3_sql values 
(NULL,'Hector','Caballero','1994-03-25 18:00:00','Canada',3012,654654,null);
select * from clase3_sql;
alter table clase3_sql
change telefono movil varchar(255) default 0 not null;
select * from clase3_sql;

alter table clase3_sql
drop column movil;
select * from clase3_sql;

select *  from clase3_sql
order by apellido;

select * from clase3_sql
order by apellido desc;
select * from clase3_sql
order by apellido, sucursal desc;

select * from clase3_sql
where sueldo between 2000 and 4000;

select * from clase3_sql
where idCliente <1;

SELECT * 
FROM clase3_sql
LIMIT 3 OFFSET 4;

select * from clase3_sql
where fechaNacimiento > 2000-01-01;

select * from clase3_sql
where fechaNacimiento <= '2000-01-01';
 
 select nombre, apellido, fechaNacimiento from clase3_sql
 where fechaNacimiento >= '1995-01-01';
 
  select nombre, apellido, YEAR(fechaNacimiento) from clase3_sql
 where fechaNacimiento >= '1995-01-01';
 
 select * from clase3_sql
 where sucursal =1 or Sucursal =4;
 
 select * from clase3_sql
 where year(fechaNacimiento) between 1999 and 2003;
 
 select * from clase3_sql
 where apellido != 'Fernandez';
 
 



