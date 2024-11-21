-- evitar dirty read, nonreap read y phantom tuples con la cola de atencion que se selecciona
set transaction isolation level serializable;

create or replace function desistimiento_de_llamado(id_cola int) 
returns boolean as $$
declare
    estado_actual char(15);
    llamada_existente boolean;
begin
    -- Verificar si el id de la cola de atencion existe
    select exists(
        select 1
        from cola_atencion c
        where c.id_cola_atencion = id_cola
    ) into llamada_existente;

    if not llamada_existente then
        insert into error (
            operacion,
            id_cliente,
            id_cola_atencion,
            f_error,
            motivo
        )
        values (
            'baja llamado',
            null,
            id_cola,
            now(),
            'id de la cola de atencion no valido'
        );
        raise notice 'id de la cola de atencion no valido';
        return false;
    end if;

    -- Verificar el estado actual de la llamada
    select estado
    into estado_actual
    from cola_atencion 
    where id_cola_atencion = id_cola;

    -- Si el estado actual no es 'en linea', registrar un error
    if estado_actual not in ('en linea','en espera') then
        insert into error (
            operacion,
            id_cliente,
            id_cola_atencion,
            f_error,
            motivo
        )
        values (
            'baja llamado',
            null,
            id_cola,
            now(),
            'el llamado no esta ni en linea ni en espera'
        );
        raise notice 'el llamado no esta en linea ni en espera';
        return false;
    else
        update cola_atencion
        set estado = 'desistido',
            f_fin_atencion = now()
        where id_cola_atencion = id_cola;
    end if;

    return true;

end;
$$ language plpgsql;
