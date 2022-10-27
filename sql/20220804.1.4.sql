-- adapt cs-leads to handle leads uploaded by the user
ALTER TABLE fl_lead ADD COLUMN IF NOT EXISTS id_user UUID NULL REFERENCES "user"("id"); -- if id_user is null that means the lead has not owner
ALTER TABLE fl_lead ADD COLUMN IF NOT EXISTS public BOOL NOT NULL DEFAULT true; -- if public, the it is shown in the leads marketplace

-- adapt cs-leads to handle export lists with hidden data, for just sending emails
ALTER TABLE fl_export_lead ADD COLUMN IF NOT EXISTS hide_data BOOL NOT NULL DEFAULT false;

-- adapt cs-leads for validating the emails uploaded by users
alter table fl_data add column if not exists verify_reservation_id uuid null; -- if not null, the email is pending of verification
alter table fl_data add column if not exists verify_reservation_times int null; -- how many times the email was reserved for verification
alter table fl_data add column if not exists verify_reservation_time timestamp null; -- when the verification was reserved
alter table fl_data add column if not exists verify_start_time timestamp null; -- when the verification started
alter table fl_data add column if not exists verify_end_time timestamp null; -- when the verification ended
alter table fl_data add column if not exists verify_success boolean null; -- if the verification was successful
alter table fl_data add column if not exists verify_error_description text null; -- if the verification was not successful, the error message

alter table fl_data add column if not exists custom_field_name varchar(500) null; -- if the verification was not successful, the error message

-- adapt cs-leads to allow user to upload his/her own leads
create table if not exists eml_upload_leads_job (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this account
    create_time timestamp not null, -- when registered this account
    -- the list to import the ledas
    id_export uuid not null references fl_export(id),
    -- configurations
    skip_existing_emails boolean not null default true, -- if true, skip the emails that already exists in the list
    separator_char varchar(1) not null default ',', -- the separator char
    enclosure_char varchar(1) not null default '"', -- the enclosure char
    -- the content of the file
    content text not null, 
    -- import status
    ingest_reservation_id uuid null, -- if not null, the import is in progress
    ingest_reservation_times int null, -- how many times the import was reserved
    ingest_reservation_time timestamp null, -- when the import was reserved
    ingest_start_time timestamp null, -- when the import started
    ingest_end_time timestamp null, -- when the import ended
    ingest_success boolean null, -- if the import was successful
    ingest_error_description text null, -- if the import was not successful, the error message
    -- stats
    stat_total_rows bigint null,
    stat_imported_rows bigint null,
    stat_error_rows bigint null
);

create table if not exists eml_upload_leads_mapping (
    id uuid not null primary key,
    id_upload_leads_job uuid not null references eml_upload_leads_job(id), -- who registered this account
    create_time timestamp not null, -- when registered this account
    "column" int not null, -- the column number
    data_type int not null, -- the data type from Leads::FlData
    custom_field_name varchar(500) not null, -- the name of the column for custom fields
    unique(id_upload_leads_job, "column")
);

create table if not exists eml_upload_leads_row (
    id uuid not null primary key,
    id_upload_leads_job uuid not null references eml_upload_leads_job(id), -- who registered this account
    line_number bigint not null, -- the line number
    "line" varchar(8000) not null, -- the line content
    -- import status
    import_reservation_id uuid null, -- if not null, the import is in progress
    import_reservation_times int null, -- how many times the import was reserved
    import_reservation_time timestamp null, -- when the import was reserved
    import_start_time timestamp null, -- when the import started
    import_end_time timestamp null, -- when the import ended
    import_success boolean null, -- if the import was successful
    import_error_description text null -- if the import was not successful, the error message
);

create table if not exists eml_upload_leads_row_aux (
    id uuid null,
    id_upload_leads_job uuid null, -- who registered this account
    line_number bigint null, -- the line number
    "line" varchar(8000) not null -- the line content
);

ALTER TABLE fl_lead ADD COLUMN IF NOT EXISTS id_upload_leads_job uuid NULL references eml_upload_leads_job(id); -- if not null, the lead was imported by a user

ALTER TABLE fl_lead ADD COLUMN IF NOT EXISTS id_upload_leads_row uuid NULL references eml_upload_leads_row(id); -- if not null, the lead was imported by a user

