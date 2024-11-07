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
    
CREATE TABLE IF NOT EXISTS detalle_cotizacion (
	idDetalle_cotizacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	detalle text,
    observaciones varchar(255)
    );

CREATE TABLE IF NOT EXISTS cotizacion (
	idCotizacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	cantidad int,
    detalle_cotizacion int,
    precio_unitario float,
    valor_dolar float, -- para tener una referencia temporal del precio equivalente a la cotización del día de la confección
    total float,
    observaciones varchar(255),
    FOREIGN KEY (detalle_cotizacion) REFERENCES detalle_cotizacion(idDetalle_cotizacion)
    );    
    
CREATE TABLE IF NOT EXISTS presupuesto (
	idPresupuesto INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	empresa int not null,
    usuario int,
    cotizador int not null, -- persona que realizó la cotización
    fecha datetime not null,
    vigencia_oferta int,
    forma_pago varchar (50),
    plazo_entrega varchar (100),
    observaciones varchar (255),
    link varchar (255),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (usuario) REFERENCES usuario(idUsuario),
    FOREIGN KEY (cotizador) REFERENCES personal(idPersonal)
    );
  
-- detalle o items a presupuestar
-- Tabla intermedia para asociar presupuesto con items cotizados
CREATE TABLE IF NOT EXISTS presupuesto_cotizado (
	idPresupuesto_cotizado INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	idPresupuesto INT NOT NULL,
	idCotizacion INT NOT NULL,
    FOREIGN KEY (idPresupuesto) REFERENCES presupuesto(idPresupuesto),
    FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion)
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
  
-- Proformas para enviar a la Fundación para que facture los trabajos del Laboratorio a la Empresa  
-- encabezado
CREATE TABLE IF NOT EXISTS a_facturacion ( 
	idA_facturacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	fecha datetime,
    empresa int,
    ref_presupuesto int, -- se utiliza para tener una referencia
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (ref_presupuesto) REFERENCES presupuesto(idPresupuesto)
    );
 
-- detalle o items a facturar
-- Tabla intermedia para asociar certificados con facturación
CREATE TABLE IF NOT EXISTS a_facturacion_certificado (
	idA_facturacion_certificado INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	idA_facturacion INT NOT NULL,
	idCertificado INT NOT NULL,
    FOREIGN KEY (idA_facturacion) REFERENCES a_facturacion(idA_facturacion),
    FOREIGN KEY (idCertificado) REFERENCES certificado(idCertificado)
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
    a_facturacion int,
    remito_out int,
    FOREIGN KEY (tipo_elemento) REFERENCES tipo_elemento(idTipo_elemento),
	FOREIGN KEY (status_elemento) REFERENCES status_elemento(idStatus_elemento),
    FOREIGN KEY (ficha_tecnica) REFERENCES ficha_tecnica(idFicha_tecnica),
    FOREIGN KEY (presupuesto) REFERENCES presupuesto(idPresupuesto),
    FOREIGN KEY (remito_in) REFERENCES remito_in(idRemito_in),
    FOREIGN KEY (ensayo) REFERENCES ensayo(idEnsayo),
    FOREIGN KEY (certificado) REFERENCES certificado(idCertificado),
    FOREIGN KEY (a_facturacion) REFERENCES a_facturacion(idA_facturacion),
    FOREIGN KEY (remito_out) REFERENCES remito_out(idRemito_out)
    ); 
    
 /* Inserción de Datos */
    
-- Tabla tipo_usuario
INSERT INTO tipo_usuario (tipo_usuario) VALUES
('interno'),
('externo'),
('empresa'),
('terceros'),
('institucional'),
('auditor'),
('contabilidad'),
('municipio'),
('investigador'),
('docente');

-- select * from tipo_usuario;

-- Tabla cargo_empresa
INSERT INTO cargo_empresa (idCargoEmpresa, cargo_empresa) VALUES
(NULL, 'auditor'),
(NULL, 'dueño'),
(NULL, 'calidad'),
(NULL, 'administración'),
(NULL, 'técnico'),
(NULL, 'supervisor'),
(NULL, 'mantenimiento'),
(NULL, 'operario'),
(NULL, 'logística'),
(NULL, 'depósito'),
(NULL, 'recepción');

-- select * from cargo_empresa;

-- Tabla empresa
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 198630368825, 'Considine, Kassulke and Borer', '121 Cottonwood Road', '9024 Blackbird Court', 'mlawlie0@soup.io', 'lloads0@blogtalkradio.com', '1027859749', '6896827580');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 245727737217, 'Streich Inc', '6957 Burning Wood Drive', '7766 Coleman Road', 'npiet1@uiuc.edu', 'kbritzius1@mapquest.com', '1741865999', '5578323689');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 211825238884, 'Hammes, Hoppe and Marquardt', '15 Saint Paul Lane', '743 Straubel Terrace', 'chowgego2@tinyurl.com', 'pdoughton2@twitter.com', '8691071986', '9007528876');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 724413458504, 'Bahringer, Ratke and Runolfsson', '6 Longview Crossing', '0 Sycamore Crossing', 'mvandenvelden3@nba.com', 'vcorragan3@wisc.edu', '3054984203', '4809628673');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 988693137581, 'Bins-Wolf', '6136 Manufacturers Terrace', '8834 Mendota Crossing', 'dlucian4@barnesandnoble.com', 'kboyford4@yandex.ru', '9418692190', '2016513045');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 410999809159, 'Bosco LLC', '780 Novick Terrace', '85 Maywood Street', 'adaal5@imdb.com', 'bdreher5@t.co', '7891963396', '2447129810');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 999164101394, 'Collier-O''Connell', '85 Pankratz Parkway', '4 Ilene Point', 'drumford6@symantec.com', 'cwadeling6@vinaora.com', '8966860634', '7577365245');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 450175723967, 'Jacobs-Lakin', '33094 Towne Parkway', '98264 Lake View Road', 'bsatchel7@opera.com', 'aquinnet7@pen.io', '1476055475', '8906008304');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 893720460714, 'Gulgowski, Johnston and Langworth', '9 Corscot Park', '587 Scott Place', 'ttassell8@ox.ac.uk', 'doteague8@mediafire.com', '2281993929', '1706810143');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 443800037549, 'Keeling Group', '59 Ridgeview Junction', '838 Texas Point', 'zlangdon9@stanford.edu', 'lgaenor9@timesonline.co.uk', '9743372696', '1692418977');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 852990781340, 'Block-Considine', '1793 Lotheville Center', '4 Cody Street', 'lhubanda@nps.gov', 'wwinleya@parallels.com', '8004537736', '5847883470');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 423266119585, 'Herzog-McLaughlin', '94927 Londonderry Place', '63866 Ludington Hill', 'lstoeckleb@sphinn.com', 'vstockmanb@bigcartel.com', '2084016960', '9294844251');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 774551908191, 'Effertz, Lubowitz and Koepp', '20362 Morrow Terrace', '1 Spohn Hill', 'imckeurtanc@hubpages.com', 'greppaportc@opensource.org', '6545868721', '6385607547');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 640871625809, 'Kozey and Sons', '43 Mandrake Center', '52499 Hermina Street', 'rmatysd@smh.com.au', 'btaddd@storify.com', '7065156118', '4954360118');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 888066137584, 'Christiansen Inc', '0454 Granby Trail', '7620 Bluestem Place', 'ccromlye@adobe.com', 'lvaheye@wordpress.org', '5663313914', '1045926025');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 185282029563, 'Bergstrom LLC', '59 Artisan Street', '47 Mariners Cove Drive', 'ffewlessf@mapy.cz', 'tgeffef@pinterest.com', '2115489480', '4736239912');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 114878619932, 'Boyer, Hoppe and Medhurst', '73348 Walton Terrace', '1053 Pine View Pass', 'myousterg@omniture.com', 'nklimowskig@ycombinator.com', '3178402470', '3144999946');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 355310946934, 'Fay Group', '6738 Crownhardt Parkway', '22466 Stang Court', 'tannwylh@google.fr', 'htoppash@typepad.com', '4689278697', '1287009681');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 401523789838, 'Dibbert and Sons', '9516 Evergreen Plaza', '6 Holy Cross Plaza', 'hgruczkai@angelfire.com', 'iphilpotsi@odnoklassniki.ru', '1703578627', '5912884829');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 819205555185, 'Hegmann, Kuvalis and Goldner', '0 Vidon Plaza', '1005 Scoville Plaza', 'pdavidescuj@topsy.com', 'ccausleyj@eventbrite.com', '5713531705', '8446599509');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 955266041570, 'Fahey and Sons', '8 Westerfield Road', '66 Division Terrace', 'ghaslehurstk@hubpages.com', 'binglesk@4shared.com', '7323147132', '7603717420');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 330287390590, 'Homenick, Lowe and Bergnaum', '93517 Moulton Junction', '411 Hauk Trail', 'dminneyl@51.la', 'hbruyntjesl@addtoany.com', '9095662610', '8695119464');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 602763146125, 'Wintheiser-Terry', '03 Upham Center', '9 Park Meadow Point', 'tgeerem@fotki.com', 'echalkm@woothemes.com', '6555142646', '4667749976');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 815964492088, 'Toy, Turner and Purdy', '3 Schmedeman Trail', '1003 Caliangt Terrace', 'ebessantn@hud.gov', 'mbutlinn@smugmug.com', '9515030080', '8565123795');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 362226413937, 'Stiedemann, Konopelski and Daugherty', '9216 Knutson Pass', '7 Golf Parkway', 'kanniceo@ftc.gov', 'tdaborno@senate.gov', '2063445296', '8637625450');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 712440025093, 'McDermott-Hilpert', '7035 Vahlen Terrace', '37731 Northwestern Terrace', 'aelgiep@meetup.com', 'pcubuzzip@google.com.br', '9422004283', '9668870957');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 118754012085, 'Welch, Bashirian and Kunze', '18295 Anthes Point', '71077 Village Way', 'rsamsq@accuweather.com', 'lajamq@delicious.com', '8751129893', '6608961353');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 961125092580, 'Mills-Schmidt', '19 Union Court', '9854 Columbus Crossing', 'cmacdermotr@berkeley.edu', 'scollissonr@patch.com', '9452558977', '6243239342');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 570237700951, 'Considine, Shanahan and Streich', '7 Butternut Avenue', '03 Oxford Junction', 'fswalteridges@harvard.edu', 'bdavidoves@usa.gov', '6676649040', '5949645265');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 946878033491, 'O''Conner Inc', '71 South Circle', '64 Graedel Alley', 'asevent@amazonaws.com', 'wbaddamt@uiuc.edu', '2329718202', '3294277081');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 270333828307, 'Champlin-Ferry', '710 Delaware Way', '171 Valley Edge Parkway', 'gnisbyu@4shared.com', 'dmalsheru@ucla.edu', '4906562840', '9948917002');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 633824771424, 'Romaguera Group', '6 Welch Junction', '42 Montana Court', 'wkachelerv@fema.gov', 'aflynnv@wordpress.com', '1538918103', '6943008208');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 502843084980, 'Barrows, Heller and Morissette', '640 Warner Center', '7 Iowa Point', 'mverlanderw@geocities.com', 'bsmartw@mail.ru', '5134329006', '2078849960');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 508070733214, 'Dibbert-Spencer', '34 Amoth Crossing', '75 Macpherson Avenue', 'rjarlmannx@bbb.org', 'nbelfragex@netlog.com', '3278647950', '1511852537');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 163937445915, 'Murazik and Sons', '10912 Fordem Drive', '77 Reindahl Crossing', 'smalinsy@uiuc.edu', 'tkneaphseyy@cocolog-nifty.com', '9724681682', '7127081191');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 961055805974, 'Deckow-Hahn', '2208 American Junction', '784 Vera Street', 'lfarraz@businesswire.com', 'zmanwaringz@cnet.com', '2168243170', '5381923218');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 622896853379, 'Zulauf LLC', '1894 Banding Park', '651 Messerschmidt Junction', 'messame10@microsoft.com', 'mdrewett10@epa.gov', '7728155133', '9086992801');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 554418645854, 'Strosin, Windler and Lesch', '7286 Moland Lane', '9 Service Pass', 'mpirelli11@topsy.com', 'foldland11@facebook.com', '6735172269', '8861103220');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 945244063821, 'Conroy, Nolan and Altenwerth', '601 Montana Circle', '7 Dottie Parkway', 'ajanusz12@godaddy.com', 'spaz12@prweb.com', '5644790155', '6529048490');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 578431698830, 'Parisian, Strosin and Kiehn', '58 Carberry Place', '58 Ridge Oak Way', 'achisholm13@weather.com', 'alankford13@google.com', '8268738990', '3008136459');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 359446472909, 'Tillman and Sons', '56 Artisan Crossing', '49 Waxwing Junction', 'afruchter14@examiner.com', 'mratie14@arstechnica.com', '2724950903', '5438960935');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 635663832613, 'Ullrich, Hudson and Fay', '97415 Cordelia Center', '30 Beilfuss Pass', 'nsquire15@about.com', 'rbridge15@dyndns.org', '3972168267', '5641125783');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 935897080837, 'Collier, Shields and Bednar', '81 Elka Center', '20 Merchant Street', 'mgillice16@wikipedia.org', 'jrenol16@sitemeter.com', '3987537047', '7255265144');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 380091616309, 'Okuneva-McCullough', '225 Dapin Parkway', '3008 Briar Crest Terrace', 'adagon17@constantcontact.com', 'sgood17@etsy.com', '9715444582', '9643237837');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 830361383882, 'Shanahan Group', '895 Nancy Road', '1 Division Street', 'gmingaud18@yahoo.com', 'ccallear18@apple.com', '8237872477', '9167539342');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 182833404785, 'Bradtke, Bahringer and Gerhold', '9505 Hazelcrest Crossing', '300 Orin Alley', 'bgethings19@accuweather.com', 'elemme19@spotify.com', '8019446984', '1189920082');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 962193217463, 'Stanton Inc', '1072 Comanche Park', '203 Mockingbird Point', 'jfrigot1a@loc.gov', 'jboseley1a@flickr.com', '3751954419', '9637697506');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 686424994290, 'Turner LLC', '360 Green Ridge Pass', '29548 Arrowood Park', 'ktreadgall1b@skype.com', 'ashervil1b@so-net.ne.jp', '9502738641', '1777461260');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 979542922411, 'Douglas Group', '3139 Park Meadow Plaza', '482 Commercial Place', 'fpymar1c@elpais.com', 'tmaffioletti1c@si.edu', '9861318848', '9156516622');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 736234695818, 'Durgan-Weimann', '4494 Sugar Terrace', '85342 Maple Junction', 'kebbage1d@noaa.gov', 'njocic1d@123-reg.co.uk', '2618974634', '5273290434');

-- select * from empresa;

