
-- Creación de tablas
drop table if exists datos_de_prueba;
drop table if exists rendimiento_operadore;
drop table if exists error;
drop table if exists envio_mail;
drop table if exists tramite;
drop table if exists cola_atencion;
drop table if exists cliente;
drop table if exists operadore;

create table cliente(
    id_cliente int,
    nombre text not null,
    apellido text not null,
    dni int,
    fecha_nacimiento date not null,
    telefono char(12),
    email text
);

create table operadore(
    id_operadore int,
    nombre text not null,
    apellido text not null,
    dni int,
    fecha_ingreso date not null,
    disponible boolean not null
);

create table cola_atencion(
    id_cola_atencion serial,
    id_cliente int not null,
    f_inicio_llamada timestamp,
    id_operadore int,
    f_inicio_atencion date,
    f_fin_atencion date,
    estado char(15) not null
);
create table tramite(
    id_tramite serial,
    id_cliente int not null,
    id_cola_atencion int not null,
    tipo_tramite char(10),
    f_inicio_gestion timestamp,
    descripcion text,
    f_fin_gestion date,
    respuesta text,
    estado char(15) not null
);

create table rendimiento_operadore(
    id_operadore int not null,
    fecha_atencion date not null,
    duracion_total_atencion interval,
    cantidad_total_atenciones int,
    duracion_promedio_total_atenciones interval,
    duracion_atenciones_finalizadas interval,
    cantidad_atenciones_finalizadas int,
	duracion_promedio_atenciones_finalizadas interval,
    duracion_atenciones_desistidas interval,
    cantidad_atenciones_desistidas int,
    duracion_promedio_atenciones_desistidas interval 
);
create table error(
    id_error serial,
    operacion char(20),
    id_cliente int,
    id_cola_atencion int,
    tipo_tramite char(10),
    id_tramite int,
    estado_cierre_tramite char(15),
    f_error timestamp,
    motivo varchar(80) not null
);
create table envio_mail(
    id_mail serial,
    f_generacion timestamp not null,
    email_cliente text not null,
    asunto text,
    cuerpo text,
    f_envio timestamp,
    estado char(10)
);
create table datos_de_prueba(
    id_orden int,
    operacion char(20),
    id_cliente int,
    id_cola_atencion int,
    tipo_tramite char(10),
    descripcion_tramite text,
    id_tramite int,
    estado_cierre_tramite char(15),
    respuesta_tramite text
);
