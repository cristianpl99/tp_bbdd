create trigger trigger_cierre_tramite 
after update on tramite 
for each row when (new.estado = 'solucionado' or new.estado = 'rechazado') 
execute function email_cierre_tramite();
