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


-- deliveries from manually written emails need to register the id_user
alter table eml_delivery add column if not exists id_user uuid references "user"(id) null;

-- deliveries from manually written emails need to register the id_address
alter table eml_delivery add column if not exists id_address uuid references eml_address(id) null;

-- incoming messages (replies) include the name of the sender
alter table eml_delivery add column if not exists "name" varchar(500) null;

-- to process the inboxes, we need to know the last id processed
alter table eml_address add column if not exists imap_inbox_last_id varchar(500) null;
alter table eml_address add column if not exists imap_spam_last_id varchar(500) null;
