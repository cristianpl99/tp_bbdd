-- evitar dirty read, nonreap read y phantom tuples con el operadore y la cola de atencion que se seleccionan
set transaction isolation level serializable;

create or replace function finalizar_llamado(p_id_cola_atencion int) 
returns boolean as $$
declare
	_id_operadore int;
begin
    -- Validación de la existencia del id_cola_atencion y su estado
    if not exists (
        select 1
        from cola_atencion c
        where c.id_cola_atencion = p_id_cola_atencion -- Se compara correctamente con el parámetro
    ) then
        -- Registro de error si el id_cola_atencion no existe
        insert into error (
            id_error,
            operacion,
            id_cliente,
            id_cola_atencion,
            tipo_tramite,
            id_tramite,
            estado_cierre_tramite,
            f_error,
            motivo
        ) values (
            default,
            'finalizar llamado',
            null,
            p_id_cola_atencion, -- Uso correcto del parámetro
            null,
            null,
            'rechazado',
            current_timestamp,
            'id de cola de atención no válido'
        );
        raise notice 'id de cola de atención no válido';
        return false;
    end if;

    -- Validar si el estado es 'en linea'
    if not exists (
        select 1
        from cola_atencion c
        where c.id_cola_atencion = p_id_cola_atencion
        and c.estado = 'en linea'
    ) then
        -- Registro de error si el estado no es 'en linea'
        insert into error (
            id_error,
            operacion,
            id_cliente,
            id_cola_atencion,
            tipo_tramite,
            id_tramite,
            estado_cierre_tramite,
            f_error,
            motivo
        ) values (
            default,
            'finalizar llamado',
            null,
            p_id_cola_atencion, -- Uso correcto del parámetro
            null,
            null,
            'rechazado',
            current_timestamp,
            'el llamado no está en línea'
        );
        raise notice 'el llamado no está en línea';
        return false;
    end if;
    
    select id_operadore 
    into _id_operadore 
    from cola_atencion 
    where id_cola_atencion = p_id_cola_atencion;
    
    -- Actualización de la fecha de fin y cambio de estado a 'finalizado'
    update cola_atencion
    set f_fin_atencion = current_timestamp,
        estado = 'finalizado'
    where id_cola_atencion = p_id_cola_atencion; -- Uso correcto del parámetro

	update operadore 
	set disponible = true 
	where id_operadore = _id_operadore;
	
    return true;
end;
$$ language plpgsql;