-- https://github.com/leandrosardi/emails/issues/31
-- register SMTP servers
create table if not exists eml_mta (
    id uuid not null primary key,
    id_user uuid not null references "user"(id),
    create_time timestamp not null,
    -- connection parameters
    smtp_address varchar(500) not null,
    smtp_port int not null,
    imap_port int not null,
    imap_address varchar(500) not null,
    -- connection parameters
    "authentication" varchar(500) not null,
    enable_starttls_auto boolean not null,
    openssl_verify_mode varchar(500) not null,
    -- parameters to process IMAP
    inbox_label varchar(500) not null default 'Inbox',
    spam_label varchar(500) not null default 'Spam',
    search_all_wildcard varchar(500) not null default ''
);

--
create table IF NOT EXISTS eml_address (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this account
    id_mta uuid not null references eml_mta(id), -- the SMTP server
    create_time timestamp not null, -- when registered this account
    "type" int not null, -- 0 - gmail, 1 - yahoo, 2 - hotmail
    first_name varchar(500) not null, -- first name
    last_name varchar(500) not null, -- last name
    "address" varchar(500) not null, -- example: ceo123@gmail.com
    "password" varchar(500) not null, -- the password of the email account
    -- true if I am willing to rent this account to other users of the platform
    shared boolean not null, 
    -- if address is allowed or not for sending emails
    "enabled" boolean not null, -- if the account is enabled
    -- to process the inboxes, we need to know the last id processed
    imap_inbox_last_id varchar(500) null,
    imap_spam_last_id varchar(500) null,
    -- stealth
    max_deliveries_per_day int not null, -- how many emails per day can deliver
    delivery_interval_min_minutes int not null, -- how many minutes to wait between emails
    delivery_interval_max_minutes int not null, -- how many minutes to wait between emails
    unique("address")
);

create table IF NOT EXISTS eml_tag (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this account
    create_time timestamp not null, -- when registered this account
    "name" varchar(500) not null -- the name of the tag    
);

create table IF NOT EXISTS eml_address_tag (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this account
    create_time timestamp not null, -- when registered this account
    id_address uuid not null references eml_address(id), -- the email address
    id_tag uuid not null references eml_tag(id), -- the tag
    unique(id_address, id_tag)
);

alter table eml_address add column if not exists stat_tags varchar(8000) null;

create table IF NOT EXISTS eml_campaign (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this
    create_time timestamp not null, -- when registered this
    -- header settings
    "name" varchar(255) not null, -- name of the campaign
    id_export uuid not null references fl_export(id), -- id of the export that will be used to send the emails
    -- statistics of the campaign
    stat_sents bigint not null, -- how many emails were sent
    stat_opens bigint not null, -- how many emails were opened
    stat_clicks bigint not null, -- how many emails were clicked
    stat_replies bigint not null, -- how many emails were replied
    stat_bounces bigint not null, -- how many emails were bounced
    stat_unsubscribes bigint not null, -- how many emails were unsubscribed
    stat_complaints bigint not null -- how many emails were complained
);

alter table eml_campaign add column if not exists stat_positive_replies bigint not null;

-- list of emails that will be sent by a campaign, based on rules
create table IF NOT EXISTS eml_followup (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this
    create_time timestamp not null, -- when registered this
    -- header settings
    "name" varchar(255) not null, -- name of the campaign
    id_campaign uuid not null references eml_campaign(id), -- id of the export that will be used to send the emails
    -- content of the campaign  
    "subject" varchar(255) not null, -- subject of the campaign
    body text not null, -- body of the campaign
    --from_name varchar(255) not null, -- from of the campaign
    --from_email varchar(255) not null, -- from of the campaign
    --reply_to varchar(255) not null, -- reply to of the campaign
    "type" int not null, -- 0 - plain text, 1 - html
    "status" int not null, -- 0 - draft, 1 - sent, 2 - error
    -- automation rules
    sequence_number int not null, -- the order of the followup
    delay_days int not null, -- how many days to wait before sending the email, just after the rule has been raised
    --trigger_event int not null, -- 0 - email sent and don't reply, 1 - open and don't reply, 2 - click and don't reply, 3 - reply
    -- statistics of the spintax variation
    stat_subject_spintax_variations bigint not null, -- how many spintax variations can I get from the subject
    stat_body_spintax_variations bigint not null, -- how many spintax variations can I get from the body
    -- statistics of the campaign
    stat_sents bigint not null, -- how many emails were sent
    stat_opens bigint not null, -- how many emails were opened
    stat_clicks bigint not null, -- how many emails were clicked
    stat_replies bigint not null, -- how many emails were replied
    stat_bounces bigint not null, -- how many emails were bounced
    stat_unsubscribes bigint not null, -- how many emails were unsubscribed
    stat_complaints bigint not null, -- how many emails were complained
    -- pampa: add planning fields to the campaign.
    planning_reservation_id uuid null,
    planning_reservation_time timestamp null,
    planning_reservation_times int null,
    planning_start_time timestamp null,
    planning_end_time timestamp null,
    planning_success boolean null,
    planning_error_description varchar(8000) null 
);

