create trigger trigger_reporte_rendimiento
after update of estado on cola_atencion
for each row
when ((new.estado = 'desistido' or new.estado = 'finalizado') and new.id_operadore is not null)
execute function reporte_rendimiento();
