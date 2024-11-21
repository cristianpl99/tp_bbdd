-- evitar dirty read, nonreap read y phantom tuples con el cliente  que se seleccionan
set transaction isolation level serializable;

create or replace function email_cierre_tramite() 
returns trigger as $$ 
begin -- Insertar un nuevo email en la tabla envio_email 
	insert into envio_mail ( 
		f_generacion, 
		email_cliente, 
		asunto, 
		cuerpo, 
		estado 
		) values ( 
		current_timestamp, 
		(select email from cliente where id_cliente = new.id_cliente),  
		'Skynet - cierre de trámite: ' || new.id_tramite, 
		'Estimado cliente,' || chr(10) || 
		'El trámite con los siguientes datos ha sido cerrado:' || chr(10) || 
		'Tipo de trámite: ' || new.tipo_tramite || chr(10) || 
		'Fecha y hora de inicio: ' || new.f_inicio_gestion || chr(10) || 
		'Fecha y hora de fin: ' || current_timestamp || chr(10) || 
		'Descripción: ' || new.descripcion || chr(10) || 
		'Gracias por utilizar Skynet.', 
		'pendiente' 
		); return null; 
	end; 
	$$ language plpgsql;