-- Tabla usuario
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'caddionizio0', 'jG7"#uAG', 'Clarabelle', 'Addionizio', 69720172, 'caddionizio0@home.pl', 'caddionizio0@unicef.org', '2024-07-15 02:44:57', 49, '7dbc67a12da7d880bc9383a70ede9f79f94498f34956ed11e6f6a7df29e53f3e', '15980597e704c3eca12203c2d90870cf45a9f4a2778a083b9a136490f986c430', '$2a$04$miXH2NNevjxr4hNWjFNUhuQsEsKeg/CgYz5ntiTLHz8ynpmobgmaK', 4, 12, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ldjakovic1', 'pM0\s6}S/', 'Lauree', 'Djakovic', 28269633, 'ldjakovic1@photobucket.com', 'ldjakovic1@nifty.com', '2024-02-22 16:41:12', 6, '9f39a5d13d90937c3a4c9902eb338494b8b41d6bde6e40d26f3ccc692d376466', 'e7678289005ad81fdb165984e9288a4d5a69f511f39a4776b5dc87e6da384348', '$2a$04$9IVYGBSXi6ZCIU/8n3ohmup.flHQ7MJYRd0XA38ZfzF/poYCznwZa', 5, 23, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ssanson2', 'iE7)_3kGAUXv', 'Shaine', 'Sanson', 88939457, 'ssanson2@soup.io', 'ssanson2@baidu.com', '2024-03-07 22:36:02', 89, 'b67f2c5feefad7a4c97e7422a624a259de749eff7770fc111c4ca1a689cf86d4', '5e672ce9a7f05b816e4d6fefead17d98633a05e333bac42c0ef34890f1f38774', '$2a$04$CX2Mgd6rER0OWECJJFZP1uQS/MMxIV/yGGlaZ1U9DrRhrMD/ArNFO', 7, 25, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'khischke3', 'sS5`Q1!/mL~T}', 'Kath', 'Hischke', 79963690, 'khischke3@parallels.com', 'khischke3@surveymonkey.com', '2024-06-28 04:59:25', 71, '9284e779bb74cbe2b37acbc90389b715cc3f704dc836d0a580294ca00811e715', '3e11ab198a493016139f8136682bfc94f56f821bcd4bdf2a6d2e0b013aac5081', '$2a$04$S.OBeq1j3EH37fSIaCZDV.ikQLeDFVmIxfgKKYpLwnjxIhXg91OJ.', 4, 27, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mdjurkovic4', 'bX7(XKX9`T&&x', 'Maggy', 'Djurkovic', 70711214, 'mdjurkovic4@comsenz.com', 'mdjurkovic4@infoseek.co.jp', '2024-09-17 04:33:53', 100, '99618f649dec1f0c40c7db36987978d22de7dabf4541204eae13469211114f15', '4d2d75741c50e5d99d3b42084443c5f9fa28d5991a4ee412d74f42f476444ddf', '$2a$04$P//WV5q/lPOgL4Da7mFgRe2a3jbqZJG5Nh5UGy.VJN69mv46CAyW.', 5, 4, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'jfarrall5', 'aT9=%iD!,D.0`SF6', 'Juana', 'Farrall', 20585451, 'jfarrall5@liveinternet.ru', 'jfarrall5@cnbc.com', '2024-08-12 14:52:39', 57, 'e9d83d8f7c4eba59fb34b5fd00fe9574d0e83838c592385600c81b06738074e3', '26e88428374d70db9f7bb6ad51d02cdb02fca18344d1352487d9ca33dd3123f4', '$2a$04$RNOO/oF25RpXW9X.i9QxQO/NqlmjGqoab1UInaitYyGylZBj5Lfeu', 3, 33, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'hroman6', 'iN2|Qs?p', 'Homerus', 'Roman', 77568687, 'hroman6@marriott.com', 'hroman6@sogou.com', '2024-05-04 22:57:15', 70, '91bac31f78934488dd04518b43cefd85b384daaea11f84d558c2abb4fc0994fb', '1cf0d615632d7af1e98a6e43c61562f0b6728d100360c547410739b98366b1f6', '$2a$04$smV299iHGtZ5bYl2gfuERe87nw86cGwqFiPslDfAvutQ0jy/RTy/6', 5, 33, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'sfattori7', 'aH4"2}<PBa''J+TS', 'Shirl', 'Fattori', 90938104, 'sfattori7@over-blog.com', 'sfattori7@godaddy.com', '2024-06-20 15:04:57', 56, '9c0dbb61f9e34aa9072febe330cdec46590c0453ce6837afbf0c43af54084372', '5a47426119556959494098d4e972b0138d5742e1e2e6b950c23241a1824aac7e', '$2a$04$/Y2aJU3aNj2l4is/N6PJx.UapwQ8x1n3yOa2hh56dDbOmRcBRP04C', 10, 39, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mcarlesso8', 'uX3!9e~U<', 'Marabel', 'Carlesso', 10614907, 'mcarlesso8@wikia.com', 'mcarlesso8@about.com', '2024-04-19 17:34:02', 100, '0602232c60b64cfbd7645c3e73bed3c1b819f214926d5b2ed8d60deeceec7064', '5a44487643f1cff3b3e1d0e899829b801cfa92bbc6f5b0e3f653cd464aaa48ef', '$2a$04$RhoJomdOAz6cLniSObATZu5Y88twrcCnL0cwEsIVP3gpNQ9gMfbUC', 5, 17, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'tpine9', 'iJ2\)>b!4G(', 'Timmie', 'Pine', 93349578, 'tpine9@nature.com', 'tpine9@blogger.com', '2023-12-06 22:45:32', 50, 'df01dbba4faa46b90f157615bb04817a4373833a1fec393015635eb5410d0332', 'f2f17bfa84a39b5705bc7c243bf2e69840b6aee672ee055466509da24a2e71c3', '$2a$04$/2iuRIdZbPHARHd0b.Js3.gBk/7UELWiIOK7ZgH71PzLPRW/rcLfS', 10, 17, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'tstidstona', 'vW7}F/B#', 'Toddie', 'Stidston', 89217246, 'tstidstona@engadget.com', 'tstidstona@kickstarter.com', '2024-02-12 05:24:08', 9, '45fd78737e3c6d4dbc1af52df4c689c7223f24793a5e0042864d3d85467af3c5', '03a797e9cab709535e51fa99ce5e0b66be84ab4b3a8a11e97ee9da4f411c3583', '$2a$04$3.bBpxLbEOOmfSBahxRc3ucFRySkVKaxuxXSNfFPVT.MBTstQ1qwm', 3, 15, 1);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bionnidisb', 'mK2`%{WI`C3', 'Belia', 'Ionnidis', 4178997, 'bionnidisb@psu.edu', 'bionnidisb@tripod.com', '2024-09-03 05:34:07', 96, '7fbf827363430a4c37ed1142a82a8194fa3cf55b038baccf7d25c207805340a9', 'f37748d8d77f8d0fe26ebb89054909b254c44e034aeb814f47180d82e05b4b3a', '$2a$04$iDWfpEwiFiuJGzBoeAmRzuu2oRetmyDUoQ77LUKiF9P/nepkb49nK', 4, 11, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'rsaunperc', 'bO0}{X%*$`A)w4', 'Raymund', 'Saunper', 91085253, 'rsaunperc@wufoo.com', 'rsaunperc@webs.com', '2024-05-18 19:40:23', 69, 'af3c29ef2cb77696942e673f6d93141e72766eb3e2914a82c89f99017476c045', '5b67aa75b37290df2823d86f8cc32636be33f8543be9b9fa9a9efb8e0ec2fa76', '$2a$04$3rYKk8KTdtrz4RpXdnSM6.CAoADUKZxhh45RKCaPFG5WOvtDAkAzS', 10, 16, 1);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bsongerd', 'pU9~&D3i}5', 'Blakelee', 'Songer', 74563195, 'bsongerd@elegantthemes.com', 'bsongerd@cafepress.com', '2023-12-15 22:34:39', 18, 'b8fabdbc24b10d291d7a1f199bd417e763b6219024831ed3478dd54035795414', '1288a7c04f524952eeb6eece696fc3d7ec561dbe61eaf69bc5012a9704632316', '$2a$04$Divq1j2wQpFv0JVYRHEEVegOU9yHaR0apwBnhk8PwDUFfVQW3vmOW', 3, 32, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'kblampiede', 'rI3<GQea&', 'Keelby', 'Blampied', 99848387, 'kblampiede@flavors.me', 'kblampiede@yahoo.co.jp', '2023-10-15 07:39:41', 80, '38c8574bfbb62587daaa637445b5e7324e6aa80a6907c92d6b9f118731cef51b', 'df4142658ede37bc6fdd2278a42fa29bac12397b39cd85e95da53740dc43fa11', '$2a$04$OSbvC7.Q3eR3uVDJbx/n4.tPogppo9YWVHdpMV2UhNhLfNkekaV6e', 9, 46, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mstrobandf', 'yC3@wZ`wK#s', 'Mellicent', 'Stroband', 60942831, 'mstrobandf@hhs.gov', 'mstrobandf@bloomberg.com', '2024-08-20 21:32:38', 24, '7e036f8985f714f94df87847b45aec138ec85a5d14a54ccb8a592c3d026e72e8', '43ba756dfb7f9fecb2263a212550db8e68bb80682e6b78af930f8a3e44be5e26', '$2a$04$U41WCfQXip81YV9ri70bKutqJtXAbmIa1GIKZdP.GvpJYsUsOo0CS', 7, 7, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'blovelaceg', 'pR5@|&P>\W4E+', 'Benedetto', 'Lovelace', 32258497, 'blovelaceg@google.com.hk', 'blovelaceg@admin.ch', '2023-11-07 18:06:29', 16, '6878b35d627779880c3662887020f290f41d1fd1dba5e18e9a118c40a9fb5a39', '888ef460f585adb0217908e29d1c692a2deaa4fd5947235777231a9d16cc764c', '$2a$04$apL3R8Boe6LVSbmL5rEgCOMXk7mbjNajcVq0KkVlmaZF8Dl9PF6xC', 7, 5, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mrouchh', 'lM1)vosl}aUscY', 'Mirilla', 'Rouch', 32963952, 'mrouchh@whitehouse.gov', 'mrouchh@theguardian.com', '2024-09-10 09:45:07', 29, 'c6a9443a0024e63a9a2a8a1f6c803ce2c4eef72617c7756baf0137d8a658aeb9', 'f0582b52704579c393220734415293f752ced1d4bcf2e8c7105b2f97df599a37', '$2a$04$LYDyly/GR98dxubCGab33OSzjCNgHMUm/tUmVs.g/OYJ0qHnjBHxG', 3, 14, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'aroartyi', 'cL8|_Pkg0M_|C', 'Anatole', 'Roarty', 60056287, 'aroartyi@blinklist.com', 'aroartyi@blogtalkradio.com', '2023-12-11 00:14:49', 52, 'd5092701683a3d2294bb1dc9bc2f226a5592fa56c516db6ce4145cd6cd96f7e1', '3c4e2a9e40d9282d68240fb0e0e503c22848e11c6e5123174728ef865d4e58dc', '$2a$04$H7sa1ZSV3KDAtltxgzdqO.hLn0jIu35cYvLY/vtN8vmOv02uQPl8e', 10, 49, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'efittj', 'kR9@jPf1', 'Engracia', 'Fitt', 55705454, 'efittj@dagondesign.com', 'efittj@psu.edu', '2023-10-09 15:05:12', 71, 'e18e854404824f2d3de1ea03c83fc4c6b63f851b3d9396a5e655157821f9b558', '0baef0e8a9b25ba272912dd63b3908d865a94769b7ccf97c7a001c1432a74910', '$2a$04$y2eqMhIgBREJjLpDKM2fj.a433SvWEDx5W1mqvvyWpT/vYlBQJkuu', 2, 22, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'emurfettk', 'cW6}b96C7{W9!', 'Emalee', 'Murfett', 44416289, 'emurfettk@miitbeian.gov.cn', 'emurfettk@skyrock.com', '2024-09-20 17:05:01', 39, 'f03115b01b69bc6a388394834046208505079ff89547f0480f57b9325f428d24', '63dc1e1537dd5453ebf9897017f832aaad72557e62911b08e37c6be242080d6d', '$2a$04$rvNF2CPzsyo3e2guQs3.S.afFaZfIVWHRUUN/Izgj/4E8szKH71MG', 1, 32, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'agottschalkl', 'hM7)8)pG_', 'Augie', 'Gottschalk', 78115514, 'agottschalkl@cbc.ca', 'agottschalkl@liveinternet.ru', '2024-07-31 15:28:52', 68, '46b655be02e40afd7b6d88e70f91626ec564b85fb76905d5d93cd548d4a0f5f3', 'd997a8b8e8a0fe0fe7ae5fbfbfc912d13608a4d54c6f607357aca0e065d51f53', '$2a$04$lUIeW3596ZmhJfI7VwRh1u76gzvuqFVn1cRwGFHaAmFi88zhA1Fze', 7, 43, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bmarom', 'vB1=yEi<@m~_otl', 'Boone', 'Maro', 70110804, 'bmarom@mapy.cz', 'bmarom@umn.edu', '2024-05-30 21:09:51', 73, '423885aa4ee8d7cfbaa8633224de749d2b431ea4226b2b980184bfdb3558f19b', '09c6a552d5a0881c71c39843c21c62717e1b57a4b72a942ebe14762250cd4c29', '$2a$04$YnwCrN04cDVh3.RsFmVDi.xX4jtFAXgAIJPWJE4d44TgSwp.gRtom', 10, 50, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'vmcettigenn', 'iY7&zr(GCKRe', 'Valentina', 'McEttigen', 53547821, 'vmcettigenn@icio.us', 'vmcettigenn@dmoz.org', '2024-04-14 10:01:36', 72, 'bc5fba48c4ec2190470f121dd5cc5cf447cb31265ece7c130ca60176363c4c89', 'c4b1bf5e833396842cc0a415155419e5e729eec8d61271dc2ba6aa8d359efd6d', '$2a$04$cMePHKxImiH9nLvKSo22veSKvBtB1MT5AHuL2rHwV2mtgGlP1jdFy', 6, 31, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'owixono', 'sV5+@9%0t+FV}~W%', 'Odelia', 'Wixon', 41982221, 'owixono@netlog.com', 'owixono@bbc.co.uk', '2024-04-10 00:38:35', 39, '38f23b3391b762381be0617d4294e3e56a4e747a57b456e5a4812c763599aa18', 'aba920eabef8e570d1ab62a65a12c69c654e1a958472ac5b82125bd69a891c30', '$2a$04$XrKnIf0PaYgaOt/8IYCRq.tI.f0Ee1.TYST66kWbHf9pFtMz27ZQG', 8, 15, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'escreasp', 'vM8!vPdS4W/5?!S`', 'Ellissa', 'Screas', 22707468, 'escreasp@deviantart.com', 'escreasp@1und1.de', '2024-07-11 03:48:22', 75, 'efc7c6583ecefb6f66f16199e63aca67aef5013f965349f22307820972472d09', '32fc53c919b390f48ce8717f246b0bcf392d0862261fbbca6a765df61f7eb1d5', '$2a$04$SoeoGSRjDO2I9ecRSar0UOmpT5mhciUU6nwb/mFg7GEQbIqz3RqqS', 2, 48, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'fnelq', 'kE5%@&iPN', 'Forest', 'Nel', 81144533, 'fnelq@techcrunch.com', 'fnelq@google.es', '2024-04-30 08:17:40', 4, '5ae99f0b32c4d8a14a64150e73c166bed8c4a4bf34ac484d44c1baade76f66e6', '8011d216bb37840c79c4bc1accdb9b0fc9b7dd452b88b812097373912655e82b', '$2a$04$8u9GxbMtBk78ZlJmNRuLNeFsd1lEkoUoHns3ayxjZSd0mJ7YfSMri', 8, 10, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'kscarffr', 'zY3/hwCTYSk?b', 'Kerrie', 'Scarff', 18531051, 'kscarffr@icq.com', 'kscarffr@omniture.com', '2023-12-25 03:23:31', 31, 'd10d75e5f284f94c56774fdf81e5ece4b118851b14ec7c024c7216ce5f5db014', '4b700f601da7097d3507b5ee7adff1c03259268045415efd2cbc35ae3979d182', '$2a$04$IMwvc7pkyat0zl.9XsQtluyU5X4788h3NpvmLMGyRmU61tDP3GP7m', 8, 18, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'twrathalls', 'pX2}eRyN6', 'Tildie', 'Wrathall', 7749595, 'twrathalls@networksolutions.com', 'twrathalls@businessweek.com', '2023-12-13 11:30:59', 47, 'b3827fe7572f39614c3aa18f04df638c7d93290cb0b3d68e347116e143536a07', 'bdd3635dd3f40859662f38977f750b7347841deefea8a847fc6f2a6eb0c8ac05', '$2a$04$86tzNiTIhtokURCUFnMmqOpTYWEba8lwHs6INQWKWrxW7ju.gEPSi', 3, 16, 8);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ebraidt', 'pN9#"o8B&p1<8j', 'Emmett', 'Braid', 37631861, 'ebraidt@google.de', 'ebraidt@list-manage.com', '2024-08-04 11:47:22', 35, 'c73211664ec879746c8a949cbe802ceee7077ea07297bdb077d010cf633a4051', '1c09f56950bcfe40470278e20506e9abed51ad793f5b12fd8325fc9a4f720232', '$2a$04$UYzcjD4bLjjlocoO6QkXp.gBdCFQZ5x6h.Lu.CzhcaOPOdkWktPbO', 7, 32, 8);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'aummfreyu', 'tF5!el@9D@N#eIV', 'Ado', 'Ummfrey', 88859806, 'aummfreyu@skype.com', 'aummfreyu@goo.gl', '2023-11-17 21:28:24', 50, 'acf67d75c34f38055948ea588a60540872426a6f5bc3f3aeb516469bee71b0d2', 'e0f062131945fe442d6dc4e1f29e970fc82b73aa6b2e0c484f3afe2626e801ed', '$2a$04$MtsjoDEZTX0XtrrZ4Al2EOFMLZRmfpLvCe9o7oGNVzJtTuln5sKVa', 7, 49, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'rbreedv', 'aM2''b4RD@B', 'Regan', 'Breed', 94054890, 'rbreedv@cloudflare.com', 'rbreedv@imdb.com', '2024-02-12 04:51:35', 61, '60a23c6610ac199b6adfc94076d38b33e3e625bf1fd9a276a6de5f192f4eca69', 'ae30cd84acfef616465f4c7227e546fc69464b2d3f07ba1e53c8d432acacaa12', '$2a$04$xwvTGP0Ymh51fg8A6zmLRuphTP.udOrORBwPoiuHHb2U/twvCmdzu', 8, 38, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'averrillw', 'zZ8%k6RhS', 'Alvis', 'Verrill', 82434577, 'averrillw@virginia.edu', 'averrillw@dropbox.com', '2023-11-18 20:56:45', 71, '78b3cc41df474b550f8d635b7c6cffe9a1855a4d9c685aa853ed209320def20b', 'd0f370ce11bbde98068953aabaa4391e104b1734e1eba319e539bc9ad4b0e329', '$2a$04$HldeI0NCgLFQpnhsldywJ.gQ6kqFi8Xb28s7U6Z/BYUSmiLXBx/Zi', 6, 21, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'igrimditchx', 'tM2_(+6nwv7CrW', 'Isidora', 'Grimditch', 60830814, 'igrimditchx@printfriendly.com', 'igrimditchx@theglobeandmail.com', '2024-08-16 19:08:23', 81, '9067826399df3f98635cd619c000fbec658d72d533b16ef5f1fc8ea83d2a9098', 'bb9ddeadc626c8b4729a0996302456afd1e444754f875d4f2ec1a088e2886070', '$2a$04$WzhTMPYw4cLRFxg0ILOEje2xjq8PloFa6IcLQAIMYkqFVDDTCDg5u', 8, 49, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'gmoulesy', 'pT4(~QYr', 'Greg', 'Moules', 54696641, 'gmoulesy@yale.edu', 'gmoulesy@indiatimes.com', '2024-04-20 23:24:27', 70, 'f7b0b1303db2c83633627dc99be694409916df0c8f3b170768e6dbf9f1d7cbfd', 'fd7c197e8b86154499a7469a017a88e1adddcb5b9252bdce080c6149227651a2', '$2a$04$6Slx4Ux6tWf5kgSrXfT2xueHkBmp./Pt/xK5TAlN8uc1CNyDlvaXe', 8, 45, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'tpetytz', 'pQ1@9k}abn_', 'Tremayne', 'Petyt', 91571339, 'tpetytz@google.ca', 'tpetytz@godaddy.com', '2024-01-14 07:53:25', 26, 'c25d7b8a27920d8464f210a29350a965707cffd85bf4d0e1d45041a7cc09cf0e', '4b5ac3f2725b291b69fb671e0034883d3c3237293ccc652f9148bea9483a8e01', '$2a$04$T4MlKPq/u/2NmoTrHpRGWu5Cn4mY7QyIUDUEL2I89dcQMO0BuemzK', 1, 14, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'wfishlee10', 'iO4,+27pJDk', 'Wilfred', 'Fishlee', 61782677, 'wfishlee10@ehow.com', 'wfishlee10@phoca.cz', '2023-11-19 12:25:19', 61, 'a5dc0bda02fa97aa4aec815eb9bddf948940127d6082f58b27e910dd4508eb39', 'f3a77ff750bef8c20ded4aee97edf67cf9b3f8f0c2828b5b141230c7bfd40a34', '$2a$04$7JXpje.Lk3uZvPOPDMxuxOTjJ/ipTnGjkuTTjuRZW28jNNx8cIUcu', 2, 13, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'wwilleman11', 'gU0|QH>KNYRaJ7$', 'Winfield', 'Willeman', 74603773, 'wwilleman11@edublogs.org', 'wwilleman11@icio.us', '2023-11-09 10:37:48', 2, '3761563c268647cbb9fd3efc6719f99e90220e5614828b08a9791edc373d799d', 'da1452a84c74d406d7cdd34e1cfbc4d652b31becb937e758a627f0aaecf9c1e2', '$2a$04$ib5eoWtpNJfJVkqVfIKMc.unfWdfoyIAQMTtkouxm/9/v6FPH8vr2', 10, 22, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bewence12', 'uF6}kn''"', 'Brittan', 'Ewence', 64914464, 'bewence12@wiley.com', 'bewence12@bloglines.com', '2024-08-16 21:39:01', 24, 'cb5a5c7b7cbc12d5800befe10d947491d64d81819ab8353d90e6c746a019411c', '3ef1ff39c76c16de2c86e4178d81989e139bcc7e211c44f244c56c7969180385', '$2a$04$imHO2Hs.uFxgHDqdDSvPl.aPcgcSSeMflc4jUWaAXs7cosNNPV1RG', 4, 22, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'hforsdike13', 'yG2~MiU%gR&CB', 'Henrie', 'Forsdike', 52008713, 'hforsdike13@google.pl', 'hforsdike13@dedecms.com', '2024-05-17 13:58:00', 33, '27fb1cfade76d1570a7045af5cf0ad78268fa1fa6699105d789cb32b6aa69722', 'fa9a62fbd9bb9e44c70244ba59326dbbaa20a97d2601b887ec949e0a600bc939', '$2a$04$/GapGulx0rOBc3i0VPO3luw.D8YkSG/3Wow7MhAOPR.iu9IuUN0r2', 10, 1, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'fbattaille14', 'dL0"0\&''L', 'Flint', 'Battaille', 7485998, 'fbattaille14@forbes.com', 'fbattaille14@sciencedirect.com', '2024-08-25 15:45:50', 88, 'd591d511582ce816a6ed847779fffe3bce4070fc8a7640730013f7b71440539c', '83823d837eb2da856d2cf31714232cfcab0fe2b329d2d9ad4c7a7655b6a9c02c', '$2a$04$JTUAsVIVf8wytgzBBONXFO5s.YXgOleunYnLDvLwvT7gZ2bgdZrCK', 1, 37, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ethairs15', 'mP6@KSCz|73su!M', 'Electra', 'Thairs', 78697385, 'ethairs15@altervista.org', 'ethairs15@yale.edu', '2023-10-30 06:43:21', 63, '5d6ee7cd52ce5edfbf925da06acef7b680b7a91c2a66841dac337bbe069e4338', '2dc6b601d982ea7b3d9dd91fecd871880daf2895acfeec510ed0694839b9551c', '$2a$04$WklOZfcPXgo3fksS7QW/Ju8vTmnVfDXNa8fhutiDdMMX3Pf41RHiC', 4, 11, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'vbaress16', 'pK5\$a}/Q*Xn8', 'Violet', 'Baress', 80986613, 'vbaress16@ucoz.ru', 'vbaress16@hugedomains.com', '2023-12-16 02:38:11', 83, '7e3be2bca2ab337155cc947308f14a980f5aa5f98d03ef4804dd4113b4362e29', '57a62f6a5a00ce02c524c67732df2cda4646a04c6dc712aeb9cd9dcdf49e0bf2', '$2a$04$ognvFuT8vh3GXl8W3gNDg.xAqiY1SHbgEyY/fPMeVqt3pHmD6hipm', 2, 5, 8);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'gbenzies17', 'fD4>TW$\#', 'Geordie', 'Benzies', 3666560, 'gbenzies17@booking.com', 'gbenzies17@flickr.com', '2024-07-03 19:38:13', 83, 'e61004bda90490cfefa067083a2c0facbd2d03a52f2094877d34df3d40d87d7b', '66d17149b83f6c49e4a6ddf9fd31c241852c62357296442918d729d2b0c3881a', '$2a$04$E5/8x/LEmitadKaYYrDt8.9IOZSJHMS/g7T.oQH40jXEoMo29QSCm', 2, 38, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'xgrzegorek18', 'bU9_w''$mSY`', 'Xerxes', 'Grzegorek', 87567660, 'xgrzegorek18@weebly.com', 'xgrzegorek18@wiley.com', '2023-10-12 03:00:35', 85, '2f9d47f5f9bac2a37909f38bc4e88b0975ef0706d1e1f7d38d730ac9383b455d', '12a4dfdfaa00842846e84076a193315deb6ef0ded733a8c636a89ad0c603decd', '$2a$04$WurZfmqyaoMBbsvHF6CU9um8dLH932srHL.DnbQk.YexsXXAiljOq', 4, 38, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'dbreeder19', 'qS3>~E@%7x', 'Dory', 'Breeder', 31588572, 'dbreeder19@hexun.com', 'dbreeder19@statcounter.com', '2024-03-01 07:53:56', 11, 'e15843cd621f9609e65a8bc1f2e877e798f8185574d433c9067aaac2d3ac5f52', 'd107137926514380308a3d1e48dfae8096a520122b1fd7e45fc000266b433a76', '$2a$04$US0qOqRB1DActK5DxAh6S.WGI7tfRfaCbuJWdkjliY0SE550B8oGK', 3, 1, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ablinerman1a', 'jZ1"NINI', 'Amerigo', 'Blinerman', 66299867, 'ablinerman1a@geocities.com', 'ablinerman1a@about.com', '2024-08-09 15:47:15', 6, 'df238de66584021feb2d67b7a1e36ba1be1f1180104583200683af0d0315af98', '2523458ed7be655be97b222fa20febe6a5ec57f563c5012349af8dedf6119543', '$2a$04$REQdGDlWtpeF/7dnbvmHHO/rbp/F9UJZYHpsvooIlRd.7cE.5Bn.G', 10, 46, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'horis1b', 'fL5%*GCkUkpMa', 'Haskel', 'Oris', 82981860, 'horis1b@sun.com', 'horis1b@youku.com', '2024-06-05 17:52:27', 56, '818d1d83188769b650c4f076879454c0776d8f5337a863ecc64baa6e86f8dcd0', 'c60a9587bcab200bb421ed7dfb4b2d5d9389469df9bd7aff8fc7a207b1d004a9', '$2a$04$cNvD9Iw8eva0WNtD0lh/hOycBaUaU7U6uacC5I2zdKd5yaaUqVRxO', 2, 40, 1);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'hmingo1c', 'nQ1>L4Xm3$_VCb', 'Humfrid', 'Mingo', 84740193, 'hmingo1c@etsy.com', 'hmingo1c@4shared.com', '2024-05-21 00:46:38', 23, 'b300d94c7d3b2a353fdc8a8eefc3186f647bc5ffc301614c51b5a29cd7f6c858', '9acb1033dddaa41dee5b503520e75f34f3d93d66bc1e6d50fed3d62c0b0e1405', '$2a$04$T0XWPoxsaTvh0uorrRFdAuWExNQbHOMASs2NheRkpQd0bGFKcba.2', 10, 32, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bmcdonough1d', 'jO4/.OP8W', 'Barbi', 'McDonough', 62496298, 'bmcdonough1d@booking.com', 'bmcdonough1d@ycombinator.com', '2024-07-05 11:05:07', 3, 'ffc8aab63cc82850328a658b436788150145ed8ceb281c3f16840f253ae54a15', '8d1058b0a3dae44dbfd4e28a05a74a6b06b414533ff4a82f592cd19c68d697f9', '$2a$04$aAi8DIdd8HhROUe1fIykMeeJqNIhliHRGLy2BK05mvlnR7s4N0TRW', 5, 5, 1);

-- select * from usuario;

-- Tabla personal
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Olivero', 'Bruin', 17821251, 'Doctora', 'logistica', 'obruin0@tripod.com', 'obruin0@intel.com', 20444);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Arlee', 'Camis', 48180150, 'Arquitecta', 'cotizador', 'acamis1@mapquest.com', 'acamis1@gov.uk', 37391);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Hasheem', 'Casini', 78770186, 'Licenciado', 'calculista', 'hcasini2@telegraph.co.uk', 'hcasini2@deliciousdays.com', 5354);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Claire', 'Edgcombe', 87292612, 'Magister', 'calculista', 'cedgcombe3@microsoft.com', 'cedgcombe3@domainmarket.com', 5187);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Ambrosius', 'Kilfoyle', 99683288, 'Ingeniero', 'cotizador', 'akilfoyle4@cisco.com', 'akilfoyle4@miitbeian.gov.cn', 23443);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Prisca', 'Farries', 27278322, 'Técnico', 'compras', 'pfarries5@qq.com', 'pfarries5@digg.com', 48079);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Tommie', 'Roll', 92434271, 'Técnica', 'operador', 'troll6@yale.edu', 'troll6@github.io', 25891);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Rodrick', 'Ruddock', 6533637, 'Ingeniera', 'sistemas', 'rruddock7@oaic.gov.au', 'rruddock7@ebay.com', 25019);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Alley', 'Coad', 95011895, 'Licenciado', 'calculista', 'acoad8@freewebs.com', 'acoad8@tripod.com', 42334);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Michele', 'Sundin', 62151851, 'Licenciado', 'certificante', 'msundin9@godaddy.com', 'msundin9@upenn.edu', 14907);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Adolpho', 'Grundy', 59642409, 'Doctor', 'certificante', 'agrundya@home.pl', 'agrundya@cnbc.com', 21129);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Willetta', 'Wyndham', 77415656, 'Técnico', 'cotizador', 'wwyndhamb@mashable.com', 'wwyndhamb@fda.gov', 38371);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Gilbert', 'Hamnett', 84152806, 'Contador Público', 'administrador', 'ghamnettc@diigo.com', 'ghamnettc@csmonitor.com', 9977);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Jens', 'Munks', 80259952, 'Técnico', 'operador', 'jmunksd@usgs.gov', 'jmunksd@japanpost.jp', 19753);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Valentina', 'Twiddy', 52823424, 'Ingeniera', 'compras', 'vtwiddye@github.com', 'vtwiddye@go.com', 12821);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'August', 'Baiyle', 57746540, 'Técnica', 'sistemas', 'abaiylef@newyorker.com', 'abaiylef@gravatar.com', 28234);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Bea', 'Fittall', 45546596, 'Licenciada', 'ayudante', 'bfittallg@myspace.com', 'bfittallg@nih.gov', 33996);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Jacki', 'Parmer', 67385209, 'Ingeniera', 'calculista', 'jparmerh@ox.ac.uk', 'jparmerh@facebook.com', 12948);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Claudianus', 'Gonoude', 39552215, 'Contadora Pública', 'logistica', 'cgonoudei@tripod.com', 'cgonoudei@ow.ly', 12787);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Bryana', 'Tofano', 34849060, 'Doctora', 'ayudante', 'btofanoj@timesonline.co.uk', 'btofanoj@typepad.com', 24536);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Irina', 'Lumbers', 99745348, 'Técnico', 'sistemas', 'ilumbersk@lulu.com', 'ilumbersk@baidu.com', 24377);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Lu', 'Christauffour', 67298079, 'Licenciada', 'administrador', 'lchristauffourl@cpanel.net', 'lchristauffourl@feedburner.com', 11973);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Zulema', 'Heams', 72173037, 'Doctor', 'operador', 'zheamsm@etsy.com', 'zheamsm@timesonline.co.uk', 35210);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Kimberlee', 'McCuis', 14524575, 'Contadora Pública', 'compras', 'kmccuisn@sciencedaily.com', 'kmccuisn@cbslocal.com', 22896);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Pavlov', 'Gibbeson', 96055100, 'Técnico', 'logistica', 'pgibbesono@biglobe.ne.jp', 'pgibbesono@smh.com.au', 8605);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Meagan', 'Kempshall', 87100014, 'Arquitecta', 'ayudante', 'mkempshallp@ovh.net', 'mkempshallp@walmart.com', 7891);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Micki', 'Sousa', 4757577, 'Arquitecta', 'operador', 'msousaq@opera.com', 'msousaq@yellowbook.com', 36373);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Claudetta', 'Exley', 33428272, 'Contadora Pública', 'compras', 'cexleyr@howstuffworks.com', 'cexleyr@yahoo.com', 17714);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Emmy', 'Merriment', 41285346, 'Doctora', 'compras', 'emerriments@webnode.com', 'emerriments@twitpic.com', 18776);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Mile', 'Leaves', 94944722, 'Ingeniero', 'operador', 'mleavest@goo.ne.jp', 'mleavest@homestead.com', 38241);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Rhodia', 'Littley', 99986629, 'Contadora Pública', 'administrador', 'rlittleyu@sfgate.com', 'rlittleyu@paginegialle.it', 23912);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Renaud', 'Duns', 69226464, 'Contador Público', 'ayudante', 'rdunsv@altervista.org', 'rdunsv@mlb.com', 10914);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dionne', 'Philliphs', 81318136, 'Licenciado', 'ayudante', 'dphilliphsw@ucla.edu', 'dphilliphsw@discovery.com', 7421);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dulcine', 'Durham', 24847353, 'Ingeniero', 'certificante', 'ddurhamx@4shared.com', 'ddurhamx@hhs.gov', 22235);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Jarrod', 'Gibby', 85211228, 'Ingeniera', 'cotizador', 'jgibbyy@issuu.com', 'jgibbyy@mozilla.org', 45027);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Catie', 'Axtens', 68257632, 'Magister', 'compras', 'caxtensz@nsw.gov.au', 'caxtensz@nsw.gov.au', 17694);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Hilary', 'Segoe', 58313558, 'Licenciada', 'ayudante', 'hsegoe10@topsy.com', 'hsegoe10@over-blog.com', 35700);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dewain', 'Lawday', 32449772, 'Contador Público', 'certificante', 'dlawday11@independent.co.uk', 'dlawday11@ibm.com', 23431);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dulci', 'Fouldes', 45209276, 'Técnica', 'certificante', 'dfouldes12@myspace.com', 'dfouldes12@biblegateway.com', 28099);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dolli', 'Jickells', 72790083, 'Ingeniero', 'certificante', 'djickells13@hc360.com', 'djickells13@last.fm', 27838);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Farly', 'Earengey', 5578300, 'Técnica', 'administrador', 'fearengey14@dyndns.org', 'fearengey14@twitpic.com', 8188);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Putnem', 'Dayborne', 58502566, 'Ingeniera', 'sistemas', 'pdayborne15@answers.com', 'pdayborne15@163.com', 29348);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Niles', 'Speechly', 26531826, 'Doctora', 'calculista', 'nspeechly16@squarespace.com', 'nspeechly16@livejournal.com', 5999);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Irvine', 'Dreossi', 8819444, 'Técnico', 'calculista', 'idreossi17@indiatimes.com', 'idreossi17@theatlantic.com', 19314);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Elnora', 'Poundsford', 22247391, 'Ingeniero', 'ayudante', 'epoundsford18@php.net', 'epoundsford18@oracle.com', 5022);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Fee', 'McGuire', 80453357, 'Ingeniera', 'administrador', 'fmcguire19@berkeley.edu', 'fmcguire19@blogs.com', 39982);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Bondon', 'Buckham', 22054155, 'Ingeniera', 'logistica', 'bbuckham1a@stanford.edu', 'bbuckham1a@foxnews.com', 39109);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Aron', 'McAviy', 94805432, 'Doctor', 'sistemas', 'amcaviy1b@plala.or.jp', 'amcaviy1b@who.int', 23882);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Ophelie', 'Strafen', 37279498, 'Licenciado', 'sistemas', 'ostrafen1c@pinterest.com', 'ostrafen1c@go.com', 45500);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Abigael', 'Kensett', 32410812, 'Técnica', 'compras', 'akensett1d@vk.com', 'akensett1d@nbcnews.com', 28979);

-- select * from personal;

-- Tabla detalle_cotizacion
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 'diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'feugiat non pretium quis lectus suspendisse potenti in eleifend quam');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 'ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam tristique tortor eu pede');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'vehicula consequat morbi a ipsum integer a nibh in quis justo');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 'et ultrices posuere cubilia curae nulla dapibus dolor vel est');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.', 'vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris');

-- select * from detalle_cotizacion;

-- Tabla cotizacion
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 49, 1, 4256, 1359, 557377, 'id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 95, 40, 39513, 1041, 657000, 'ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 52, 2, 19681, 1047, 551577, 'sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 83, 2, 31303, 1454, 682202, 'tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 38, 43, 38806, 1148, 227832, 'vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 45, 36, 26065, 1182, 460176, 'ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 84, 26, 19926, 1259, 400688, 'elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 5, 28, 47686, 1155, 544951, 'congue eget semper rutrum nulla nunc purus phasellus in felis');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 85, 3, 46360, 1151, 304881, 'aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 8, 40, 12071, 1324, 717539, 'mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 46, 37, 36881, 1483, 935345, 'consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 19, 27, 46038, 1109, 186709, 'magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 70, 2, 33486, 1229, 523099, 'a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 8, 38, 9843, 1367, 66375, 'suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 90, 15, 41595, 1053, 284770, 'sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 9, 10, 40663, 1199, 681805, 'adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis a');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 58, 45, 35553, 1038, 844509, 'sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 27, 23, 29131, 1394, 172726, 'augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 1, 50, 26973, 1286, 816133, 'eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 69, 34, 13627, 1069, 429270, 'ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 76, 38, 18676, 1389, 329844, 'blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 22, 8, 39641, 1056, 507441, 'dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 46, 50, 4517, 1436, 471831, 'ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 48, 39, 12232, 1131, 540832, 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 76, 28, 29305, 1307, 922526, 'rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 21, 48, 4297, 1286, 595617, 'nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 8, 25, 18782, 1300, 146313, 'vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 1, 50, 44346, 1076, 692181, 'nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 84, 50, 49981, 1223, 478051, 'elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 28, 26, 26329, 1339, 847543, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 22, 32, 47623, 1487, 281121, 'eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 9, 8, 11596, 1029, 41062, 'suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 54, 42, 769, 1445, 109915, 'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 83, 5, 20558, 1215, 246202, 'neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 93, 35, 32100, 1481, 31457, 'turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 18, 46, 11903, 1436, 894587, 'non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 71, 35, 30757, 1462, 332153, 'sed tristique in tempus sit amet sem fusce consequat nulla');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 74, 50, 26915, 1458, 555873, 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 26, 42, 32791, 1118, 244706, 'nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 6, 49, 38557, 1485, 849111, 'consequat nulla nisl nunc nisl duis bibendum felis sed interdum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 43, 25, 19434, 1317, 839305, 'habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 23, 43, 33692, 1088, 32998, 'ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 59, 7, 4552, 1271, 391123, 'vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 56, 27, 18835, 1347, 67380, 'habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 69, 7, 40095, 1293, 483592, 'lobortis est phasellus sit amet erat nulla tempus vivamus in felis');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 58, 29, 38356, 1096, 129589, 'sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 43, 41, 31318, 1390, 184098, 'quam sapien varius ut blandit non interdum in ante vestibulum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 56, 24, 28431, 1068, 858758, 'in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 91, 37, 41423, 1181, 652235, 'morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 96, 8, 30876, 1120, 664529, 'quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque');

-- select * from cotizacion;

-- Tabla presupuesto
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 8, 22, 10, '2024-09-19 17:16:17', 86, 'cheque', 44, 'vestibulum quam sapien varius ut blandit non interdum in ante vestibulum', 'https://i2i.jp/in/lacus/curabitur/at/ipsum/ac.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 15, 31, 22, '2024-07-09 04:58:32', 94, 'tarjeta', 60, 'donec posuere metus vitae ipsum aliquam non mauris morbi non lectus', 'https://pen.io/pede/morbi/porttitor.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 50, 21, 9, '2024-09-10 09:02:01', 8, 'transferencia', 38, 'turpis enim blandit mi in porttitor pede justo eu massa donec', 'http://cloudflare.com/erat/fermentum.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 12, 40, '2024-03-30 23:32:56', 99, 'cheque', 33, 'ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui', 'https://exblog.jp/pede.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 2, 9, 6, '2023-10-22 00:48:47', 53, 'cheque', 24, 'sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et', 'https://cam.ac.uk/erat.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 16, 41, 41, '2023-10-29 14:52:56', 99, 'cheque', 40, 'non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus', 'http://usatoday.com/aliquet/at/feugiat/non/pretium/quis/lectus.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 1, 25, 43, '2024-02-16 13:19:57', 54, 'tarjeta', 1, 'pede justo lacinia eget tincidunt eget tempus vel pede morbi', 'http://washington.edu/iaculis/diam/erat.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 6, 50, 35, '2024-02-21 01:26:33', 41, 'transferencia', 84, 'quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras', 'https://pbs.org/primis/in.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 41, 50, 27, '2024-08-25 03:09:08', 16, 'tarjeta', 47, 'eu mi nulla ac enim in tempor turpis nec euismod', 'http://hugedomains.com/porttitor/lacus/at.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 13, 47, 20, '2023-11-30 00:08:26', 25, 'cheque', 11, 'amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut', 'http://ucoz.com/tempus/semper/est/quam/pharetra/magna/ac.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 1, 31, 44, '2024-08-04 00:28:07', 71, 'cheque', 26, 'nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit', 'http://behance.net/quam/pede.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 45, 24, 28, '2023-11-17 01:43:42', 77, 'cheque', 29, 'dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id', 'https://jigsy.com/sapien/iaculis/congue/vivamus.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 24, 10, 5, '2024-05-01 09:09:43', 91, 'tarjeta', 35, 'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat', 'http://huffingtonpost.com/arcu/libero.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 50, 22, 38, '2024-03-24 18:21:51', 24, 'tarjeta', 34, 'vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 'http://symantec.com/vulputate.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 39, 32, 35, '2023-10-12 20:58:33', 78, 'cheque', 2, 'maecenas leo odio condimentum id luctus nec molestie sed justo', 'https://wiley.com/etiam/pretium/iaculis/justo/in/hac.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 48, 30, 18, '2024-02-19 17:03:39', 25, 'transferencia', 94, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam', 'http://si.edu/mattis/odio/donec/vitae.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 32, 25, 32, '2024-09-19 19:32:05', 66, 'tarjeta', 41, 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet', 'http://freewebs.com/adipiscing/elit/proin/risus/praesent/lectus/vestibulum.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 28, 30, 4, '2023-11-21 12:08:00', 78, 'cheque', 32, 'nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros', 'http://huffingtonpost.com/donec/quis/orci/eget/orci.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 20, 31, 45, '2024-09-27 00:25:59', 67, 'transferencia', 24, 'a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus', 'https://bigcartel.com/suscipit/ligula/in/lacus.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 25, 47, 6, '2024-07-04 19:01:24', 55, 'tarjeta', 46, 'dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula', 'http://istockphoto.com/velit/donec/diam.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 8, 45, 48, '2024-04-03 11:11:53', 34, 'transferencia', 55, 'convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in', 'http://elegantthemes.com/sapien/in.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 26, 21, '2024-07-12 19:03:13', 60, 'cheque', 28, 'vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi', 'http://cbslocal.com/quisque/arcu/libero/rutrum/ac/lobortis.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 27, 10, 32, '2024-03-29 21:49:04', 85, 'cheque', 82, 'vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et', 'https://symantec.com/auctor/gravida/sem/praesent/id/massa/id.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 20, 29, 30, '2024-01-24 12:39:50', 64, 'cheque', 10, 'dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet', 'https://msn.com/sem/mauris.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 11, 48, 48, '2024-06-22 10:41:34', 15, 'tarjeta', 52, 'tincidunt lacus at velit vivamus vel nulla eget eros elementum', 'https://eepurl.com/sapien/iaculis.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 10, 32, 29, '2024-08-17 10:28:01', 85, 'cheque', 88, 'congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus', 'http://who.int/quis/justo.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 47, 44, 9, '2024-09-20 07:19:29', 88, 'tarjeta', 5, 'quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu', 'http://over-blog.com/volutpat/eleifend/donec.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 8, 30, 23, '2024-08-21 08:56:56', 25, 'cheque', 100, 'lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue', 'http://wufoo.com/egestas/metus/aenean/fermentum.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 26, 31, 20, '2024-07-08 01:10:28', 51, 'cheque', 26, 'rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel', 'http://theguardian.com/faucibus/orci/luctus/et/ultrices/posuere/cubilia.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 4, 22, '2024-07-16 03:32:29', 44, 'transferencia', 55, 'massa donec dapibus duis at velit eu est congue elementum in hac', 'https://reddit.com/nulla/ut/erat/id/mauris.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 1, 1, 1, '2024-08-02 16:22:50', 100, 'cheque', 72, 'ante ipsum primis in faucibus orci luctus et ultrices posuere', 'http://cnbc.com/aliquam/convallis/nunc/proin/at/turpis.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 17, 50, 21, '2024-08-31 13:08:30', 90, 'tarjeta', 39, 'ligula vehicula consequat morbi a ipsum integer a nibh in quis', 'https://t.co/posuere/metus/vitae/ipsum/aliquam/non/mauris.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 43, 48, 8, '2024-02-27 14:13:14', 82, 'transferencia', 29, 'tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis', 'http://liveinternet.ru/viverra/dapibus/nulla/suscipit.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 13, 8, 36, '2024-04-22 09:17:52', 93, 'cheque', 58, 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit', 'http://lulu.com/sapien/sapien/non/mi.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 3, 39, 7, '2024-01-28 10:10:58', 21, 'cheque', 52, 'sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut', 'http://admin.ch/risus.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 11, 34, 40, '2024-08-16 06:12:57', 78, 'cheque', 56, 'tempus semper est quam pharetra magna ac consequat metus sapien', 'https://gnu.org/integer/ac/neque/duis/bibendum/morbi/non.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 10, 14, '2024-08-17 14:20:01', 65, 'cheque', 51, 'facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus', 'https://engadget.com/elementum/nullam.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 45, 32, 45, '2024-08-17 08:48:53', 11, 'transferencia', 28, 'mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus', 'http://gizmodo.com/aliquam/non/mauris.json');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 35, 14, 13, '2024-03-29 03:07:58', 31, 'cheque', 97, 'convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar', 'https://wordpress.com/erat/tortor/sollicitudin/mi/sit/amet.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 18, 35, 26, '2024-07-25 15:27:06', 37, 'transferencia', 29, 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis', 'https://google.cn/quam/sollicitudin/vitae/consectetuer.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 32, 49, 7, '2023-12-03 03:01:48', 54, 'transferencia', 37, 'interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien', 'https://typepad.com/vestibulum/ante/ipsum/primis/in/faucibus.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 31, 39, 45, '2024-03-31 02:17:11', 15, 'tarjeta', 14, 'est et tempus semper est quam pharetra magna ac consequat metus', 'https://ucoz.ru/adipiscing/elit/proin/interdum.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 46, 35, 4, '2023-10-04 19:20:00', 58, 'cheque', 70, 'scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor', 'http://yellowpages.com/amet/nunc/viverra/dapibus/nulla.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 30, 14, 11, '2024-01-06 17:45:59', 62, 'tarjeta', 89, 'integer a nibh in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo', 'http://dyndns.org/ultrices.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 15, 45, 1, '2024-05-22 09:45:26', 57, 'transferencia', 95, 'pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in', 'https://homestead.com/leo/odio/condimentum.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 36, 27, 17, '2024-03-31 05:16:22', 31, 'transferencia', 83, 'lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat', 'http://google.com.br/volutpat/eleifend/donec/ut/dolor.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 41, 29, 34, '2023-12-09 02:01:16', 8, 'transferencia', 75, 'ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at', 'http://github.io/non/ligula/pellentesque/ultrices/phasellus/id.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 47, 12, 19, '2023-10-05 04:30:08', 9, 'cheque', 72, 'maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida', 'https://msn.com/quisque/erat/eros/viverra/eget.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 7, 42, 47, '2024-10-01 17:34:52', 92, 'tarjeta', 69, 'ac leo pellentesque ultrices mattis odio donec vitae nisi nam', 'https://paginegialle.it/sed/magna/at/nunc/commodo.json');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 26, 41, '2023-12-31 17:52:00', 9, 'cheque', 69, 'libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum', 'http://un.org/donec/odio/justo/sollicitudin/ut.jpg');

