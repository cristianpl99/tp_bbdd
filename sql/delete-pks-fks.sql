--alter table cola_atencion drop constraint cola_atencion_id_cliente_fk;
alter table cola_atencion drop constraint cola_atencion_cliente_fk;

alter table tramite drop constraint tramite_cliente_fk;
--alter table tramite drop constraint cola_atencion_id_cola_atencion_fk;
alter table tramite drop constraint tramite_cola_atencion_fk;

--alter table rendimiento_operadore drop constraint operadore_fk;
alter table rendimiento_operadore drop constraint rendimiento_operadore_operadore_fk;

--alter table error drop constraint cliente_id_cliente_fk;

--alter table error drop constraint cola_atencion_id_cola_atencion_fk;
alter table error drop constraint error_cola_atencion_fk;

--alter table error drop constraint tramite_id_tramite_fk;
alter table error drop constraint error_tramite_fk;

--alter table datos_de_prueba drop constraint cliente_id_cliente_fk;
--alter table datos_de_prueba drop constraint cola_atencion_id_cola_atencion_fk;
--alter table datos_de_prueba drop constraint tramite_id_tramite_fk;


alter table cliente drop constraint cliente_pk;

alter table operadore drop constraint operadore_pk;

alter table cola_atencion drop constraint cola_atencion_pk;

alter table tramite drop constraint tramite_pk;

alter table rendimiento_operadore drop constraint rendimiento_operadore_pk;


alter table error drop constraint error_pk;

alter table envio_mail drop constraint envio_mail_pk;

alter table datos_de_prueba drop constraint datos_de_prueba_pk;
