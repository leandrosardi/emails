alter table fl_data drop column if exists verify_reservation_id;
alter table fl_data add column if not exists verify_reservation_id varchar(500) null;

alter table eml_upload_leads_job drop column if exists ingest_reservation_id;
alter table eml_upload_leads_job add column if not exists ingest_reservation_id varchar(500) null;

alter table eml_upload_leads_row drop column if exists import_reservation_id;
alter table eml_upload_leads_row add column if not exists import_reservation_id varchar(500) null;

alter table eml_followup drop column if exists planning_reservation_id;
alter table eml_followup add column if not exists planning_reservation_id varchar(500) null;

alter table eml_delivery drop column if exists delivery_reservation_id;
alter table eml_delivery add column if not exists delivery_reservation_id varchar(500) null;