-- select * from presupuesto;

-- Tabla presupuesto_cotizado
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 32, 16);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 3);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 10, 23);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 22, 24);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 5, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 33, 12);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 49, 21);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 29, 16);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 31, 42);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 4, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 38, 43);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 22, 2);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 20, 13);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 24, 17);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 27, 20);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 36, 46);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 1, 9);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 34, 9);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 18, 44);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 49, 10);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 46, 26);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 49);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 11, 6);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 5, 42);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 44);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 25, 38);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 24, 15);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 27);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 35, 44);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 32, 27);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 42, 12);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 38);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 50, 9);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 16);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 28, 10);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 25, 22);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 2, 39);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 17);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 33, 30);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 24, 31);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 5, 38);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 2, 26);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 12);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 6, 31);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 36, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 28, 24);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 45, 18);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 44, 36);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 1, 13);

-- select * from presupuesto_cotizado;

-- Tabla remito_in
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 16, '2024-03-09 13:21:56', 27, 44, 'non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 16, '2024-03-30 17:26:21', 22, 35, 'est donec odio justo sollicitudin ut suscipit a feugiat et');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 18, '2023-11-09 17:53:53', 16, 19, 'ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 9, '2024-05-25 03:53:46', 30, 21, 'odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 39, '2024-08-09 18:52:47', 23, 21, 'amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 38, '2024-01-04 11:28:23', 34, 35, 'sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 5, '2024-08-11 06:43:03', 4, 8, 'lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 24, '2024-01-26 00:23:07', 19, 49, 'diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 36, '2024-07-07 15:16:33', 19, 8, 'lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 28, '2024-06-22 07:59:52', 16, 31, 'curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 31, '2023-10-22 07:48:43', 37, 13, 'in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 21, '2024-01-23 07:50:39', 44, 25, 'accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 12, '2024-07-28 19:01:31', 37, 19, 'velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 3, '2024-02-03 07:11:28', 9, 29, 'eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 6, '2024-09-28 23:26:07', 19, 16, 'pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 41, '2024-09-20 23:23:34', 10, 29, 'sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 13, '2023-12-18 16:23:34', 10, 44, 'ut blandit non interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et ultrices');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 18, '2024-05-03 09:13:19', 49, 29, 'platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 19, '2024-06-17 09:42:00', 27, 39, 'mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 43, '2024-06-17 01:27:54', 50, 29, 'erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 17, '2024-05-16 07:09:28', 34, 3, 'id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 31, '2024-04-09 02:24:59', 3, 38, 'tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 38, '2024-07-03 19:07:07', 28, 42, 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 16, '2024-01-01 12:55:51', 29, 37, 'sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 33, '2024-02-17 16:17:43', 47, 6, 'orci eget orci vehicula condimentum curabitur in libero ut massa volutpat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 40, '2023-12-01 14:51:52', 38, 30, 'turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 40, '2024-09-26 20:31:06', 46, 27, 'cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 9, '2024-09-25 21:23:45', 11, 18, 'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 43, '2023-12-11 15:40:39', 47, 38, 'nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 46, '2024-01-03 20:27:13', 20, 17, 'vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 29, '2023-12-01 05:48:32', 9, 50, 'venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 6, '2023-10-26 05:33:16', 49, 32, 'aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 20, '2024-03-30 21:32:48', 38, 15, 'nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 12, '2024-06-12 23:26:25', 2, 44, 'amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 11, '2024-06-01 06:44:09', 12, 31, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 29, '2024-03-27 09:54:12', 43, 23, 'ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 36, '2024-05-05 17:31:12', 13, 43, 'posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 14, '2024-04-06 04:07:50', 21, 30, 'nulla nunc purus phasellus in felis donec semper sapien a libero nam dui proin leo odio porttitor');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 3, '2023-12-24 02:00:33', 24, 10, 'odio donec vitae nisi nam ultrices libero non mattis pulvinar');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 47, '2024-08-26 22:37:25', 5, 43, 'montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 41, '2024-05-23 10:17:15', 33, 31, 'in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 42, '2024-03-20 13:44:25', 7, 11, 'in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 3, '2023-11-07 08:49:43', 31, 19, 'donec ut dolor morbi vel lectus in quam fringilla rhoncus');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 9, '2024-04-09 05:49:52', 21, 14, 'augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 13, '2024-05-05 06:32:07', 20, 40, 'ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae donec');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 44, '2024-04-29 10:31:16', 21, 47, 'in congue etiam justo etiam pretium iaculis justo in hac habitasse');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 45, '2023-10-29 01:54:29', 11, 34, 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 25, '2024-02-27 01:38:42', 12, 34, 'lobortis vel dapibus at diam nam tristique tortor eu pede');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 35, '2024-02-27 04:32:16', 34, 3, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 39, '2023-11-04 03:42:54', 3, 45, 'diam erat fermentum justo nec condimentum neque sapien placerat ante nulla');

-- select * from remito_in;

-- Tabla tipo_elemento
INSERT INTO tipo_elemento (tipo_elemento) VALUES
('manguera'),
('manómetro'),
('bomba'),
('recipiente'),
('molinete');

-- select * from tipo_elemento;

-- Tabla protocolo
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar', 1007, 218, 8305, 33, 288, 489, 383, 747, 67, 983, '712-710-0846', 'consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'https://usatoday.com/mauris/enim/leo/rhoncus.png', 'CO-CAQ', 7, '2024-05-13 22:55:51');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla', 1501, 792, 5213, 58, 200, 499, 677, 642, 1, 376, '937-141-5630', 'in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'http://yolasite.com/sit/amet/consectetuer/adipiscing/elit.xml', 'BR-DF', 6, '2024-09-09 14:30:06');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst', 1672, 138, 4394, 7, 271, 970, 660, 1000, 41, 674, '773-228-4645', 'primis in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://pagesperso-orange.fr/pede/ac/diam/cras/pellentesque.jsp', 'SS-14', 3, '2024-04-01 12:41:17');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa', 1176, 836, 4090, 58, 330, 221, 360, 990, 7, 778, '227-396-1234', 'luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://blogs.com/urna.js', 'US-AZ', 8, '2024-01-13 23:53:51');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'purus phasellus in felis donec semper sapien a libero nam dui proin leo odio porttitor id consequat in', 1975, 649, 4595, 7, 148, 181, 183, 253, 90, 1790, '490-790-7611', 'luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida nisi at', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'http://hatena.ne.jp/a.jpg', 'PK-PB', 9, '2023-10-05 00:09:42');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'sed augue aliquam erat volutpat in congue etiam justo etiam', 1996, 120, 9522, 10, 151, 770, 790, 93, 72, 851, '500-130-1732', 'varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 'http://cbsnews.com/nulla/elit/ac/nulla/sed.json', 'NZ-GIS', 10, '2023-10-26 15:12:19');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam tristique', 1262, 282, 4706, 50, 235, 429, 926, 485, 92, 1414, '622-489-9728', 'blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'http://istockphoto.com/varius/ut/blandit/non/interdum.png', 'LS-C', 6, '2023-11-08 12:44:45');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper', 1389, 66, 5464, 9, 139, 733, 314, 425, 48, 1691, '378-164-3823', 'mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 'https://addtoany.com/iaculis/diam/erat.json', 'AU-QLD', 7, '2023-12-23 13:21:20');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'proin eu mi nulla ac enim in tempor turpis nec', 1768, 628, 9221, 27, 203, 960, 799, 978, 0, 21, '492-408-2885', 'felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://goo.gl/orci/luctus/et.js', 'LR-LO', 1, '2024-02-24 09:48:28');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'aliquam convallis nunc proin at turpis a pede posuere nonummy integer non velit donec diam neque', 1445, 447, 4309, 27, 132, 293, 342, 64, 34, 1768, '115-112-9150', 'fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'http://apple.com/semper/sapien/a/libero.jpg', 'SZ-LU', 4, '2024-06-29 19:56:35');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis', 1052, 198, 2932, 58, 315, 610, 664, 130, 1, 202, '870-249-6636', 'adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'http://vkontakte.ru/a/suscipit/nulla/elit/ac/nulla.html', 'CA-MB', 8, '2024-05-22 21:43:15');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque', 1248, 834, 3400, 52, 148, 366, 386, 301, 6, 1975, '172-378-0635', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante', 'In congue. Etiam justo. Etiam pretium iaculis justo.', 'https://skyrock.com/auctor/sed/tristique/in/tempus/sit/amet.js', 'US-MN', 4, '2023-10-16 16:29:21');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'rutrum at lorem integer tincidunt ante vel ipsum praesent blandit', 1369, 967, 7817, 33, 331, 688, 896, 414, 66, 1331, '605-270-0015', 'in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://huffingtonpost.com/in/est/risus/auctor/sed/tristique.png', 'CA-ON', 9, '2024-06-21 00:46:48');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio', 1439, 29, 4890, 54, 260, 413, 658, 745, 70, 857, '169-443-0967', 'dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://illinois.edu/suspendisse.xml', 'ZA-MP', 1, '2024-07-08 11:03:54');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam', 1037, 150, 5257, 38, 203, 605, 805, 489, 15, 1790, '315-713-7755', 'rutrum nulla nunc purus phasellus in felis donec semper sapien a', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 'https://state.tx.us/condimentum/id.aspx', 'FR-E', 2, '2024-04-12 14:31:52');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum', 1158, 208, 4622, 59, 228, 430, 909, 502, 18, 434, '216-462-7900', 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'http://php.net/turpis/elementum/ligula/vehicula.json', 'US-AZ', 5, '2023-11-30 08:28:56');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam', 1711, 49, 4015, 5, 320, 779, 757, 72, 54, 1167, '576-168-4066', 'in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'http://cornell.edu/elementum.xml', 'CA-MB', 3, '2024-05-10 13:49:47');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet', 1141, 902, 6826, 56, 287, 628, 451, 747, 50, 1628, '459-253-0262', 'at turpis a pede posuere nonummy integer non velit donec diam', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 'http://cornell.edu/ac/est.js', 'ZM-08', 9, '2023-12-09 14:18:56');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse', 1349, 167, 6201, 46, 172, 560, 573, 846, 25, 987, '745-224-2510', 'lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'http://oracle.com/mattis/egestas/metus/aenean/fermentum.jsp', 'US-MO', 3, '2024-05-31 15:03:13');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia', 1285, 947, 7633, 34, 233, 141, 748, 282, 77, 968, '984-247-1534', 'in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://cmu.edu/nisl/aenean.js', 'US-MO', 7, '2023-12-11 17:48:38');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'est lacinia nisi venenatis tristique fusce congue diam id ornare', 1418, 386, 5830, 22, 356, 266, 700, 923, 75, 53, '220-553-0529', 'eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'http://1688.com/dui/maecenas/tristique.aspx', 'SE-AB', 9, '2023-12-14 22:00:39');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu', 1173, 253, 8147, 37, 85, 689, 847, 42, 8, 1206, '123-683-7544', 'rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://tamu.edu/at/velit/vivamus/vel/nulla.js', 'NO-18', 4, '2024-09-04 07:56:12');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere', 1201, 111, 8502, 59, 128, 387, 626, 850, 0, 1044, '328-990-9597', 'id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://hugedomains.com/vitae/nisi/nam.xml', 'TR-35', 4, '2023-10-15 20:51:57');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'vel ipsum praesent blandit lacinia erat vestibulum sed magna at', 1670, 217, 3249, 46, 325, 487, 945, 802, 57, 759, '561-473-5110', 'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 'https://soup.io/curabitur/gravida/nisi/at/nibh.jsp', 'NI-AN', 7, '2024-03-01 22:16:09');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor', 1557, 879, 3962, 7, 162, 193, 494, 240, 56, 1184, '865-293-0981', 'ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'http://goo.ne.jp/elementum/ligula/vehicula/consequat/morbi/a/ipsum.aspx', 'PL-KP', 10, '2024-05-03 18:57:29');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget', 1621, 989, 6066, 60, 144, 640, 709, 365, 82, 1508, '489-945-6253', 'pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'https://google.pl/orci.aspx', 'ZA-GT', 3, '2024-04-20 16:18:38');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas', 1902, 61, 8742, 15, 225, 556, 693, 208, 47, 590, '952-635-2972', 'adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'https://soundcloud.com/sed/tincidunt/eu/felis/fusce/posuere/felis.jsp', 'PG-SAN', 10, '2024-03-04 06:14:13');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 1144, 373, 8544, 36, 340, 841, 89, 480, 54, 1221, '151-762-8035', 'sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'http://cloudflare.com/diam/cras/pellentesque.aspx', 'SE-Q', 7, '2024-08-22 01:32:33');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam', 1578, 201, 8831, 33, 72, 53, 599, 657, 47, 674, '827-495-3007', 'nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'https://homestead.com/luctus/nec/molestie/sed/justo/pellentesque/viverra.html', 'LK-3', 10, '2023-10-29 09:23:11');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl', 1331, 276, 9807, 60, 276, 722, 907, 154, 32, 204, '990-457-6671', 'maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'https://live.com/ut/nulla.aspx', 'IN-TN', 5, '2024-03-06 08:31:39');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst', 1527, 75, 3258, 49, 276, 470, 134, 899, 97, 1417, '568-653-5487', 'pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'http://msn.com/ligula.jpg', 'US-IN', 7, '2024-09-13 14:35:02');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit', 1843, 376, 3750, 38, 279, 14, 689, 576, 1, 0, '284-763-9039', 'sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://shinystat.com/proin/interdum/mauris/non/ligula/pellentesque/ultrices.jpg', 'US-FL', 7, '2024-02-24 11:23:15');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros', 1724, 126, 2283, 51, 175, 66, 421, 354, 64, 1029, '526-523-7221', 'felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://domainmarket.com/cum/sociis/natoque/penatibus/et/magnis/dis.html', 'CD-EQ', 1, '2023-10-28 17:02:12');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi', 1200, 972, 8722, 35, 264, 575, 891, 323, 63, 759, '510-623-5625', 'molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'http://posterous.com/nec/sem/duis/aliquam/convallis/nunc.jpg', 'KZ-YUZ', 6, '2023-10-30 17:06:45');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla', 1559, 681, 7654, 40, 146, 15, 83, 1, 82, 1966, '540-366-2465', 'cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://t.co/interdum/in/ante/vestibulum/ante/ipsum.jpg', 'US-WA', 4, '2024-04-15 12:02:09');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis', 1186, 226, 8836, 3, 230, 683, 466, 70, 78, 1871, '552-865-5085', 'in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'http://qq.com/interdum/mauris/non/ligula/pellentesque/ultrices/phasellus.html', 'CA-QC', 2, '2023-11-08 01:49:00');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris', 1349, 652, 3574, 38, 272, 379, 448, 17, 88, 28, '339-697-8973', 'in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'http://issuu.com/non/quam/nec/dui/luctus/rutrum/nulla.jpg', 'DE-HB', 4, '2024-05-02 09:26:03');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at', 1663, 931, 9434, 44, 313, 252, 838, 369, 92, 1512, '610-839-3797', 'sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'http://mit.edu/tincidunt/ante/vel/ipsum.json', 'AU-WA', 7, '2024-08-31 04:14:30');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae', 1463, 363, 5777, 25, 223, 579, 74, 235, 98, 1812, '315-651-4541', 'ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://smugmug.com/suspendisse.png', 'MY-13', 2, '2024-04-19 10:07:48');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae', 1332, 50, 2463, 13, 303, 910, 453, 502, 77, 1198, '754-200-5421', 'ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'http://multiply.com/et/commodo/vulputate/justo.json', 'US-AK', 4, '2024-02-14 11:56:57');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia', 1672, 105, 7066, 24, 324, 502, 433, 822, 62, 869, '601-855-6621', 'amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'http://newsvine.com/nec/condimentum/neque/sapien/placerat/ante/nulla.aspx', 'UY-AR', 8, '2024-04-26 00:16:05');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus', 1732, 686, 8411, 19, 151, 110, 300, 70, 97, 835, '292-551-0727', 'lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 'https://parallels.com/donec/diam/neque.jpg', 'BF-BLG', 10, '2024-06-18 18:26:49');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque', 1097, 1000, 5840, 57, 315, 902, 72, 228, 40, 880, '916-174-8183', 'tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'http://scientificamerican.com/ut/massa/quis.aspx', 'CA-NT', 10, '2024-07-08 09:16:59');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec', 1124, 753, 8763, 21, 147, 662, 644, 247, 40, 1932, '948-829-5521', 'ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'http://fda.gov/enim/lorem/ipsum/dolor/sit.jpg', 'US-TN', 10, '2024-04-10 10:26:29');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium', 1428, 370, 3554, 10, 257, 334, 129, 695, 76, 924, '104-373-5834', 'consequat morbi a ipsum integer a nibh in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'http://si.edu/scelerisque/mauris/sit/amet/eros/suspendisse/accumsan.html', 'CN-50', 4, '2024-09-03 11:38:43');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt', 1301, 814, 7088, 8, 350, 480, 187, 722, 36, 558, '540-629-4106', 'condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'https://vistaprint.com/cubilia/curae/donec/pharetra.aspx', 'PH-MAD', 9, '2024-03-17 21:55:31');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi', 1360, 475, 8920, 44, 198, 25, 610, 446, 51, 1268, '873-157-0943', 'etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'http://jimdo.com/quam/suspendisse/potenti/nullam/porttitor/lacus.png', 'US-VA', 2, '2023-11-22 17:37:51');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta volutpat', 1776, 21, 4454, 59, 222, 242, 590, 136, 46, 527, '952-975-0074', 'nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'https://pinterest.com/duis/at/velit.aspx', 'CD-NK', 4, '2024-06-23 15:17:06');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'duis ac nibh fusce lacus purus aliquet at feugiat non pretium', 1272, 133, 3691, 55, 266, 244, 758, 665, 68, 160, '683-957-8809', 'faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://instagram.com/risus/auctor/sed/tristique/in/tempus.aspx', 'CA-ON', 9, '2024-04-14 07:27:15');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'at nulla suspendisse potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis', 1079, 456, 5634, 30, 302, 731, 224, 207, 65, 1322, '260-364-4040', 'erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://so-net.ne.jp/curabitur.aspx', 'BR-RO', 5, '2024-01-26 08:23:11');

-- select * from protocolo;

-- Tabla ensayo
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-24 01:02:47', 'movil', 26, 47, 25, 42, 20);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-04 04:55:31', 'campo', 36, 34, 27, 20, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-27 06:11:09', 'laboratorio', 33, 5, 28, 45, 21);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-02 19:24:14', 'planta', 40, 37, 8, 16, 28);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-01 19:50:36', 'planta', 4, 42, 10, 36, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-06 11:39:17', 'campo', 34, 39, 3, 41, 40);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-01 08:36:29', 'laboratorio', 16, 24, 8, 17, 25);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-07 07:44:05', 'movil', 43, 6, 32, 30, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-04 04:21:53', 'laboratorio', 17, 10, 4, 48, 11);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-18 02:49:08', 'movil', 20, 19, 49, 17, 5);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-22 09:53:06', 'movil', 2, 20, 9, 47, 9);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-23 09:14:18', 'planta', 27, 25, 14, 48, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-04 05:17:58', 'campo', 23, 10, 32, 3, 28);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-25 00:05:02', 'campo', 45, 7, 37, 48, 6);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-16 04:03:55', 'laboratorio', 40, 2, 8, 44, 1);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-30 11:01:27', 'campo', 49, 4, 23, 35, 48);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-03 07:28:25', 'laboratorio', 8, 50, 28, 26, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-11 12:10:17', 'movil', 12, 36, 43, 16, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-10 18:40:05', 'laboratorio', 16, 49, 32, 16, 3);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-24 15:24:58', 'campo', 42, 48, 1, 27, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-25 20:52:15', 'campo', 1, 25, 38, 19, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-27 14:44:07', 'campo', 43, 40, 20, 20, 17);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-25 11:28:15', 'movil', 48, 2, 15, 10, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-20 18:00:22', 'campo', 19, 40, 9, 24, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-05 05:23:07', 'campo', 3, 10, 44, 6, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-01 02:57:06', 'planta', 26, 34, 20, 3, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-10-01 11:48:07', 'campo', 42, 16, 32, 43, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-23 20:50:51', 'movil', 42, 13, 35, 31, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-22 12:42:19', 'laboratorio', 43, 26, 25, 35, 36);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-14 06:06:34', 'campo', 25, 22, 19, 46, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-25 10:57:13', 'planta', 50, 10, 48, 41, 16);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-08 12:37:04', 'planta', 1, 9, 18, 46, 16);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-29 20:03:01', 'laboratorio', 23, 23, 25, 30, 38);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-01 04:21:34', 'campo', 33, 3, 45, 33, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-06 11:19:18', 'laboratorio', 14, 17, 9, 1, 14);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-06 06:50:55', 'movil', 9, 18, 16, 50, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-15 23:17:23', 'laboratorio', 24, 43, 8, 14, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-06 03:44:15', 'movil', 24, 44, 22, 39, 5);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-04 07:05:58', 'laboratorio', 46, 19, 8, 11, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-28 17:14:28', 'laboratorio', 44, 13, 31, 30, 35);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-07 08:47:57', 'laboratorio', 48, 16, 27, 10, 17);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-23 13:48:44', 'laboratorio', 22, 14, 31, 27, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-07 10:00:48', 'planta', 41, 17, 40, 13, 17);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-14 00:23:51', 'laboratorio', 40, 50, 35, 30, 10);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-08 20:05:08', 'laboratorio', 35, 18, 40, 13, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-05 11:31:18', 'movil', 29, 26, 3, 2, 40);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-22 17:56:20', 'movil', 37, 34, 42, 3, 47);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-29 04:22:19', 'planta', 37, 44, 45, 26, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-20 21:58:29', 'movil', 24, 21, 17, 44, 30);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-29 15:12:52', 'planta', 39, 34, 11, 49, 43);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-26 02:59:59', 'laboratorio', 27, 4, 25, 36, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-10 09:38:52', 'campo', 22, 48, 38, 9, 30);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-04 17:58:19', 'campo', 43, 22, 23, 42, 50);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-03 08:14:16', 'laboratorio', 42, 1, 16, 3, 3);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-01 10:00:48', 'planta', 5, 32, 45, 18, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-23 15:26:20', 'campo', 33, 41, 48, 39, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-08 07:03:09', 'movil', 36, 33, 10, 5, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-09 15:51:52', 'campo', 16, 32, 39, 1, 39);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-10 14:43:46', 'movil', 50, 23, 17, 22, 14);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-26 19:54:18', 'campo', 1, 32, 17, 12, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-28 06:53:20', 'laboratorio', 32, 40, 11, 14, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-13 01:05:11', 'movil', 10, 40, 40, 29, 43);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-17 16:20:56', 'campo', 50, 10, 33, 9, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-31 06:11:26', 'planta', 46, 6, 14, 3, 23);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-10 18:04:45', 'movil', 35, 2, 6, 22, 42);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-24 12:39:22', 'planta', 39, 5, 26, 47, 44);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-13 09:56:14', 'movil', 3, 42, 10, 30, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-24 14:41:18', 'laboratorio', 31, 42, 18, 19, 11);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-24 09:43:08', 'laboratorio', 3, 6, 5, 28, 10);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-13 05:37:20', 'laboratorio', 2, 32, 24, 30, 9);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-01 21:13:16', 'planta', 48, 31, 43, 44, 40);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-03 15:42:16', 'campo', 31, 3, 8, 14, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-28 20:54:07', 'campo', 50, 50, 42, 25, 42);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-06 21:45:41', 'campo', 14, 35, 20, 17, 18);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-22 19:43:22', 'movil', 47, 38, 23, 33, 31);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-26 09:52:51', 'movil', 11, 11, 45, 36, 49);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-04 08:41:59', 'movil', 21, 45, 35, 50, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-23 17:06:09', 'laboratorio', 39, 16, 38, 7, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-04 03:15:33', 'movil', 47, 26, 30, 38, 48);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-11 11:36:45', 'campo', 32, 32, 19, 9, 25);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-19 12:28:38', 'movil', 7, 44, 34, 44, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-04 14:51:18', 'movil', 44, 16, 17, 45, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-16 18:01:48', 'campo', 47, 15, 27, 4, 21);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-11 08:09:57', 'movil', 13, 7, 35, 25, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-14 19:53:12', 'movil', 45, 29, 31, 32, 35);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-26 09:45:25', 'laboratorio', 18, 37, 12, 47, 21);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-19 18:34:20', 'planta', 31, 25, 2, 24, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-26 13:02:57', 'campo', 45, 41, 42, 36, 35);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-28 05:43:39', 'laboratorio', 34, 14, 27, 29, 9);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-22 22:56:33', 'planta', 43, 20, 27, 8, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-19 23:02:10', 'movil', 7, 1, 31, 20, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-01 22:03:31', 'laboratorio', 5, 50, 39, 1, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-18 00:37:15', 'movil', 7, 38, 11, 35, 19);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-01 19:20:45', 'movil', 18, 6, 25, 42, 24);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-12 00:51:59', 'planta', 27, 23, 34, 5, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-24 07:56:27', 'planta', 42, 33, 47, 13, 12);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-21 05:14:11', 'laboratorio', 46, 24, 3, 26, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-13 19:41:52', 'planta', 23, 27, 4, 11, 12);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-18 01:35:14', 'laboratorio', 34, 39, 7, 20, 15);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-29 00:59:53', 'campo', 49, 9, 33, 2, 32);

-- select * from ensayo;

