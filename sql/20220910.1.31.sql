/*
select *
from eml_address
order by create_time desc
*/

-- https://github.com/leandrosardi/emails/issues/31
-- register SMTP servers
create table if not exists eml_mta (
    id uuid not null primary key,
    smtp_address varchar(500) not null,
    smtp_port int not null,
    "authentication" varchar(500) not null,
    enable_starttls_auto boolean not null,
    openssl_verify_mode varchar(500) not null
);
alter table eml_mta add column id_user uuid not null references "user"(id);
alter table eml_mta add column create_time timestamp not null;
alter table eml_mta add column imap_port int not null;
alter table eml_mta add column imap_address varchar(500) not null;

-- https://github.com/leandrosardi/emails/issues/31
-- Add SMTP connection parameters to each account record.
alter table eml_address add column column id_mta uuid null references eml_mta(id);
alter table eml_address add column "password" varchar(500) null;

-- https://github.com/leandrosardi/emails/issues/31
-- Mark as deleted all existing accounts working with oAuth.
update eml_address set delete_time=current_timestamp where delete_time is null and id_mta is null;
update eml_address set "enabled"=false where "enabled"=true and id_mta is null;