alter table eml_followup add column if not exists stat_positive_replies bigint not null;

alter table eml_followup add column if not exists delete_time timestamp null;

-- addresses used by a campaign to deliver emails
create table IF NOT EXISTS eml_outreach (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this
    create_time timestamp not null, -- when registered this
    -- header settings
    id_campaign uuid not null references eml_campaign(id), -- id of the export that will be used to send the emails
    id_tag uuid not null references eml_tag(id), -- all addresses with this tag will be used for this campaign
    unique(id_campaign, id_tag)
);

-- days and hours when the campaign will be sent
create table IF NOT EXISTS eml_schedule (
    id uuid not null primary key,
    id_user uuid not null references "user"(id), -- who registered this
    create_time timestamp not null, -- when registered this
    -- header settings
    "name" varchar(255) not null, -- name of the campaign
    id_campaign uuid not null references eml_campaign(id), -- id of the export that will be used to send the emails
    -- schedule of the campaign
    schedule_start_time timestamp not null, -- when the campaign will be sent
    schedule_hour_0 boolean not null, -- true if the campaign is scheduled at 0 hour
    schedule_hour_1 boolean not null, -- true if the campaign is scheduled at 1 hour
    schedule_hour_2 boolean not null, -- true if the campaign is scheduled at 2 hour
    schedule_hour_3 boolean not null, -- true if the campaign is scheduled at 3 hour
    schedule_hour_4 boolean not null, -- true if the campaign is scheduled at 4 hour
    schedule_hour_5 boolean not null, -- true if the campaign is scheduled at 5 hour
    schedule_hour_6 boolean not null, -- true if the campaign is scheduled at 6 hour
    schedule_hour_7 boolean not null, -- true if the campaign is scheduled at 7 hour
    schedule_hour_8 boolean not null, -- true if the campaign is scheduled at 8 hour
    schedule_hour_9 boolean not null, -- true if the campaign is scheduled at 9 hour
    schedule_hour_10 boolean not null, -- true if the campaign is scheduled at 10 hour
    schedule_hour_11 boolean not null, -- true if the campaign is scheduled at 11 hour
    schedule_hour_12 boolean not null, -- true if the campaign is scheduled at 12 hour
    schedule_hour_13 boolean not null, -- true if the campaign is scheduled at 13 hour
    schedule_hour_14 boolean not null, -- true if the campaign is scheduled at 14 hour
    schedule_hour_15 boolean not null, -- true if the campaign is scheduled at 15 hour
    schedule_hour_16 boolean not null, -- true if the campaign is scheduled at 16 hour
    schedule_hour_17 boolean not null, -- true if the campaign is scheduled at 17 hour
    schedule_hour_18 boolean not null, -- true if the campaign is scheduled at 18 hour
    schedule_hour_19 boolean not null, -- true if the campaign is scheduled at 19 hour
    schedule_hour_20 boolean not null, -- true if the campaign is scheduled at 20 hour
    schedule_hour_21 boolean not null, -- true if the campaign is scheduled at 21 hour
    schedule_hour_22 boolean not null, -- true if the campaign is scheduled at 22 hour
    schedule_hour_23 boolean not null, -- true if the campaign is scheduled at 23 hour
    schedule_day_0 boolean not null, -- true if the campaign is scheduled at 0 day
    schedule_day_1 boolean not null, -- true if the campaign is scheduled at 1 day
    schedule_day_2 boolean not null, -- true if the campaign is scheduled at 2 day
    schedule_day_3 boolean not null, -- true if the campaign is scheduled at 3 day
    schedule_day_4 boolean not null, -- true if the campaign is scheduled at 4 day
    schedule_day_5 boolean not null, -- true if the campaign is scheduled at 5 day
    schedule_day_6 boolean not null -- true if the campaign is scheduled at 6 day
);

alter table eml_schedule add column if not exists delete_time timestamp null;

-- each URL in the body is replaced by this link
-- filter for tracking clicks receive 2 parameters: id of the link and id of the lead.
create table IF NOT EXISTS eml_link (
    id uuid not null primary key,
    id_followup uuid not null references eml_followup(id), 
    create_time TIMESTAMP NOT NULL,
    link_number int NOT NULL, -- the number of the link in the body
    "url" VARCHAR(8000) NOT NULL, -- the url to redirect.
    CONSTRAINT uk_link UNIQUE (id_followup, "link_number")
);

