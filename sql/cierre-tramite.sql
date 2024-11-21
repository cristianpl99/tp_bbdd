-- evitar dirty read, nonreap read y phantom tuples con el tramite que se selecciona
set transaction isolation level serializable;

create or replace function cierre_tramite(_id_tramite int, _estado char(15), _respuesta text) 
returns boolean as $$
declare 
	_existe_tramite boolean;
	_estado_tramite char(15);
	_tipo_tramite char(10);
	_descripcion_tramite text;
	
begin
	select exists(
	    select 1
	    from tramite t
	    where t.id_tramite = _id_tramite
	) into _existe_tramite;
	
	-- validar que exista el tramite
	if not _existe_tramite then
		insert into error(
			operacion,
            tipo_tramite,
            descripcion_tramite,
            id_tramite,
            estado_cierre_tramite,
            respuesta_tramite,
            f_error,
            motivo
        )
        values (
            'cierre tramite',
            null,
            null,
            _id_tramite,
            _estado,
            _respuesta,
            now(),
            'id de trámite no válido'
        );
        raise notice 'id de trámite no válido';
        return false;
    end if;


    select estado, tipo_tramite, descripcion 
    into _estado_tramite, _tipo_tramite, _descripcion_tramite
    from tramite t
    where t.id_tramite = _id_tramite;

    
	-- validar el estado de cierre del tramite pasado por parametro
	if _estado not in ('solucionado', 'rechazado') then
		insert into error(
			operacion,
            tipo_tramite,
            descripcion_tramite,
            id_tramite,
            estado_cierre_tramite,
            respuesta_tramite,
            f_error,
            motivo
        )
        values (
            'cierre tramite',
            _tipo_tramite,
            _descripcion_tramite,
            _id_tramite,
            _estado,
            _respuesta,
            now(),
            'estado de cierre no valido'
        );
        raise notice 'estado de cierre no valido';
        return false;
    end if;


    -- validar el estado del tramite
    if _estado_tramite != 'iniciado' then
		insert into error(
			operacion,
           	tipo_tramite,
           	descripcion_tramite,
           	id_tramite,
           	estado_cierre_tramite,
           	respuesta_tramite,
           	f_error,
           	motivo
       	)
       	values (
	      	'cierre tramite',
          	_tipo_tramite,
          	_descripcion_tramite,
          	_id_tramite,
          	_estado,
          	_respuesta,
          	now(),
          	'el trámite se encuentra cerrado'
       	);
       	raise notice 'el trámite se encuentra cerrado';
       	return false;
    end if;

    -- si pasa todas las validaciones actualizamos el registro
	update tramite
    set 
    	estado = _estado,
    	respuesta = _respuesta,
    	f_fin_gestion = now()::date
   	where id_tramite = _id_tramite;

   	return true;

end;
$$ language plpgsql;