-- Tabla certificado
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-09-07 03:23:28', 24, 'quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae', 0, 157, '6252327158', 26, 45, 44, 25, 'https://phpbb.com/dapibus/duis.json');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-30 21:32:15', 15, 'volutpat dui maecenas tristique est et tempus semper est quam pharetra', 1, 51, '9944694460', 42, 26, 25, 20, 'https://feedburner.com/ultrices.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-30 23:44:15', 5, 'mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam', 1, 54, '6683308292', 29, 44, 12, 17, 'http://pinterest.com/odio/justo.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-18 10:30:40', 10, 'nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam', 0, 297, '8791810485', 42, 10, 3, 39, 'https://wikispaces.com/id/pretium/iaculis.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-23 05:09:58', 28, 'mauris non ligula pellentesque ultrices phasellus id sapien in sapien', 0, 132, '2929564784', 29, 42, 24, 45, 'https://constantcontact.com/cubilia.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-03 18:19:51', 45, 'vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget', 0, 75, '4510466080', 50, 25, 18, 46, 'http://dot.gov/pede/posuere/nonummy/integer/non/velit/donec.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-30 08:20:01', 22, 'malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet', 1, 105, '7850014405', 5, 42, 33, 1, 'https://hc360.com/eu/orci/mauris/lacinia/sapien/quis.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-18 16:28:55', 50, 'vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante ipsum primis', 1, 30, '8943676506', 24, 44, 40, 37, 'http://github.com/sit/amet/nunc/viverra/dapibus/nulla.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-29 03:28:15', 36, 'sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in', 1, 295, '9736649687', 31, 38, 44, 48, 'http://apple.com/amet/nulla.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-05-27 22:53:49', 2, 'et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut', 0, 299, '0786041080', 12, 20, 45, 34, 'http://paypal.com/nulla.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-28 20:30:23', 41, 'lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 1, 203, '7883105949', 44, 44, 40, 26, 'https://msu.edu/amet.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-31 06:57:03', 13, 'sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed', 0, 237, '1536201138', 38, 22, 1, 27, 'https://gravatar.com/dolor/sit.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-02 06:06:57', 15, 'justo eu massa donec dapibus duis at velit eu est congue', 1, 291, '5404189282', 36, 22, 12, 35, 'http://cbslocal.com/imperdiet/nullam/orci/pede/venenatis.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-06-22 18:21:14', 13, 'ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum', 0, 329, '7545938976', 27, 27, 29, 38, 'https://sakura.ne.jp/justo/lacinia/eget/tincidunt/eget.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-16 05:49:39', 41, 'leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu', 1, 152, '3985901635', 45, 3, 6, 44, 'https://nationalgeographic.com/non/mauris.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-10 16:22:50', 27, 'nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus', 0, 139, '0479049173', 4, 34, 35, 47, 'http://google.ru/id.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-08-09 01:05:16', 32, 'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy', 0, 246, '7401986191', 41, 43, 39, 4, 'https://sourceforge.net/velit/nec/nisi/vulputate/nonummy.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-10-02 19:20:55', 28, 'eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a', 1, 79, '7680715750', 37, 23, 10, 37, 'https://moonfruit.com/est/lacinia.json');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-29 06:38:04', 6, 'ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus', 1, 293, '8826473315', 18, 24, 1, 22, 'http://xrea.com/maecenas/ut/massa/quis/augue/luctus.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-06-17 03:39:03', 28, 'eget semper rutrum nulla nunc purus phasellus in felis donec semper', 0, 277, '4106258552', 41, 30, 24, 20, 'http://usatoday.com/sit/amet/erat/nulla/tempus/vivamus/in.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-14 18:50:16', 26, 'vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et', 1, 339, '8891258733', 2, 46, 6, 33, 'http://redcross.org/lobortis/vel/dapibus/at/diam/nam/tristique.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-16 01:22:02', 46, 'potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis', 1, 293, '3633799680', 46, 34, 22, 44, 'https://feedburner.com/amet/eleifend/pede.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-23 12:12:56', 4, 'pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat', 0, 190, '1787685527', 42, 49, 24, 12, 'http://dell.com/facilisi/cras/non/velit.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-15 08:35:44', 14, 'vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque', 0, 281, '7295187367', 46, 11, 31, 43, 'http://unc.edu/quis/turpis/eget/elit/sodales.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-05-26 09:21:47', 5, 'cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus', 1, 341, '3623843393', 18, 12, 29, 8, 'http://istockphoto.com/vulputate/nonummy/maecenas/tincidunt/lacus/at.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-31 05:37:16', 32, 'fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui', 0, 287, '6786149901', 25, 6, 41, 38, 'https://nps.gov/id/pretium/iaculis/diam.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-09-07 10:02:13', 28, 'lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea', 0, 241, '4197065795', 24, 29, 40, 2, 'https://webeden.co.uk/nisi/at/nibh/in.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-12 08:23:21', 34, 'risus auctor sed tristique in tempus sit amet sem fusce consequat nulla', 0, 343, '3317926686', 31, 45, 47, 46, 'http://constantcontact.com/rhoncus/aliquam/lacus/morbi.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-02 21:26:33', 28, 'turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut', 1, 131, '2368252282', 16, 47, 19, 24, 'https://sphinn.com/dolor/sit.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-07-23 21:55:07', 43, 'praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante', 1, 347, '6289988514', 34, 34, 7, 15, 'http://wordpress.org/lectus/pellentesque/at/nulla/suspendisse/potenti.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-31 14:36:27', 39, 'potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus', 1, 192, '1807890597', 17, 24, 26, 7, 'http://discovery.com/ipsum/praesent.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-04-05 07:44:01', 36, 'tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi', 1, 316, '0422417343', 12, 4, 29, 23, 'http://thetimes.co.uk/in/tempor/turpis/nec/euismod.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-04-20 17:49:45', 23, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum', 1, 300, '5667060183', 35, 40, 35, 17, 'https://blinklist.com/a/pede/posuere/nonummy/integer/non.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-15 14:33:22', 22, 'eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean', 0, 93, '5993308842', 22, 30, 6, 48, 'http://boston.com/blandit/lacinia/erat.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-09 04:15:50', 50, 'velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam', 1, 289, '2450034595', 9, 41, 39, 11, 'http://amazon.co.uk/porttitor/pede/justo/eu/massa/donec/dapibus.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-06-17 13:32:01', 44, 'leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas', 1, 115, '4904365186', 36, 27, 13, 41, 'http://odnoklassniki.ru/maecenas/tristique/est/et/tempus.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-16 18:05:42', 50, 'congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum', 0, 311, '9904739838', 29, 13, 9, 24, 'http://youku.com/ut/odio/cras/mi/pede/malesuada.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-06 22:36:06', 4, 'blandit lacinia erat vestibulum sed magna at nunc commodo placerat', 1, 208, '2549066588', 24, 42, 1, 29, 'http://nyu.edu/sagittis/dui/vel.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-01 10:12:18', 23, 'mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a', 0, 122, '1596386819', 8, 42, 40, 26, 'https://purevolume.com/neque/duis/bibendum/morbi/non/quam/nec.json');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-26 00:22:19', 27, 'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien', 0, 250, '4954462150', 29, 2, 27, 11, 'https://oracle.com/sit/amet/turpis/elementum/ligula.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-27 13:50:57', 26, 'semper sapien a libero nam dui proin leo odio porttitor id consequat in consequat', 0, 79, '3380113085', 33, 42, 47, 18, 'http://guardian.co.uk/consequat.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-07-23 17:57:00', 7, 'malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer', 0, 32, '6495887256', 32, 8, 20, 22, 'https://privacy.gov.au/vel/pede/morbi.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-03 14:00:19', 27, 'pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue', 0, 133, '8622677311', 15, 6, 41, 26, 'http://harvard.edu/volutpat/quam/pede.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-03 01:13:07', 41, 'consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius', 1, 143, '6730197447', 10, 42, 12, 34, 'https://psu.edu/eget/nunc.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-05-16 10:06:42', 8, 'tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie', 0, 326, '8838441855', 6, 36, 4, 7, 'http://discovery.com/dictumst/morbi/vestibulum/velit/id/pretium.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-09-30 16:47:22', 40, 'ultrices mattis odio donec vitae nisi nam ultrices libero non', 0, 138, '1811374883', 26, 1, 13, 31, 'https://linkedin.com/elementum/in/hac/habitasse/platea/dictumst.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-17 15:49:07', 49, 'auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc', 0, 73, '3102902154', 24, 44, 32, 19, 'http://diigo.com/at/turpis/donec.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-31 00:54:28', 14, 'et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec', 0, 72, '9391557198', 27, 2, 8, 22, 'http://clickbank.net/ultrices/vel/augue/vestibulum/ante.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-29 19:37:44', 45, 'volutpat sapien arcu sed augue aliquam erat volutpat in congue', 0, 177, '9169825114', 4, 17, 42, 42, 'https://cnn.com/cubilia/curae/duis/faucibus.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-04-07 10:22:10', 10, 'aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna', 0, 184, '8036505436', 27, 15, 26, 32, 'http://angelfire.com/ultrices/posuere/cubilia/curae/mauris.jsp');

-- select * from certificado;

-- Tabla a_facturacion
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-19 02:30:36', 41, 8);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-27 02:20:59', 10, 33);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-15 18:56:35', 20, 29);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-01 20:39:17', 41, 12);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-16 22:26:21', 22, 43);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-07-29 01:08:21', 2, 4);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-22 01:34:01', 37, 46);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-09 20:50:41', 49, 44);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-27 22:26:15', 2, 29);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-26 18:22:19', 46, 38);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-11 00:51:40', 45, 22);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-30 08:33:31', 22, 47);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-06-01 10:28:40', 50, 20);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-22 19:44:47', 28, 19);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-08 06:24:26', 41, 22);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-23 07:09:58', 13, 27);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-01-17 15:05:52', 13, 28);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-01 23:02:46', 44, 21);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-19 06:04:31', 49, 7);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-28 02:56:18', 16, 28);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-26 19:53:29', 38, 33);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-06 08:28:07', 37, 44);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-11 15:31:21', 13, 18);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-07-22 08:26:07', 23, 40);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-05 11:14:26', 42, 17);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-23 21:53:42', 24, 27);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-06-30 21:18:19', 29, 44);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-26 03:36:17', 45, 21);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-30 02:41:16', 28, 28);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-29 04:15:23', 44, 4);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-14 12:13:09', 34, 6);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-09 13:16:44', 49, 23);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-23 09:33:18', 23, 43);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-01-06 01:55:38', 22, 39);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-28 15:34:55', 28, 30);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-22 20:00:48', 31, 36);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-01 03:43:15', 20, 15);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-06-04 10:00:30', 35, 7);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-07 22:05:01', 37, 2);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-11 16:06:01', 12, 2);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-13 09:23:42', 27, 37);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-02 00:20:05', 24, 12);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-13 05:02:17', 47, 15);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-17 08:06:31', 50, 24);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-08 08:25:30', 50, 11);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-10 11:47:37', 48, 13);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-17 18:25:35', 24, 24);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-03-14 05:38:02', 10, 47);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-19 19:24:34', 25, 16);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-02-26 19:37:54', 44, 15);

-- select * from a_facturacion;

-- Tabla a_facturacion_certificado
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 31, 9);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 43, 33);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 31);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 50);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 25, 1);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 46, 5);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 13);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 49, 43);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 33, 19);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 17, 1);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 7, 25);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 33, 28);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 24, 35);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 16, 33);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 30, 2);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 14, 40);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 40, 31);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 1, 7);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 8, 21);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 35, 31);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 40, 47);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 25, 2);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 42, 41);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 17, 30);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 36, 24);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 45, 3);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 45);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 27, 47);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 40, 43);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 17, 35);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 44, 13);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 2, 36);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 9, 50);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 31, 46);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 29, 9);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 7, 3);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 22, 7);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 15, 10);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 30, 14);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 26, 9);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 24, 27);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 9, 41);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 24, 4);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 4, 25);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 12, 30);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 46, 3);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 27, 28);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 41, 48);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 7, 1);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 18, 4);

-- select * from a_facturacion_certificado;

-- Tabla ficha_tecnica
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://blinklist.com/blandit/ultrices/enim/lorem.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://mozilla.org/ipsum/primis/in/faucibus.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://mozilla.com/integer/ac.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://mediafire.com/amet/sem.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://nytimes.com/lacus/curabitur/at/ipsum/ac.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://tripadvisor.com/cubilia/curae/mauris/viverra/diam/vitae/quam.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://whitehouse.gov/consequat/lectus/in/est.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://ustream.tv/bibendum/imperdiet/nullam/orci/pede/venenatis/non.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://ft.com/ante/ipsum/primis/in.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://wisc.edu/in/blandit/ultrices.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://cnet.com/dapibus/at/diam/nam/tristique/tortor.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://istockphoto.com/donec/vitae/nisi/nam/ultrices/libero.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://cam.ac.uk/amet/erat/nulla.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://google.co.jp/adipiscing/molestie/hendrerit/at/vulputate.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://marketwatch.com/nec/dui/luctus.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://earthlink.net/ipsum/ac/tellus/semper/interdum.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://networksolutions.com/luctus/nec/molestie/sed/justo.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://moonfruit.com/nulla/ultrices/aliquet/maecenas/leo/odio/condimentum.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://discuz.net/lacinia/sapien/quis/libero/nullam/sit.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://jimdo.com/platea/dictumst/etiam.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://dyndns.org/sed/justo/pellentesque/viverra.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://webmd.com/potenti/in/eleifend/quam/a.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://shop-pro.jp/in/magna/bibendum/imperdiet/nullam/orci.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://phoca.cz/justo/maecenas/rhoncus.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://sciencedaily.com/donec/ut/mauris.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://blogger.com/eros/elementum/pellentesque.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://eventbrite.com/odio/porttitor/id/consequat.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://squarespace.com/ultrices.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://army.mil/ut/massa.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://edublogs.org/consectetuer/adipiscing/elit.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://printfriendly.com/ipsum/dolor/sit/amet.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://soup.io/duis.jpg');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://newsvine.com/dolor.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://epa.gov/fusce.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://barnesandnoble.com/ac/consequat/metus/sapien/ut/nunc/vestibulum.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://behance.net/in/magna/bibendum/imperdiet/nullam/orci.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://guardian.co.uk/consequat/nulla/nisl/nunc/nisl/duis/bibendum.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://google.es/libero.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://phpbb.com/ligula/nec/sem/duis/aliquam.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://wikimedia.org/nulla/eget/eros/elementum/pellentesque/quisque/porta.jpg');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://simplemachines.org/sociis/natoque/penatibus/et/magnis.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://smugmug.com/curabitur/in.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://godaddy.com/nonummy/maecenas.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://tripod.com/aliquet/ultrices/erat/tortor.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://who.int/praesent/blandit/lacinia/erat.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://dell.com/ut/volutpat/sapien/arcu/sed/augue.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://weebly.com/duis/faucibus/accumsan/odio/curabitur.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://merriam-webster.com/cras/mi/pede/malesuada/in.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://ucla.edu/volutpat/convallis/morbi/odio/odio/elementum.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://photobucket.com/sollicitudin/vitae/consectetuer.html');

-- select * from ficha_tecnica;

-- Tabla remito_out
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (1, 15, '2024-03-09 01:00:34', 28, 58, 'id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (2, 35, '2023-12-14 14:19:34', 14, 43, 'sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (3, 8, '2023-11-23 17:46:47', 9, 11, 'massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (4, 30, '2023-12-07 13:15:03', 27, 8, 'cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (5, 48, '2024-07-13 17:21:18', 4, 19, 'posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (6, 42, '2024-02-14 14:04:48', 50, 3, 'rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (7, 7, '2024-06-07 08:11:52', 43, 69, 'at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (8, 48, '2024-07-30 06:49:55', 17, 5, 'aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (9, 39, '2024-01-27 08:32:00', 25, 33, 'elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (10, 43, '2023-10-03 11:52:47', 30, 5, 'curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (11, 12, '2024-01-21 07:17:45', 17, 42, 'urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (12, 20, '2024-06-22 19:33:19', 20, 82, 'justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (13, 32, '2024-09-29 13:31:43', 48, 19, 'mi integer ac neque duis bibendum morbi non quam nec dui luctus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (14, 31, '2024-07-30 09:47:21', 14, 83, 'sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (15, 22, '2024-03-21 19:46:57', 14, 49, 'pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (16, 38, '2024-04-23 13:59:17', 2, 16, 'ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (17, 36, '2024-01-19 01:28:07', 17, 18, 'et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (18, 3, '2023-12-30 21:41:53', 46, 95, 'dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (19, 41, '2024-08-08 21:12:16', 11, 69, 'est phasellus sit amet erat nulla tempus vivamus in felis');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (20, 36, '2024-07-27 17:10:50', 46, 23, 'penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (21, 6, '2024-09-18 09:03:14', 40, 51, 'curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (22, 40, '2024-07-01 06:57:37', 14, 86, 'nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (23, 40, '2024-03-14 23:48:21', 6, 18, 'nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (24, 40, '2024-08-05 08:27:28', 29, 84, 'ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (25, 23, '2024-03-01 14:48:41', 41, 12, 'id pretium iaculis diam erat fermentum justo nec condimentum neque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (26, 17, '2024-04-05 09:21:45', 39, 30, 'sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (27, 22, '2023-12-29 02:24:30', 7, 2, 'risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (28, 20, '2023-10-30 03:29:47', 46, 64, 'justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (29, 34, '2024-07-29 13:37:20', 23, 1, 'integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (30, 10, '2024-09-01 01:32:41', 19, 13, 'bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (31, 34, '2023-12-05 12:29:25', 11, 100, 'in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (32, 29, '2024-04-28 19:04:27', 42, 85, 'dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (33, 43, '2024-09-27 01:06:21', 31, 68, 'in hac habitasse platea dictumst maecenas ut massa quis augue');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (34, 11, '2023-11-30 10:38:21', 40, 7, 'mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (35, 12, '2023-11-03 19:38:17', 33, 44, 'consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (36, 44, '2023-10-08 19:01:42', 32, 44, 'posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (37, 31, '2024-02-12 04:44:27', 5, 99, 'est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (38, 4, '2024-05-10 08:52:10', 23, 83, 'sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (39, 49, '2024-01-19 10:36:06', 34, 57, 'in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (40, 36, '2024-03-18 03:19:14', 42, 35, 'nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (41, 49, '2024-07-27 17:12:31', 32, 23, 'magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (42, 11, '2024-08-18 02:33:54', 24, 52, 'sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (43, 38, '2024-02-07 10:41:21', 42, 94, 'sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (44, 39, '2024-05-14 01:59:38', 38, 21, 'pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (45, 44, '2024-05-02 16:59:45', 37, 77, 'tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (46, 1, '2023-12-22 13:01:25', 42, 99, 'ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (47, 3, '2024-09-04 03:00:33', 3, 89, 'ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (48, 46, '2024-08-25 06:35:14', 48, 33, 'nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (49, 2, '2024-03-02 23:49:23', 1, 4, 'amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (50, 49, '2024-05-06 12:05:20', 32, 32, 'vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit');

-- select * from remito_out;

-- Tabla status_elemento
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');

-- select * from status_elemento;

-- Tabla elemento
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
    
CREATE TABLE IF NOT EXISTS detalle_cotizacion (
	idDetalle_cotizacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	detalle text,
    observaciones varchar(255)
    );

CREATE TABLE IF NOT EXISTS cotizacion (
	idCotizacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	cantidad int,
    detalle_cotizacion int,
    precio_unitario float,
    valor_dolar float, -- para tener una referencia temporal del precio equivalente a la cotización del día de la confección
    total float,
    observaciones varchar(255),
    FOREIGN KEY (detalle_cotizacion) REFERENCES detalle_cotizacion(idDetalle_cotizacion)
    );    
    
CREATE TABLE IF NOT EXISTS presupuesto (
	idPresupuesto INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	empresa int not null,
    usuario int,
    cotizador int not null, -- persona que realizó la cotización
    fecha datetime not null,
    vigencia_oferta int,
    forma_pago varchar (50),
    plazo_entrega varchar (100),
    observaciones varchar (255),
    link varchar (255),
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (usuario) REFERENCES usuario(idUsuario),
    FOREIGN KEY (cotizador) REFERENCES personal(idPersonal)
    );
  
-- detalle o items a presupuestar
-- Tabla intermedia para asociar presupuesto con items cotizados
CREATE TABLE IF NOT EXISTS presupuesto_cotizado (
	idPresupuesto_cotizado INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	idPresupuesto INT NOT NULL,
	idCotizacion INT NOT NULL,
    FOREIGN KEY (idPresupuesto) REFERENCES presupuesto(idPresupuesto),
    FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion)
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
  
-- Proformas para enviar a la Fundación para que facture los trabajos del Laboratorio a la Empresa  
-- encabezado
CREATE TABLE IF NOT EXISTS a_facturacion ( 
	idA_facturacion INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	fecha datetime,
    empresa int,
    ref_presupuesto int, -- se utiliza para tener una referencia
    FOREIGN KEY (empresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (ref_presupuesto) REFERENCES presupuesto(idPresupuesto)
    );
 
-- detalle o items a facturar
-- Tabla intermedia para asociar certificados con facturación
CREATE TABLE IF NOT EXISTS a_facturacion_certificado (
	idA_facturacion_certificado INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	idA_facturacion INT NOT NULL,
	idCertificado INT NOT NULL,
    FOREIGN KEY (idA_facturacion) REFERENCES a_facturacion(idA_facturacion),
    FOREIGN KEY (idCertificado) REFERENCES certificado(idCertificado)
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
    a_facturacion int,
    remito_out int,
    FOREIGN KEY (tipo_elemento) REFERENCES tipo_elemento(idTipo_elemento),
	FOREIGN KEY (status_elemento) REFERENCES status_elemento(idStatus_elemento),
    FOREIGN KEY (ficha_tecnica) REFERENCES ficha_tecnica(idFicha_tecnica),
    FOREIGN KEY (presupuesto) REFERENCES presupuesto(idPresupuesto),
    FOREIGN KEY (remito_in) REFERENCES remito_in(idRemito_in),
    FOREIGN KEY (ensayo) REFERENCES ensayo(idEnsayo),
    FOREIGN KEY (certificado) REFERENCES certificado(idCertificado),
    FOREIGN KEY (a_facturacion) REFERENCES a_facturacion(idA_facturacion),
    FOREIGN KEY (remito_out) REFERENCES remito_out(idRemito_out)
    ); 
    
 /* Inserción de Datos */
    
-- Tabla tipo_usuario
INSERT INTO tipo_usuario (tipo_usuario) VALUES
('interno'),
('externo'),
('empresa'),
('terceros'),
('institucional'),
('auditor'),
('contabilidad'),
('municipio'),
('investigador'),
('docente');

-- select * from tipo_usuario;

-- Tabla cargo_empresa
INSERT INTO cargo_empresa (idCargoEmpresa, cargo_empresa) VALUES
(NULL, 'auditor'),
(NULL, 'dueño'),
(NULL, 'calidad'),
(NULL, 'administración'),
(NULL, 'técnico'),
(NULL, 'supervisor'),
(NULL, 'mantenimiento'),
(NULL, 'operario'),
(NULL, 'logística'),
(NULL, 'depósito'),
(NULL, 'recepción');

-- select * from cargo_empresa;

-- Tabla empresa
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 198630368825, 'Considine, Kassulke and Borer', '121 Cottonwood Road', '9024 Blackbird Court', 'mlawlie0@soup.io', 'lloads0@blogtalkradio.com', '1027859749', '6896827580');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 245727737217, 'Streich Inc', '6957 Burning Wood Drive', '7766 Coleman Road', 'npiet1@uiuc.edu', 'kbritzius1@mapquest.com', '1741865999', '5578323689');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 211825238884, 'Hammes, Hoppe and Marquardt', '15 Saint Paul Lane', '743 Straubel Terrace', 'chowgego2@tinyurl.com', 'pdoughton2@twitter.com', '8691071986', '9007528876');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 724413458504, 'Bahringer, Ratke and Runolfsson', '6 Longview Crossing', '0 Sycamore Crossing', 'mvandenvelden3@nba.com', 'vcorragan3@wisc.edu', '3054984203', '4809628673');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 988693137581, 'Bins-Wolf', '6136 Manufacturers Terrace', '8834 Mendota Crossing', 'dlucian4@barnesandnoble.com', 'kboyford4@yandex.ru', '9418692190', '2016513045');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 410999809159, 'Bosco LLC', '780 Novick Terrace', '85 Maywood Street', 'adaal5@imdb.com', 'bdreher5@t.co', '7891963396', '2447129810');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 999164101394, 'Collier-O''Connell', '85 Pankratz Parkway', '4 Ilene Point', 'drumford6@symantec.com', 'cwadeling6@vinaora.com', '8966860634', '7577365245');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 450175723967, 'Jacobs-Lakin', '33094 Towne Parkway', '98264 Lake View Road', 'bsatchel7@opera.com', 'aquinnet7@pen.io', '1476055475', '8906008304');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 893720460714, 'Gulgowski, Johnston and Langworth', '9 Corscot Park', '587 Scott Place', 'ttassell8@ox.ac.uk', 'doteague8@mediafire.com', '2281993929', '1706810143');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 443800037549, 'Keeling Group', '59 Ridgeview Junction', '838 Texas Point', 'zlangdon9@stanford.edu', 'lgaenor9@timesonline.co.uk', '9743372696', '1692418977');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 852990781340, 'Block-Considine', '1793 Lotheville Center', '4 Cody Street', 'lhubanda@nps.gov', 'wwinleya@parallels.com', '8004537736', '5847883470');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 423266119585, 'Herzog-McLaughlin', '94927 Londonderry Place', '63866 Ludington Hill', 'lstoeckleb@sphinn.com', 'vstockmanb@bigcartel.com', '2084016960', '9294844251');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 774551908191, 'Effertz, Lubowitz and Koepp', '20362 Morrow Terrace', '1 Spohn Hill', 'imckeurtanc@hubpages.com', 'greppaportc@opensource.org', '6545868721', '6385607547');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 640871625809, 'Kozey and Sons', '43 Mandrake Center', '52499 Hermina Street', 'rmatysd@smh.com.au', 'btaddd@storify.com', '7065156118', '4954360118');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 888066137584, 'Christiansen Inc', '0454 Granby Trail', '7620 Bluestem Place', 'ccromlye@adobe.com', 'lvaheye@wordpress.org', '5663313914', '1045926025');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 185282029563, 'Bergstrom LLC', '59 Artisan Street', '47 Mariners Cove Drive', 'ffewlessf@mapy.cz', 'tgeffef@pinterest.com', '2115489480', '4736239912');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 114878619932, 'Boyer, Hoppe and Medhurst', '73348 Walton Terrace', '1053 Pine View Pass', 'myousterg@omniture.com', 'nklimowskig@ycombinator.com', '3178402470', '3144999946');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 355310946934, 'Fay Group', '6738 Crownhardt Parkway', '22466 Stang Court', 'tannwylh@google.fr', 'htoppash@typepad.com', '4689278697', '1287009681');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 401523789838, 'Dibbert and Sons', '9516 Evergreen Plaza', '6 Holy Cross Plaza', 'hgruczkai@angelfire.com', 'iphilpotsi@odnoklassniki.ru', '1703578627', '5912884829');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 819205555185, 'Hegmann, Kuvalis and Goldner', '0 Vidon Plaza', '1005 Scoville Plaza', 'pdavidescuj@topsy.com', 'ccausleyj@eventbrite.com', '5713531705', '8446599509');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 955266041570, 'Fahey and Sons', '8 Westerfield Road', '66 Division Terrace', 'ghaslehurstk@hubpages.com', 'binglesk@4shared.com', '7323147132', '7603717420');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 330287390590, 'Homenick, Lowe and Bergnaum', '93517 Moulton Junction', '411 Hauk Trail', 'dminneyl@51.la', 'hbruyntjesl@addtoany.com', '9095662610', '8695119464');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 602763146125, 'Wintheiser-Terry', '03 Upham Center', '9 Park Meadow Point', 'tgeerem@fotki.com', 'echalkm@woothemes.com', '6555142646', '4667749976');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 815964492088, 'Toy, Turner and Purdy', '3 Schmedeman Trail', '1003 Caliangt Terrace', 'ebessantn@hud.gov', 'mbutlinn@smugmug.com', '9515030080', '8565123795');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 362226413937, 'Stiedemann, Konopelski and Daugherty', '9216 Knutson Pass', '7 Golf Parkway', 'kanniceo@ftc.gov', 'tdaborno@senate.gov', '2063445296', '8637625450');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 712440025093, 'McDermott-Hilpert', '7035 Vahlen Terrace', '37731 Northwestern Terrace', 'aelgiep@meetup.com', 'pcubuzzip@google.com.br', '9422004283', '9668870957');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 118754012085, 'Welch, Bashirian and Kunze', '18295 Anthes Point', '71077 Village Way', 'rsamsq@accuweather.com', 'lajamq@delicious.com', '8751129893', '6608961353');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 961125092580, 'Mills-Schmidt', '19 Union Court', '9854 Columbus Crossing', 'cmacdermotr@berkeley.edu', 'scollissonr@patch.com', '9452558977', '6243239342');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 570237700951, 'Considine, Shanahan and Streich', '7 Butternut Avenue', '03 Oxford Junction', 'fswalteridges@harvard.edu', 'bdavidoves@usa.gov', '6676649040', '5949645265');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 946878033491, 'O''Conner Inc', '71 South Circle', '64 Graedel Alley', 'asevent@amazonaws.com', 'wbaddamt@uiuc.edu', '2329718202', '3294277081');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 270333828307, 'Champlin-Ferry', '710 Delaware Way', '171 Valley Edge Parkway', 'gnisbyu@4shared.com', 'dmalsheru@ucla.edu', '4906562840', '9948917002');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 633824771424, 'Romaguera Group', '6 Welch Junction', '42 Montana Court', 'wkachelerv@fema.gov', 'aflynnv@wordpress.com', '1538918103', '6943008208');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 502843084980, 'Barrows, Heller and Morissette', '640 Warner Center', '7 Iowa Point', 'mverlanderw@geocities.com', 'bsmartw@mail.ru', '5134329006', '2078849960');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 508070733214, 'Dibbert-Spencer', '34 Amoth Crossing', '75 Macpherson Avenue', 'rjarlmannx@bbb.org', 'nbelfragex@netlog.com', '3278647950', '1511852537');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 163937445915, 'Murazik and Sons', '10912 Fordem Drive', '77 Reindahl Crossing', 'smalinsy@uiuc.edu', 'tkneaphseyy@cocolog-nifty.com', '9724681682', '7127081191');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 961055805974, 'Deckow-Hahn', '2208 American Junction', '784 Vera Street', 'lfarraz@businesswire.com', 'zmanwaringz@cnet.com', '2168243170', '5381923218');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 622896853379, 'Zulauf LLC', '1894 Banding Park', '651 Messerschmidt Junction', 'messame10@microsoft.com', 'mdrewett10@epa.gov', '7728155133', '9086992801');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 554418645854, 'Strosin, Windler and Lesch', '7286 Moland Lane', '9 Service Pass', 'mpirelli11@topsy.com', 'foldland11@facebook.com', '6735172269', '8861103220');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 945244063821, 'Conroy, Nolan and Altenwerth', '601 Montana Circle', '7 Dottie Parkway', 'ajanusz12@godaddy.com', 'spaz12@prweb.com', '5644790155', '6529048490');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 578431698830, 'Parisian, Strosin and Kiehn', '58 Carberry Place', '58 Ridge Oak Way', 'achisholm13@weather.com', 'alankford13@google.com', '8268738990', '3008136459');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 359446472909, 'Tillman and Sons', '56 Artisan Crossing', '49 Waxwing Junction', 'afruchter14@examiner.com', 'mratie14@arstechnica.com', '2724950903', '5438960935');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 635663832613, 'Ullrich, Hudson and Fay', '97415 Cordelia Center', '30 Beilfuss Pass', 'nsquire15@about.com', 'rbridge15@dyndns.org', '3972168267', '5641125783');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 935897080837, 'Collier, Shields and Bednar', '81 Elka Center', '20 Merchant Street', 'mgillice16@wikipedia.org', 'jrenol16@sitemeter.com', '3987537047', '7255265144');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 380091616309, 'Okuneva-McCullough', '225 Dapin Parkway', '3008 Briar Crest Terrace', 'adagon17@constantcontact.com', 'sgood17@etsy.com', '9715444582', '9643237837');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 830361383882, 'Shanahan Group', '895 Nancy Road', '1 Division Street', 'gmingaud18@yahoo.com', 'ccallear18@apple.com', '8237872477', '9167539342');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 182833404785, 'Bradtke, Bahringer and Gerhold', '9505 Hazelcrest Crossing', '300 Orin Alley', 'bgethings19@accuweather.com', 'elemme19@spotify.com', '8019446984', '1189920082');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 962193217463, 'Stanton Inc', '1072 Comanche Park', '203 Mockingbird Point', 'jfrigot1a@loc.gov', 'jboseley1a@flickr.com', '3751954419', '9637697506');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 686424994290, 'Turner LLC', '360 Green Ridge Pass', '29548 Arrowood Park', 'ktreadgall1b@skype.com', 'ashervil1b@so-net.ne.jp', '9502738641', '1777461260');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 979542922411, 'Douglas Group', '3139 Park Meadow Plaza', '482 Commercial Place', 'fpymar1c@elpais.com', 'tmaffioletti1c@si.edu', '9861318848', '9156516622');
insert into empresa (idEmpresa, cuit, nombre, domicilio_facturacion, domicilio_deposito, mail_facturacion, mail_deposito, telefono, telefono_alternativo) values (null, 736234695818, 'Durgan-Weimann', '4494 Sugar Terrace', '85342 Maple Junction', 'kebbage1d@noaa.gov', 'njocic1d@123-reg.co.uk', '2618974634', '5273290434');

