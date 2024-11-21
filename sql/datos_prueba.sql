-- Inserción en la tabla datos_de_prueba
insert into  datos_de_prueba (id_orden, operacion, id_cliente, id_cola_atencion, tipo_tramite, descripcion_tramite, id_tramite, estado_cierre_tramite, respuesta_tramite) values
(1, 'nuevo llamado', 21, null, '', '', null, '', '?id de cliente no válido'), 
--chequear que tabla error registre esto OK
(2, 'nuevo llamado', 4, null, '', '', null, '', 'nueva fila id 1 en espera'),
--chequea cola atencion agregue esto OK
(3, 'atencion llamado', null, null, '', '', null, '', 'act fila id 1 estado en linea'),
--chequear actualizacion cola atencion OK
(4, 'atencion llamado', null, null, '', '', null, '', '?no existe ningún llamado en espera'),
--chequear tabla error:devuelve:  OK
(5, 'nuevo llamado', 8, null, '', '', null, '', 'nueva fila id 2 en espera'),
--chequear cola atencion: OK
(6, 'nuevo llamado', 12, null, '', '', null, '', 'nueva fila id 3 en espera'),
--chequear cola atencion: OK
(7, 'nuevo llamado', 16, null, '', '', null, '', 'nueva fila id 4 en espera'),
--chequear cola atencion: OK
(8, 'baja llamado', null, 2, '', '', null, '', 'act fila 2 estado desistido'),
--chequear cola atencion: OK
(9, 'baja llamado', null, 2, '', '', null, '', '?el llamado no está en espera ni en línea'),
--chequear tabla error: OK
(10,'nuevo llamado', 20, null, '', '', null, '', 'nueva fila id 5 en espera'),
--chequear cola atencion: OK
(11, 'alta tramite', null, 1, 'consulta', '¿Es posible suspender temporalmente el servicio por 2 meses? (vacaciones)',null,'','nueva fila id 1'),
--chequear tramite: OK
(12, 'alta tramite', null, 1, 'reclamo', 'El monto de la última factura fue debitado dos veces en la tarjeta de crédito', null, '', 'nueva fila id 2'),
--chequear tramite: OK
(13, 'atencion llamado', null, null, '', '', null, '', 'act fila id 3 estado en linea'),
--chequear cola atencion: OK
(14, 'atencion llamado', null, null, '', '', null, '', 'act fila id 4 estado en linea'),
--chequear cola atencion: OK
(15, 'atencion llamado', null, null, '', '', null, '', '?no existe ningune operadore disponible'),
--chequear error: OK
(16, 'fin llamado', null, 1, '', '', null, '', 'act fila id 1 estado finalizado'),
--chequear cola atencion: OK
--tabla rendimiento operadore no rompe pero muestra calculos en 0 porque se ejecutan todos los sql al mismo tiempo
(17, 'atencion llamado', null, null, '', '', null, '', 'act fila id 5 estado en linea'),
--chequear cola atencion; OK
(18, 'baja llamado', null, 3, '', '', null, '', 'act fila id 3 estado desistido'),
--chequear cola atencion: OK
(19, 'cierre tramite', null, null, '', '', 2, 'rechazado', 'Los dos cobros corresponden a facturas de meses diferentes'),
--chequear tramite
(20, 'cierre tramite', null, null, '', '', 1, 'solucionado', 'Es posible suspender el servicio, avisando con 20 días de anticipación.'),
--chequear cola atencion
(21, 'fin llamado', null, 4, '', '', null, '', 'act fila id 4 estado finalizado'),
--chequear cola atencion: OK
(22, 'fin llamado', null, 5, '', '', null, '', 'act fila id 5 estado finalizado');
--chequear cola atencion: OK