create table IF NOT EXISTS eml_delivery (
    id uuid not null primary key,
    id_followup uuid not null references eml_followup(id),
    id_address uuid not null references eml_address(id), 
    id_lead uuid not null references fl_lead(id),
    create_time TIMESTAMP NOT NULL,
    -- pampa fields
    delivery_reservation_id uuid null, -- id of the reservation in the delivery service
    delivery_reservation_time timestamp null,
    delivery_reservation_times int null,
    delivery_start_time TIMESTAMP NULL,
    delivery_end_time TIMESTAMP NULL,
    delivery_success boolean null,
    delivery_error_description varchar(8000) null,
    -- one lead may have more than 1 email address, so I have to specify the email address to deliver the email to.
    email varchar(500) not null,
    "subject" varchar(8000) not null,
    body text not null,
    -- message_id of delivered email.
    message_id varchar(500) null,
    -- create a id_conversation for a delivery when it receives the first response.
    id_conversation uuid null,
    -- record responses from leads in the delivery table
    is_response boolean not null default false,
    -- incoming messages (replies) include the name of the sender
    "name" varchar(500) null,
    -- track if an email is single email - that means: an email sent to a lead manually by a user.
    is_single boolean not null default false,
    -- deliveries from manually written emails (single) need to register the id_user
    id_user uuid references "user"(id) null,
    --
    unique(id_followup, id_address, id_lead)
);

create table IF NOT EXISTS eml_open (
    id uuid not null primary key,
    id_delivery uuid not null references eml_delivery(id), 
    create_time TIMESTAMP NOT NULL
);

create table IF NOT EXISTS eml_click (
    id uuid not null primary key,
    id_delivery uuid not null references eml_delivery(id), 
    id_link uuid not null references eml_link(id),
    create_time TIMESTAMP NOT NULL
);

create table IF NOT EXISTS eml_unsubscribe (
    id uuid not null primary key,
    id_delivery uuid not null references eml_delivery(id), 
    create_time TIMESTAMP NOT NULL
);

-- timeline snapshot of deliveries.
create table IF NOT EXISTS eml_timeline (
    id uuid not null primary key,
    id_campaign uuid not null references eml_campaign(id), 
    id_followup uuid not null references eml_followup(id), 
    id_address uuid not null references eml_address(id),
    create_time TIMESTAMP NOT NULL,
    -- 
    year int not null,
    month int not null,
    day int not null,
    hour int not null,
    minute int not null,
    -- stats
    stat_sents bigint not null,
    stat_opens bigint not null,
    stat_clicks bigint not null,
    stat_replies bigint not null, -- how many emails were replied
    stat_bounces bigint not null,
    stat_unsubscribes bigint not null,
    stat_complaints bigint not null,
    UNIQUE (id_campaign, id_followup, id_address, year, month, day, hour, minute)
);

-- deliveries event tracking.
-- use this snapshot to show the activity of each campaign.
create table IF NOT EXISTS eml_log (
    id uuid not null primary key,
    create_time TIMESTAMP NOT NULL,
    "type" varchar(50) not null, -- 'planned', 'failed', 'sent', 'opened', 'clicked', 'unsubscribed', 'replied'
    "color" varchar(50) not null, -- 'gray', 'red', 'green', 'opened', 'pink', 'orange'
    id_delivery uuid not null references eml_delivery(id), 
    planning_time timestamp not null, -- useful for for pending deliveries
    "url" varchar(8000) null -- this is the URL for when the event is a click.
);

-- add support to delete objects
alter table eml_address add column if not exists delete_time timestamp null;
alter table eml_campaign add column if not exists delete_time timestamp null;

-- hourly limit for emails delivery has been deprecated.
alter table eml_address drop column if exists max_emails_per_hour;

-- enable or disable accounts
alter table eml_address add column if not exists "enabled" boolean not null default true;

-- correction: CSV content is stored in the storage folder of the account.
alter table eml_upload_leads_job drop column if exists content;

-- this is necessary to upload CSV files to the cockroach cloud server.
CREATE DATABASE IF NOT EXISTS defaultdb;
SET CLUSTER SETTING sql.telemetry.query_sampling.enabled = false;

-- this is necessary to import records into the table, and just then iterate them and assign the line number.
alter table eml_upload_leads_row alter column line_number DROP NOT NULL;