-- select * from empresa;

-- Tabla usuario
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'caddionizio0', 'jG7"#uAG', 'Clarabelle', 'Addionizio', 69720172, 'caddionizio0@home.pl', 'caddionizio0@unicef.org', '2024-07-15 02:44:57', 49, '7dbc67a12da7d880bc9383a70ede9f79f94498f34956ed11e6f6a7df29e53f3e', '15980597e704c3eca12203c2d90870cf45a9f4a2778a083b9a136490f986c430', '$2a$04$miXH2NNevjxr4hNWjFNUhuQsEsKeg/CgYz5ntiTLHz8ynpmobgmaK', 4, 12, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ldjakovic1', 'pM0\s6}S/', 'Lauree', 'Djakovic', 28269633, 'ldjakovic1@photobucket.com', 'ldjakovic1@nifty.com', '2024-02-22 16:41:12', 6, '9f39a5d13d90937c3a4c9902eb338494b8b41d6bde6e40d26f3ccc692d376466', 'e7678289005ad81fdb165984e9288a4d5a69f511f39a4776b5dc87e6da384348', '$2a$04$9IVYGBSXi6ZCIU/8n3ohmup.flHQ7MJYRd0XA38ZfzF/poYCznwZa', 5, 23, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ssanson2', 'iE7)_3kGAUXv', 'Shaine', 'Sanson', 88939457, 'ssanson2@soup.io', 'ssanson2@baidu.com', '2024-03-07 22:36:02', 89, 'b67f2c5feefad7a4c97e7422a624a259de749eff7770fc111c4ca1a689cf86d4', '5e672ce9a7f05b816e4d6fefead17d98633a05e333bac42c0ef34890f1f38774', '$2a$04$CX2Mgd6rER0OWECJJFZP1uQS/MMxIV/yGGlaZ1U9DrRhrMD/ArNFO', 7, 25, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'khischke3', 'sS5`Q1!/mL~T}', 'Kath', 'Hischke', 79963690, 'khischke3@parallels.com', 'khischke3@surveymonkey.com', '2024-06-28 04:59:25', 71, '9284e779bb74cbe2b37acbc90389b715cc3f704dc836d0a580294ca00811e715', '3e11ab198a493016139f8136682bfc94f56f821bcd4bdf2a6d2e0b013aac5081', '$2a$04$S.OBeq1j3EH37fSIaCZDV.ikQLeDFVmIxfgKKYpLwnjxIhXg91OJ.', 4, 27, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mdjurkovic4', 'bX7(XKX9`T&&x', 'Maggy', 'Djurkovic', 70711214, 'mdjurkovic4@comsenz.com', 'mdjurkovic4@infoseek.co.jp', '2024-09-17 04:33:53', 100, '99618f649dec1f0c40c7db36987978d22de7dabf4541204eae13469211114f15', '4d2d75741c50e5d99d3b42084443c5f9fa28d5991a4ee412d74f42f476444ddf', '$2a$04$P//WV5q/lPOgL4Da7mFgRe2a3jbqZJG5Nh5UGy.VJN69mv46CAyW.', 5, 4, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'jfarrall5', 'aT9=%iD!,D.0`SF6', 'Juana', 'Farrall', 20585451, 'jfarrall5@liveinternet.ru', 'jfarrall5@cnbc.com', '2024-08-12 14:52:39', 57, 'e9d83d8f7c4eba59fb34b5fd00fe9574d0e83838c592385600c81b06738074e3', '26e88428374d70db9f7bb6ad51d02cdb02fca18344d1352487d9ca33dd3123f4', '$2a$04$RNOO/oF25RpXW9X.i9QxQO/NqlmjGqoab1UInaitYyGylZBj5Lfeu', 3, 33, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'hroman6', 'iN2|Qs?p', 'Homerus', 'Roman', 77568687, 'hroman6@marriott.com', 'hroman6@sogou.com', '2024-05-04 22:57:15', 70, '91bac31f78934488dd04518b43cefd85b384daaea11f84d558c2abb4fc0994fb', '1cf0d615632d7af1e98a6e43c61562f0b6728d100360c547410739b98366b1f6', '$2a$04$smV299iHGtZ5bYl2gfuERe87nw86cGwqFiPslDfAvutQ0jy/RTy/6', 5, 33, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'sfattori7', 'aH4"2}<PBa''J+TS', 'Shirl', 'Fattori', 90938104, 'sfattori7@over-blog.com', 'sfattori7@godaddy.com', '2024-06-20 15:04:57', 56, '9c0dbb61f9e34aa9072febe330cdec46590c0453ce6837afbf0c43af54084372', '5a47426119556959494098d4e972b0138d5742e1e2e6b950c23241a1824aac7e', '$2a$04$/Y2aJU3aNj2l4is/N6PJx.UapwQ8x1n3yOa2hh56dDbOmRcBRP04C', 10, 39, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mcarlesso8', 'uX3!9e~U<', 'Marabel', 'Carlesso', 10614907, 'mcarlesso8@wikia.com', 'mcarlesso8@about.com', '2024-04-19 17:34:02', 100, '0602232c60b64cfbd7645c3e73bed3c1b819f214926d5b2ed8d60deeceec7064', '5a44487643f1cff3b3e1d0e899829b801cfa92bbc6f5b0e3f653cd464aaa48ef', '$2a$04$RhoJomdOAz6cLniSObATZu5Y88twrcCnL0cwEsIVP3gpNQ9gMfbUC', 5, 17, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'tpine9', 'iJ2\)>b!4G(', 'Timmie', 'Pine', 93349578, 'tpine9@nature.com', 'tpine9@blogger.com', '2023-12-06 22:45:32', 50, 'df01dbba4faa46b90f157615bb04817a4373833a1fec393015635eb5410d0332', 'f2f17bfa84a39b5705bc7c243bf2e69840b6aee672ee055466509da24a2e71c3', '$2a$04$/2iuRIdZbPHARHd0b.Js3.gBk/7UELWiIOK7ZgH71PzLPRW/rcLfS', 10, 17, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'tstidstona', 'vW7}F/B#', 'Toddie', 'Stidston', 89217246, 'tstidstona@engadget.com', 'tstidstona@kickstarter.com', '2024-02-12 05:24:08', 9, '45fd78737e3c6d4dbc1af52df4c689c7223f24793a5e0042864d3d85467af3c5', '03a797e9cab709535e51fa99ce5e0b66be84ab4b3a8a11e97ee9da4f411c3583', '$2a$04$3.bBpxLbEOOmfSBahxRc3ucFRySkVKaxuxXSNfFPVT.MBTstQ1qwm', 3, 15, 1);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bionnidisb', 'mK2`%{WI`C3', 'Belia', 'Ionnidis', 4178997, 'bionnidisb@psu.edu', 'bionnidisb@tripod.com', '2024-09-03 05:34:07', 96, '7fbf827363430a4c37ed1142a82a8194fa3cf55b038baccf7d25c207805340a9', 'f37748d8d77f8d0fe26ebb89054909b254c44e034aeb814f47180d82e05b4b3a', '$2a$04$iDWfpEwiFiuJGzBoeAmRzuu2oRetmyDUoQ77LUKiF9P/nepkb49nK', 4, 11, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'rsaunperc', 'bO0}{X%*$`A)w4', 'Raymund', 'Saunper', 91085253, 'rsaunperc@wufoo.com', 'rsaunperc@webs.com', '2024-05-18 19:40:23', 69, 'af3c29ef2cb77696942e673f6d93141e72766eb3e2914a82c89f99017476c045', '5b67aa75b37290df2823d86f8cc32636be33f8543be9b9fa9a9efb8e0ec2fa76', '$2a$04$3rYKk8KTdtrz4RpXdnSM6.CAoADUKZxhh45RKCaPFG5WOvtDAkAzS', 10, 16, 1);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bsongerd', 'pU9~&D3i}5', 'Blakelee', 'Songer', 74563195, 'bsongerd@elegantthemes.com', 'bsongerd@cafepress.com', '2023-12-15 22:34:39', 18, 'b8fabdbc24b10d291d7a1f199bd417e763b6219024831ed3478dd54035795414', '1288a7c04f524952eeb6eece696fc3d7ec561dbe61eaf69bc5012a9704632316', '$2a$04$Divq1j2wQpFv0JVYRHEEVegOU9yHaR0apwBnhk8PwDUFfVQW3vmOW', 3, 32, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'kblampiede', 'rI3<GQea&', 'Keelby', 'Blampied', 99848387, 'kblampiede@flavors.me', 'kblampiede@yahoo.co.jp', '2023-10-15 07:39:41', 80, '38c8574bfbb62587daaa637445b5e7324e6aa80a6907c92d6b9f118731cef51b', 'df4142658ede37bc6fdd2278a42fa29bac12397b39cd85e95da53740dc43fa11', '$2a$04$OSbvC7.Q3eR3uVDJbx/n4.tPogppo9YWVHdpMV2UhNhLfNkekaV6e', 9, 46, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mstrobandf', 'yC3@wZ`wK#s', 'Mellicent', 'Stroband', 60942831, 'mstrobandf@hhs.gov', 'mstrobandf@bloomberg.com', '2024-08-20 21:32:38', 24, '7e036f8985f714f94df87847b45aec138ec85a5d14a54ccb8a592c3d026e72e8', '43ba756dfb7f9fecb2263a212550db8e68bb80682e6b78af930f8a3e44be5e26', '$2a$04$U41WCfQXip81YV9ri70bKutqJtXAbmIa1GIKZdP.GvpJYsUsOo0CS', 7, 7, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'blovelaceg', 'pR5@|&P>\W4E+', 'Benedetto', 'Lovelace', 32258497, 'blovelaceg@google.com.hk', 'blovelaceg@admin.ch', '2023-11-07 18:06:29', 16, '6878b35d627779880c3662887020f290f41d1fd1dba5e18e9a118c40a9fb5a39', '888ef460f585adb0217908e29d1c692a2deaa4fd5947235777231a9d16cc764c', '$2a$04$apL3R8Boe6LVSbmL5rEgCOMXk7mbjNajcVq0KkVlmaZF8Dl9PF6xC', 7, 5, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'mrouchh', 'lM1)vosl}aUscY', 'Mirilla', 'Rouch', 32963952, 'mrouchh@whitehouse.gov', 'mrouchh@theguardian.com', '2024-09-10 09:45:07', 29, 'c6a9443a0024e63a9a2a8a1f6c803ce2c4eef72617c7756baf0137d8a658aeb9', 'f0582b52704579c393220734415293f752ced1d4bcf2e8c7105b2f97df599a37', '$2a$04$LYDyly/GR98dxubCGab33OSzjCNgHMUm/tUmVs.g/OYJ0qHnjBHxG', 3, 14, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'aroartyi', 'cL8|_Pkg0M_|C', 'Anatole', 'Roarty', 60056287, 'aroartyi@blinklist.com', 'aroartyi@blogtalkradio.com', '2023-12-11 00:14:49', 52, 'd5092701683a3d2294bb1dc9bc2f226a5592fa56c516db6ce4145cd6cd96f7e1', '3c4e2a9e40d9282d68240fb0e0e503c22848e11c6e5123174728ef865d4e58dc', '$2a$04$H7sa1ZSV3KDAtltxgzdqO.hLn0jIu35cYvLY/vtN8vmOv02uQPl8e', 10, 49, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'efittj', 'kR9@jPf1', 'Engracia', 'Fitt', 55705454, 'efittj@dagondesign.com', 'efittj@psu.edu', '2023-10-09 15:05:12', 71, 'e18e854404824f2d3de1ea03c83fc4c6b63f851b3d9396a5e655157821f9b558', '0baef0e8a9b25ba272912dd63b3908d865a94769b7ccf97c7a001c1432a74910', '$2a$04$y2eqMhIgBREJjLpDKM2fj.a433SvWEDx5W1mqvvyWpT/vYlBQJkuu', 2, 22, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'emurfettk', 'cW6}b96C7{W9!', 'Emalee', 'Murfett', 44416289, 'emurfettk@miitbeian.gov.cn', 'emurfettk@skyrock.com', '2024-09-20 17:05:01', 39, 'f03115b01b69bc6a388394834046208505079ff89547f0480f57b9325f428d24', '63dc1e1537dd5453ebf9897017f832aaad72557e62911b08e37c6be242080d6d', '$2a$04$rvNF2CPzsyo3e2guQs3.S.afFaZfIVWHRUUN/Izgj/4E8szKH71MG', 1, 32, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'agottschalkl', 'hM7)8)pG_', 'Augie', 'Gottschalk', 78115514, 'agottschalkl@cbc.ca', 'agottschalkl@liveinternet.ru', '2024-07-31 15:28:52', 68, '46b655be02e40afd7b6d88e70f91626ec564b85fb76905d5d93cd548d4a0f5f3', 'd997a8b8e8a0fe0fe7ae5fbfbfc912d13608a4d54c6f607357aca0e065d51f53', '$2a$04$lUIeW3596ZmhJfI7VwRh1u76gzvuqFVn1cRwGFHaAmFi88zhA1Fze', 7, 43, 6);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bmarom', 'vB1=yEi<@m~_otl', 'Boone', 'Maro', 70110804, 'bmarom@mapy.cz', 'bmarom@umn.edu', '2024-05-30 21:09:51', 73, '423885aa4ee8d7cfbaa8633224de749d2b431ea4226b2b980184bfdb3558f19b', '09c6a552d5a0881c71c39843c21c62717e1b57a4b72a942ebe14762250cd4c29', '$2a$04$YnwCrN04cDVh3.RsFmVDi.xX4jtFAXgAIJPWJE4d44TgSwp.gRtom', 10, 50, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'vmcettigenn', 'iY7&zr(GCKRe', 'Valentina', 'McEttigen', 53547821, 'vmcettigenn@icio.us', 'vmcettigenn@dmoz.org', '2024-04-14 10:01:36', 72, 'bc5fba48c4ec2190470f121dd5cc5cf447cb31265ece7c130ca60176363c4c89', 'c4b1bf5e833396842cc0a415155419e5e729eec8d61271dc2ba6aa8d359efd6d', '$2a$04$cMePHKxImiH9nLvKSo22veSKvBtB1MT5AHuL2rHwV2mtgGlP1jdFy', 6, 31, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'owixono', 'sV5+@9%0t+FV}~W%', 'Odelia', 'Wixon', 41982221, 'owixono@netlog.com', 'owixono@bbc.co.uk', '2024-04-10 00:38:35', 39, '38f23b3391b762381be0617d4294e3e56a4e747a57b456e5a4812c763599aa18', 'aba920eabef8e570d1ab62a65a12c69c654e1a958472ac5b82125bd69a891c30', '$2a$04$XrKnIf0PaYgaOt/8IYCRq.tI.f0Ee1.TYST66kWbHf9pFtMz27ZQG', 8, 15, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'escreasp', 'vM8!vPdS4W/5?!S`', 'Ellissa', 'Screas', 22707468, 'escreasp@deviantart.com', 'escreasp@1und1.de', '2024-07-11 03:48:22', 75, 'efc7c6583ecefb6f66f16199e63aca67aef5013f965349f22307820972472d09', '32fc53c919b390f48ce8717f246b0bcf392d0862261fbbca6a765df61f7eb1d5', '$2a$04$SoeoGSRjDO2I9ecRSar0UOmpT5mhciUU6nwb/mFg7GEQbIqz3RqqS', 2, 48, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'fnelq', 'kE5%@&iPN', 'Forest', 'Nel', 81144533, 'fnelq@techcrunch.com', 'fnelq@google.es', '2024-04-30 08:17:40', 4, '5ae99f0b32c4d8a14a64150e73c166bed8c4a4bf34ac484d44c1baade76f66e6', '8011d216bb37840c79c4bc1accdb9b0fc9b7dd452b88b812097373912655e82b', '$2a$04$8u9GxbMtBk78ZlJmNRuLNeFsd1lEkoUoHns3ayxjZSd0mJ7YfSMri', 8, 10, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'kscarffr', 'zY3/hwCTYSk?b', 'Kerrie', 'Scarff', 18531051, 'kscarffr@icq.com', 'kscarffr@omniture.com', '2023-12-25 03:23:31', 31, 'd10d75e5f284f94c56774fdf81e5ece4b118851b14ec7c024c7216ce5f5db014', '4b700f601da7097d3507b5ee7adff1c03259268045415efd2cbc35ae3979d182', '$2a$04$IMwvc7pkyat0zl.9XsQtluyU5X4788h3NpvmLMGyRmU61tDP3GP7m', 8, 18, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'twrathalls', 'pX2}eRyN6', 'Tildie', 'Wrathall', 7749595, 'twrathalls@networksolutions.com', 'twrathalls@businessweek.com', '2023-12-13 11:30:59', 47, 'b3827fe7572f39614c3aa18f04df638c7d93290cb0b3d68e347116e143536a07', 'bdd3635dd3f40859662f38977f750b7347841deefea8a847fc6f2a6eb0c8ac05', '$2a$04$86tzNiTIhtokURCUFnMmqOpTYWEba8lwHs6INQWKWrxW7ju.gEPSi', 3, 16, 8);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ebraidt', 'pN9#"o8B&p1<8j', 'Emmett', 'Braid', 37631861, 'ebraidt@google.de', 'ebraidt@list-manage.com', '2024-08-04 11:47:22', 35, 'c73211664ec879746c8a949cbe802ceee7077ea07297bdb077d010cf633a4051', '1c09f56950bcfe40470278e20506e9abed51ad793f5b12fd8325fc9a4f720232', '$2a$04$UYzcjD4bLjjlocoO6QkXp.gBdCFQZ5x6h.Lu.CzhcaOPOdkWktPbO', 7, 32, 8);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'aummfreyu', 'tF5!el@9D@N#eIV', 'Ado', 'Ummfrey', 88859806, 'aummfreyu@skype.com', 'aummfreyu@goo.gl', '2023-11-17 21:28:24', 50, 'acf67d75c34f38055948ea588a60540872426a6f5bc3f3aeb516469bee71b0d2', 'e0f062131945fe442d6dc4e1f29e970fc82b73aa6b2e0c484f3afe2626e801ed', '$2a$04$MtsjoDEZTX0XtrrZ4Al2EOFMLZRmfpLvCe9o7oGNVzJtTuln5sKVa', 7, 49, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'rbreedv', 'aM2''b4RD@B', 'Regan', 'Breed', 94054890, 'rbreedv@cloudflare.com', 'rbreedv@imdb.com', '2024-02-12 04:51:35', 61, '60a23c6610ac199b6adfc94076d38b33e3e625bf1fd9a276a6de5f192f4eca69', 'ae30cd84acfef616465f4c7227e546fc69464b2d3f07ba1e53c8d432acacaa12', '$2a$04$xwvTGP0Ymh51fg8A6zmLRuphTP.udOrORBwPoiuHHb2U/twvCmdzu', 8, 38, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'averrillw', 'zZ8%k6RhS', 'Alvis', 'Verrill', 82434577, 'averrillw@virginia.edu', 'averrillw@dropbox.com', '2023-11-18 20:56:45', 71, '78b3cc41df474b550f8d635b7c6cffe9a1855a4d9c685aa853ed209320def20b', 'd0f370ce11bbde98068953aabaa4391e104b1734e1eba319e539bc9ad4b0e329', '$2a$04$HldeI0NCgLFQpnhsldywJ.gQ6kqFi8Xb28s7U6Z/BYUSmiLXBx/Zi', 6, 21, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'igrimditchx', 'tM2_(+6nwv7CrW', 'Isidora', 'Grimditch', 60830814, 'igrimditchx@printfriendly.com', 'igrimditchx@theglobeandmail.com', '2024-08-16 19:08:23', 81, '9067826399df3f98635cd619c000fbec658d72d533b16ef5f1fc8ea83d2a9098', 'bb9ddeadc626c8b4729a0996302456afd1e444754f875d4f2ec1a088e2886070', '$2a$04$WzhTMPYw4cLRFxg0ILOEje2xjq8PloFa6IcLQAIMYkqFVDDTCDg5u', 8, 49, 9);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'gmoulesy', 'pT4(~QYr', 'Greg', 'Moules', 54696641, 'gmoulesy@yale.edu', 'gmoulesy@indiatimes.com', '2024-04-20 23:24:27', 70, 'f7b0b1303db2c83633627dc99be694409916df0c8f3b170768e6dbf9f1d7cbfd', 'fd7c197e8b86154499a7469a017a88e1adddcb5b9252bdce080c6149227651a2', '$2a$04$6Slx4Ux6tWf5kgSrXfT2xueHkBmp./Pt/xK5TAlN8uc1CNyDlvaXe', 8, 45, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'tpetytz', 'pQ1@9k}abn_', 'Tremayne', 'Petyt', 91571339, 'tpetytz@google.ca', 'tpetytz@godaddy.com', '2024-01-14 07:53:25', 26, 'c25d7b8a27920d8464f210a29350a965707cffd85bf4d0e1d45041a7cc09cf0e', '4b5ac3f2725b291b69fb671e0034883d3c3237293ccc652f9148bea9483a8e01', '$2a$04$T4MlKPq/u/2NmoTrHpRGWu5Cn4mY7QyIUDUEL2I89dcQMO0BuemzK', 1, 14, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'wfishlee10', 'iO4,+27pJDk', 'Wilfred', 'Fishlee', 61782677, 'wfishlee10@ehow.com', 'wfishlee10@phoca.cz', '2023-11-19 12:25:19', 61, 'a5dc0bda02fa97aa4aec815eb9bddf948940127d6082f58b27e910dd4508eb39', 'f3a77ff750bef8c20ded4aee97edf67cf9b3f8f0c2828b5b141230c7bfd40a34', '$2a$04$7JXpje.Lk3uZvPOPDMxuxOTjJ/ipTnGjkuTTjuRZW28jNNx8cIUcu', 2, 13, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'wwilleman11', 'gU0|QH>KNYRaJ7$', 'Winfield', 'Willeman', 74603773, 'wwilleman11@edublogs.org', 'wwilleman11@icio.us', '2023-11-09 10:37:48', 2, '3761563c268647cbb9fd3efc6719f99e90220e5614828b08a9791edc373d799d', 'da1452a84c74d406d7cdd34e1cfbc4d652b31becb937e758a627f0aaecf9c1e2', '$2a$04$ib5eoWtpNJfJVkqVfIKMc.unfWdfoyIAQMTtkouxm/9/v6FPH8vr2', 10, 22, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bewence12', 'uF6}kn''"', 'Brittan', 'Ewence', 64914464, 'bewence12@wiley.com', 'bewence12@bloglines.com', '2024-08-16 21:39:01', 24, 'cb5a5c7b7cbc12d5800befe10d947491d64d81819ab8353d90e6c746a019411c', '3ef1ff39c76c16de2c86e4178d81989e139bcc7e211c44f244c56c7969180385', '$2a$04$imHO2Hs.uFxgHDqdDSvPl.aPcgcSSeMflc4jUWaAXs7cosNNPV1RG', 4, 22, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'hforsdike13', 'yG2~MiU%gR&CB', 'Henrie', 'Forsdike', 52008713, 'hforsdike13@google.pl', 'hforsdike13@dedecms.com', '2024-05-17 13:58:00', 33, '27fb1cfade76d1570a7045af5cf0ad78268fa1fa6699105d789cb32b6aa69722', 'fa9a62fbd9bb9e44c70244ba59326dbbaa20a97d2601b887ec949e0a600bc939', '$2a$04$/GapGulx0rOBc3i0VPO3luw.D8YkSG/3Wow7MhAOPR.iu9IuUN0r2', 10, 1, 4);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'fbattaille14', 'dL0"0\&''L', 'Flint', 'Battaille', 7485998, 'fbattaille14@forbes.com', 'fbattaille14@sciencedirect.com', '2024-08-25 15:45:50', 88, 'd591d511582ce816a6ed847779fffe3bce4070fc8a7640730013f7b71440539c', '83823d837eb2da856d2cf31714232cfcab0fe2b329d2d9ad4c7a7655b6a9c02c', '$2a$04$JTUAsVIVf8wytgzBBONXFO5s.YXgOleunYnLDvLwvT7gZ2bgdZrCK', 1, 37, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ethairs15', 'mP6@KSCz|73su!M', 'Electra', 'Thairs', 78697385, 'ethairs15@altervista.org', 'ethairs15@yale.edu', '2023-10-30 06:43:21', 63, '5d6ee7cd52ce5edfbf925da06acef7b680b7a91c2a66841dac337bbe069e4338', '2dc6b601d982ea7b3d9dd91fecd871880daf2895acfeec510ed0694839b9551c', '$2a$04$WklOZfcPXgo3fksS7QW/Ju8vTmnVfDXNa8fhutiDdMMX3Pf41RHiC', 4, 11, 7);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'vbaress16', 'pK5\$a}/Q*Xn8', 'Violet', 'Baress', 80986613, 'vbaress16@ucoz.ru', 'vbaress16@hugedomains.com', '2023-12-16 02:38:11', 83, '7e3be2bca2ab337155cc947308f14a980f5aa5f98d03ef4804dd4113b4362e29', '57a62f6a5a00ce02c524c67732df2cda4646a04c6dc712aeb9cd9dcdf49e0bf2', '$2a$04$ognvFuT8vh3GXl8W3gNDg.xAqiY1SHbgEyY/fPMeVqt3pHmD6hipm', 2, 5, 8);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'gbenzies17', 'fD4>TW$\#', 'Geordie', 'Benzies', 3666560, 'gbenzies17@booking.com', 'gbenzies17@flickr.com', '2024-07-03 19:38:13', 83, 'e61004bda90490cfefa067083a2c0facbd2d03a52f2094877d34df3d40d87d7b', '66d17149b83f6c49e4a6ddf9fd31c241852c62357296442918d729d2b0c3881a', '$2a$04$E5/8x/LEmitadKaYYrDt8.9IOZSJHMS/g7T.oQH40jXEoMo29QSCm', 2, 38, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'xgrzegorek18', 'bU9_w''$mSY`', 'Xerxes', 'Grzegorek', 87567660, 'xgrzegorek18@weebly.com', 'xgrzegorek18@wiley.com', '2023-10-12 03:00:35', 85, '2f9d47f5f9bac2a37909f38bc4e88b0975ef0706d1e1f7d38d730ac9383b455d', '12a4dfdfaa00842846e84076a193315deb6ef0ded733a8c636a89ad0c603decd', '$2a$04$WurZfmqyaoMBbsvHF6CU9um8dLH932srHL.DnbQk.YexsXXAiljOq', 4, 38, 3);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'dbreeder19', 'qS3>~E@%7x', 'Dory', 'Breeder', 31588572, 'dbreeder19@hexun.com', 'dbreeder19@statcounter.com', '2024-03-01 07:53:56', 11, 'e15843cd621f9609e65a8bc1f2e877e798f8185574d433c9067aaac2d3ac5f52', 'd107137926514380308a3d1e48dfae8096a520122b1fd7e45fc000266b433a76', '$2a$04$US0qOqRB1DActK5DxAh6S.WGI7tfRfaCbuJWdkjliY0SE550B8oGK', 3, 1, 5);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'ablinerman1a', 'jZ1"NINI', 'Amerigo', 'Blinerman', 66299867, 'ablinerman1a@geocities.com', 'ablinerman1a@about.com', '2024-08-09 15:47:15', 6, 'df238de66584021feb2d67b7a1e36ba1be1f1180104583200683af0d0315af98', '2523458ed7be655be97b222fa20febe6a5ec57f563c5012349af8dedf6119543', '$2a$04$REQdGDlWtpeF/7dnbvmHHO/rbp/F9UJZYHpsvooIlRd.7cE.5Bn.G', 10, 46, 10);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'horis1b', 'fL5%*GCkUkpMa', 'Haskel', 'Oris', 82981860, 'horis1b@sun.com', 'horis1b@youku.com', '2024-06-05 17:52:27', 56, '818d1d83188769b650c4f076879454c0776d8f5337a863ecc64baa6e86f8dcd0', 'c60a9587bcab200bb421ed7dfb4b2d5d9389469df9bd7aff8fc7a207b1d004a9', '$2a$04$cNvD9Iw8eva0WNtD0lh/hOycBaUaU7U6uacC5I2zdKd5yaaUqVRxO', 2, 40, 1);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'hmingo1c', 'nQ1>L4Xm3$_VCb', 'Humfrid', 'Mingo', 84740193, 'hmingo1c@etsy.com', 'hmingo1c@4shared.com', '2024-05-21 00:46:38', 23, 'b300d94c7d3b2a353fdc8a8eefc3186f647bc5ffc301614c51b5a29cd7f6c858', '9acb1033dddaa41dee5b503520e75f34f3d93d66bc1e6d50fed3d62c0b0e1405', '$2a$04$T0XWPoxsaTvh0uorrRFdAuWExNQbHOMASs2NheRkpQd0bGFKcba.2', 10, 32, 2);
insert into usuario (idUsuario, usuario, pass, nombre, apellido, dni, email, email_alternativo, last_session, activacion, token, token_password, password_request, tipo_usuario, empresa, cargo_empresa) values (null, 'bmcdonough1d', 'jO4/.OP8W', 'Barbi', 'McDonough', 62496298, 'bmcdonough1d@booking.com', 'bmcdonough1d@ycombinator.com', '2024-07-05 11:05:07', 3, 'ffc8aab63cc82850328a658b436788150145ed8ceb281c3f16840f253ae54a15', '8d1058b0a3dae44dbfd4e28a05a74a6b06b414533ff4a82f592cd19c68d697f9', '$2a$04$aAi8DIdd8HhROUe1fIykMeeJqNIhliHRGLy2BK05mvlnR7s4N0TRW', 5, 5, 1);

-- select * from usuario;

-- Tabla personal
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Olivero', 'Bruin', 17821251, 'Doctora', 'logistica', 'obruin0@tripod.com', 'obruin0@intel.com', 20444);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Arlee', 'Camis', 48180150, 'Arquitecta', 'cotizador', 'acamis1@mapquest.com', 'acamis1@gov.uk', 37391);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Hasheem', 'Casini', 78770186, 'Licenciado', 'calculista', 'hcasini2@telegraph.co.uk', 'hcasini2@deliciousdays.com', 5354);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Claire', 'Edgcombe', 87292612, 'Magister', 'calculista', 'cedgcombe3@microsoft.com', 'cedgcombe3@domainmarket.com', 5187);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Ambrosius', 'Kilfoyle', 99683288, 'Ingeniero', 'cotizador', 'akilfoyle4@cisco.com', 'akilfoyle4@miitbeian.gov.cn', 23443);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Prisca', 'Farries', 27278322, 'Técnico', 'compras', 'pfarries5@qq.com', 'pfarries5@digg.com', 48079);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Tommie', 'Roll', 92434271, 'Técnica', 'operador', 'troll6@yale.edu', 'troll6@github.io', 25891);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Rodrick', 'Ruddock', 6533637, 'Ingeniera', 'sistemas', 'rruddock7@oaic.gov.au', 'rruddock7@ebay.com', 25019);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Alley', 'Coad', 95011895, 'Licenciado', 'calculista', 'acoad8@freewebs.com', 'acoad8@tripod.com', 42334);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Michele', 'Sundin', 62151851, 'Licenciado', 'certificante', 'msundin9@godaddy.com', 'msundin9@upenn.edu', 14907);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Adolpho', 'Grundy', 59642409, 'Doctor', 'certificante', 'agrundya@home.pl', 'agrundya@cnbc.com', 21129);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Willetta', 'Wyndham', 77415656, 'Técnico', 'cotizador', 'wwyndhamb@mashable.com', 'wwyndhamb@fda.gov', 38371);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Gilbert', 'Hamnett', 84152806, 'Contador Público', 'administrador', 'ghamnettc@diigo.com', 'ghamnettc@csmonitor.com', 9977);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Jens', 'Munks', 80259952, 'Técnico', 'operador', 'jmunksd@usgs.gov', 'jmunksd@japanpost.jp', 19753);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Valentina', 'Twiddy', 52823424, 'Ingeniera', 'compras', 'vtwiddye@github.com', 'vtwiddye@go.com', 12821);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'August', 'Baiyle', 57746540, 'Técnica', 'sistemas', 'abaiylef@newyorker.com', 'abaiylef@gravatar.com', 28234);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Bea', 'Fittall', 45546596, 'Licenciada', 'ayudante', 'bfittallg@myspace.com', 'bfittallg@nih.gov', 33996);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Jacki', 'Parmer', 67385209, 'Ingeniera', 'calculista', 'jparmerh@ox.ac.uk', 'jparmerh@facebook.com', 12948);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Claudianus', 'Gonoude', 39552215, 'Contadora Pública', 'logistica', 'cgonoudei@tripod.com', 'cgonoudei@ow.ly', 12787);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Bryana', 'Tofano', 34849060, 'Doctora', 'ayudante', 'btofanoj@timesonline.co.uk', 'btofanoj@typepad.com', 24536);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Irina', 'Lumbers', 99745348, 'Técnico', 'sistemas', 'ilumbersk@lulu.com', 'ilumbersk@baidu.com', 24377);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Lu', 'Christauffour', 67298079, 'Licenciada', 'administrador', 'lchristauffourl@cpanel.net', 'lchristauffourl@feedburner.com', 11973);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Zulema', 'Heams', 72173037, 'Doctor', 'operador', 'zheamsm@etsy.com', 'zheamsm@timesonline.co.uk', 35210);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Kimberlee', 'McCuis', 14524575, 'Contadora Pública', 'compras', 'kmccuisn@sciencedaily.com', 'kmccuisn@cbslocal.com', 22896);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Pavlov', 'Gibbeson', 96055100, 'Técnico', 'logistica', 'pgibbesono@biglobe.ne.jp', 'pgibbesono@smh.com.au', 8605);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Meagan', 'Kempshall', 87100014, 'Arquitecta', 'ayudante', 'mkempshallp@ovh.net', 'mkempshallp@walmart.com', 7891);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Micki', 'Sousa', 4757577, 'Arquitecta', 'operador', 'msousaq@opera.com', 'msousaq@yellowbook.com', 36373);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Claudetta', 'Exley', 33428272, 'Contadora Pública', 'compras', 'cexleyr@howstuffworks.com', 'cexleyr@yahoo.com', 17714);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Emmy', 'Merriment', 41285346, 'Doctora', 'compras', 'emerriments@webnode.com', 'emerriments@twitpic.com', 18776);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Mile', 'Leaves', 94944722, 'Ingeniero', 'operador', 'mleavest@goo.ne.jp', 'mleavest@homestead.com', 38241);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Rhodia', 'Littley', 99986629, 'Contadora Pública', 'administrador', 'rlittleyu@sfgate.com', 'rlittleyu@paginegialle.it', 23912);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Renaud', 'Duns', 69226464, 'Contador Público', 'ayudante', 'rdunsv@altervista.org', 'rdunsv@mlb.com', 10914);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dionne', 'Philliphs', 81318136, 'Licenciado', 'ayudante', 'dphilliphsw@ucla.edu', 'dphilliphsw@discovery.com', 7421);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dulcine', 'Durham', 24847353, 'Ingeniero', 'certificante', 'ddurhamx@4shared.com', 'ddurhamx@hhs.gov', 22235);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Jarrod', 'Gibby', 85211228, 'Ingeniera', 'cotizador', 'jgibbyy@issuu.com', 'jgibbyy@mozilla.org', 45027);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Catie', 'Axtens', 68257632, 'Magister', 'compras', 'caxtensz@nsw.gov.au', 'caxtensz@nsw.gov.au', 17694);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Hilary', 'Segoe', 58313558, 'Licenciada', 'ayudante', 'hsegoe10@topsy.com', 'hsegoe10@over-blog.com', 35700);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dewain', 'Lawday', 32449772, 'Contador Público', 'certificante', 'dlawday11@independent.co.uk', 'dlawday11@ibm.com', 23431);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dulci', 'Fouldes', 45209276, 'Técnica', 'certificante', 'dfouldes12@myspace.com', 'dfouldes12@biblegateway.com', 28099);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Dolli', 'Jickells', 72790083, 'Ingeniero', 'certificante', 'djickells13@hc360.com', 'djickells13@last.fm', 27838);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Farly', 'Earengey', 5578300, 'Técnica', 'administrador', 'fearengey14@dyndns.org', 'fearengey14@twitpic.com', 8188);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Putnem', 'Dayborne', 58502566, 'Ingeniera', 'sistemas', 'pdayborne15@answers.com', 'pdayborne15@163.com', 29348);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Niles', 'Speechly', 26531826, 'Doctora', 'calculista', 'nspeechly16@squarespace.com', 'nspeechly16@livejournal.com', 5999);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Irvine', 'Dreossi', 8819444, 'Técnico', 'calculista', 'idreossi17@indiatimes.com', 'idreossi17@theatlantic.com', 19314);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Elnora', 'Poundsford', 22247391, 'Ingeniero', 'ayudante', 'epoundsford18@php.net', 'epoundsford18@oracle.com', 5022);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Fee', 'McGuire', 80453357, 'Ingeniera', 'administrador', 'fmcguire19@berkeley.edu', 'fmcguire19@blogs.com', 39982);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Bondon', 'Buckham', 22054155, 'Ingeniera', 'logistica', 'bbuckham1a@stanford.edu', 'bbuckham1a@foxnews.com', 39109);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Aron', 'McAviy', 94805432, 'Doctor', 'sistemas', 'amcaviy1b@plala.or.jp', 'amcaviy1b@who.int', 23882);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Ophelie', 'Strafen', 37279498, 'Licenciado', 'sistemas', 'ostrafen1c@pinterest.com', 'ostrafen1c@go.com', 45500);
insert into personal (idPersonal, nombre, apellido, dni, titulo, funcion, mail, mail_alternativo, legajo) values (null, 'Abigael', 'Kensett', 32410812, 'Técnica', 'compras', 'akensett1d@vk.com', 'akensett1d@nbcnews.com', 28979);

