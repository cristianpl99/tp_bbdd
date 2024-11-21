create trigger trigger_nuevo_tramite
after insert on tramite
for each row
execute function email_nuevo_tramite();
