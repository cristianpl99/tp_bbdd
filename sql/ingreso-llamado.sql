-- evitar dirty read, nonreap read y phantom tuples con el clienter y la cola de atencion que se seleccionan
set transaction isolation level serializable;

create or replace function ingreso_llamado(cliente_id int)
 returns int as $$
declare
    nuevo_id_cola int;
begin
    -- verificar si el cliente existe
    if not exists (
    select 1
    from cliente 
    where id_cliente = cliente_id
    ) then
        insert into error (
   --       id_error,
            operacion,
            id_cliente,
            id_cola_atencion,
            tipo_tramite,
            id_tramite,
            estado_cierre_tramite,
            f_error,
            motivo
        ) values (
   --       1,
            'nuevo llamado',
            cliente_id,
            null,
            null,
            null,
            null,
            current_timestamp,
            'id de cliente no valido'
        );
        raise notice 'id de cliente no valido';
        return -1;
    end if;
    
    -- insertar el llamado en la cola de atención y
    -- retornar el id generado
    insert into cola_atencion (
        id_cliente,
        f_inicio_llamada,
        estado
    ) values (
        cliente_id,
        current_timestamp,
        'en espera'
    ) returning id_cola_atencion into nuevo_id_cola;
        
    return nuevo_id_cola;
end;
$$ language plpgsql;