-- select * from personal;

-- Tabla detalle_cotizacion
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 'diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'feugiat non pretium quis lectus suspendisse potenti in eleifend quam');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 'ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam tristique tortor eu pede');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'vehicula consequat morbi a ipsum integer a nibh in quis justo');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 'et ultrices posuere cubilia curae nulla dapibus dolor vel est');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'risus auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.', 'vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl');
insert into detalle_cotizacion (idDetalle_cotizacion, detalle, observaciones) values (null, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris');

-- select * from detalle_cotizacion;

-- Tabla cotizacion
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 49, 1, 4256, 1359, 557377, 'id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 95, 40, 39513, 1041, 657000, 'ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 52, 2, 19681, 1047, 551577, 'sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 83, 2, 31303, 1454, 682202, 'tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 38, 43, 38806, 1148, 227832, 'vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 45, 36, 26065, 1182, 460176, 'ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 84, 26, 19926, 1259, 400688, 'elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 5, 28, 47686, 1155, 544951, 'congue eget semper rutrum nulla nunc purus phasellus in felis');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 85, 3, 46360, 1151, 304881, 'aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 8, 40, 12071, 1324, 717539, 'mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 46, 37, 36881, 1483, 935345, 'consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 19, 27, 46038, 1109, 186709, 'magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 70, 2, 33486, 1229, 523099, 'a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 8, 38, 9843, 1367, 66375, 'suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 90, 15, 41595, 1053, 284770, 'sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 9, 10, 40663, 1199, 681805, 'adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis a');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 58, 45, 35553, 1038, 844509, 'sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo vulputate justo in blandit');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 27, 23, 29131, 1394, 172726, 'augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 1, 50, 26973, 1286, 816133, 'eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 69, 34, 13627, 1069, 429270, 'ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 76, 38, 18676, 1389, 329844, 'blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 22, 8, 39641, 1056, 507441, 'dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 46, 50, 4517, 1436, 471831, 'ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 48, 39, 12232, 1131, 540832, 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 76, 28, 29305, 1307, 922526, 'rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 21, 48, 4297, 1286, 595617, 'nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 8, 25, 18782, 1300, 146313, 'vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 1, 50, 44346, 1076, 692181, 'nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 84, 50, 49981, 1223, 478051, 'elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 28, 26, 26329, 1339, 847543, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 22, 32, 47623, 1487, 281121, 'eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 9, 8, 11596, 1029, 41062, 'suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 54, 42, 769, 1445, 109915, 'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 83, 5, 20558, 1215, 246202, 'neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 93, 35, 32100, 1481, 31457, 'turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 18, 46, 11903, 1436, 894587, 'non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 71, 35, 30757, 1462, 332153, 'sed tristique in tempus sit amet sem fusce consequat nulla');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 74, 50, 26915, 1458, 555873, 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 26, 42, 32791, 1118, 244706, 'nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 6, 49, 38557, 1485, 849111, 'consequat nulla nisl nunc nisl duis bibendum felis sed interdum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 43, 25, 19434, 1317, 839305, 'habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 23, 43, 33692, 1088, 32998, 'ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 59, 7, 4552, 1271, 391123, 'vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 56, 27, 18835, 1347, 67380, 'habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 69, 7, 40095, 1293, 483592, 'lobortis est phasellus sit amet erat nulla tempus vivamus in felis');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 58, 29, 38356, 1096, 129589, 'sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 43, 41, 31318, 1390, 184098, 'quam sapien varius ut blandit non interdum in ante vestibulum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 56, 24, 28431, 1068, 858758, 'in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 91, 37, 41423, 1181, 652235, 'morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum');
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones) values (null, 96, 8, 30876, 1120, 664529, 'quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque');

-- select * from cotizacion;

-- Tabla presupuesto
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 8, 22, 10, '2024-09-19 17:16:17', 86, 'cheque', 44, 'vestibulum quam sapien varius ut blandit non interdum in ante vestibulum', 'https://i2i.jp/in/lacus/curabitur/at/ipsum/ac.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 15, 31, 22, '2024-07-09 04:58:32', 94, 'tarjeta', 60, 'donec posuere metus vitae ipsum aliquam non mauris morbi non lectus', 'https://pen.io/pede/morbi/porttitor.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 50, 21, 9, '2024-09-10 09:02:01', 8, 'transferencia', 38, 'turpis enim blandit mi in porttitor pede justo eu massa donec', 'http://cloudflare.com/erat/fermentum.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 12, 40, '2024-03-30 23:32:56', 99, 'cheque', 33, 'ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui', 'https://exblog.jp/pede.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 2, 9, 6, '2023-10-22 00:48:47', 53, 'cheque', 24, 'sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et', 'https://cam.ac.uk/erat.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 16, 41, 41, '2023-10-29 14:52:56', 99, 'cheque', 40, 'non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus', 'http://usatoday.com/aliquet/at/feugiat/non/pretium/quis/lectus.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 1, 25, 43, '2024-02-16 13:19:57', 54, 'tarjeta', 1, 'pede justo lacinia eget tincidunt eget tempus vel pede morbi', 'http://washington.edu/iaculis/diam/erat.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 6, 50, 35, '2024-02-21 01:26:33', 41, 'transferencia', 84, 'quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras', 'https://pbs.org/primis/in.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 41, 50, 27, '2024-08-25 03:09:08', 16, 'tarjeta', 47, 'eu mi nulla ac enim in tempor turpis nec euismod', 'http://hugedomains.com/porttitor/lacus/at.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 13, 47, 20, '2023-11-30 00:08:26', 25, 'cheque', 11, 'amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut', 'http://ucoz.com/tempus/semper/est/quam/pharetra/magna/ac.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 1, 31, 44, '2024-08-04 00:28:07', 71, 'cheque', 26, 'nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit', 'http://behance.net/quam/pede.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 45, 24, 28, '2023-11-17 01:43:42', 77, 'cheque', 29, 'dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id', 'https://jigsy.com/sapien/iaculis/congue/vivamus.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 24, 10, 5, '2024-05-01 09:09:43', 91, 'tarjeta', 35, 'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat', 'http://huffingtonpost.com/arcu/libero.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 50, 22, 38, '2024-03-24 18:21:51', 24, 'tarjeta', 34, 'vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 'http://symantec.com/vulputate.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 39, 32, 35, '2023-10-12 20:58:33', 78, 'cheque', 2, 'maecenas leo odio condimentum id luctus nec molestie sed justo', 'https://wiley.com/etiam/pretium/iaculis/justo/in/hac.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 48, 30, 18, '2024-02-19 17:03:39', 25, 'transferencia', 94, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam', 'http://si.edu/mattis/odio/donec/vitae.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 32, 25, 32, '2024-09-19 19:32:05', 66, 'tarjeta', 41, 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet', 'http://freewebs.com/adipiscing/elit/proin/risus/praesent/lectus/vestibulum.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 28, 30, 4, '2023-11-21 12:08:00', 78, 'cheque', 32, 'nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros', 'http://huffingtonpost.com/donec/quis/orci/eget/orci.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 20, 31, 45, '2024-09-27 00:25:59', 67, 'transferencia', 24, 'a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus', 'https://bigcartel.com/suscipit/ligula/in/lacus.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 25, 47, 6, '2024-07-04 19:01:24', 55, 'tarjeta', 46, 'dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula', 'http://istockphoto.com/velit/donec/diam.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 8, 45, 48, '2024-04-03 11:11:53', 34, 'transferencia', 55, 'convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in', 'http://elegantthemes.com/sapien/in.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 26, 21, '2024-07-12 19:03:13', 60, 'cheque', 28, 'vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi', 'http://cbslocal.com/quisque/arcu/libero/rutrum/ac/lobortis.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 27, 10, 32, '2024-03-29 21:49:04', 85, 'cheque', 82, 'vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et', 'https://symantec.com/auctor/gravida/sem/praesent/id/massa/id.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 20, 29, 30, '2024-01-24 12:39:50', 64, 'cheque', 10, 'dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet', 'https://msn.com/sem/mauris.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 11, 48, 48, '2024-06-22 10:41:34', 15, 'tarjeta', 52, 'tincidunt lacus at velit vivamus vel nulla eget eros elementum', 'https://eepurl.com/sapien/iaculis.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 10, 32, 29, '2024-08-17 10:28:01', 85, 'cheque', 88, 'congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus', 'http://who.int/quis/justo.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 47, 44, 9, '2024-09-20 07:19:29', 88, 'tarjeta', 5, 'quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu', 'http://over-blog.com/volutpat/eleifend/donec.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 8, 30, 23, '2024-08-21 08:56:56', 25, 'cheque', 100, 'lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue', 'http://wufoo.com/egestas/metus/aenean/fermentum.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 26, 31, 20, '2024-07-08 01:10:28', 51, 'cheque', 26, 'rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel', 'http://theguardian.com/faucibus/orci/luctus/et/ultrices/posuere/cubilia.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 4, 22, '2024-07-16 03:32:29', 44, 'transferencia', 55, 'massa donec dapibus duis at velit eu est congue elementum in hac', 'https://reddit.com/nulla/ut/erat/id/mauris.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 1, 1, 1, '2024-08-02 16:22:50', 100, 'cheque', 72, 'ante ipsum primis in faucibus orci luctus et ultrices posuere', 'http://cnbc.com/aliquam/convallis/nunc/proin/at/turpis.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 17, 50, 21, '2024-08-31 13:08:30', 90, 'tarjeta', 39, 'ligula vehicula consequat morbi a ipsum integer a nibh in quis', 'https://t.co/posuere/metus/vitae/ipsum/aliquam/non/mauris.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 43, 48, 8, '2024-02-27 14:13:14', 82, 'transferencia', 29, 'tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis', 'http://liveinternet.ru/viverra/dapibus/nulla/suscipit.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 13, 8, 36, '2024-04-22 09:17:52', 93, 'cheque', 58, 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit', 'http://lulu.com/sapien/sapien/non/mi.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 3, 39, 7, '2024-01-28 10:10:58', 21, 'cheque', 52, 'sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut', 'http://admin.ch/risus.aspx');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 11, 34, 40, '2024-08-16 06:12:57', 78, 'cheque', 56, 'tempus semper est quam pharetra magna ac consequat metus sapien', 'https://gnu.org/integer/ac/neque/duis/bibendum/morbi/non.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 10, 14, '2024-08-17 14:20:01', 65, 'cheque', 51, 'facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus', 'https://engadget.com/elementum/nullam.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 45, 32, 45, '2024-08-17 08:48:53', 11, 'transferencia', 28, 'mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus', 'http://gizmodo.com/aliquam/non/mauris.json');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 35, 14, 13, '2024-03-29 03:07:58', 31, 'cheque', 97, 'convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar', 'https://wordpress.com/erat/tortor/sollicitudin/mi/sit/amet.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 18, 35, 26, '2024-07-25 15:27:06', 37, 'transferencia', 29, 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis', 'https://google.cn/quam/sollicitudin/vitae/consectetuer.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 32, 49, 7, '2023-12-03 03:01:48', 54, 'transferencia', 37, 'interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien', 'https://typepad.com/vestibulum/ante/ipsum/primis/in/faucibus.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 31, 39, 45, '2024-03-31 02:17:11', 15, 'tarjeta', 14, 'est et tempus semper est quam pharetra magna ac consequat metus', 'https://ucoz.ru/adipiscing/elit/proin/interdum.png');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 46, 35, 4, '2023-10-04 19:20:00', 58, 'cheque', 70, 'scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor', 'http://yellowpages.com/amet/nunc/viverra/dapibus/nulla.jsp');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 30, 14, 11, '2024-01-06 17:45:59', 62, 'tarjeta', 89, 'integer a nibh in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo', 'http://dyndns.org/ultrices.html');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 15, 45, 1, '2024-05-22 09:45:26', 57, 'transferencia', 95, 'pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in', 'https://homestead.com/leo/odio/condimentum.xml');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 36, 27, 17, '2024-03-31 05:16:22', 31, 'transferencia', 83, 'lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat', 'http://google.com.br/volutpat/eleifend/donec/ut/dolor.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 41, 29, 34, '2023-12-09 02:01:16', 8, 'transferencia', 75, 'ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at', 'http://github.io/non/ligula/pellentesque/ultrices/phasellus/id.js');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 47, 12, 19, '2023-10-05 04:30:08', 9, 'cheque', 72, 'maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida', 'https://msn.com/quisque/erat/eros/viverra/eget.jpg');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 7, 42, 47, '2024-10-01 17:34:52', 92, 'tarjeta', 69, 'ac leo pellentesque ultrices mattis odio donec vitae nisi nam', 'https://paginegialle.it/sed/magna/at/nunc/commodo.json');
insert into presupuesto (idPresupuesto, empresa, usuario, cotizador, fecha, vigencia_oferta, forma_pago, plazo_entrega, observaciones, link) values (null, 40, 26, 41, '2023-12-31 17:52:00', 9, 'cheque', 69, 'libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum', 'http://un.org/donec/odio/justo/sollicitudin/ut.jpg');

-- select * from presupuesto;

-- Tabla presupuesto_cotizado
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 32, 16);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 3);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 10, 23);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 22, 24);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 5, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 33, 12);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 49, 21);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 29, 16);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 31, 42);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 4, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 38, 43);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 22, 2);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 20, 13);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 24, 17);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 27, 20);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 36, 46);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 1, 9);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 34, 9);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 18, 44);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 49, 10);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 46, 26);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 49);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 11, 6);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 5, 42);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 44);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 25, 38);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 24, 15);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 27);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 35, 44);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 32, 27);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 42, 12);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 38);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 50, 9);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 7, 16);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 28, 10);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 25, 22);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 2, 39);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 17);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 33, 30);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 24, 31);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 5, 38);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 2, 26);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 26, 12);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 6, 31);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 36, 45);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 28, 24);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 45, 18);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 44, 36);
insert into presupuesto_cotizado (idPresupuesto_cotizado, idPresupuesto, idCotizacion) values (null, 1, 13);

-- select * from presupuesto_cotizado;

-- Tabla remito_in
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 16, '2024-03-09 13:21:56', 27, 44, 'non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 16, '2024-03-30 17:26:21', 22, 35, 'est donec odio justo sollicitudin ut suscipit a feugiat et');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 18, '2023-11-09 17:53:53', 16, 19, 'ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 9, '2024-05-25 03:53:46', 30, 21, 'odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 39, '2024-08-09 18:52:47', 23, 21, 'amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 38, '2024-01-04 11:28:23', 34, 35, 'sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 5, '2024-08-11 06:43:03', 4, 8, 'lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 24, '2024-01-26 00:23:07', 19, 49, 'diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 36, '2024-07-07 15:16:33', 19, 8, 'lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 28, '2024-06-22 07:59:52', 16, 31, 'curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 31, '2023-10-22 07:48:43', 37, 13, 'in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 21, '2024-01-23 07:50:39', 44, 25, 'accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 12, '2024-07-28 19:01:31', 37, 19, 'velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 3, '2024-02-03 07:11:28', 9, 29, 'eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 6, '2024-09-28 23:26:07', 19, 16, 'pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 41, '2024-09-20 23:23:34', 10, 29, 'sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 13, '2023-12-18 16:23:34', 10, 44, 'ut blandit non interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et ultrices');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 18, '2024-05-03 09:13:19', 49, 29, 'platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 19, '2024-06-17 09:42:00', 27, 39, 'mi pede malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 43, '2024-06-17 01:27:54', 50, 29, 'erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 17, '2024-05-16 07:09:28', 34, 3, 'id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 31, '2024-04-09 02:24:59', 3, 38, 'tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 38, '2024-07-03 19:07:07', 28, 42, 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 16, '2024-01-01 12:55:51', 29, 37, 'sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 33, '2024-02-17 16:17:43', 47, 6, 'orci eget orci vehicula condimentum curabitur in libero ut massa volutpat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 40, '2023-12-01 14:51:52', 38, 30, 'turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 40, '2024-09-26 20:31:06', 46, 27, 'cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 9, '2024-09-25 21:23:45', 11, 18, 'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 43, '2023-12-11 15:40:39', 47, 38, 'nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 46, '2024-01-03 20:27:13', 20, 17, 'vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 29, '2023-12-01 05:48:32', 9, 50, 'venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 6, '2023-10-26 05:33:16', 49, 32, 'aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 20, '2024-03-30 21:32:48', 38, 15, 'nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 12, '2024-06-12 23:26:25', 2, 44, 'amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 11, '2024-06-01 06:44:09', 12, 31, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 29, '2024-03-27 09:54:12', 43, 23, 'ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 36, '2024-05-05 17:31:12', 13, 43, 'posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 14, '2024-04-06 04:07:50', 21, 30, 'nulla nunc purus phasellus in felis donec semper sapien a libero nam dui proin leo odio porttitor');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 3, '2023-12-24 02:00:33', 24, 10, 'odio donec vitae nisi nam ultrices libero non mattis pulvinar');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 47, '2024-08-26 22:37:25', 5, 43, 'montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 41, '2024-05-23 10:17:15', 33, 31, 'in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 42, '2024-03-20 13:44:25', 7, 11, 'in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 3, '2023-11-07 08:49:43', 31, 19, 'donec ut dolor morbi vel lectus in quam fringilla rhoncus');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 9, '2024-04-09 05:49:52', 21, 14, 'augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 13, '2024-05-05 06:32:07', 20, 40, 'ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae donec');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 44, '2024-04-29 10:31:16', 21, 47, 'in congue etiam justo etiam pretium iaculis justo in hac habitasse');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 45, '2023-10-29 01:54:29', 11, 34, 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 25, '2024-02-27 01:38:42', 12, 34, 'lobortis vel dapibus at diam nam tristique tortor eu pede');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 35, '2024-02-27 04:32:16', 34, 3, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat');
insert into remito_in (idRemito_in, empresa, fecha, recibe, cantidad, detalle) values (null, 39, '2023-11-04 03:42:54', 3, 45, 'diam erat fermentum justo nec condimentum neque sapien placerat ante nulla');

-- select * from remito_in;

-- Tabla tipo_elemento
INSERT INTO tipo_elemento (tipo_elemento) VALUES
('manguera'),
('manómetro'),
('bomba'),
('recipiente'),
('molinete');

-- select * from tipo_elemento;

