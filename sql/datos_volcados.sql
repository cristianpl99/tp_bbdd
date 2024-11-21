-- Inserción en la tabla cliente
insert into  cliente (id_cliente, nombre, apellido, dni, fecha_nacimiento, telefono, email) values
(1, 'Ken', 'Thompson', '5153057', '1995-05-05 00:00:00', '15-2889-7948', 'ken@thompson.org'),
(2, 'Dennis', 'Ritchie', '25610126', '1955-04-11 00:00:00', '15-7811-5045', 'dennis@ritchie.org'),
(3, 'Donald', 'Knuth', '9168297', '1984-04-05 00:00:00', '15-2780-6005', 'don@knuth.org'),
(4, 'Rob', 'Pike', '4915593', '1946-08-16 00:00:00', '15-1114-9719', 'rob@pike.org'),
(5, 'Douglas', 'McIlroy', '33187055', '1939-06-09 00:00:00', '15-9625-0245', 'douglas@mcilroy.org'),
(6, 'Brian', 'Kernighan', '13897948', '1992-11-22 00:00:00', '15-6410-6066', 'brian@kernighan.org'),
(7, 'Bill', 'Joy', '34115045', '1954-02-04 00:00:00', '15-4215-8655', 'bill@joy.org'),
(8, 'Marshall Kirk', 'McKusick', '9806005', '1995-12-27 00:00:00', '15-5197-4379', 'marshall_kirk@mckusick.org'),
(9, 'Theo', 'de Raadt', '5149719', '1950-02-07 00:00:00', '15-6470-9444', 'theo@deraadt.org'),
(10, 'Cristina', 'Kirchner', '6250245', '1990-08-17 00:00:00', '15-5291-0113', 'cfk@fpv.gov.ar'),
(11, 'Diego', 'Maradona', '19158655', '1985-02-27 00:00:00', '15-3361-4854', 'diego@dios.com.ar'),
(12, 'Martín', 'Palermo', '5974379', '1918-06-09 00:00:00', '15-9877-3169', 'martin@palermo.com.ar'),
(13, 'Guillermo', 'Barros Schelotto', '3910113', '1982-05-03 00:00:00', '15-5020-5695', 'guille@melli.com.ar'),
(14, 'Susú', 'Pecoraro', '7547862', '1935-04-03 00:00:00', '15-6695-9505', 'susu@pecoraro.com.ar'),
(15, 'Norma', 'Aleandro', '26614854', '1992-03-18 00:00:00', '15-9155-4115', 'norma@aleandro.com.ar'),
(16, 'Soledad', 'Silveyra', '7773169', '1957-07-28 00:00:00', '15-9184-4522', 'sole@silveyra.com.ar'),
(17, 'Libertad', 'Lamarque', '32205695', '1971-03-07 00:00:00', '15-6363-9690', 'libertad@lamarque.com.ar'),
(18, 'Ana María', 'Picchio', '19020903', '1946-08-06 00:00:00', '15-4819-2117', 'ana.maria@picchio.com.ar'),
(19, 'Niní', 'Marshall', '10535508', '1951-09-07 00:00:00', '15-9799-6045', 'nini@marshall.com'),
(20, 'Claudia', 'Lapacó', '30934609', '1961-08-03 00:00:00', '15-2005-4879', 'claudia@lapaco.com.ar');

-- Inserción en la tabla operadore
insert into operadore (id_operadore, nombre, apellido, dni, fecha_ingreso, disponible) values
(1, 'Wilhelm', 'Steinitz', '5053058', '2018-05-14 00:00:00', true),
(2, 'Emanuel', 'Lasker', '24610127', '2018-12-24 00:00:00', true),
(3, 'Jose Raul', 'Capablanca', '9068298', '2019-11-19 00:00:00', true);
