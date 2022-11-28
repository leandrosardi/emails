alter table eml_upload_leads_job drop column if exists ingest_reservation_id;
alter table eml_upload_leads_row drop column if exists import_reservation_id;
alter table eml_upload_leads_job add column if not exists ingest_reservation_id varchar(500) null;
alter table eml_upload_leads_row add column if not exists import_reservation_id varchar(500) null;