-- Tabla protocolo
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar', 1007, 218, 8305, 33, 288, 489, 383, 747, 67, 983, '712-710-0846', 'consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'https://usatoday.com/mauris/enim/leo/rhoncus.png', 'CO-CAQ', 7, '2024-05-13 22:55:51');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla', 1501, 792, 5213, 58, 200, 499, 677, 642, 1, 376, '937-141-5630', 'in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'http://yolasite.com/sit/amet/consectetuer/adipiscing/elit.xml', 'BR-DF', 6, '2024-09-09 14:30:06');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst', 1672, 138, 4394, 7, 271, 970, 660, 1000, 41, 674, '773-228-4645', 'primis in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://pagesperso-orange.fr/pede/ac/diam/cras/pellentesque.jsp', 'SS-14', 3, '2024-04-01 12:41:17');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa', 1176, 836, 4090, 58, 330, 221, 360, 990, 7, 778, '227-396-1234', 'luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://blogs.com/urna.js', 'US-AZ', 8, '2024-01-13 23:53:51');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'purus phasellus in felis donec semper sapien a libero nam dui proin leo odio porttitor id consequat in', 1975, 649, 4595, 7, 148, 181, 183, 253, 90, 1790, '490-790-7611', 'luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida nisi at', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'http://hatena.ne.jp/a.jpg', 'PK-PB', 9, '2023-10-05 00:09:42');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'sed augue aliquam erat volutpat in congue etiam justo etiam', 1996, 120, 9522, 10, 151, 770, 790, 93, 72, 851, '500-130-1732', 'varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 'http://cbsnews.com/nulla/elit/ac/nulla/sed.json', 'NZ-GIS', 10, '2023-10-26 15:12:19');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam tristique', 1262, 282, 4706, 50, 235, 429, 926, 485, 92, 1414, '622-489-9728', 'blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'http://istockphoto.com/varius/ut/blandit/non/interdum.png', 'LS-C', 6, '2023-11-08 12:44:45');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper', 1389, 66, 5464, 9, 139, 733, 314, 425, 48, 1691, '378-164-3823', 'mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 'https://addtoany.com/iaculis/diam/erat.json', 'AU-QLD', 7, '2023-12-23 13:21:20');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'proin eu mi nulla ac enim in tempor turpis nec', 1768, 628, 9221, 27, 203, 960, 799, 978, 0, 21, '492-408-2885', 'felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://goo.gl/orci/luctus/et.js', 'LR-LO', 1, '2024-02-24 09:48:28');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'aliquam convallis nunc proin at turpis a pede posuere nonummy integer non velit donec diam neque', 1445, 447, 4309, 27, 132, 293, 342, 64, 34, 1768, '115-112-9150', 'fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet massa id lobortis', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'http://apple.com/semper/sapien/a/libero.jpg', 'SZ-LU', 4, '2024-06-29 19:56:35');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis', 1052, 198, 2932, 58, 315, 610, 664, 130, 1, 202, '870-249-6636', 'adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'http://vkontakte.ru/a/suscipit/nulla/elit/ac/nulla.html', 'CA-MB', 8, '2024-05-22 21:43:15');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque', 1248, 834, 3400, 52, 148, 366, 386, 301, 6, 1975, '172-378-0635', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante', 'In congue. Etiam justo. Etiam pretium iaculis justo.', 'https://skyrock.com/auctor/sed/tristique/in/tempus/sit/amet.js', 'US-MN', 4, '2023-10-16 16:29:21');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'rutrum at lorem integer tincidunt ante vel ipsum praesent blandit', 1369, 967, 7817, 33, 331, 688, 896, 414, 66, 1331, '605-270-0015', 'in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://huffingtonpost.com/in/est/risus/auctor/sed/tristique.png', 'CA-ON', 9, '2024-06-21 00:46:48');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'orci eget orci vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio', 1439, 29, 4890, 54, 260, 413, 658, 745, 70, 857, '169-443-0967', 'dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://illinois.edu/suspendisse.xml', 'ZA-MP', 1, '2024-07-08 11:03:54');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam', 1037, 150, 5257, 38, 203, 605, 805, 489, 15, 1790, '315-713-7755', 'rutrum nulla nunc purus phasellus in felis donec semper sapien a', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 'https://state.tx.us/condimentum/id.aspx', 'FR-E', 2, '2024-04-12 14:31:52');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum', 1158, 208, 4622, 59, 228, 430, 909, 502, 18, 434, '216-462-7900', 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'http://php.net/turpis/elementum/ligula/vehicula.json', 'US-AZ', 5, '2023-11-30 08:28:56');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam', 1711, 49, 4015, 5, 320, 779, 757, 72, 54, 1167, '576-168-4066', 'in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'http://cornell.edu/elementum.xml', 'CA-MB', 3, '2024-05-10 13:49:47');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet', 1141, 902, 6826, 56, 287, 628, 451, 747, 50, 1628, '459-253-0262', 'at turpis a pede posuere nonummy integer non velit donec diam', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 'http://cornell.edu/ac/est.js', 'ZM-08', 9, '2023-12-09 14:18:56');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse', 1349, 167, 6201, 46, 172, 560, 573, 846, 25, 987, '745-224-2510', 'lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam nulla integer pede justo lacinia', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'http://oracle.com/mattis/egestas/metus/aenean/fermentum.jsp', 'US-MO', 3, '2024-05-31 15:03:13');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia', 1285, 947, 7633, 34, 233, 141, 748, 282, 77, 968, '984-247-1534', 'in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://cmu.edu/nisl/aenean.js', 'US-MO', 7, '2023-12-11 17:48:38');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'est lacinia nisi venenatis tristique fusce congue diam id ornare', 1418, 386, 5830, 22, 356, 266, 700, 923, 75, 53, '220-553-0529', 'eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'http://1688.com/dui/maecenas/tristique.aspx', 'SE-AB', 9, '2023-12-14 22:00:39');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu', 1173, 253, 8147, 37, 85, 689, 847, 42, 8, 1206, '123-683-7544', 'rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://tamu.edu/at/velit/vivamus/vel/nulla.js', 'NO-18', 4, '2024-09-04 07:56:12');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere', 1201, 111, 8502, 59, 128, 387, 626, 850, 0, 1044, '328-990-9597', 'id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://hugedomains.com/vitae/nisi/nam.xml', 'TR-35', 4, '2023-10-15 20:51:57');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'vel ipsum praesent blandit lacinia erat vestibulum sed magna at', 1670, 217, 3249, 46, 325, 487, 945, 802, 57, 759, '561-473-5110', 'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 'https://soup.io/curabitur/gravida/nisi/at/nibh.jsp', 'NI-AN', 7, '2024-03-01 22:16:09');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor', 1557, 879, 3962, 7, 162, 193, 494, 240, 56, 1184, '865-293-0981', 'ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'http://goo.ne.jp/elementum/ligula/vehicula/consequat/morbi/a/ipsum.aspx', 'PL-KP', 10, '2024-05-03 18:57:29');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget', 1621, 989, 6066, 60, 144, 640, 709, 365, 82, 1508, '489-945-6253', 'pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'https://google.pl/orci.aspx', 'ZA-GT', 3, '2024-04-20 16:18:38');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas', 1902, 61, 8742, 15, 225, 556, 693, 208, 47, 590, '952-635-2972', 'adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'https://soundcloud.com/sed/tincidunt/eu/felis/fusce/posuere/felis.jsp', 'PG-SAN', 10, '2024-03-04 06:14:13');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 1144, 373, 8544, 36, 340, 841, 89, 480, 54, 1221, '151-762-8035', 'sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'http://cloudflare.com/diam/cras/pellentesque.aspx', 'SE-Q', 7, '2024-08-22 01:32:33');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam', 1578, 201, 8831, 33, 72, 53, 599, 657, 47, 674, '827-495-3007', 'nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'https://homestead.com/luctus/nec/molestie/sed/justo/pellentesque/viverra.html', 'LK-3', 10, '2023-10-29 09:23:11');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl', 1331, 276, 9807, 60, 276, 722, 907, 154, 32, 204, '990-457-6671', 'maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'https://live.com/ut/nulla.aspx', 'IN-TN', 5, '2024-03-06 08:31:39');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst', 1527, 75, 3258, 49, 276, 470, 134, 899, 97, 1417, '568-653-5487', 'pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'http://msn.com/ligula.jpg', 'US-IN', 7, '2024-09-13 14:35:02');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit', 1843, 376, 3750, 38, 279, 14, 689, 576, 1, 0, '284-763-9039', 'sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://shinystat.com/proin/interdum/mauris/non/ligula/pellentesque/ultrices.jpg', 'US-FL', 7, '2024-02-24 11:23:15');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros', 1724, 126, 2283, 51, 175, 66, 421, 354, 64, 1029, '526-523-7221', 'felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://domainmarket.com/cum/sociis/natoque/penatibus/et/magnis/dis.html', 'CD-EQ', 1, '2023-10-28 17:02:12');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi', 1200, 972, 8722, 35, 264, 575, 891, 323, 63, 759, '510-623-5625', 'molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'http://posterous.com/nec/sem/duis/aliquam/convallis/nunc.jpg', 'KZ-YUZ', 6, '2023-10-30 17:06:45');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla', 1559, 681, 7654, 40, 146, 15, 83, 1, 82, 1966, '540-366-2465', 'cursus id turpis integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://t.co/interdum/in/ante/vestibulum/ante/ipsum.jpg', 'US-WA', 4, '2024-04-15 12:02:09');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis', 1186, 226, 8836, 3, 230, 683, 466, 70, 78, 1871, '552-865-5085', 'in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'http://qq.com/interdum/mauris/non/ligula/pellentesque/ultrices/phasellus.html', 'CA-QC', 2, '2023-11-08 01:49:00');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris', 1349, 652, 3574, 38, 272, 379, 448, 17, 88, 28, '339-697-8973', 'in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'http://issuu.com/non/quam/nec/dui/luctus/rutrum/nulla.jpg', 'DE-HB', 4, '2024-05-02 09:26:03');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at', 1663, 931, 9434, 44, 313, 252, 838, 369, 92, 1512, '610-839-3797', 'sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'http://mit.edu/tincidunt/ante/vel/ipsum.json', 'AU-WA', 7, '2024-08-31 04:14:30');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae', 1463, 363, 5777, 25, 223, 579, 74, 235, 98, 1812, '315-651-4541', 'ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://smugmug.com/suspendisse.png', 'MY-13', 2, '2024-04-19 10:07:48');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae', 1332, 50, 2463, 13, 303, 910, 453, 502, 77, 1198, '754-200-5421', 'ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'http://multiply.com/et/commodo/vulputate/justo.json', 'US-AK', 4, '2024-02-14 11:56:57');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia', 1672, 105, 7066, 24, 324, 502, 433, 822, 62, 869, '601-855-6621', 'amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 'http://newsvine.com/nec/condimentum/neque/sapien/placerat/ante/nulla.aspx', 'UY-AR', 8, '2024-04-26 00:16:05');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 1, 'varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus', 1732, 686, 8411, 19, 151, 110, 300, 70, 97, 835, '292-551-0727', 'lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 'https://parallels.com/donec/diam/neque.jpg', 'BF-BLG', 10, '2024-06-18 18:26:49');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 5, 'nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque', 1097, 1000, 5840, 57, 315, 902, 72, 228, 40, 880, '916-174-8183', 'tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'http://scientificamerican.com/ut/massa/quis.aspx', 'CA-NT', 10, '2024-07-08 09:16:59');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec', 1124, 753, 8763, 21, 147, 662, 644, 247, 40, 1932, '948-829-5521', 'ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'http://fda.gov/enim/lorem/ipsum/dolor/sit.jpg', 'US-TN', 10, '2024-04-10 10:26:29');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium', 1428, 370, 3554, 10, 257, 334, 129, 695, 76, 924, '104-373-5834', 'consequat morbi a ipsum integer a nibh in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'http://si.edu/scelerisque/mauris/sit/amet/eros/suspendisse/accumsan.html', 'CN-50', 4, '2024-09-03 11:38:43');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt', 1301, 814, 7088, 8, 350, 480, 187, 722, 36, 558, '540-629-4106', 'condimentum neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'https://vistaprint.com/cubilia/curae/donec/pharetra.aspx', 'PH-MAD', 9, '2024-03-17 21:55:31');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi', 1360, 475, 8920, 44, 198, 25, 610, 446, 51, 1268, '873-157-0943', 'etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'http://jimdo.com/quam/suspendisse/potenti/nullam/porttitor/lacus.png', 'US-VA', 2, '2023-11-22 17:37:51');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 4, 'rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta volutpat', 1776, 21, 4454, 59, 222, 242, 590, 136, 46, 527, '952-975-0074', 'nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'https://pinterest.com/duis/at/velit.aspx', 'CD-NK', 4, '2024-06-23 15:17:06');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 2, 'duis ac nibh fusce lacus purus aliquet at feugiat non pretium', 1272, 133, 3691, 55, 266, 244, 758, 665, 68, 160, '683-957-8809', 'faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://instagram.com/risus/auctor/sed/tristique/in/tempus.aspx', 'CA-ON', 9, '2024-04-14 07:27:15');
insert into protocolo (idProtocolo, tipo_elemento, fluido, presion_trabajo, presion_min, presion_max, tiempo_min, tiempo_max, velocidad, caudal, temperatura, humedad, barometrica, coordenadas_gps, observaciones, metodologia, link, norma, recurso, ultima_revision) values (null, 3, 'at nulla suspendisse potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis', 1079, 456, 5634, 30, 302, 731, 224, 207, 65, 1322, '260-364-4040', 'erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://so-net.ne.jp/curabitur.aspx', 'BR-RO', 5, '2024-01-26 08:23:11');

-- select * from protocolo;

-- Tabla ensayo
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-24 01:02:47', 'movil', 26, 47, 25, 42, 20);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-04 04:55:31', 'campo', 36, 34, 27, 20, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-27 06:11:09', 'laboratorio', 33, 5, 28, 45, 21);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-02 19:24:14', 'planta', 40, 37, 8, 16, 28);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-01 19:50:36', 'planta', 4, 42, 10, 36, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-06 11:39:17', 'campo', 34, 39, 3, 41, 40);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-01 08:36:29', 'laboratorio', 16, 24, 8, 17, 25);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-07 07:44:05', 'movil', 43, 6, 32, 30, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-04 04:21:53', 'laboratorio', 17, 10, 4, 48, 11);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-18 02:49:08', 'movil', 20, 19, 49, 17, 5);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-22 09:53:06', 'movil', 2, 20, 9, 47, 9);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-23 09:14:18', 'planta', 27, 25, 14, 48, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-04 05:17:58', 'campo', 23, 10, 32, 3, 28);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-25 00:05:02', 'campo', 45, 7, 37, 48, 6);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-16 04:03:55', 'laboratorio', 40, 2, 8, 44, 1);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-30 11:01:27', 'campo', 49, 4, 23, 35, 48);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-03 07:28:25', 'laboratorio', 8, 50, 28, 26, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-11 12:10:17', 'movil', 12, 36, 43, 16, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-10 18:40:05', 'laboratorio', 16, 49, 32, 16, 3);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-24 15:24:58', 'campo', 42, 48, 1, 27, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-25 20:52:15', 'campo', 1, 25, 38, 19, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-27 14:44:07', 'campo', 43, 40, 20, 20, 17);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-25 11:28:15', 'movil', 48, 2, 15, 10, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-20 18:00:22', 'campo', 19, 40, 9, 24, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-05 05:23:07', 'campo', 3, 10, 44, 6, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-01 02:57:06', 'planta', 26, 34, 20, 3, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-10-01 11:48:07', 'campo', 42, 16, 32, 43, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-23 20:50:51', 'movil', 42, 13, 35, 31, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-22 12:42:19', 'laboratorio', 43, 26, 25, 35, 36);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-14 06:06:34', 'campo', 25, 22, 19, 46, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-25 10:57:13', 'planta', 50, 10, 48, 41, 16);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-08 12:37:04', 'planta', 1, 9, 18, 46, 16);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-29 20:03:01', 'laboratorio', 23, 23, 25, 30, 38);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-01 04:21:34', 'campo', 33, 3, 45, 33, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-06 11:19:18', 'laboratorio', 14, 17, 9, 1, 14);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-06 06:50:55', 'movil', 9, 18, 16, 50, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-15 23:17:23', 'laboratorio', 24, 43, 8, 14, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-06 03:44:15', 'movil', 24, 44, 22, 39, 5);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-04 07:05:58', 'laboratorio', 46, 19, 8, 11, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-28 17:14:28', 'laboratorio', 44, 13, 31, 30, 35);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-07 08:47:57', 'laboratorio', 48, 16, 27, 10, 17);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-23 13:48:44', 'laboratorio', 22, 14, 31, 27, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-07 10:00:48', 'planta', 41, 17, 40, 13, 17);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-14 00:23:51', 'laboratorio', 40, 50, 35, 30, 10);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-08 20:05:08', 'laboratorio', 35, 18, 40, 13, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-05 11:31:18', 'movil', 29, 26, 3, 2, 40);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-22 17:56:20', 'movil', 37, 34, 42, 3, 47);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-29 04:22:19', 'planta', 37, 44, 45, 26, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-20 21:58:29', 'movil', 24, 21, 17, 44, 30);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-29 15:12:52', 'planta', 39, 34, 11, 49, 43);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-26 02:59:59', 'laboratorio', 27, 4, 25, 36, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-10 09:38:52', 'campo', 22, 48, 38, 9, 30);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-04 17:58:19', 'campo', 43, 22, 23, 42, 50);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-03 08:14:16', 'laboratorio', 42, 1, 16, 3, 3);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-01 10:00:48', 'planta', 5, 32, 45, 18, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-23 15:26:20', 'campo', 33, 41, 48, 39, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-08 07:03:09', 'movil', 36, 33, 10, 5, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-09 15:51:52', 'campo', 16, 32, 39, 1, 39);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-10 14:43:46', 'movil', 50, 23, 17, 22, 14);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-26 19:54:18', 'campo', 1, 32, 17, 12, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-09-28 06:53:20', 'laboratorio', 32, 40, 11, 14, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-13 01:05:11', 'movil', 10, 40, 40, 29, 43);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-17 16:20:56', 'campo', 50, 10, 33, 9, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-31 06:11:26', 'planta', 46, 6, 14, 3, 23);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-10 18:04:45', 'movil', 35, 2, 6, 22, 42);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-24 12:39:22', 'planta', 39, 5, 26, 47, 44);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-13 09:56:14', 'movil', 3, 42, 10, 30, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-24 14:41:18', 'laboratorio', 31, 42, 18, 19, 11);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-24 09:43:08', 'laboratorio', 3, 6, 5, 28, 10);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-13 05:37:20', 'laboratorio', 2, 32, 24, 30, 9);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-02-01 21:13:16', 'planta', 48, 31, 43, 44, 40);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-03 15:42:16', 'campo', 31, 3, 8, 14, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-28 20:54:07', 'campo', 50, 50, 42, 25, 42);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-06 21:45:41', 'campo', 14, 35, 20, 17, 18);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-22 19:43:22', 'movil', 47, 38, 23, 33, 31);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-26 09:52:51', 'movil', 11, 11, 45, 36, 49);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-04 08:41:59', 'movil', 21, 45, 35, 50, 29);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-23 17:06:09', 'laboratorio', 39, 16, 38, 7, 27);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-04 03:15:33', 'movil', 47, 26, 30, 38, 48);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-11 11:36:45', 'campo', 32, 32, 19, 9, 25);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-10-19 12:28:38', 'movil', 7, 44, 34, 44, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-04 14:51:18', 'movil', 44, 16, 17, 45, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-16 18:01:48', 'campo', 47, 15, 27, 4, 21);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-11 08:09:57', 'movil', 13, 7, 35, 25, 13);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-14 19:53:12', 'movil', 45, 29, 31, 32, 35);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-04-26 09:45:25', 'laboratorio', 18, 37, 12, 47, 21);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-01-19 18:34:20', 'planta', 31, 25, 2, 24, 33);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-26 13:02:57', 'campo', 45, 41, 42, 36, 35);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-08-28 05:43:39', 'laboratorio', 34, 14, 27, 29, 9);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-22 22:56:33', 'planta', 43, 20, 27, 8, 34);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-19 23:02:10', 'movil', 7, 1, 31, 20, 46);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-01 22:03:31', 'laboratorio', 5, 50, 39, 1, 2);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-18 00:37:15', 'movil', 7, 38, 11, 35, 19);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-11-01 19:20:45', 'movil', 18, 6, 25, 42, 24);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-12 00:51:59', 'planta', 27, 23, 34, 5, 7);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-05-24 07:56:27', 'planta', 42, 33, 47, 13, 12);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-06-21 05:14:11', 'laboratorio', 46, 24, 3, 26, 4);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-07-13 19:41:52', 'planta', 23, 27, 4, 11, 12);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2024-03-18 01:35:14', 'laboratorio', 34, 39, 7, 20, 15);
insert into ensayo (idEnsayo, fecha, locacion, operador1, operador2, operador3, operador4, protocolo) values (null, '2023-12-29 00:59:53', 'campo', 49, 9, 33, 2, 32);

-- select * from ensayo;

-- Tabla certificado
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-09-07 03:23:28', 24, 'quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae', 0, 157, '6252327158', 26, 45, 44, 25, 'https://phpbb.com/dapibus/duis.json');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-30 21:32:15', 15, 'volutpat dui maecenas tristique est et tempus semper est quam pharetra', 1, 51, '9944694460', 42, 26, 25, 20, 'https://feedburner.com/ultrices.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-30 23:44:15', 5, 'mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam', 1, 54, '6683308292', 29, 44, 12, 17, 'http://pinterest.com/odio/justo.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-18 10:30:40', 10, 'nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam', 0, 297, '8791810485', 42, 10, 3, 39, 'https://wikispaces.com/id/pretium/iaculis.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-23 05:09:58', 28, 'mauris non ligula pellentesque ultrices phasellus id sapien in sapien', 0, 132, '2929564784', 29, 42, 24, 45, 'https://constantcontact.com/cubilia.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-03 18:19:51', 45, 'vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget', 0, 75, '4510466080', 50, 25, 18, 46, 'http://dot.gov/pede/posuere/nonummy/integer/non/velit/donec.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-30 08:20:01', 22, 'malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet', 1, 105, '7850014405', 5, 42, 33, 1, 'https://hc360.com/eu/orci/mauris/lacinia/sapien/quis.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-18 16:28:55', 50, 'vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante ipsum primis', 1, 30, '8943676506', 24, 44, 40, 37, 'http://github.com/sit/amet/nunc/viverra/dapibus/nulla.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-29 03:28:15', 36, 'sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in', 1, 295, '9736649687', 31, 38, 44, 48, 'http://apple.com/amet/nulla.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-05-27 22:53:49', 2, 'et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut', 0, 299, '0786041080', 12, 20, 45, 34, 'http://paypal.com/nulla.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-28 20:30:23', 41, 'lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 1, 203, '7883105949', 44, 44, 40, 26, 'https://msu.edu/amet.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-31 06:57:03', 13, 'sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed', 0, 237, '1536201138', 38, 22, 1, 27, 'https://gravatar.com/dolor/sit.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-02 06:06:57', 15, 'justo eu massa donec dapibus duis at velit eu est congue', 1, 291, '5404189282', 36, 22, 12, 35, 'http://cbslocal.com/imperdiet/nullam/orci/pede/venenatis.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-06-22 18:21:14', 13, 'ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum', 0, 329, '7545938976', 27, 27, 29, 38, 'https://sakura.ne.jp/justo/lacinia/eget/tincidunt/eget.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-16 05:49:39', 41, 'leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu', 1, 152, '3985901635', 45, 3, 6, 44, 'https://nationalgeographic.com/non/mauris.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-10 16:22:50', 27, 'nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus', 0, 139, '0479049173', 4, 34, 35, 47, 'http://google.ru/id.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-08-09 01:05:16', 32, 'vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy', 0, 246, '7401986191', 41, 43, 39, 4, 'https://sourceforge.net/velit/nec/nisi/vulputate/nonummy.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-10-02 19:20:55', 28, 'eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a', 1, 79, '7680715750', 37, 23, 10, 37, 'https://moonfruit.com/est/lacinia.json');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-29 06:38:04', 6, 'ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus', 1, 293, '8826473315', 18, 24, 1, 22, 'http://xrea.com/maecenas/ut/massa/quis/augue/luctus.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-06-17 03:39:03', 28, 'eget semper rutrum nulla nunc purus phasellus in felis donec semper', 0, 277, '4106258552', 41, 30, 24, 20, 'http://usatoday.com/sit/amet/erat/nulla/tempus/vivamus/in.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-14 18:50:16', 26, 'vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et', 1, 339, '8891258733', 2, 46, 6, 33, 'http://redcross.org/lobortis/vel/dapibus/at/diam/nam/tristique.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-16 01:22:02', 46, 'potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis', 1, 293, '3633799680', 46, 34, 22, 44, 'https://feedburner.com/amet/eleifend/pede.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-23 12:12:56', 4, 'pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat', 0, 190, '1787685527', 42, 49, 24, 12, 'http://dell.com/facilisi/cras/non/velit.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-15 08:35:44', 14, 'vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque', 0, 281, '7295187367', 46, 11, 31, 43, 'http://unc.edu/quis/turpis/eget/elit/sodales.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-05-26 09:21:47', 5, 'cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus', 1, 341, '3623843393', 18, 12, 29, 8, 'http://istockphoto.com/vulputate/nonummy/maecenas/tincidunt/lacus/at.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-31 05:37:16', 32, 'fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui', 0, 287, '6786149901', 25, 6, 41, 38, 'https://nps.gov/id/pretium/iaculis/diam.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-09-07 10:02:13', 28, 'lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea', 0, 241, '4197065795', 24, 29, 40, 2, 'https://webeden.co.uk/nisi/at/nibh/in.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-12 08:23:21', 34, 'risus auctor sed tristique in tempus sit amet sem fusce consequat nulla', 0, 343, '3317926686', 31, 45, 47, 46, 'http://constantcontact.com/rhoncus/aliquam/lacus/morbi.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-02 21:26:33', 28, 'turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut', 1, 131, '2368252282', 16, 47, 19, 24, 'https://sphinn.com/dolor/sit.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-07-23 21:55:07', 43, 'praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante', 1, 347, '6289988514', 34, 34, 7, 15, 'http://wordpress.org/lectus/pellentesque/at/nulla/suspendisse/potenti.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-10-31 14:36:27', 39, 'potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus', 1, 192, '1807890597', 17, 24, 26, 7, 'http://discovery.com/ipsum/praesent.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-04-05 07:44:01', 36, 'tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi', 1, 316, '0422417343', 12, 4, 29, 23, 'http://thetimes.co.uk/in/tempor/turpis/nec/euismod.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-04-20 17:49:45', 23, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum', 1, 300, '5667060183', 35, 40, 35, 17, 'https://blinklist.com/a/pede/posuere/nonummy/integer/non.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-15 14:33:22', 22, 'eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean', 0, 93, '5993308842', 22, 30, 6, 48, 'http://boston.com/blandit/lacinia/erat.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-09 04:15:50', 50, 'velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla justo aliquam', 1, 289, '2450034595', 9, 41, 39, 11, 'http://amazon.co.uk/porttitor/pede/justo/eu/massa/donec/dapibus.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-06-17 13:32:01', 44, 'leo odio condimentum id luctus nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas', 1, 115, '4904365186', 36, 27, 13, 41, 'http://odnoklassniki.ru/maecenas/tristique/est/et/tempus.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-01-16 18:05:42', 50, 'congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum', 0, 311, '9904739838', 29, 13, 9, 24, 'http://youku.com/ut/odio/cras/mi/pede/malesuada.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-06 22:36:06', 4, 'blandit lacinia erat vestibulum sed magna at nunc commodo placerat', 1, 208, '2549066588', 24, 42, 1, 29, 'http://nyu.edu/sagittis/dui/vel.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-01 10:12:18', 23, 'mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a', 0, 122, '1596386819', 8, 42, 40, 26, 'https://purevolume.com/neque/duis/bibendum/morbi/non/quam/nec.json');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-26 00:22:19', 27, 'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien', 0, 250, '4954462150', 29, 2, 27, 11, 'https://oracle.com/sit/amet/turpis/elementum/ligula.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-12-27 13:50:57', 26, 'semper sapien a libero nam dui proin leo odio porttitor id consequat in consequat', 0, 79, '3380113085', 33, 42, 47, 18, 'http://guardian.co.uk/consequat.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-07-23 17:57:00', 7, 'malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer', 0, 32, '6495887256', 32, 8, 20, 22, 'https://privacy.gov.au/vel/pede/morbi.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-03 14:00:19', 27, 'pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue', 0, 133, '8622677311', 15, 6, 41, 26, 'http://harvard.edu/volutpat/quam/pede.jpg');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-02-03 01:13:07', 41, 'consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius', 1, 143, '6730197447', 10, 42, 12, 34, 'https://psu.edu/eget/nunc.html');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-05-16 10:06:42', 8, 'tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie', 0, 326, '8838441855', 6, 36, 4, 7, 'http://discovery.com/dictumst/morbi/vestibulum/velit/id/pretium.aspx');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-09-30 16:47:22', 40, 'ultrices mattis odio donec vitae nisi nam ultrices libero non', 0, 138, '1811374883', 26, 1, 13, 31, 'https://linkedin.com/elementum/in/hac/habitasse/platea/dictumst.jsp');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-17 15:49:07', 49, 'auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc', 0, 73, '3102902154', 24, 44, 32, 19, 'http://diigo.com/at/turpis/donec.js');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-03-31 00:54:28', 14, 'et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec', 0, 72, '9391557198', 27, 2, 8, 22, 'http://clickbank.net/ultrices/vel/augue/vestibulum/ante.xml');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2023-11-29 19:37:44', 45, 'volutpat sapien arcu sed augue aliquam erat volutpat in congue', 0, 177, '9169825114', 4, 17, 42, 42, 'https://cnn.com/cubilia/curae/duis/faucibus.png');
insert into certificado (idCertificado, fecha, ensayo, observaciones, aptitud, vigencia_dias, precinto, confecciona, revisa, firma1, firma2, link) values (null, '2024-04-07 10:22:10', 10, 'aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna', 0, 184, '8036505436', 27, 15, 26, 32, 'http://angelfire.com/ultrices/posuere/cubilia/curae/mauris.jsp');

-- select * from certificado;

-- Tabla a_facturacion
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-19 02:30:36', 41, 8);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-27 02:20:59', 10, 33);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-15 18:56:35', 20, 29);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-01 20:39:17', 41, 12);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-16 22:26:21', 22, 43);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-07-29 01:08:21', 2, 4);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-22 01:34:01', 37, 46);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-09 20:50:41', 49, 44);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-27 22:26:15', 2, 29);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-26 18:22:19', 46, 38);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-11 00:51:40', 45, 22);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-30 08:33:31', 22, 47);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-06-01 10:28:40', 50, 20);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-22 19:44:47', 28, 19);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-08 06:24:26', 41, 22);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-23 07:09:58', 13, 27);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-01-17 15:05:52', 13, 28);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-01 23:02:46', 44, 21);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-19 06:04:31', 49, 7);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-28 02:56:18', 16, 28);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-26 19:53:29', 38, 33);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-06 08:28:07', 37, 44);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-11 15:31:21', 13, 18);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-07-22 08:26:07', 23, 40);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-05 11:14:26', 42, 17);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-23 21:53:42', 24, 27);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-06-30 21:18:19', 29, 44);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-26 03:36:17', 45, 21);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-30 02:41:16', 28, 28);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-29 04:15:23', 44, 4);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-14 12:13:09', 34, 6);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-09 13:16:44', 49, 23);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-23 09:33:18', 23, 43);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-01-06 01:55:38', 22, 39);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-05-28 15:34:55', 28, 30);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-22 20:00:48', 31, 36);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-01 03:43:15', 20, 15);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-06-04 10:00:30', 35, 7);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-12-07 22:05:01', 37, 2);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-11 16:06:01', 12, 2);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-13 09:23:42', 27, 37);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-02 00:20:05', 24, 12);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-13 05:02:17', 47, 15);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-04-17 08:06:31', 50, 24);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-10-08 08:25:30', 50, 11);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-08-10 11:47:37', 48, 13);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2023-11-17 18:25:35', 24, 24);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-03-14 05:38:02', 10, 47);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-09-19 19:24:34', 25, 16);
insert into a_facturacion (idA_facturacion, fecha, empresa, ref_presupuesto) values (null, '2024-02-26 19:37:54', 44, 15);

-- select * from a_facturacion;

-- Tabla a_facturacion_certificado
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 31, 9);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 43, 33);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 31);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 50);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 25, 1);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 46, 5);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 13);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 49, 43);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 33, 19);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 17, 1);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 7, 25);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 33, 28);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 24, 35);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 16, 33);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 30, 2);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 14, 40);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 40, 31);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 1, 7);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 8, 21);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 35, 31);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 40, 47);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 25, 2);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 42, 41);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 17, 30);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 36, 24);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 45, 3);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 37, 45);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 27, 47);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 40, 43);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 17, 35);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 44, 13);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 2, 36);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 9, 50);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 31, 46);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 29, 9);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 7, 3);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 22, 7);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 15, 10);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 30, 14);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 26, 9);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 24, 27);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 9, 41);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 24, 4);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 4, 25);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 12, 30);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 46, 3);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 27, 28);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 41, 48);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 7, 1);
insert into a_facturacion_certificado (idA_facturacion_certificado, idA_facturacion, idCertificado) values (null, 18, 4);

-- select * from a_facturacion_certificado;

