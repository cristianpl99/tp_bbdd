-- evitar dirty read, nonreap read y phantom tuples con el operadore y la cola de atencion que se seleccionan
set transaction isolation level serializable;

create or replace function atender_llamado_en_espera() 
returns boolean as $$
declare
    _id_operadore int; -- Renombrado para evitar conflictos
    _id_cola_atencion int; -- Renombrado para evitar conflictos
    ahora timestamp := now(); -- Variable para obtener la fecha y hora exacta
begin
    -- Verificar si existe algún llamado en espera
    select id_cola_atencion
    into _id_cola_atencion
    from cola_atencion
    where estado = 'en espera'
    order by f_inicio_llamada
    limit 1;

    -- Verificar si existe el id de cola de atención
    if _id_cola_atencion is null then
        -- Registrar el error
        insert into error (
            operacion, 
            id_cliente, 
            id_cola_atencion, 
            f_error, 
            motivo
        ) values (
            'atencion llamado', 
            null, 
            null, 
            ahora, 
            'no existe ningun llamado en espera'
        );

        raise notice 'no existe ningun llamado en espera';
        return false;
    end if;

    -- Verificar si hay algún operador disponible
    select id_operadore
    into _id_operadore
    from operadore
    where disponible = true
    limit 1;

    -- Analizar qué sucede si no hay ningún operador disponible
    if _id_operadore is null then
        -- Registrar un error en la tabla error
        insert into error (
            operacion, 
            id_cliente, 
            id_cola_atencion, 
            f_error, 
            motivo
        ) values (
            'atencion llamado', 
            null, 
            _id_cola_atencion, 
            ahora, 
            'no existe ningún operador disponible'
        );

        raise notice 'no existe ningún operador disponible';
        return false;
    end if;

    -- Asignar el operador al llamado
    update cola_atencion
    set 
        id_operadore = _id_operadore,
        f_inicio_atencion = ahora, -- Fecha de inicio de atención
        estado = 'en linea'
    where cola_atencion.id_cola_atencion = _id_cola_atencion;

    -- Actualizar el estado del operador a no disponible
    update operadore
    set disponible = false
    where id_operadore = _id_operadore;
    return true;
end;
$$ language plpgsql;
