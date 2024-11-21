-- evitar dirty read, nonreap read y phantom tuples con el cliente  que se seleccionan
set transaction isolation level serializable;

create or replace function email_nuevo_tramite() 
returns trigger as $$
begin
    -- insertar un nuevo email en la tabla envio_email
    insert into envio_mail (
        f_generacion, 
        email_cliente, 
        asunto, 
        cuerpo, 
        estado
    ) values (
    	-- || chr(10) || para concatenar y hacer salto de carro
        current_timestamp,
        (select email from cliente where id_cliente = new.id_cliente),
        'Skynet - nuevo trámite: ' || new.id_tramite,
        'Estimado cliente,' || chr(10) || 
        'Se ha generado un nuevo trámite con los siguientes datos:' || chr(10) || 
        'Tipo de trámite: ' || new.tipo_tramite || chr(10) || 
        'Fecha y hora de inicio: ' || current_timestamp || chr(10) || 
        'Descripción: ' || new.descripcion || chr(10) || 
        'Gracias por utilizar Skynet.',
        'pendiente'
    );
    
    return null;
end;
$$ language plpgsql;