-- Tabla ficha_tecnica
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://blinklist.com/blandit/ultrices/enim/lorem.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://mozilla.org/ipsum/primis/in/faucibus.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://mozilla.com/integer/ac.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://mediafire.com/amet/sem.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://nytimes.com/lacus/curabitur/at/ipsum/ac.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://tripadvisor.com/cubilia/curae/mauris/viverra/diam/vitae/quam.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://whitehouse.gov/consequat/lectus/in/est.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://ustream.tv/bibendum/imperdiet/nullam/orci/pede/venenatis/non.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://ft.com/ante/ipsum/primis/in.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://wisc.edu/in/blandit/ultrices.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://cnet.com/dapibus/at/diam/nam/tristique/tortor.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://istockphoto.com/donec/vitae/nisi/nam/ultrices/libero.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://cam.ac.uk/amet/erat/nulla.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://google.co.jp/adipiscing/molestie/hendrerit/at/vulputate.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://marketwatch.com/nec/dui/luctus.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://earthlink.net/ipsum/ac/tellus/semper/interdum.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://networksolutions.com/luctus/nec/molestie/sed/justo.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://moonfruit.com/nulla/ultrices/aliquet/maecenas/leo/odio/condimentum.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://discuz.net/lacinia/sapien/quis/libero/nullam/sit.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://jimdo.com/platea/dictumst/etiam.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://dyndns.org/sed/justo/pellentesque/viverra.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://webmd.com/potenti/in/eleifend/quam/a.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://shop-pro.jp/in/magna/bibendum/imperdiet/nullam/orci.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://phoca.cz/justo/maecenas/rhoncus.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://sciencedaily.com/donec/ut/mauris.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://blogger.com/eros/elementum/pellentesque.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://eventbrite.com/odio/porttitor/id/consequat.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://squarespace.com/ultrices.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://army.mil/ut/massa.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://edublogs.org/consectetuer/adipiscing/elit.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://printfriendly.com/ipsum/dolor/sit/amet.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://soup.io/duis.jpg');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://newsvine.com/dolor.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://epa.gov/fusce.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://barnesandnoble.com/ac/consequat/metus/sapien/ut/nunc/vestibulum.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://behance.net/in/magna/bibendum/imperdiet/nullam/orci.json');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://guardian.co.uk/consequat/nulla/nisl/nunc/nisl/duis/bibendum.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://google.es/libero.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://phpbb.com/ligula/nec/sem/duis/aliquam.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://wikimedia.org/nulla/eget/eros/elementum/pellentesque/quisque/porta.jpg');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://simplemachines.org/sociis/natoque/penatibus/et/magnis.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://smugmug.com/curabitur/in.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://godaddy.com/nonummy/maecenas.js');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://tripod.com/aliquet/ultrices/erat/tortor.html');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://who.int/praesent/blandit/lacinia/erat.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://dell.com/ut/volutpat/sapien/arcu/sed/augue.xml');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://weebly.com/duis/faucibus/accumsan/odio/curabitur.aspx');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'https://merriam-webster.com/cras/mi/pede/malesuada/in.png');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://ucla.edu/volutpat/convallis/morbi/odio/odio/elementum.jsp');
insert into ficha_tecnica (idFicha_tecnica, link) values (null, 'http://photobucket.com/sollicitudin/vitae/consectetuer.html');

-- select * from ficha_tecnica;

-- Tabla remito_out
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (1, 15, '2024-03-09 01:00:34', 28, 58, 'id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem fusce consequat');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (2, 35, '2023-12-14 14:19:34', 14, 43, 'sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (3, 8, '2023-11-23 17:46:47', 9, 11, 'massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet et commodo');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (4, 30, '2023-12-07 13:15:03', 27, 8, 'cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (5, 48, '2024-07-13 17:21:18', 4, 19, 'posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (6, 42, '2024-02-14 14:04:48', 50, 3, 'rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (7, 7, '2024-06-07 08:11:52', 43, 69, 'at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (8, 48, '2024-07-30 06:49:55', 17, 5, 'aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (9, 39, '2024-01-27 08:32:00', 25, 33, 'elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (10, 43, '2023-10-03 11:52:47', 30, 5, 'curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (11, 12, '2024-01-21 07:17:45', 17, 42, 'urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (12, 20, '2024-06-22 19:33:19', 20, 82, 'justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (13, 32, '2024-09-29 13:31:43', 48, 19, 'mi integer ac neque duis bibendum morbi non quam nec dui luctus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (14, 31, '2024-07-30 09:47:21', 14, 83, 'sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (15, 22, '2024-03-21 19:46:57', 14, 49, 'pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (16, 38, '2024-04-23 13:59:17', 2, 16, 'ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (17, 36, '2024-01-19 01:28:07', 17, 18, 'et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (18, 3, '2023-12-30 21:41:53', 46, 95, 'dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (19, 41, '2024-08-08 21:12:16', 11, 69, 'est phasellus sit amet erat nulla tempus vivamus in felis');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (20, 36, '2024-07-27 17:10:50', 46, 23, 'penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (21, 6, '2024-09-18 09:03:14', 40, 51, 'curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (22, 40, '2024-07-01 06:57:37', 14, 86, 'nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (23, 40, '2024-03-14 23:48:21', 6, 18, 'nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (24, 40, '2024-08-05 08:27:28', 29, 84, 'ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula in lacus');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (25, 23, '2024-03-01 14:48:41', 41, 12, 'id pretium iaculis diam erat fermentum justo nec condimentum neque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (26, 17, '2024-04-05 09:21:45', 39, 30, 'sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (27, 22, '2023-12-29 02:24:30', 7, 2, 'risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (28, 20, '2023-10-30 03:29:47', 46, 64, 'justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (29, 34, '2024-07-29 13:37:20', 23, 1, 'integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (30, 10, '2024-09-01 01:32:41', 19, 13, 'bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (31, 34, '2023-12-05 12:29:25', 11, 100, 'in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (32, 29, '2024-04-28 19:04:27', 42, 85, 'dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (33, 43, '2024-09-27 01:06:21', 31, 68, 'in hac habitasse platea dictumst maecenas ut massa quis augue');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (34, 11, '2023-11-30 10:38:21', 40, 7, 'mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate nonummy maecenas');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (35, 12, '2023-11-03 19:38:17', 33, 44, 'consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (36, 44, '2023-10-08 19:01:42', 32, 44, 'posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (37, 31, '2024-02-12 04:44:27', 5, 99, 'est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (38, 4, '2024-05-10 08:52:10', 23, 83, 'sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (39, 49, '2024-01-19 10:36:06', 34, 57, 'in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (40, 36, '2024-03-18 03:19:14', 42, 35, 'nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (41, 49, '2024-07-27 17:12:31', 32, 23, 'magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (42, 11, '2024-08-18 02:33:54', 24, 52, 'sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (43, 38, '2024-02-07 10:41:21', 42, 94, 'sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (44, 39, '2024-05-14 01:59:38', 38, 21, 'pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa volutpat');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (45, 44, '2024-05-02 16:59:45', 37, 77, 'tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (46, 1, '2023-12-22 13:01:25', 42, 99, 'ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel dapibus at diam nam');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (47, 3, '2024-09-04 03:00:33', 3, 89, 'ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (48, 46, '2024-08-25 06:35:14', 48, 33, 'nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (49, 2, '2024-03-02 23:49:23', 1, 4, 'amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non');
insert into remito_out (idRemito_out, empresa, fecha, envia, cantidad, detalle) values (50, 49, '2024-05-06 12:05:20', 32, 32, 'vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit');

-- select * from remito_out;

-- Tabla status_elemento
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'caduco');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'ingresado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'enviado');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'en ensayo');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');
insert into status_elemento (idStatus_elemento, status_elemento) values (null, 'apto');

-- select * from status_elemento;

-- Tabla elemento
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 4, '2179272480', '9699510641', 28, 39, 9, 26, 31, 'ac lobortis vel dapibus at diam nam tristique tortor eu', 6, 47);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 3, '1262835801', '1511536497', 22, 8, 41, 35, 43, 'scelerisque mauris sit amet eros suspendisse', 16, 17);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 5, '1961018918', '9884873194', 37, 33, 28, 25, 44, 'nullam molestie nibh in lectus pellentesque', 42, 17);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 3, '8164238309', '2535953099', 31, 14, 44, 49, 19, 'enim blandit mi in porttitor pede justo eu massa', 29, 40);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 3, '0036109452', '4036182730', 25, 12, 35, 43, 12, 'sit amet eros suspendisse accumsan tortor quis turpis', 50, 15);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 3, '0606413464', '8370131840', 44, 12, 34, 9, 50, 'a nibh in quis justo maecenas rhoncus aliquam lacus', 11, 17);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 2, '0117728071', '6260156464', 18, 41, 34, 1, 1, 'vitae nisi nam ultrices libero', 16, 42);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 3, '8141217429', '1628892587', 42, 7, 40, 30, 36, 'ut at dolor quis odio consequat varius', 6, 15);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 4, '0040373754', '7704771051', 48, 35, 41, 46, 8, 'mauris vulputate elementum nullam varius nulla facilisi cras', 30, 22);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 1, '0499299744', '3813746852', 24, 35, 4, 16, 25, 'posuere cubilia curae mauris viverra diam', 5, 19);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 1, '9435666639', '3600187589', 14, 43, 2, 38, 21, 'odio in hac habitasse platea dictumst', 34, 4);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 3, '7927154230', '9823539340', 4, 43, 3, 38, 39, 'justo morbi ut odio cras mi pede malesuada in imperdiet', 44, 9);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 2, '1368512348', '7756199200', 46, 45, 15, 50, 34, 'eu orci mauris lacinia sapien', 7, 32);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 4, '7664020158', '0127300627', 16, 9, 31, 26, 15, 'vulputate justo in blandit ultrices enim lorem ipsum dolor', 18, 29);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 4, '3819354123', '5081573345', 33, 6, 7, 38, 5, 'consequat nulla nisl nunc nisl duis bibendum', 19, 22);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 1, '1887711759', '2702017916', 34, 38, 48, 47, 29, 'ultrices erat tortor sollicitudin mi sit amet', 25, 48);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 1, '8987497380', '5921119954', 18, 33, 31, 14, 14, 'magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis', 43, 41);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 3, '0576508098', '5000750063', 27, 29, 32, 31, 42, 'in felis donec semper sapien a libero nam dui', 44, 43);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 3, '5300074950', '3354810475', 41, 11, 8, 9, 9, 'sed ante vivamus tortor duis mattis egestas metus aenean fermentum', 20, 41);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 2, '0619740485', '6502049370', 20, 22, 32, 28, 30, 'nec condimentum neque sapien placerat ante nulla', 9, 6);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 1, 3, '5660645410', '5948386120', 18, 7, 5, 40, 4, 'ut mauris eget massa tempor convallis', 39, 5);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 5, '2805523318', '8415131364', 26, 16, 3, 50, 40, 'dictumst etiam faucibus cursus urna ut', 14, 18);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 4, '1434416658', '0895842394', 35, 50, 21, 50, 47, 'donec dapibus duis at velit', 45, 35);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 2, '8861682081', '3224039396', 8, 20, 16, 38, 11, 'justo sollicitudin ut suscipit a feugiat et eros vestibulum ac', 46, 38);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 2, '3184189902', '4350661654', 42, 28, 21, 36, 23, 'fermentum justo nec condimentum neque sapien placerat ante nulla justo', 47, 40);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 3, '6975656339', '9850492074', 17, 9, 25, 23, 20, 'nec nisi volutpat eleifend donec ut dolor morbi vel', 15, 45);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 5, '4177317349', '5811941064', 25, 21, 41, 26, 38, 'cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor', 18, 18);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 2, '8741582128', '7593064921', 1, 26, 44, 42, 16, 'nulla pede ullamcorper augue a suscipit nulla elit ac', 22, 23);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 1, '8162633235', '8295903292', 19, 37, 4, 28, 48, 'non ligula pellentesque ultrices phasellus id sapien in sapien', 21, 11);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 5, '9034018024', '5005112294', 43, 44, 29, 28, 2, 'in faucibus orci luctus et ultrices posuere', 4, 6);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 4, '0192431358', '2368289127', 35, 12, 24, 48, 46, 'est phasellus sit amet erat nulla tempus vivamus in', 35, 29);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 1, 1, '3226363980', '5219729454', 16, 3, 31, 29, 10, 'sapien sapien non mi integer ac neque', 34, 50);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 3, '9166773032', '8091658621', 25, 39, 40, 33, 45, 'congue elementum in hac habitasse platea dictumst', 22, 30);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 1, '5115008149', '5530180140', 21, 3, 18, 1, 7, 'leo odio porttitor id consequat in consequat ut nulla', 29, 26);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 2, '9356158991', '9257888436', 35, 6, 33, 17, 32, 'cursus urna ut tellus nulla ut', 37, 1);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 1, '5243236942', '5061831896', 41, 39, 33, 38, 22, 'id ligula suspendisse ornare consequat lectus', 9, 12);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 1, 4, '4073157485', '2998919456', 20, 15, 6, 8, 33, 'tortor sollicitudin mi sit amet lobortis sapien sapien non mi', 9, 38);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 4, '8918219350', '9230334936', 48, 49, 42, 43, 17, 'justo morbi ut odio cras mi', 21, 3);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 3, '7719119096', '9092740764', 41, 1, 35, 21, 13, 'morbi vestibulum velit id pretium iaculis diam erat fermentum', 9, 49);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 1, '4160659357', '6997320260', 16, 44, 2, 2, 28, 'sit amet consectetuer adipiscing elit', 1, 45);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 2, '5308481725', '2384835351', 43, 25, 31, 7, 24, 'maecenas tristique est et tempus semper est quam pharetra', 39, 27);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 2, 4, '9945836870', '7284702966', 36, 45, 25, 43, 18, 'volutpat quam pede lobortis ligula sit amet eleifend', 20, 30);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 5, '2633470963', '8746193375', 7, 39, 37, 41, 35, 'pellentesque at nulla suspendisse potenti cras in purus', 46, 9);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 3, '1865814814', '7370637999', 45, 9, 27, 32, 6, 'amet nulla quisque arcu libero rutrum ac lobortis', 25, 49);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 5, '1575316137', '6131308136', 29, 29, 30, 8, 41, 'eros suspendisse accumsan tortor quis turpis sed ante', 19, 17);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 3, '3203268213', '1721557148', 7, 33, 6, 13, 49, 'ultrices vel augue vestibulum ante ipsum primis in faucibus', 11, 45);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 3, 2, '5506848870', '3457743045', 16, 8, 14, 11, 26, 'vel dapibus at diam nam', 39, 31);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 5, 1, '8545323611', '1832929582', 4, 40, 12, 25, 37, 'ut suscipit a feugiat et eros vestibulum', 24, 35);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 3, '6066285947', '8930296998', 46, 48, 39, 33, 27, 'odio in hac habitasse platea dictumst maecenas ut massa', 23, 3);
insert into elemento (idElemento, tipo_elemento, status_elemento, tag_original, precinto, presupuesto, remito_in, ficha_tecnica, ensayo, certificado, observaciones, a_facturacion, remito_out) values (null, 4, 3, '2976048886', '0825167760', 12, 14, 44, 41, 3, 'diam neque vestibulum eget vulputate', 46, 24);

-- select * from elemento;

/*
Se crea una VISTA para obtener la lista de personas que participaron del úiltimo ensayo del Laboratorio,
para que puedan ser notificados por mail que entran en un ciclo de descanso de este tipo de trabajo 
por el período que indique la gerencia operativa ( cronograma de turno rotativo ).
*/


CREATE OR REPLACE VIEW ultimo_turno_trabajadores_ensayo AS
SELECT
    E.idEnsayo AS Nro_Ensayo, 
    E.fecha AS Fecha, 
    CONCAT(P1.nombre, ' ', P1.apellido) AS STAFF_1, 
    P1.legajo AS Legajo_1,
    P1.funcion AS Funcion_1,
    P1.mail AS mail_1,
    CONCAT(P2.nombre, ' ', P2.apellido) AS STAFF_2, 
    P2.legajo AS Legajo_2,
    P2.funcion AS Funcion_2,
    P2.mail AS mail_2,
    CONCAT(P3.nombre, ' ', P3.apellido) AS STAFF_3,
    P3.legajo AS Legajo_3,
    P3.funcion AS Funcion_3,
    P3.mail AS mail_3,
    CONCAT(P4.nombre, ' ', P4.apellido) AS STAFF_4, 
    P4.legajo AS Legajo_4,
    P4.funcion AS Funcion_4,
    P4.mail AS mail_4
FROM 
    ensayo AS E
LEFT JOIN personal AS P1 ON E.operador1 = P1.idPersonal
LEFT JOIN personal AS P2 ON E.operador2 = P2.idPersonal
LEFT JOIN personal AS P3 ON E.operador3 = P3.idPersonal
LEFT JOIN personal AS P4 ON E.operador4 = P4.idPersonal
ORDER BY E.fecha DESC
LIMIT 1;

SELECT * FROM ultimo_turno_trabajadores_ensayo;


/* Se genera una VISTA para listar los certificados emitidos por el Laboratorio
con el fin de contar con una memoria de los trabajos realizados
independientemente si los elementos superaron satisfactoriamente los ensayos
*/

CREATE OR REPLACE VIEW listado_elementos_certificados_emitidos AS
SELECT 
	E.Certificado,
    TP.tipo_elemento,
    E.idElemento,
    E.tag_original,
    E.precinto
    FROM 
    elemento AS E
INNER JOIN 
    tipo_elemento AS TP ON E.tipo_elemento = TP.idTipo_elemento
order by E.Certificado asc;

select * from listado_elementos_certificados_emitidos;


/* Se genera una VISTA para informar al sector de Calidad
sobre los elementos que no resultaron APTOS 
para que no se le asignen nuevos precintos 
*/

CREATE OR REPLACE VIEW elementos_rechazados AS
SELECT 
    E.idElemento,
    E.tag_original,
    E.precinto,
    C.idCertificado AS Nro_Certificado,
    C.fecha AS Fecha,
    C.observaciones AS Observaciones,
    C.aptitud
FROM 
    elemento AS E
LEFT JOIN 
    certificado AS C ON E.certificado = C.idCertificado
WHERE 
    C.aptitud =0;
    
select * from elementos_rechazados;
    
/*
Con esta VISTA se pretende comunicar por mail a todos los usuarios supervisores, técnicos y personal de mantenimiento
un material de difusión del Laboratorio respecto a la posibilidad de certificar bajo una nueva norma de CALIDAD
*/
    

CREATE OR REPLACE VIEW anuncio_circular_tecnica_NORMA_CALIDAD AS
select U.nombre,U.apellido,U.email,E.nombre AS 'Empresa',CE.cargo_empresa 
from usuario AS U 
left join empresa as E
on U.empresa = E.idEmpresa
left join cargo_empresa as CE
on U.cargo_empresa = CE.idCargoEmpresa
WHERE CE.cargo_empresa IN ('supervisor','técnico','mantenimiento','calidad')
order by U.empresa, CE.cargo_empresa
;

select * from anuncio_circular_tecnica_NORMA_CALIDAD;

/*
Tercera Parte del TRABAJO PRACTICO EVOLUTIVO

Funciones

*/

/*
Se desea invitar a todos los clientes (usuarios) del Laboratorio
a un evento a fin de año para celebrar nuestro 10 aniversario en el rubro.
Se enviarán las tarjetas personalizadas a las distintas empresas a participar 
*/

DROP FUNCTION IF EXISTS get_nombre_empresa;

DELIMITER $$
CREATE FUNCTION get_nombre_empresa (p_empresa INT)
RETURNS VARCHAR(255)

READS SQL DATA

BEGIN
    DECLARE resultado VARCHAR(255);
    SET resultado = (SELECT nombre FROM empresa WHERE idEmpresa = p_empresa);
    RETURN resultado;
END
$$

DROP FUNCTION IF EXISTS get_cargo_empresa;

DELIMITER $$
CREATE FUNCTION get_cargo_empresa (p_cargo_empresa INT)
RETURNS VARCHAR(255)

READS SQL DATA
BEGIN
    DECLARE retorno VARCHAR(255);
    SET retorno = (SELECT cargo_empresa FROM cargo_empresa WHERE idCargoEmpresa = p_cargo_empresa);
    RETURN retorno;
END
$$

SELECT nombre, apellido, get_nombre_empresa(empresa) as 'Empresa', get_cargo_empresa(cargo_empresa) as 'Cargo',email FROM usuario order by empresa,cargo_empresa;

/*
El departamento comercial lanza una promoción para todos los presupuestos realizados en el año 2024,
donde se otorga un beneficio de acuerdo a la forma de pago. Se establece que para la cancelación con transferencia
amplía el plazo a 90 días, si abona con tarjeta es de 60 y en caso de utilizar cheque, se reduce a 30.
*/


DROP FUNCTION IF EXISTS promo2024;

DELIMITER $$

CREATE FUNCTION promo2024 (p_forma_pago VARCHAR(50))
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE beneficio VARCHAR(50);

    IF p_forma_pago = 'transferencia' THEN
        SET beneficio = 'Plazo: 90 días';
    ELSEIF p_forma_pago = 'tarjeta' THEN
        SET beneficio = 'Plazo: 60 días';
    ELSEIF p_forma_pago = 'cheque' THEN
        SET beneficio = 'Plazo: 30 días';
    END IF;

    RETURN beneficio;
END $$

SELECT idPresupuesto, get_nombre_empresa(empresa) AS 'Empresa', fecha, forma_pago, promo2024(forma_pago) AS 'Beneficio_promo2024'
FROM presupuesto where fecha >= '2024-01-01' order by Beneficio_promo2024 desc ;

/*
Tercera Parte del TRABAJO PRACTICO EVOLUTIVO

Store Procedure

*/

use servicios_terceros_lh;

/*
Se necesita realizar un listado de los usuarios inactivos para depurar la base de datos.
Previo a la eliminación se les enviará un mail con una invitación o una encuesta
con el objeto de revincularlos a la plataforma.
El procedimiento permitirá tomar como variable la cantidad de días deseado como corte anterior a la fecha actual
en que se realiza la consulta
*/

select * from usuario where last_session <= (now());

-- DROP PROCEDURE usuario_inactivo;

DELIMITER $$

CREATE PROCEDURE usuario_inactivo (IN dias_inactividad INT)
BEGIN
	DECLARE fecha_limite DATE;
	SET fecha_limite = DATE_SUB(CURDATE(), INTERVAL dias_inactividad DAY);
    SELECT 	nombre, apellido, email, last_session, now() as FECHA_HOY FROM usuario WHERE last_session < fecha_limite AND activacion > 0;
END
$$

-- se ingresa la cantidad de días a partir de la cual se considera inactivo
CALL usuario_inactivo(365);

/*
Se desea realizar un listado de los certificados próximos a caducar, ya que el personal
comenzará a tomar vacaciones y es necesario preveer una guardia para atender las necesidades de los clientes
en este período del año. El procedimiento contempla la cantidad de días a partir del día de la consulta del operador
*/

SELECT * FROM certificado;

-- DROP PROCEDURE certificado_proximo_a_vencer;

DELIMITER $$

CREATE PROCEDURE certificado_proximo_a_vencer (IN dias_a_cubrir INT)
BEGIN
    SELECT 
        idCertificado,
        fecha,
        ensayo,
        aptitud,
        vigencia_dias,
        precinto,
        DATE_ADD(fecha, INTERVAL vigencia_dias DAY) AS fecha_vencimiento,
        now() as FECHA_HOY
    FROM certificado
    WHERE DATE_ADD(fecha, INTERVAL vigencia_dias DAY) BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL dias_a_cubrir DAY) AND aptitud > 0;

END
$$

-- días a preveer de vencimientos de certificados para organizar esquema de licencias del personal
CALL certificado_proximo_a_vencer (30);

/*
Tercera Parte del TRABAJO PRACTICO EVOLUTIVO

Triggers

*/

/* El procedimiento tiene por objeto validar el ingreso del DNI de un nuevo usuario
para evitar 0 y números negativos. Un mensaje de error aparece cuando se quebranta la regla.
*/

DROP TRIGGER IF EXISTS comprobar_DNI;

DELIMITER //

CREATE TRIGGER comprobar_DNI
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF NEW.dni <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI debe ser un valor positivo';
    END IF;
END //
DELIMITER ;

select * from usuario;

/*
Para verificar su funcionamiento, favor de ejecutar

//////////////////////////////////////////////////////////////////
INSERT INTO usuario (dni) VALUES (0);  -- para que genere error
select * from usuario;
INSERT INTO usuario (dni) VALUES (-1);  -- para que genere error
select * from usuario;
//////////////////////////////////////////////////////////////////

*/

DELIMITER //

CREATE TRIGGER trigger_bonificacion_precio_unitario
BEFORE INSERT ON COTIZACION
FOR EACH ROW
BEGIN
    -- Verificar la cantidad y aplicar el descuento al precio_unitario
    IF NEW.cantidad >= 10 THEN
        SET NEW.precio_unitario = NEW.precio_unitario * 0.80; -- 20% de bonificación
    ELSEIF NEW.cantidad >= 5 THEN
        SET NEW.precio_unitario = NEW.precio_unitario * 0.85; -- 15% de bonificación
    ELSEIF NEW.cantidad >= 1 THEN
        SET NEW.precio_unitario = NEW.precio_unitario * 0.90; -- 10% de bonificación
    END IF;

    -- Actualizar el total basado en el precio_unitario modificado
    SET NEW.total = NEW.precio_unitario * NEW.cantidad;
    
END//
DELIMITER ;
select * from cotizacion;





/*
El Laboratorio desea crear un historial de precios por los servicios cotizados
para ver su evolución y analizar la estacionalidad de algunos insumos.
*/

CREATE TABLE IF NOT EXISTS historial_precios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCotizacion INT,
    precio_unitario FLOAT,
    fecha DATE,
    FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion)
);

DELIMITER //

CREATE TRIGGER registrar_historial_precio
AFTER UPDATE ON cotizacion
FOR EACH ROW
BEGIN
    
    IF OLD.precio_unitario != NEW.precio_unitario THEN
        INSERT INTO historial_precios (idCotizacion, precio_unitario, fecha)
        VALUES (NEW.idCotizacion, NEW.precio_unitario, CURDATE());
    END IF;
END //
DELIMITER ;

SELECT *FROM cotizacion where idCotizacion = 1;

UPDATE cotizacion
SET precio_unitario = 14000
WHERE idCotizacion = 1;

SELECT * FROM cotizacion where idCotizacion = 1;

SELECT * FROM historial_precios;

/*
El Laboratorio desea crear un bono o beneficio para su personal por productividad.
Para ello se diseña un trigger, con el fin de registrar en una tabla su participación 
cada vez que se realiza un ensayo. Luego se podría agruparlos por fecha, cantidad u otro criterio para efectivilizarlo.
*/


CREATE TABLE IF NOT EXISTS registro_operadores_ensayos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    operador_id INT,
    fecha_ensayo DATETIME,
    FOREIGN KEY (operador_id) REFERENCES personal(idPersonal)
);

DROP TRIGGER IF EXISTS registrar_operadores_ensayo;

DELIMITER //
CREATE TRIGGER registrar_operadores_ensayo
AFTER INSERT ON ensayo
FOR EACH ROW
BEGIN
    
    IF NEW.operador1 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador1, NEW.fecha);
    END IF;

    IF NEW.operador2 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador2, NEW.fecha);
    END IF;

    IF NEW.operador3 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador3, NEW.fecha);
    END IF;

    IF NEW.operador4 IS NOT NULL THEN
        INSERT INTO registro_operadores_ensayos (operador_id, fecha_ensayo)
        VALUES (NEW.operador4, NEW.fecha);
    END IF;
END //

DELIMITER ;
-- TRUNCATE TABLE registro_operadores_ensayos;

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-03 09:41:00', 'planta', 43, 19, 2, 6, 44);

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-04 12:34:00', 'movil', 24, 9, 45, 42, 27);

INSERT INTO ensayo (fecha, locacion, operador1, operador2, operador3, operador4, protocolo)
VALUES ('2024-11-05 08:12:00', 'laboratorio', 34, 2, 11, 28, 6);

SELECT * FROM registro_operadores_ensayos;

/*
Se desea realizar el módulo de auditoría para verificar modificaciones en las cotizaciones.
Es necesario incoporar la columna cotizador a la tabla para luego poder utilizar ese dato
en una tercera donde registrará la actividad del mismo en este sector que es tan sensible
en la rentabilidad del negocio.
*/

-- Agrego columna cotizador a la tabla cotizacion
ALTER TABLE cotizacion
ADD COLUMN cotizador INT;

-- Agrego clave foránea para que cotizador esté relacionado con idPersonal de la tabla personal
ALTER TABLE cotizacion
ADD CONSTRAINT fk_cotizador
FOREIGN KEY (cotizador) REFERENCES personal(idPersonal);

select * from cotizacion;

-- para el ejemplo, trabajaremos para cotizaciones que ingresen a partir del id= 50

DROP TABLE IF EXISTS auditoria_cotizaciones;

CREATE TABLE auditoria_cotizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCotizacion INT,
    fecha_actualizacion DATETIME,
    idCotizador INT,  -- Personal que realizó la actualización (cotizador), el que modifica
    accion VARCHAR(50), -- Tipo de acción: 'Actualización'
    idCotizador_OLD INT, -- antigüo cotizador
    cantidad INT,
    detalle_cotizacion INT,
    precio_unitario FLOAT,
    valor_dolar FLOAT,
    total FLOAT,
    observaciones varchar(255),
    FOREIGN KEY (idCotizacion) REFERENCES cotizacion(idCotizacion),
    FOREIGN KEY (idCotizador) REFERENCES personal(idPersonal)
);

DROP TRIGGER IF EXISTS registrar_auditoria_cotizacion;

DELIMITER //

CREATE TRIGGER registrar_auditoria_cotizacion
AFTER UPDATE ON cotizacion
FOR EACH ROW
BEGIN
    -- Insertar en la tabla de auditoría con la fecha de actualización, el cotizador y la cotización anterior, ya que la actualizada 
    -- estará en la tabla disponible
    
    INSERT INTO auditoria_cotizaciones (idCotizacion, fecha_actualizacion, idCotizador, accion, idCotizador_OLD, cantidad,
    detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones)
    VALUES (OLD.idCotizacion, NOW(), NEW.cotizador, 'Actualización', OLD.cotizador, OLD.cantidad,
    OLD.detalle_cotizacion, OLD.precio_unitario, OLD.valor_dolar, OLD.total, OLD.observaciones);
END //
DELIMITER ;

-- inserción de ejemplos
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 11, 8, 497, 1286, 59517, 'nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh',1);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 4, 2, 1782, 1300, 14613, 'vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi',3);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 18, 5, 4346, 1076, 62181, 'nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta',5);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 4, 10, 4998, 1223, 47851, 'elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus',4);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 8, 6, 2329, 1339, 84743, 'eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat',7);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 2, 3, 4763, 1487, 28111, 'eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc',8);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 29, 2, 1596, 1029, 1062, 'suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero',8);
insert into cotizacion (idCotizacion, cantidad, detalle_cotizacion, precio_unitario, valor_dolar, total, observaciones, cotizador) values (null, 74, 2, 7694, 1445, 10915, 'tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue',1);

-- disparo trigger

UPDATE cotizacion
SET cantidad = 110, precio_unitario = 115.00, cotizador = 6
WHERE idCotizacion = 51;

UPDATE cotizacion
SET cantidad = 225, precio_unitario = 124.00, cotizador = 8
WHERE idCotizacion = 54;

UPDATE cotizacion
SET cantidad = 96, precio_unitario = 88.00, cotizador = 4
WHERE idCotizacion = 55;

select * from auditoria_cotizaciones;
-- select * from cotizacion;

-- select * from cotizacion where idCotizacion > 50;

-- truncate table auditoria_cotizaciones;

-- Miguel Flores   ####    miguelflores.devops@gmail.com