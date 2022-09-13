/*
select *
from eml_address
order by create_time desc
*/

-- https://github.com/leandrosardi/emails/issues/14

-- message_id of delivered email.
alter table eml_delivery add column if not exists message_id varchar(500) null;

-- create a id_conversation for a delivery when it receives the first response.
alter table eml_delivery add column if not exists id_conversation uuid null;

-- record responses from leads in the delivery table
alter table eml_delivery add column if not exists is_response boolean not null default false;

-- deliveries from manually written emails don't require id_job
alter table eml_delivery alter column id_job set not null;

-- deliveries from manually written emails don't require subject
alter table eml_delivery alter column "subject" set not null;

