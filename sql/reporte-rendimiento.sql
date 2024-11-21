create or replace function reporte_rendimiento()
returns trigger as $$
declare
    fecha date;
    f_inicio timestamp;
    f_fin timestamp;
    estado_actual text;
    id_operadore_atencion int;
    duracion interval;
begin
    -- obtengo los datos de la cola de atención usando NEW.id_cola_atencion
    select 
        estado, 
        f_fin_atencion::date, 
        id_operadore, 
        f_inicio_atencion,  
        f_fin_atencion
    into 
        estado_actual, 
        fecha, 
        id_operadore_atencion, 
        f_inicio,  
        f_fin
    from public.cola_atencion  -- Especificar esquema si es necesario
    where id_cola_atencion = new.id_cola_atencion;  -- Accediendo a la fila actual actualizada
	--si el llamado no esta en cola, id_operadore es null
	if id_operadore_atencion is null then
	        raise notice 'No se encontró el operador para id_cola_atencion %', new.id_cola_atencion;
	    end if;
    -- cálculo de duración y actualización de rendimiento según el estado
    --	duracion := f_fin - f_inicio;
    -- a fines prácticos para ver diferencias en rendimiento_operadore agregamos
    -- una adicion de minutos randoma la duracion
	duracion := f_fin - f_inicio + (floor(random() * (10 - 2 + 1) + 2) * interval '1 minute');
    if estado_actual = 'desistido' then
        if exists (    
            select 1 
            from rendimiento_operadore
            where fecha_atencion = fecha
            and id_operadore = id_operadore_atencion
        ) then
            update rendimiento_operadore
            set
                duracion_total_atencion = duracion_total_atencion + duracion, 
                cantidad_total_atenciones = cantidad_total_atenciones + 1,
                duracion_promedio_total_atenciones = 
                (duracion_total_atencion + duracion) / (cantidad_total_atenciones + 1),
                duracion_atenciones_desistidas = duracion_atenciones_desistidas + duracion, 
                cantidad_atenciones_desistidas = cantidad_atenciones_desistidas + 1,
                duracion_promedio_atenciones_desistidas = 
                (duracion_atenciones_desistidas + duracion) / (cantidad_atenciones_desistidas + 1)
            where id_operadore = id_operadore_atencion and fecha_atencion = fecha;
        else
            insert into rendimiento_operadore (
                id_operadore,
                fecha_atencion,
                duracion_total_atencion,
                cantidad_total_atenciones,
                duracion_promedio_total_atenciones,
                duracion_atenciones_finalizadas,
                cantidad_atenciones_finalizadas,
                duracion_promedio_atenciones_finalizadas,
                duracion_atenciones_desistidas,
                cantidad_atenciones_desistidas,
                duracion_promedio_atenciones_desistidas
            )
            values (
                id_operadore_atencion,
                fecha,
                duracion,
                1,
                duracion,
                interval '0',
                0,
                interval '0',
                duracion,
                1,
                duracion
            );
        end if;

    elsif estado_actual = 'finalizado' then
        if exists (    
            select 1 
            from rendimiento_operadore
            where fecha_atencion = fecha
            and id_operadore = id_operadore_atencion
        ) then
            update rendimiento_operadore
            set
                duracion_total_atencion = duracion_total_atencion + duracion, 
                cantidad_total_atenciones = cantidad_total_atenciones + 1,
                duracion_promedio_total_atenciones = 
                (duracion_total_atencion + duracion) / (cantidad_total_atenciones + 1),
                duracion_atenciones_finalizadas = duracion_atenciones_finalizadas + duracion, 
                cantidad_atenciones_finalizadas = cantidad_atenciones_finalizadas + 1,
                duracion_promedio_atenciones_finalizadas = 
                (duracion_atenciones_finalizadas + duracion) / (cantidad_atenciones_finalizadas + 1)
            where id_operadore = id_operadore_atencion and fecha_atencion = fecha;
        else
            insert into rendimiento_operadore (
                id_operadore,
                fecha_atencion,
                duracion_total_atencion,
                cantidad_total_atenciones,
                duracion_promedio_total_atenciones,
                duracion_atenciones_finalizadas,
                cantidad_atenciones_finalizadas,
                duracion_promedio_atenciones_finalizadas,
                duracion_atenciones_desistidas,
                cantidad_atenciones_desistidas,
                duracion_promedio_atenciones_desistidas
            )
            values (
                id_operadore_atencion,
                fecha,
                duracion,
                1,
                duracion,
                duracion,
                1,
                duracion,
                interval '0',
                0,
                interval '0'
            );
        end if;
    end if;

    return new;
end;
$$ language plpgsql;
