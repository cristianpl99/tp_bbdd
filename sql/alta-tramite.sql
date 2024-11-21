create or replace function alta_tramite (
    p_id_cola_atencion int, 
    p_tipo_tramite text,  
    p_descripcion text
) returns int as $$
declare
    _id_tramite int;
    cliente_id int;
    _id_cola_atencion int;
begin
    --verificar que el tipo de tramite sea 'consulta' o 'reclamo'
    --por algun motivo no me tomaba el parametro correctamente
    p_tipo_tramite := lower(trim(p_tipo_tramite));
    if p_tipo_tramite not in ('consulta', 'reclamo') then
        insert into error (
            operacion,
            id_cliente,
            id_cola_atencion,
            tipo_tramite,
            id_tramite,
            estado_cierre_tramite,
            f_error,
            motivo
        ) values (
            'alta tramite',
            cliente_id,
            null,
            null,
            null,
            'rechazado',
            current_timestamp,
            'tipo de tramite no valido'
        );
        raise notice 'tipo de tramite no valido';
        return -1;
    end if;

    -- verifica si existe el id de cola de atención
    select c.id_cola_atencion into _id_cola_atencion
    from cola_atencion c
    where c.id_cola_atencion = p_id_cola_atencion;

    if _id_cola_atencion is null then
        insert into error (
            operacion,
            id_cliente,
            id_cola_atencion,
            tipo_tramite,
            id_tramite,
            estado_cierre_tramite,
            f_error, 
            motivo
        ) values (
            'alta tramite',
            cliente_id,
            p_id_cola_atencion,
            p_tipo_tramite,
            null, -- Usamos `null` para `id_tramite` aquí también
            'rechazado',
            current_timestamp,
            'id cola de atencion no valido'
        );
        raise notice 'id de cola de atencion no valido';
        return -1;
    end if;

    -- inserta el tramite y retornar el id generado
    select id_cliente into cliente_id
    from cola_atencion
    where id_cola_atencion = p_id_cola_atencion;
    
    insert into tramite (
        id_cliente,
        id_cola_atencion,
        tipo_tramite,
        f_inicio_gestion,
        descripcion,
        f_fin_gestion,
        respuesta,
        estado
    ) values (
        cliente_id,
        p_id_cola_atencion,
        p_tipo_tramite,
        current_timestamp,
        p_descripcion,
        null,
        null,
        'iniciado'
    ) returning id_tramite into _id_tramite; -- Usamos la variable renombrada aquí

    return _id_tramite; -- Regresamos el id generado
end;
$$ language plpgsql;




